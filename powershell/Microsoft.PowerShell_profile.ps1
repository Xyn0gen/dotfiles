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
    }
    else {
        Write-Host (" err") -ForegroundColor Yellow
    }
	Write-Host ("$") -NoNewline
    return " "
}
function which($name)
{
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function jpgtowebp() {
	[CmdletBinding(PositionalBinding=$False)]
    Param(
        [Alias("q")]
        [int]
        $quality = -1,
        
        [Alias("r")]
        [string]
        $resize = ""
    )
    if (-Not $resize -match "(^\d{1,4}x\d{1,4}[^A-Za-z0-9]*$)|(\d{1,2}%$)|(100%)") {
        $resize = ""
    }
    # $output = "original"
	New-Item -ItemType Directory -Force -Path .\$output | Out-Null
    if ($resize -eq "") {
        if ($quality -eq -1) {
            magick mogrify -strip -format webp -identify *.jpg
        } else {
            magick mogrify -strip -format webp -quality $quality -identify *.jpg
        } 
    } else {
        if ($quality -eq -1) {
            magick mogrify -strip -resize $resize -format webp -identify *.jpg
        } else {
            magick mogrify -strip -resize $resize -format webp -quality $quality -identify *.jpg
        }
    }
    # Get-Item *.jpg | Move-Item -Destination .\$output
    Get-ChildItem *.jpg | ForEach-Object {Recycle-Item $_.FullName}
}

function mergeAudio($video) {
    if (Test-Path($video)) {
        $output = (Get-Item $video).Name
        ffmpeg -i $video -filter_complex "[0:a:0][0:a:1]amerge=inputs=2[outa]" -c:v copy -c:a aac -map 0:v -map "[outa]" "merged_$output"
    } else {
        "$VideoInput is Invalid"
    }
}

function trim() {
    [CmdletBinding(PositionalBinding=$False)]
    Param(
        [Parameter(Mandatory, Position=0)]
        [Alias("i","input")]
        [string]
        $VideoInput,
        
        [Parameter(Mandatory)]
        [Alias("s")]
        [string]
        $start,
        
        [Alias("d")]
        [int]
        $duration,

        [Alias("vc")]
        [string]
        $vcodec = "hevc_nvenc",

        [Alias("p")]
        [string]
        $preset = "slow",

        [Alias("q")]
        [int]
        $qp = 23,
        
        [Parameter(Position=1)]
        [Alias("o")]
        [string]
        $output
    )
    
    if (Test-Path($VideoInput)) {
        $video_name = (Get-Item $VideoInput).Basename
        if ($duration -eq 0) {
            if ($output -eq "") {
                ffmpeg -hide_banner -ss $start -i "$VideoInput" -vcodec $vcodec -qp $qp -map 0 -preset $preset .\clips\trimmed_$video_name.mp4			
            } else {
                ffmpeg -hide_banner -ss $start -i "$VideoInput" -vcodec $vcodec -qp $qp -map 0 -preset $preset .\clips\$output.mp4
            }
        } else {
            if ($output -eq "") {
                ffmpeg -hide_banner -ss $start -t $duration -i "$VideoInput" -vcodec $vcodec -qp $qp -preset $preset -map 0 .\clips\trimmed_$video_name.mp4			
            } else {
                ffmpeg -hide_banner -ss $start -t $duration -i "$VideoInput" -vcodec $vcodec -qp $qp -preset $preset -map 0 .\clips\$output.mp4
            }
        }
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
    if ($extn -eq ".jpg") {
        magick identify -verbose $a | grep quality	
    }
    elseif ($extn -eq ".jpeg") {
        magick identify -verbose $a | grep quality
    }
    else {
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

# Write-Host "$PSCommandPath execution time: $executionTime"
