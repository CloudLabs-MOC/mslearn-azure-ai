Param(
    [Parameter(Mandatory = $false)] [string] $AzureUserName,
    [Parameter(Mandatory = $false)] [string] $AzurePassword,
    [Parameter(Mandatory = $false)] [string] $AzureTenantID,
    [Parameter(Mandatory = $false)] [string] $AzureSubscriptionID,
    [Parameter(Mandatory = $false)] [string] $ODLID,
    [Parameter(Mandatory = $false)] [string] $InstallCloudLabsShadow,
    [Parameter(Mandatory = $false)] [string] $DeploymentID,
    [Parameter(Mandatory = $false)] [string] $vmAdminUsername,
    [Parameter(Mandatory = $false)] [string] $vmAdminPassword,
    [Parameter(Mandatory = $false)] [string] $trainerUserName,
    [Parameter(Mandatory = $false)] [string] $trainerUserPassword
)

$ErrorActionPreference = 'Stop'
Start-Transcript -Path 'C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt' -Append

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $LabFilesPath = 'C:\LabFiles'
    $CommonBaseUrl = 'https://experienceazure.blob.core.windows.net/templates/cloudlabs-common'
    $MicrosoftLabUrl = 'https://learn.microsoft.com/azure/cosmos-db/quickstart-vector-store-python'
    $StarterZipUrl = 'https://github.com/Azure-Samples/cosmos-db-vector-samples/archive/refs/heads/main.zip'

    function Write-Log {
        param([string]$Message)
        Write-Host ("[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message)
    }

    function Invoke-DownloadFile {
        param(
            [Parameter(Mandatory = $true)] [string] $Url,
            [Parameter(Mandatory = $true)] [string] $Destination
        )

        $destinationFolder = Split-Path -Path $Destination -Parent
        if (-not (Test-Path $destinationFolder)) {
            New-Item -Path $destinationFolder -ItemType Directory -Force | Out-Null
        }

        Write-Log "Downloading $Url to $Destination"
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
    }

    function CreateCredFile {
        Write-Log 'Creating Azure credential helper files.'

        New-Item -Path $LabFilesPath -ItemType Directory -Force | Out-Null

        $azureCredsTxt = Join-Path $env:TEMP 'AzureCreds.txt'
        $azureCredsPs1 = Join-Path $env:TEMP 'AzureCreds.ps1'

        Invoke-DownloadFile -Url "$CommonBaseUrl/AzureCreds.txt" -Destination $azureCredsTxt
        Invoke-DownloadFile -Url "$CommonBaseUrl/AzureCreds.ps1" -Destination $azureCredsPs1

        $txtContent = Get-Content -Path $azureCredsTxt -Raw
        $txtContent = $txtContent.Replace('AzureUserNameValue', $AzureUserName)
        $txtContent = $txtContent.Replace('AzurePasswordValue', $AzurePassword)
        $txtContent = $txtContent.Replace('AzureTenantIDValue', $AzureTenantID)
        $txtContent = $txtContent.Replace('AzureSubscriptionIDValue', $AzureSubscriptionID)
        $txtContent = $txtContent.Replace('ODLIDValue', $ODLID)
        $txtContent = $txtContent.Replace('DeploymentIDValue', $DeploymentID)
        Set-Content -Path $azureCredsTxt -Value $txtContent -Force

        $ps1Content = Get-Content -Path $azureCredsPs1 -Raw
        $ps1Content = $ps1Content.Replace('AzureUserNameValue', $AzureUserName)
        $ps1Content = $ps1Content.Replace('AzurePasswordValue', $AzurePassword)
        $ps1Content = $ps1Content.Replace('AzureTenantIDValue', $AzureTenantID)
        $ps1Content = $ps1Content.Replace('AzureSubscriptionIDValue', $AzureSubscriptionID)
        $ps1Content = $ps1Content.Replace('ODLIDValue', $ODLID)
        $ps1Content = $ps1Content.Replace('DeploymentIDValue', $DeploymentID)
        Set-Content -Path $azureCredsPs1 -Value $ps1Content -Force

        Copy-Item -Path $azureCredsTxt -Destination (Join-Path $LabFilesPath 'AzureCreds.txt') -Force
        Copy-Item -Path $azureCredsPs1 -Destination (Join-Path $LabFilesPath 'AzureCreds.ps1') -Force
        Copy-Item -Path $azureCredsTxt -Destination 'C:\Users\Public\Desktop\AzureCreds.txt' -Force
        Copy-Item -Path $azureCredsPs1 -Destination 'C:\Users\Public\Desktop\AzureCreds.ps1' -Force
    }

    function Install-ChocolateyIfNeeded {
        if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
            Write-Log 'Installing Chocolatey.'
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        }
        else {
            Write-Log 'Chocolatey already installed.'
        }
    }

    function Install-PackageIfMissing {
        param(
            [Parameter(Mandatory = $true)] [string] $CommandName,
            [Parameter(Mandatory = $true)] [string] $ChocolateyPackage,
            [string] $Arguments = ''
        )

        if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
            Write-Log "Installing package $ChocolateyPackage"
            choco install $ChocolateyPackage -y --no-progress $Arguments
        }
        else {
            Write-Log "$CommandName already available."
        }
    }

    function Install-Python312IfNeeded {
        $pythonOk = $false
        $pythonCmd = Get-Command python.exe -ErrorAction SilentlyContinue

        if ($pythonCmd) {
            try {
                $versionText = (& python --version) 2>&1
                if ($versionText -match 'Python\s+(\d+)\.(\d+)') {
                    $major = [int]$Matches[1]
                    $minor = [int]$Matches[2]
                    if ($major -gt 3 -or ($major -eq 3 -and $minor -ge 12)) {
                        $pythonOk = $true
                    }
                }
            }
            catch {
                Write-Log 'Existing python version check failed; reinstalling Python 3.12.'
            }
        }

        if (-not $pythonOk) {
            Write-Log 'Installing Python 3.12.'
            choco install python --version=3.12.4 -y --no-progress
            $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
        }
        else {
            Write-Log 'Python 3.12+ already available.'
        }

        Write-Log 'Upgrading pip.'
        & python -m pip install --upgrade pip
    }

    function Install-VSCodeExtensions {
        $codeCmd = Get-Command code.cmd -ErrorAction SilentlyContinue
        if ($codeCmd) {
            $extensions = @(
                'ms-python.python',
                'ms-python.vscode-pylance',
                'ms-azuretools.vscode-cosmosdb',
                'ms-vscode.powershell',
                'ms-azuretools.vscode-azureresourcegroups'
            )

            foreach ($extension in $extensions) {
                Write-Log "Ensuring VS Code extension $extension is installed."
                & $codeCmd.Source --install-extension $extension --force | Out-Null
            }
        }
        else {
            Write-Log 'VS Code command line not found; skipping extension installation.'
        }
    }

    function New-InternetShortcut {
        param(
            [Parameter(Mandatory = $true)] [string] $ShortcutPath,
            [Parameter(Mandatory = $true)] [string] $TargetUrl
        )

        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($ShortcutPath)
        $shortcut.TargetPath = $TargetUrl
        $shortcut.Save()
    }

    function Configure-LabAssets {
        Write-Log 'Configuring lab helper assets and shortcuts.'

        New-Item -Path $LabFilesPath -ItemType Directory -Force | Out-Null
        New-Item -Path 'C:\Users\Public\Desktop' -ItemType Directory -Force | Out-Null

        $readme = @"
Azure Cosmos DB for NoSQL Semantic Search Lab

This CloudLabs VM is prepared with the workstation prerequisites needed for the Microsoft Learn lab.

Use the Microsoft instructions as the source of truth:
$MicrosoftLabUrl

Starter files download location:
$StarterZipUrl

Notes:
- Do not expect the starter files to be preloaded on this VM.
- Sign in with Azure CLI using the provided lab credentials before performing the Microsoft tasks.
- Use VS Code, Python, Git, Azure CLI, and PowerShell from this VM to complete the lab.
"@
        Set-Content -Path (Join-Path $LabFilesPath 'Lab-Overview.txt') -Value $readme -Force

        New-InternetShortcut -ShortcutPath 'C:\Users\Public\Desktop\Microsoft Semantic Search Lab.url' -TargetUrl $MicrosoftLabUrl
        New-InternetShortcut -ShortcutPath 'C:\Users\Public\Desktop\Starter Files Download.url' -TargetUrl $StarterZipUrl
    }

    function Initialize-AzureCliContext {
        Write-Log 'Initializing Azure CLI context for the lab user.'
        $azCmd = Get-Command az.cmd -ErrorAction SilentlyContinue
        if (-not $azCmd) {
            throw 'Azure CLI is not available after installation.'
        }

        try {
            & $azCmd.Source config set core.login_experience_v2=off | Out-Null
        }
        catch {
            Write-Log 'Unable to disable Azure CLI login experience v2; continuing.'
        }

        try {
            & $azCmd.Source account show | Out-Null
            Write-Log 'Azure CLI already has an active session.'
        }
        catch {
            Write-Log 'Signing in to Azure CLI with lab credentials.'
            & $azCmd.Source login --username $AzureUserName --password $AzurePassword --tenant $AzureTenantID | Out-Null
        }

        & $azCmd.Source account set --subscription $AzureSubscriptionID
        & $azCmd.Source account show | Out-Null
    }

    Write-Log 'Starting CloudLabs semantic search LabVM bootstrap.'

    CreateCredFile

    Install-ChocolateyIfNeeded
    Install-PackageIfMissing -CommandName 'git.exe' -ChocolateyPackage 'git'
    Install-PackageIfMissing -CommandName 'az.cmd' -ChocolateyPackage 'azure-cli'
    Install-PackageIfMissing -CommandName 'code.cmd' -ChocolateyPackage 'vscode'
    Install-Python312IfNeeded

    Write-Log 'Validating PowerShell availability.'
    $PSVersionTable | Out-Null

    Install-VSCodeExtensions
    Configure-LabAssets
    Initialize-AzureCliContext

    Write-Log 'Bootstrap completed successfully.'
}
catch {
    Write-Error $_.Exception.Message
    throw
}
finally {
    Stop-Transcript
}
