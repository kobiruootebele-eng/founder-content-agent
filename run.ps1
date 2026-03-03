# run.ps1 - Founder Content Agent Orchestrator
# Usage: .\run.ps1
# Drop a .txt transcript into inputs\ then run this script.
# No API keys required - uses your Claude Code session via: claude -p

$ErrorActionPreference = "Stop"
$base   = "C:\founder-content-agent"
$agents = "$base\agents"

Write-Host ""
Write-Host "============================================"
Write-Host "  FOUNDER CONTENT AGENT - starting pipeline"
Write-Host "============================================"
Write-Host ""

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Error "Claude CLI not found. Run this script from the Claude Code terminal."
    exit 1
}

# Allow claude -p to run from inside a Claude Code session
Remove-Item Env:\CLAUDECODE -ErrorAction SilentlyContinue

Write-Host "[ STEP 0 ] Detecting input file..."
$inputMeta = & "$agents\00-input-detector.ps1" -InputDir "$base\inputs"

if (-not $inputMeta) {
    Write-Host ""
    Write-Host "No input found. Drop a .txt file into: $base\inputs"
    exit 0
}

Write-Host ""
Write-Host "[ STEP 1 ] Reading transcript..."
$transcriptPath = & "$agents\01-transcriber.ps1" -InputMeta $inputMeta -OutputDir "$base\outputs\transcripts"

if (-not $transcriptPath) {
    Write-Error "Step 1 failed. Check errors above."
    exit 1
}
Write-Host ""

Write-Host "[ STEP 2 ] Extracting insights..."
$insightsPath = & "$agents\02-insight-extractor.ps1" -TranscriptPath $transcriptPath -OutputDir "$base\outputs\insights"

if (-not $insightsPath) {
    Write-Error "Step 2 failed. Check errors above."
    exit 1
}
Write-Host ""

Write-Host "[ STEP 3 ] Generating hooks..."
$hooksPath = & "$agents\03-hook-generator.ps1" -InsightsPath $insightsPath -OutputDir "$base\outputs\hooks"

if (-not $hooksPath) {
    Write-Error "Step 3 failed. Check errors above."
    exit 1
}
Write-Host ""

Write-Host "[ STEP 4 ] Packaging content..."
$packageDir = & "$agents\04-content-packager.ps1" `
    -InputMeta      $inputMeta `
    -TranscriptPath $transcriptPath `
    -InsightsPath   $insightsPath `
    -HooksPath      $hooksPath `
    -OutputDir      "$base\outputs\content"

Write-Host ""
Write-Host "============================================"
Write-Host "  DONE - content package ready"
Write-Host "  $packageDir"
Write-Host "============================================"
Write-Host ""
