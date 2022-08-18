<#
.SYNOPSIS
    Adapted setup ps1 file from https://gist.github.com/mikepruett3/7ca6518051383ee14f9cf8ae63ba18a7/
.DESCRIPTION
    Script uses scoop
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

# if (!($Env:GIT_SSH)) {
#     Write-Verbose -Message "Setting GIT_SSH User Environment Variable"
#     [System.Environment]::SetEnvironmentVariable('GIT_SSH', (Resolve-Path (scoop which ssh)), 'USER')
# }
# if ((Get-Service -Name ssh-agent).Status -ne "Running") {
#     Start-Process -FilePath "PowerShell" -ArgumentList "Set-Service","ssh-agent","-StartupType","Manual" -Verb RunAs -Wait -WindowStyle Hidden
# }


## Add Buckets


# UNIX Tools
# Write-Verbose -Message "Removing curl Alias..."
# if (Get-Alias -Name curl -ErrorAction SilentlyContinue) {
#     Remove-Item alias:curl    
# }
# if (!($Env:TERM)) {
#     Write-Verbose -Message "Setting TERM User Environment Variable"
#     [System.Environment]::SetEnvironmentVariable("TERM", "xterm-256color", "USER")
# }

# Install WinGet Packages
$WinGet = @(
    "CodecGuide.K-LiteCodecPack.Basic",
    "Google.Chrome",
    "Discord.Discord",
    "clsid2.mpc-hc",
    "Microsoft.DotNet.SDK.6",
    "Microsoft.PowerToys",
    "OBSProject.OBSStudio",
    "JetBrains.IntelliJIDEA.Ultimate",
    "JetBrains.CLion",
    "Git.Git"
    )
foreach ($item in $WinGet) {
    Install-WinGetApp -PackageID "$item"
}

Enable-Bucket -Bucket "extras"
Enable-Bucket -Bucket "java"
# Enable-Bucket -Bucket "nirsoft"

# Install Scoop Packages
$Scoop = @(
    "neovim",
    "openjdk8",
    "openjdk11",
    "openjdk",
    "python",
    "yt-dlp",
    "ffmpeg",
    "aria2",
    "imagemagick"
    )

foreach ($item in $Scoop) {
    Install-ScoopApp -Package "$item"
}


# Custom WinGet install for VSCode
winget install Microsoft.VisualStudioCode --override '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders"'

# Install Chocolatey Packages
$Choco = @(
    "eartrumpet"
)
foreach ($item in $Choco) {
    Install-ChocoApp -Package "$item"
}


# Customize DOS/PowerShell Environment
# Write-Verbose -Message "Customize DOS/PowerShell Environment..."
# if ((Get-ItemProperty -Path "HKCU:\Software\Microsoft\Command Processor").AutoRun -eq $Null) {
#     Start-Process -FilePath "cmd" -ArgumentList "/c","clink","autorun","install" -Wait -WindowStyle Hidden
# }
# Start-Process -FilePath "cmd" -ArgumentList "/c","concfg","import","solarized-dark" -Verb RunAs -Wait

# Install Visual Studio Code Integrations
#if (!(Get-Item -Path "HKCU:\Software\Classes\Directory\shell\Open with &Code" -ErrorAction Ignore)) {
#    Write-Verbose -Message "Install Visual Studio Code Integrations..."
#    Start-Process -FilePath "cmd" -ArgumentList "/c","reg","import","%UserProfile%\scoop\apps\vscode\current\install-context.reg" -Verb RunAs -Wait -WindowStyle Hidden
#    Start-Process -FilePath "cmd" -ArgumentList "/c","reg","import","%UserProfile%\scoop\apps\vscode\current\nstall-associations.reg" -Verb RunAs -Wait -WindowStyle Hidden
#}

# Pin Run to Taskbar
#Start-Process -FilePath "PowerShell" -ArgumentList "syspin","'$Env:AppData\Microsoft\Windows\Start Menu\Programs\System Tools\Run.lnk'","c:5386" -Wait -NoNewWindow
# Pin Google Chrome to Taskbar
# Write-Verbose -Message "Pin Google Chrome to Taskbar..."
# Start-Process -FilePath "PowerShell" -ArgumentList "syspin","'$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk'","c:5386" -Wait -NoNewWindow

# Install my PowerShell dot files
# if (!(Test-Path -Path "$Env:UserProfile\dotposh" -PathType Container)) {
#     Write-Verbose -Message "Install my PowerShell dot files..."
#     Start-Process -FilePath "PowerShell" -ArgumentList "git","clone","https://github.com/mikepruett3/dotposh.git","$Env:UserProfile\dotposh" -Wait -NoNewWindow
# @'
# New-Item -Path $Env:UserProfile\Documents\WindowsPowerShell -ItemType Directory -ErrorAction Ignore
# Remove-Item -Path $Env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -Force
# New-Item -Path $Env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -ItemType SymbolicLink -Target $Env:UserProfile\dotposh\profile.ps1
# '@ > $Env:Temp\dotposh.ps1
#     Start-Process -FilePath "PowerShell" -ArgumentList "$Env:Temp\dotposh.ps1" -Verb RunAs -Wait -WindowStyle Hidden
#     Remove-Item -Path $Env:Temp\dotposh.ps1 -Force
# @'
# cd $Env:UserProfile\dotposh
# git submodule init
# git submodule update
# '@ > $Env:Temp\submodule.ps1
#     Start-Process -FilePath "PowerShell" -ArgumentList "$Env:Temp\submodule.ps1" -Wait -NoNewWindow
#     Remove-Item -Path $Env:Temp\submodule.ps1 -Force
# }

# Pin PowerShell to Taskbar
# Write-Verbose -Message "Pin PowerShell to Taskbar..."
# Start-Process -FilePath "PowerShell" -ArgumentList "syspin","'$Env:AppData\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk'","c:5386" -Wait -NoNewWindow

# # Install PowerShell 7
# $PS7 = winget list --exact -q Microsoft.PowerShell
# if (!$PS7) {
#     Write-Verbose -Message "Installing PowerShell 7..."
# @'
# iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI -Quiet"
# '@ > $Env:Temp\ps7.ps1
#     Start-Process -FilePath "PowerShell" -ArgumentList "$Env:Temp\ps7.ps1" -Verb RunAs -Wait -WindowStyle Hidden
#     Remove-Item -Path $Env:Temp\ps7.ps1 -Force
# }
# Pin PowerShell 7 to Taskbar
# Write-Verbose -Message "Pin PowerShell 7 to Taskbar..."
# Start-Process -FilePath "PowerShell" -ArgumentList "syspin","'$Env:ProgramData\Microsoft\Windows\Start Menu\Programs\PowerShell\PowerShell 7 (x64).lnk'","c:5386" -Wait -NoNewWindow

# Remove unused Packages/Applications
Write-Verbose -Message "Removing Unused Applications..."
$RemoveApps = @(
    "*3DPrint*",
    "Microsoft.MixedReality.Portal")
foreach ($item in $RemoveApps) {
    Remove-InstalledApp -Package $item
}

# Install Windows SubSystems for Linux
# $wslInstalled = Get-Command "wsl" -CommandType Application -ErrorAction Ignore
# if (!$wslInstalled) {
#     Write-Verbose -Message "Installing Windows SubSystems for Linux..."
#     Start-Process -FilePath "PowerShell" -ArgumentList "wsl","--install" -Verb RunAs -Wait -WindowStyle Hidden
# }
Write-Output "Install complete! Please reboot your machine/worksation!"
Start-Sleep -Seconds 10