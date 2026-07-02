using namespace System.Net

# Note: $sub (subscription id) and $DID (deployment id) are injected by the platform.
$rg = "rg-semantic-search-$DID"
$count = 0
$found = $false

do {
    $count = $count + 1
    try {
        Set-AzContext -Subscription $sub -ErrorAction Stop

        $cosmosAccounts = @(Get-AzResource -ResourceGroupName $rg -ResourceType "Microsoft.DocumentDB/databaseAccounts" -ErrorAction Stop)

        if (-not $cosmosAccounts -or $cosmosAccounts.Count -eq 0) {
            $message = @{
                Status  = "Failed"
                Message = "No Azure Cosmos DB account was found in RG '$rg'. Complete Task 2 to deploy a Cosmos DB for NoSQL account with vector search capability."
            } | ConvertTo-Json
        }
        else {
            $matchedAccount = $null
            $matchedDatabase = $null
            $matchedContainer = $null
            $matchedVectorPath = $null
            $matchedVectorIndexType = $null
            $capabilityDetected = $false

            foreach ($account in $cosmosAccounts) {
                $accountResource = Get-AzResource -ResourceId $account.ResourceId -ExpandProperties -ErrorAction Stop
                $capabilities = @($accountResource.Properties.capabilities)
                if ($capabilities) {
                    foreach ($cap in $capabilities) {
                        if (($cap.name -eq 'EnableNoSQLVectorSearch') -or ($cap.Name -eq 'EnableNoSQLVectorSearch')) {
                            $capabilityDetected = $true
                            break
                        }
                    }
                }

                $sqlDatabases = @(Get-AzResource -ResourceGroupName $rg -ResourceType "Microsoft.DocumentDB/databaseAccounts/sqlDatabases" -ErrorAction SilentlyContinue |
                    Where-Object { $_.ResourceId -like "$($account.ResourceId)/*" })

                foreach ($database in $sqlDatabases) {
                    $containers = @(Get-AzResource -ResourceGroupName $rg -ResourceType "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers" -ErrorAction SilentlyContinue |
                        Where-Object { $_.ResourceId -like "$($database.ResourceId)/*" })

                    foreach ($container in $containers) {
                        $containerResource = Get-AzResource -ResourceId $container.ResourceId -ApiVersion "2024-05-15" -ExpandProperties -ErrorAction Stop

                        $vectorEmbeddings = @($containerResource.Properties.resource.vectorEmbeddingPolicy.vectorEmbeddings)
                        $vectorIndexes = @($containerResource.Properties.resource.indexingPolicy.vectorIndexes)

                        if ($vectorEmbeddings.Count -gt 0 -and $vectorIndexes.Count -gt 0) {
                            $matchedAccount = $account
                            $matchedDatabase = $database
                            $matchedContainer = $container
                            $matchedVectorPath = $vectorEmbeddings[0].path
                            $matchedVectorIndexType = $vectorIndexes[0].type
                            $found = $true
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

            if ($found) {
                $capabilityText = if ($capabilityDetected) { "Account capability 'EnableNoSQLVectorSearch' detected" } else { "Vector-search capability flag was not conclusively detected, but vector container configuration is present" }
                $message = @{
                    Status  = "Succeeded"
                    Message = "$capabilityText. Cosmos DB account '$($matchedAccount.Name)' in RG '$rg' contains SQL database '$($matchedDatabase.Name)' and container '$($matchedContainer.Name)' with vector embedding path '$matchedVectorPath' and vector index type '$matchedVectorIndexType'."
                } | ConvertTo-Json
            }
            else {
                $accountNames = ($cosmosAccounts | Select-Object -ExpandProperty Name) -join ', '
                $message = @{
                    Status  = "Failed"
                    Message = "Cosmos DB account(s) found in RG '$rg' ($accountNames), but no SQL container with both a vector embedding policy and vector index policy was detected yet. Complete Tasks 2 and 4."
                } | ConvertTo-Json
            }
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
        Message = "Cosmos DB vector setup not found in RG '$rg' after 3 attempts."
    } | ConvertTo-Json
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $message
    })
}
