using namespace System.Net

# Note: $sub (subscription id) and $DID (deployment id) are injected by the platform.
$rg = "rg-semanticsearch-$DID"
$count = 0
$found = $false

$scriptLines = @(
    "$tools = @()",
    "$checks = @(",
    "    @{ Name = 'VS Code'; Command = 'code.cmd' },",
    "    @{ Name = 'Azure CLI'; Command = 'az.cmd' },",
    "    @{ Name = 'Python'; Command = 'python.exe' },",
    "    @{ Name = 'pip'; Command = 'pip.exe' },",
    "    @{ Name = 'Git'; Command = 'git.exe' },",
    "    @{ Name = 'PowerShell'; Command = 'powershell.exe' }",
    ")",
    "",
    "foreach ($check in $checks) {",
    "    $cmd = Get-Command $check.Command -ErrorAction SilentlyContinue",
    "    $tools += [PSCustomObject]@{",
    "        Name = $check.Name",
    "        Available = [bool]$cmd",
    "        Path = if ($cmd) { $cmd.Source } else { '' }",
    "    }",
    "}",
    "",
    "$pythonVersion = ''",
    "try {",
    "    $pythonVersion = (& python --version 2>&1 | Out-String).Trim()",
    "} catch {",
    "    $pythonVersion = ''",
    "}",
    "",
    "$allAvailable = ($tools | Where-Object { -not $_.Available }).Count -eq 0",
    "$result = [PSCustomObject]@{",
    "    AllAvailable = $allAvailable",
    "    PythonVersion = $pythonVersion",
    "    Tools = $tools",
    "}",
    "$result | ConvertTo-Json -Depth 5"
)

$runCommandScript = $scriptLines -join "`n"

do {
    $count = $count + 1
    try {
        Set-AzContext -Subscription $sub -ErrorAction Stop

        $vms = Get-AzVM -ResourceGroupName $rg -Status -ErrorAction Stop
        $vm = $vms | Where-Object { $_.StorageProfile.OsDisk.OsType -eq 'Windows' } | Select-Object -First 1

        if ($null -eq $vm) {
            $found = $false
        } else {
            $powerState = ($vm.Statuses | Where-Object { $_.Code -like 'PowerState/*' } | Select-Object -ExpandProperty DisplayStatus -First 1)

            if ($powerState -ne 'VM running') {
                $found = $false
            } else {
                $runResult = Invoke-AzVMRunCommand -ResourceGroupName $rg -Name $vm.Name -CommandId 'RunPowerShellScript' -ScriptString $runCommandScript -ErrorAction Stop
                $rawMessage = ($runResult.Value[0].Message | Out-String).Trim()
                $jsonStart = $rawMessage.IndexOf('{')

                if ($jsonStart -ge 0) {
                    $jsonMessage = $rawMessage.Substring($jsonStart)
                    $toolResult = $jsonMessage | ConvertFrom-Json -ErrorAction Stop
                    $missingTools = @($toolResult.Tools | Where-Object { -not $_.Available } | Select-Object -ExpandProperty Name)

                    if ($toolResult.AllAvailable) {
                        $found = $true
                        $message = @{
                            Status  = 'Succeeded'
                            Message = "LabVM '$($vm.Name)' is running in RG '$rg'. Required Task 1 tools are available: VS Code, Azure CLI, Python ($($toolResult.PythonVersion)), pip, Git, and PowerShell."
                        } | ConvertTo-Json
                    } else {
                        $found = $false
                        $missingList = if ($missingTools.Count -gt 0) { $missingTools -join ', ' } else { 'Unknown tools' }
                        $message = @{
                            Status  = 'Failed'
                            Message = "LabVM '$($vm.Name)' is running in RG '$rg', but these Task 1 prerequisites are missing or not resolvable in PATH: $missingList."
                        } | ConvertTo-Json
                    }
                } else {
                    $found = $false
                    $message = @{
                        Status  = 'Failed'
                        Message = "LabVM '$($vm.Name)' is running in RG '$rg', but tool validation output could not be parsed from Run Command."
                    } | ConvertTo-Json
                }
            }
        }

        if (-not $found -and -not $message) {
            $message = @{
                Status  = 'Failed'
                Message = "A running Windows LabVM was not found in RG '$rg', or the VM is not yet reachable through Azure Run Command."
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
        Message = "LabVM readiness validation did not succeed in RG '$rg' after 3 attempts. Confirm the Windows LabVM is deployed, running, and has VS Code, Azure CLI, Python, pip, Git, and PowerShell installed."
    } | ConvertTo-Json
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $message
    })
}
