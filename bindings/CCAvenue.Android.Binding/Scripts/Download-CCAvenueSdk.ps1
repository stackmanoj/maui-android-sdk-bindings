<#
.SYNOPSIS
Downloads the CCAvenue Android SDK AAR from the private GitHub Packages Maven repository.

.DESCRIPTION
Credentials are read from CCAVENUE_MAVEN_USERNAME and CCAVENUE_MAVEN_PASSWORD when set.
If either value is missing, the script prompts for it. The password/token is not written
to this repository.

.EXAMPLE
$env:CCAVENUE_MAVEN_USERNAME = "your-username"
$env:CCAVENUE_MAVEN_PASSWORD = "your-password-or-token"
.\Scripts\Download-CCAvenueSdk.ps1

.EXAMPLE
.\Scripts\Download-CCAvenueSdk.ps1 -Version 2.1.4
#>

param(
    [string]$Version = "2.1.4",
    [string]$Username = $env:CCAVENUE_MAVEN_USERNAME,
    [string]$Password = $env:CCAVENUE_MAVEN_PASSWORD,
    [string]$RepositoryUrl = "https://maven.pkg.github.com/InfibeamAvenues/CCAvenue_SDK_2.0",
    [string]$OutputDirectory = "",
    [switch]$SkipPom
)

$ErrorActionPreference = "Stop"

function Get-PlainTextPassword {
    param([string]$ExistingPassword)

    if (-not [string]::IsNullOrWhiteSpace($ExistingPassword)) {
        return $ExistingPassword
    }

    $securePassword = Read-Host "CCAvenue Maven password/token" -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    }
    finally {
        if ($bstr -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
}

if ([string]::IsNullOrWhiteSpace($Username)) {
    $Username = Read-Host "CCAvenue Maven username"
}

$Password = Get-PlainTextPassword $Password

if ([string]::IsNullOrWhiteSpace($Username) -or [string]::IsNullOrWhiteSpace($Password)) {
    throw "Username and password/token are required."
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Resolve-Path (Join-Path $scriptRoot "..")

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $projectRoot "Jars\Maven"
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

$artifactBasePath = "com/ccavenue/indiasdk/sdk/$Version"
$artifactBaseName = "sdk-$Version"
$repository = $RepositoryUrl.TrimEnd("/")

$authBytes = [Text.Encoding]::UTF8.GetBytes("${Username}:${Password}")
$headers = @{
    Authorization = "Basic " + [Convert]::ToBase64String($authBytes)
    Accept = "application/octet-stream"
}

function Download-MavenFile {
    param(
        [string]$Extension,
        [string]$Accept = "application/octet-stream"
    )

    $url = "$repository/$artifactBasePath/$artifactBaseName.$Extension"
    $destination = Join-Path $OutputDirectory "$artifactBaseName.$Extension"
    $temporaryDestination = "$destination.download"
    $requestHeaders = $headers.Clone()
    $requestHeaders["Accept"] = $Accept

    Write-Host "Downloading $url"
    Invoke-WebRequest -Uri $url -Headers $requestHeaders -OutFile $temporaryDestination
    Move-Item -LiteralPath $temporaryDestination -Destination $destination -Force

    $file = Get-Item -LiteralPath $destination
    Write-Host "Saved $($file.FullName) ($($file.Length) bytes)"
}

try {
    Download-MavenFile -Extension "aar"

    if (-not $SkipPom) {
        Download-MavenFile -Extension "pom" -Accept "application/xml"
    }
}
finally {
    $Password = $null
    $headers = $null
}
