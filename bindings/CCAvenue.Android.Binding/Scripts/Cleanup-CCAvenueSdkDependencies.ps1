<#
.SYNOPSIS
Keeps only the CCAvenue Maven artifacts that are not covered by NuGet.

.DESCRIPTION
The dependency downloader can fetch many transitive artifacts that are already
provided by Xamarin/.NET Android NuGet packages, plus test-only artifacts from
published POMs. This script removes those extra files and keeps the small set
of raw Maven AAR/JAR files that still need local review.
#>

param(
    [string]$DependencyDirectory = ""
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Resolve-Path (Join-Path $scriptRoot "..")

if ([string]::IsNullOrWhiteSpace($DependencyDirectory)) {
    $DependencyDirectory = Join-Path $projectRoot "Jars\Maven\Dependencies"
}

$artifactDirectory = Resolve-Path (Join-Path $DependencyDirectory "artifacts")
$pomDirectory = Resolve-Path (Join-Path $DependencyDirectory "poms")
$workspaceRoot = Resolve-Path (Join-Path $projectRoot "..\..")

foreach ($directory in @($artifactDirectory, $pomDirectory)) {
    if (-not $directory.Path.StartsWith($workspaceRoot.Path, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to clean outside the repository: $($directory.Path)"
    }
}

$keepArtifacts = @(
    "com.squareup.okhttp3.logging-interceptor-5.3.0.jar",
    "com.squareup.okhttp3.okhttp-5.3.0.jar",
    "com.squareup.okhttp3.okhttp-jvm-5.3.0.jar",
    "com.squareup.okio.okio-3.16.2.jar",
    "com.squareup.okio.okio-jvm-3.16.2.jar",
    "io.coil-kt.coil-2.6.0.aar",
    "io.coil-kt.coil-base-2.6.0.aar",
    "io.coil-kt.coil-gif-2.6.0.aar",
    "io.coil-kt.coil-svg-2.6.0.aar",
    "com.caverock.androidsvg-aar-1.4.aar",
    "in.uvik.displaycardinfo-sdk-0.0.3.aar",
    "com.github.devnied.emvnfccard.library-3.0.1.jar"
)

$keepPoms = $keepArtifacts |
    ForEach-Object { [IO.Path]::ChangeExtension($_, ".pom") }

foreach ($directoryAndKeepSet in @(
    @{ Directory = $artifactDirectory.Path; Keep = $keepArtifacts },
    @{ Directory = $pomDirectory.Path; Keep = $keepPoms }
)) {
    $removed = 0
    $kept = 0

    Get-ChildItem -LiteralPath $directoryAndKeepSet.Directory -File | ForEach-Object {
        if ($directoryAndKeepSet.Keep -contains $_.Name) {
            $kept++
            return
        }

        Remove-Item -LiteralPath $_.FullName -Force
        $removed++
    }

    Write-Host "Cleaned $($directoryAndKeepSet.Directory)"
    Write-Host "  Kept: $kept"
    Write-Host "  Removed: $removed"
}

