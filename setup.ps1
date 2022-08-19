<#
.SYNOPSIS
    Adapted setup ps1 file from https://gist.github.com/mikepruett3/7ca6518051383ee14f9cf8ae63ba18a7/
.DESCRIPTION
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://gist.githubusercontent.com/Xyn0gen/ba6d61a4397bb45eaf3d9f216e63f047/raw/setup.ps1'))"
.NOTES
    **NOTE** Will configure the Execution Policy for the "CurrentUser" to Unrestricted.
#>

$VerbosePreference = "Continue"

function Install-ScoopApp {
    param (
        [string]$Package
    )
    Write-Verbose -Message "Preparing to install $Package"
    if (! (scoop info $Package).Installed ) {
        Write-Verbose -Message "Installing $Package"
        scoop install $Package
    } else {
        Write-Verbose -Message "Package $Package already installed! Skipping..."
    }
}

function Install-WinGetApp {
    param (
        [string]$PackageID
    )
    Write-Verbose -Message "Preparing to install $PackageID"
    # Added accept options based on this issue - https://github.com/microsoft/winget-cli/issues/1559
    if (!(winget list -e -q $PackageID --accept-source-agreements | Select-String $PackageID)) {
        Write-Verbose -Message "Installing $Package"
        winget install --exact --silent $PackageID
    } else {
        Write-Verbose -Message "Package $PackageID already installed! Skipping..."
    }
}

function Install-ChocoApp {
    param (
        [string]$Package
    )
    Write-Verbose -Message "Preparing to install $Package"
    $listApp = choco list --local $Package
    if ($listApp -like "0 packages installed.") {
        Write-Verbose -Message "Installing $Package"
        Start-Process -FilePath "PowerShell" -ArgumentList "choco","install","$Package","-y" -Verb RunAs -Wait
    } else {
        Write-Verbose -Message "Package $Package already installed! Skipping..."
    }
}


function Remove-InstalledApp {
    param (
        [string]$Package
    )
    Write-Verbose -Message "Uninstalling: $Package"
    Start-Process -FilePath "PowerShell" -ArgumentList "Get-AppxPackage","-AllUsers","-Name","'$Package'" -Verb RunAs -WindowStyle Hidden
}

function Enable-Bucket {
    param (
        [string]$Bucket
    )
    if (!($(scoop bucket list).Name -eq "$Bucket")) {
        Write-Verbose -Message "Adding Bucket $Bucket to scoop..."
        scoop bucket add $Bucket
    } else {
        Write-Verbose -Message "Bucket $Bucket already added! Skipping..."
    }
}

# Configure ExecutionPolicy to Unrestricted for CurrentUser Scope
if ((Get-ExecutionPolicy -Scope CurrentUser) -notcontains "Unrestricted") {
    Write-Verbose -Message "Setting Execution Policy for Current User..."
    Start-Process -FilePath "PowerShell" -ArgumentList "Set-ExecutionPolicy","-Scope","CurrentUser","-ExecutionPolicy","Unrestricted","-Force" -Verb RunAs -Wait
    Write-Output "Restart/Re-Run script!!!"
    Start-Sleep -Seconds 10
    Break
}

# Install Scoop, if not already installed
#$scoopInstalled = Get-Command "scoop"
if ( !(Get-Command -Name "scoop" -CommandType Application -ErrorAction SilentlyContinue) ) {
    Write-Verbose -Message "Installing Scoop..."
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh'))
}

# Install Chocolatey, if not already installed
if (! (Get-Command -Name "choco" -CommandType Application -ErrorAction SilentlyContinue) ) {
    Write-Verbose -Message "Installing Chocolatey..."
@'
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
'@ > $Env:Temp\choco.ps1
    Start-Process -FilePath "PowerShell" -ArgumentList "$Env:Temp\choco.ps1" -Verb RunAs -Wait
    Remove-Item -Path $Env:Temp\choco.ps1 -Force
}

