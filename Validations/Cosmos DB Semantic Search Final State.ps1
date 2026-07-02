using namespace System.Net

# Note: $sub (subscription id) and $DID (deployment id) are injected by the platform.
$rg = "rg-semanticsearch-$DID"
$count = 0
$found = $false

function Get-PropertyValue {
    param(
        [object]$Object,
        [string[]]$Names
    )

    foreach ($name in $Names) {
        if ($null -ne $Object -and $null -ne $Object.PSObject.Properties[$name]) {
            return $Object.$name
        }
    }

    return $null
}

do {
    $count = $count + 1
    try {
        Set-AzContext -Subscription $sub -ErrorAction Stop

        $cosmosAccounts = Get-AzResource -ResourceGroupName $rg -ResourceType "Microsoft.DocumentDB/databaseAccounts" -ErrorAction SilentlyContinue

        if ($cosmosAccounts) {
            foreach ($account in $cosmosAccounts) {
                $capabilities = @()
                try {
                    $capabilities = Get-AzCosmosDBAccount -ResourceGroupName $rg -Name $account.Name -ErrorAction Stop | Select-Object -ExpandProperty Capability
                }
                catch {
                    $capabilities = @()
                }

                $vectorCapability = $capabilities | Where-Object { $_.Name -eq "EnableNoSQLVectorSearch" }
                if (-not $vectorCapability) {
                    continue
                }

                $databases = Get-AzCosmosDBSqlDatabase -ResourceGroupName $rg -AccountName $account.Name -ErrorAction SilentlyContinue
                if (-not $databases) {
                    continue
                }

                foreach ($database in $databases) {
                    $containers = Get-AzCosmosDBSqlContainer -ResourceGroupName $rg -AccountName $account.Name -DatabaseName $database.Name -ErrorAction SilentlyContinue
                    if (-not $containers) {
                        continue
                    }

                    foreach ($container in $containers) {
                        $resource = $container.Resource
                        $indexingPolicy = Get-PropertyValue -Object $resource -Names @('IndexingPolicy','indexingPolicy')
                        $vectorPolicy = Get-PropertyValue -Object $resource -Names @('VectorEmbeddingPolicy','VectorPolicy','vectorEmbeddingPolicy','vectorPolicy')

                        $vectorEmbeddings = $null
                        if ($null -ne $vectorPolicy) {
                            $vectorEmbeddings = Get-PropertyValue -Object $vectorPolicy -Names @('VectorEmbeddings','vectorEmbeddings')
                        }

                        $vectorIndexes = $null
                        if ($null -ne $indexingPolicy) {
                            $vectorIndexes = Get-PropertyValue -Object $indexingPolicy -Names @('VectorIndexes','vectorIndexes')
                        }

                        $itemCount = 0
                        $documentCount = Get-PropertyValue -Object $resource -Names @('DocumentCount','documentCount')
                        if ($null -ne $documentCount) {
                            $itemCount = [int]$documentCount
                        }

                        if ($vectorEmbeddings -and $vectorEmbeddings.Count -gt 0 -and $vectorIndexes -and $vectorIndexes.Count -gt 0 -and $itemCount -gt 0) {
                            $found = $true
                            $message = @{
                                Status  = "Succeeded"
                                Message = "Cosmos DB semantic search final state verified in RG '$rg': account '$($account.Name)', SQL database '$($database.Name)', container '$($container.Name)' has EnableNoSQLVectorSearch capability, vector embedding policy, vector indexes, and $itemCount stored item(s)."
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
                Message = "Semantic search completion evidence not found yet in RG '$rg'. Expected a Cosmos DB for NoSQL account with EnableNoSQLVectorSearch, at least one SQL container with vector embedding policy and vector indexes, and at least one stored item."
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
        Message = "Cosmos DB semantic search final state not found in RG '$rg' after 3 attempts."
    } | ConvertTo-Json
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $message
    })
}
