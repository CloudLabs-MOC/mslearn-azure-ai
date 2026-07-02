using namespace System.Net

# Note: $sub (subscription id) and $DID (deployment id) are injected by the platform.
$rg = "rg-semanticsearch-$DID"
$count = 0
$found = $false

do {
    $count = $count + 1
    try {
        Set-AzContext -Subscription $sub -ErrorAction Stop

        $cosmosAccounts = Get-AzCosmosDBAccount -ResourceGroupName $rg -ErrorAction SilentlyContinue

        if ($null -ne $cosmosAccounts -and $cosmosAccounts.Count -gt 0) {
            foreach ($account in $cosmosAccounts) {
                $capabilities = @()
                if ($null -ne $account.Capabilities) {
                    $capabilities = $account.Capabilities | ForEach-Object {
                        if ($_.PSObject.Properties['Name']) { $_.Name } else { $_ }
                    }
                }

                $vectorEnabled = $capabilities -contains 'EnableNoSQLVectorSearch'
                if (-not $vectorEnabled) {
                    continue
                }

                $databases = Get-AzCosmosDBSqlDatabase -ResourceGroupName $rg -AccountName $account.Name -ErrorAction SilentlyContinue
                if ($null -eq $databases -or $databases.Count -lt 1) {
                    continue
                }

                foreach ($database in $databases) {
                    $containers = Get-AzCosmosDBSqlContainer -ResourceGroupName $rg -AccountName $account.Name -DatabaseName $database.Name -ErrorAction SilentlyContinue
                    if ($null -eq $containers -or $containers.Count -lt 1) {
                        continue
                    }

                    foreach ($container in $containers) {
                        $containerResource = Get-AzResource -ResourceGroupName $rg -ResourceType 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers' -Name "$($account.Name)/$($database.Name)/$($container.Name)" -ApiVersion '2024-05-15' -ErrorAction SilentlyContinue
                        if ($null -eq $containerResource) {
                            continue
                        }

                        $props = $containerResource.Properties.Resource
                        $hasVectorEmbeddings = $false
                        $hasVectorIndexes = $false

                        if ($null -ne $props -and $null -ne $props.vectorEmbeddingPolicy -and $null -ne $props.vectorEmbeddingPolicy.vectorEmbeddings) {
                            if ($props.vectorEmbeddingPolicy.vectorEmbeddings.Count -gt 0) {
                                $hasVectorEmbeddings = $true
                            }
                        }

                        if ($null -ne $props -and $null -ne $props.indexingPolicy -and $null -ne $props.indexingPolicy.vectorIndexes) {
                            if ($props.indexingPolicy.vectorIndexes.Count -gt 0) {
                                $hasVectorIndexes = $true
                            }
                        }

                        if ($hasVectorEmbeddings -and $hasVectorIndexes) {
                            $found = $true
                            $message = @{
                                Status  = "Succeeded"
                                Message = "Final semantic search state detected in RG '$rg': Cosmos DB account '$($account.Name)' has capability 'EnableNoSQLVectorSearch', SQL database '$($database.Name)', and container '$($container.Name)' with vector embedding and vector indexing policies configured."
                            } | ConvertTo-Json
                            break
                        }
                    }

                    if ($found) {
                        break
                    }
                }

                if ($found) {
                    break
                }
            }
        }

        if (-not $found) {
            $message = @{
                Status  = "Failed"
                Message = "Final semantic search completion state not yet detected in RG '$rg'. Expected at least one Azure Cosmos DB for NoSQL account with capability 'EnableNoSQLVectorSearch', a SQL database, and a new container configured with both vectorEmbeddingPolicy and indexingPolicy.vectorIndexes."
            } | ConvertTo-Json
        }
        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body       = $message
        })
    }
    catch {
        $message = @{
            Status  = "Failed"
            Message = "Error during check. Attempt $count of 3. Error: $($_.Exception.Message)"
        } | ConvertTo-Json
        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body       = $message
        })
        Start-Sleep -Seconds 10
    }
} while ($count -lt 3 -and -not $found)

# Post-loop: if every attempt failed, emit a final failure JSON so CloudLabs
# always sees a structured result.
if (-not $found) {
    $message = @{
        Status  = "Failed"
        Message = "Final semantic search completion state not found in RG '$rg' after 3 attempts."
    } | ConvertTo-Json
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $message
    })
}