# Install WinGet, if not already installed
# From crutkas's gist - https://gist.github.com/crutkas/6c2096eae387e544bd05cde246f23901
$hasPackageManager = Get-AppPackage -name "Microsoft.DesktopAppInstaller"
if (!$hasPackageManager) {
    Write-Verbose -Message "Installing WinGet..."
@'
# Set URL and Enable TLSv12
$releases_url = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Dont Think We Need This!!!
#Install-PackageProvider -Name NuGet

# Install Nuget as Package Source Provider
Register-PackageSource -Name Nuget -Location "http://www.nuget.org/api/v2" -ProviderName Nuget -Trusted

# Install Microsoft.UI.Xaml (This is not currently working!!!)
Install-Package Microsoft.UI.Xaml -RequiredVersion 2.7.1

# Grab "Latest" release
$releases = Invoke-RestMethod -uri $releases_url
$latestRelease = $releases.assets | Where { $_.browser_download_url.EndsWith('msixbundle') } | Select -First 1

# Install Microsoft.DesktopAppInstaller Package
Add-AppxPackage -Path $latestRelease.browser_download_url
'@ > $Env:Temp\winget.ps1
    Start-Process -FilePath "PowerShell" -ArgumentList "$Env:Temp\winget.ps1" -Verb RunAs -Wait
    Remove-Item -Path $Env:Temp\winget.ps1 -Force
}

Install-ScoopApp -Package "aria2"
if (!$(scoop config aria2-enabled) -eq $True) {
    scoop config aria2-enabled true
}
if (!$(scoop config aria2-warning-enabled) -eq $False) {
    scoop config aria2-warning-enabled false
}



# Install WinGet Packages
$WinGet = @(
    "Microsoft.PowerShell",
    "Google.Chrome",
    "Discord.Discord",
    "clsid2.mpc-hc",
    "Microsoft.DotNet.SDK.6",
    "Microsoft.PowerToys",
    "OBSProject.OBSStudio",
    "JetBrains.IntelliJIDEA.Ultimate",
    "JetBrains.CLion",
    "Git.Git",
    "Notepad++.Notepad++"
    )
foreach ($item in $WinGet) {
    Install-WinGetApp -PackageID "$item"
}

Enable-Bucket -Bucket "extras"
Enable-Bucket -Bucket "java"
# Enable-Bucket -Bucket "nirsoft"

# Install Scoop Packages
$Scoop = @(
    "7zip",
    "neovim",
    "openjdk8-redhat",
    "openjdk11",
    "openjdk",
    "python",
    "yt-dlp",
    "ffmpeg",
    "imagemagick"
    )

foreach ($item in $Scoop) {
    Install-ScoopApp -Package "$item"
}

# Custom install for K-Lite Standard
# No media info, add to playlist and no keyframing
# Download unattended ini
(New-Object System.Net.WebClient).DownloadFile('https://gist.githubusercontent.com/Xyn0gen/a8c5ad4e97f360ac375df30e4825a923/raw', $Env:Temp+"\klcp_standard_unattended.ini")
# set override arguments
$override_args = '/VERYSILENT /NORESTART /SUPPRESSMSGBOXES /LOADINF="'+$Env:temp+'\klcp_standard_unattended.ini"'
winget install "CodecGuide.K-LiteCodecPack.Standard" --override $override_args

# Custom WinGet install for VSCode
winget install Microsoft.VisualStudioCode --override '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders"'

# Install Chocolatey Packages
$Choco = @(
    "eartrumpet"
)
foreach ($item in $Choco) {
    Install-ChocoApp -Package "$item"
}


# Remove unused Packages/Applications
Write-Verbose -Message "Removing Unused Applications..."
$RemoveApps = @(
    "*3DPrint*",
    "Microsoft.MixedReality.Portal")
foreach ($item in $RemoveApps) {
    Remove-InstalledApp -Package $item
}


Write-Output "Install complete! Please reboot your machine/worksation!"
Start-Sleep -Seconds 10