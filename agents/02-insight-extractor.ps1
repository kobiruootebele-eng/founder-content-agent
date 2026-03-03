# 02-insight-extractor.ps1
# Uses the Claude CLI to extract insights from a transcript.
# No API key required - uses your existing Claude Code session.

param (
    [string]$TranscriptPath,
    [string]$OutputDir = "C:\founder-content-agent\outputs\insights"
)

function Extract-Insights {
    param ([string]$TxPath)

    if (-not (Test-Path $TxPath)) {
        Write-Error "[02] Transcript file not found: $TxPath"
        return $null
    }

    $transcript = Get-Content -Path $TxPath -Raw
    $baseName   = [System.IO.Path]::GetFileNameWithoutExtension($TxPath)
    $outFile    = Join-Path $OutputDir "$baseName.txt"

    $prompt = "You are a content strategist specializing in founder and entrepreneur stories.

Analyze the transcript below and extract the following. Use each header exactly as written in ALL CAPS.

KEY INSIGHTS:
5 to 7 bullet points covering the most important lessons, mindset shifts, or contrarian takes.

MEMORABLE QUOTES:
3 to 5 powerful standalone sentences worth sharing verbatim, exactly as spoken.

CORE THEMES:
3 to 5 recurring topics, philosophies, or values running through the conversation.

FOUNDER STORY MOMENTS:
Specific struggles, pivots, failures, or wins mentioned with enough detail to be retold.

UNDERLYING BELIEF:
The single core worldview or conviction that drives this founder, in one or two sentences.

Transcript:
---
$transcript
---"

    Write-Host "[02] Extracting insights from: $([System.IO.Path]::GetFileName($TxPath))"
    Write-Host "     (this may take 30-60 seconds)"

    try {
        $insights = $prompt | claude -p
        if (-not $insights) {
            Write-Error "[02] Claude returned no output."
            return $null
        }
        Set-Content -Path $outFile -Value $insights -Encoding UTF8
        Write-Host "[02] Saved to: $outFile"
        return $outFile
    }
    catch {
        Write-Error "[02] Claude CLI error: $_"
        return $null
    }
}

return Extract-Insights -TxPath $TranscriptPath
