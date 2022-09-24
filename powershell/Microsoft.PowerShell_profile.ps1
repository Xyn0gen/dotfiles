# $executionTime = Measure-Command {}

#$env:AZ_ENABLED=$false
#oh-my-posh prompt init pwsh --config ~/mytheme.omp.json | Invoke-Expression

function prompt {
    # Write-Host $?
    $check = $?
    Write-Host ("$env:UserName") -ForegroundColor Red -NoNewline
    Write-Host ("@") -NoNewline
    Write-Host ($env:ComputerName).ToLower() -NoNewline -ForegroundColor Yellow
    Write-Host (" in ") -NoNewline
    Write-Host ("$(Get-Location)") -NoNewline -ForegroundColor Green
    Write-Host (" | ") -NoNewline
    Write-Host ("$(Get-Date -Format "HH:mm:ss")") -NoNewLine
    if ($check) {
        Write-Host ("")
    } else {
        Write-Host (" err") -ForegroundColor Yellow
    }
    Write-Host ("$") -NoNewline
    return " "
}
function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}


function Compare-Images() {
    [CmdletBinding(PositionalBinding = $False)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Original,

        [Parameter(Mandatory, Position = 1)]
        [string]
        $Comparing,

        [Alias("m")]
        [string]
        $Metric = "ssim"
    )

    & magick compare -metric $Metric $Original $Comparing "null:"
}


function Convert-Images() {
    [CmdletBinding(PositionalBinding = $False)]
    Param(
        [Alias("q")]
        [int]
        $quality = -1,
        
        [Alias("r")]
        [string]
        $resize = "",

        [Alias("m")]
        [string]
        $method = 4,

        [Parameter(Position = 0)]
        [Alias("i")]
        [string]
        $from = "*.jpg"
    )

    $params = @(
        "-strip",
        "-format", "webp",
        "-identify",
        "-define", "webp:method=$method"
    )

    If ((-not ($resize -eq "")) -and ($resize -match "(^\d{1,4}x\d{1,4}[^A-Za-z0-9]*$)|(\d{1,2}%$)|(100%)")) {
        $params += @("-resize", $resize)
    }

    If (-not ($quality -eq -1)) {
        $params += @("-quality", $quality)
    }

    & magick mogrify $params $from

    $output = "Original"
    New-Item -ItemType Directory -Force -Path .\$output | Out-Null
    Get-Item $from | Move-Item -Destination .\$output
    # Get-ChildItem *.jpg | ForEach-Object { Recycle-Item $_.FullName }
}

function mergeAudio($video) {
    if (Test-Path($video)) {
        $output = (Get-Item $video).Name
        ffmpeg -i $video -filter_complex "[0:a:0][0:a:1]amerge=inputs=2[outa]" -c:v copy -c:a aac -map 0:v -map "[outa]" "merged_$output"
    } else {
        "$VideoInput is Invalid"
    }
}

function Student-Id() {
    Get-Content C:\Users\darre\OneDrive\Documents\Homework\studentId | clip
    Write-Host $(Get-Content C:\Users\darre\OneDrive\Documents\Homework\studentId)
}

function trim() {
    [CmdletBinding(PositionalBinding = $False)]
    Param(
        [Parameter(Mandatory, Position = 0)]
        [Alias("i", "input")]
        [string]
        $VideoInput,
        
        [Parameter(Mandatory)]
        [Alias("s")]
        [string]
        $start,
        
        [Alias("d")]
        [string]
        $duration = 0,

        [Alias("vc")]
        [string]
        $vcodec = "hevc_nvenc",

        [Alias("p")]
        [string]
        $preset = "slow",

        [Alias("q")]
        [int]
        $qp = 23,
        
        [Parameter(Position = 1)]
        [Alias("o")]
        [string]
        $output
    )
    
    if (Test-Path($VideoInput)) {
        $video_name = (Get-Item $VideoInput).Basename
        ffmpeg -hide_banner `
            -ss $start `
            -t $duration `
            -i "$VideoInput" `
            -vcodec $vcodec `
            -qp $qp `
            -preset $preset `
            -map 0 `
        $(If ($output -eq "") { ".\clips\trimmed_$video_name.mp4" } Else { ".\clips\$output" })
    } else {
        "Video Path Invalid"
    }
}

New-Alias grep Select-String

New-Alias java8 "C:\Users\darre\.jdks\temurin-1.8.0_332\bin\java.exe"
New-Alias java11 "C:\Users\darre\.jdks\temurin-11.0.15\bin\java.exe"

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

function jpgq($a) {
    $extn = [IO.Path]::GetExtension($a)
    if ($extn -eq ".jpg" -or $extn -eq '.jpeg') {
        magick identify -verbose $a | grep quality	
    } else {
        "Not a jpg"
    }
}

function Recycle-Item {
    param([string] $Path)

    $shell = New-Object -ComObject 'Shell.Application'

    $shell.NameSpace(0).
    ParseName($Path).
    InvokeVerb('Delete')
}

function Get-PublicIP() {
    (Invoke-WebRequest ifconfig.me/ip).Content.Trim()
}

# Write-Host "$PSCommandPath execution time: $executionTime"
