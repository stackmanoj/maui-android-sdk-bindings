<#
.SYNOPSIS
Patches resource metadata inside the downloaded CCAvenue SDK AAR.

.DESCRIPTION
CCAvenue SDK 2.1.4 ships string resources with multiple non-positional printf
placeholders. Android resource compilation rejects those unless the strings are
marked as non-formatted. This script updates the downloaded AAR in-place and
keeps a backup beside it.
#>

param(
    [string]$AarPath = ""
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Resolve-Path (Join-Path $scriptRoot "..")
$workspaceRoot = Resolve-Path (Join-Path $projectRoot "..\..")

if ([string]::IsNullOrWhiteSpace($AarPath)) {
    $AarPath = Join-Path $projectRoot "Jars\Maven\sdk-2.1.4.aar"
}

$resolvedAar = Resolve-Path -LiteralPath $AarPath
if (-not $resolvedAar.Path.StartsWith($workspaceRoot.Path, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to patch outside the repository: $($resolvedAar.Path)"
}

$backupPath = "$($resolvedAar.Path).original"
if (-not (Test-Path -LiteralPath $backupPath)) {
    Copy-Item -LiteralPath $resolvedAar.Path -Destination $backupPath
}
else {
    Copy-Item -LiteralPath $backupPath -Destination $resolvedAar.Path -Force
}

$work = Join-Path ([IO.Path]::GetTempPath()) ("ccavenue-aar-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $work -Force | Out-Null

try {
    $zipPath = Join-Path $work "sdk.zip"
    Copy-Item -LiteralPath $resolvedAar.Path -Destination $zipPath -Force
    Expand-Archive -LiteralPath $zipPath -DestinationPath $work -Force
    Remove-Item -LiteralPath $zipPath -Force

    $stringNames = @(
        "cc_avenues_emi_discount_note",
        "cc_avenues_txt_processing_fee_note"
    )

    Get-ChildItem -LiteralPath (Join-Path $work "res") -Recurse -Filter "*.xml" | ForEach-Object {
        $content = Get-Content -LiteralPath $_.FullName -Raw
        $updated = $content

        foreach ($stringName in $stringNames) {
            $pattern = "(<string\s+name=`"$([regex]::Escape($stringName))`")(?![^>]*\sformatted=)"
            $updated = [regex]::Replace($updated, $pattern, '$1 formatted="false"')
        }

        if ($updated -ne $content) {
            Set-Content -LiteralPath $_.FullName -Value $updated -NoNewline -Encoding UTF8
            Write-Host "Patched $($_.FullName)"
        }
    }

    $patchedAar = Join-Path ([IO.Path]::GetTempPath()) ("sdk-2.1.4-patched-" + [Guid]::NewGuid().ToString("N") + ".aar")
    Push-Location $work
    try {
        & jar cf $patchedAar .
        if ($LASTEXITCODE -ne 0) {
            throw "jar failed with exit code $LASTEXITCODE."
        }
    }
    finally {
        Pop-Location
    }

    Move-Item -LiteralPath $patchedAar -Destination $resolvedAar.Path -Force
}
finally {
    if (Test-Path -LiteralPath $work) {
        Remove-Item -LiteralPath $work -Recurse -Force
    }
}
