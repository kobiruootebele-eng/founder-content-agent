# 04-content-packager.ps1
# Bundles transcript, insights, and hooks into a dated content package folder.
# Also generates a master summary file for easy review.

param (
    [hashtable]$InputMeta,
    [string]$TranscriptPath,
    [string]$InsightsPath,
    [string]$HooksPath,
    [string]$OutputDir = "C:\founder-content-agent\outputs\content"
)

function Package-Content {
    param (
        [hashtable]$Meta,
        [string]$TxPath,
        [string]$InPath,
        [string]$HkPath
    )

    $timestamp  = Get-Date -Format "yyyy-MM-dd_HHmm"
    $packageDir = Join-Path $OutputDir "$($Meta.Name)_$timestamp"
    New-Item -ItemType Directory -Path $packageDir -Force | Out-Null

    # Copy source files into package
    $files = @{
        "transcript.txt" = $TxPath
        "insights.txt"   = $InPath
        "content.txt"    = $HkPath
    }

    foreach ($entry in $files.GetEnumerator()) {
        if ($entry.Value -and (Test-Path $entry.Value)) {
            Copy-Item -Path $entry.Value -Destination (Join-Path $packageDir $entry.Key)
        }
    }

    # Build master summary
    $separator = "`n" + ("=" * 60) + "`n"

    $summary = @"
FOUNDER CONTENT PACKAGE
Generated : $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Source    : $($Meta.Name)$($Meta.Extension)
Type      : $($Meta.Type)
Size      : $($Meta.SizeKB) KB

$separator
TRANSCRIPT
$separator
$(if ($TxPath -and (Test-Path $TxPath)) { Get-Content $TxPath -Raw } else { "[not available]" })

$separator
INSIGHTS
$separator
$(if ($InPath -and (Test-Path $InPath)) { Get-Content $InPath -Raw } else { "[not available]" })

$separator
CONTENT (LinkedIn / Twitter Thread / Video Script / Newsletter)
$separator
$(if ($HkPath -and (Test-Path $HkPath)) { Get-Content $HkPath -Raw } else { "[not available]" })
"@

    $summaryFile = Join-Path $packageDir "_SUMMARY.txt"
    Set-Content -Path $summaryFile -Value $summary -Encoding UTF8

    Write-Host "[04] Package created: $packageDir"
    Write-Host "[04] Files:"
    Get-ChildItem $packageDir | ForEach-Object { Write-Host "     - $($_.Name)" }

    return $packageDir
}

return Package-Content -Meta $InputMeta -TxPath $TranscriptPath -InPath $InsightsPath -HkPath $HooksPath
