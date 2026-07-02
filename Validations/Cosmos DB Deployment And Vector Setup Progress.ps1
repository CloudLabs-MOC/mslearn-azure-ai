using namespace System.Net

# Note: $sub (subscription id) and $DID (deployment id) are injected by the platform.
$rg = "rg-semanticsearch-$DID"
$count = 0
$found = $false

function Get-PropertyValue {
    param(
        [object]$InputObject,
        [string]$PropertyName
    )

    if ($null -eq $InputObject) {
        return $null
    }

    $prop = $InputObject.PSObject.Properties[$PropertyName]
    if ($null -ne $prop) {
        return $prop.Value
    }

    return $null
}

do {
    $count = $count + 1
    try {
        Set-AzContext -Subscription $sub -ErrorAction Stop

        $accounts = Get-AzCosmosDBAccount -ResourceGroupName $rg -ErrorAction Stop
        $sqlAccounts = @($accounts | Where-Object { $_.Kind -eq 'GlobalDocumentDB' })

        if ($sqlAccounts.Count -gt 0) {
            foreach ($account in $sqlAccounts) {
                $capabilities = @($account.Capabilities)
                $vectorCapability = $capabilities | Where-Object {
                    ($_.Name -eq 'EnableNoSQLVectorSearch') -or ($_.Name -eq 'EnableNoSqlVectorSearch')
                }

                $databases = @(Get-AzCosmosDBSqlDatabase -ResourceGroupName $rg -AccountName $account.Name -ErrorAction SilentlyContinue)
                foreach ($database in $databases) {
                    $containers = @(Get-AzCosmosDBSqlContainer -ResourceGroupName $rg -AccountName $account.Name -DatabaseName $database.Name -ErrorAction SilentlyContinue)

                    foreach ($container in $containers) {
                        $resource = Get-PropertyValue -InputObject $container -PropertyName 'Resource'
                        $vectorEmbeddingPolicy = Get-PropertyValue -InputObject $resource -PropertyName 'VectorEmbeddingPolicy'
                        $indexingPolicy = Get-PropertyValue -InputObject $resource -PropertyName 'IndexingPolicy'
                        $vectorEmbeddings = @(Get-PropertyValue -InputObject $vectorEmbeddingPolicy -PropertyName 'VectorEmbeddings')
                        $vectorIndexes = @(Get-PropertyValue -InputObject $indexingPolicy -PropertyName 'VectorIndexes')

                        if ($vectorCapability -and $vectorEmbeddings.Count -gt 0 -and $vectorIndexes.Count -gt 0) {
                            $found = $true
                            $message = @{
                                Status  = 'Succeeded'
                                Message = "Cosmos DB account '$($account.Name)' in RG '$rg' has NoSQL vector search capability enabled and includes SQL database '$($database.Name)' with container '$($container.Name)' configured with vector embedding policy and vector indexes."
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
            $capableAccount = $null
            $databaseCount = 0
            $containerCount = 0

            foreach ($account in $sqlAccounts) {
                $capabilities = @($account.Capabilities)
                $vectorCapability = $capabilities | Where-Object {
                    ($_.Name -eq 'EnableNoSQLVectorSearch') -or ($_.Name -eq 'EnableNoSqlVectorSearch')
                }

                if ($vectorCapability -and -not $capableAccount) {
                    $capableAccount = $account.Name
                }

                $databases = @(Get-AzCosmosDBSqlDatabase -ResourceGroupName $rg -AccountName $account.Name -ErrorAction SilentlyContinue)
                $databaseCount += $databases.Count

                foreach ($database in $databases) {
                    $containers = @(Get-AzCosmosDBSqlContainer -ResourceGroupName $rg -AccountName $account.Name -DatabaseName $database.Name -ErrorAction SilentlyContinue)
                    $containerCount += $containers.Count
                }
            }

            if ($sqlAccounts.Count -eq 0) {
                $detail = "No Azure Cosmos DB for NoSQL account was found in RG '$rg'. Complete Task 2 to deploy the account."
            }
            elseif (-not $capableAccount) {
                $detail = "Cosmos DB account exists in RG '$rg', but NoSQL vector search capability was not detected yet. Complete or wait for the Task 2 capability update to finish."
            }
            elseif ($databaseCount -eq 0) {
                $detail = "Cosmos DB account '$capableAccount' has vector capability in RG '$rg', but no SQL database was detected yet. Complete the database creation steps from the Microsoft lab."
            }
            elseif ($containerCount -eq 0) {
                $detail = "Cosmos DB account '$capableAccount' has vector capability and a SQL database in RG '$rg', but no SQL container was detected yet. Complete Task 4 to create the container."
            }
            else {
                $detail = "Cosmos DB account '$capableAccount' has vector capability and SQL resources in RG '$rg', but no container with both vector embedding policy and vector indexes was detected yet. Verify the Task 4 container configuration."
            }

            $message = @{
                Status  = 'Failed'
                Message = $detail
            } | ConvertTo-Json
        }

        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body       = $message
        })
    }
    catch {
        $message = @{
            Status  = 'Failed'
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
        Status  = 'Failed'
        Message = "Cosmos DB deployment and vector setup progress not found in RG '$rg' after 3 attempts."
    } | ConvertTo-Json
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $message
    })
}
