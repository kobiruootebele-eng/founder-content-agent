# 03-hook-generator.ps1
# Reads the hooks CSV library and uses Claude CLI to generate full platform content.
# Outputs: complete LinkedIn post, Twitter/X thread, video script, and newsletter.
# No API key required - uses your existing Claude Code session.

param (
    [string]$InsightsPath,
    [string]$HooksLibrary = "C:\founder-content-agent\hooks-library.csv",
    [string]$OutputDir    = "C:\founder-content-agent\outputs\hooks"
)

function Generate-Content {
    param ([string]$IPath)

    if (-not (Test-Path $IPath)) {
        Write-Error "[03] Insights file not found: $IPath"
        return $null
    }

    $insights = Get-Content -Path $IPath -Raw
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($IPath)
    $outFile  = Join-Path $OutputDir "$baseName.txt"

    # Load hooks library if available
    $hooksContext = ""
    if (Test-Path $HooksLibrary) {
        $csvRows = Import-Csv -Path $HooksLibrary
        $hooksFormatted = $csvRows | ForEach-Object {
            "[$($_.platform) | $($_.category)] $($_.hook)"
        }
        $hooksContext = "HOOKS LIBRARY (use these as opening lines or style models - pick the most relevant per platform):
" + ($hooksFormatted -join "`n")
    } else {
        Write-Host "[03] No hooks library found at $HooksLibrary - generating without it."
        $hooksContext = "No hooks library provided - generate your own strong opening hooks."
    }

    $prompt = "You are a world-class content writer for founder-led brands.
You write posts that feel personal, specific, and human. Not polished. Not corporate.
You use the hooks library as proven opening lines - pick the most fitting one per platform and build the full piece around it.

$hooksContext

---
INSIGHTS FROM THIS FOUNDER:
$insights
---

Using the insights above and the hooks library as a reference, write the following complete content pieces.
Each piece should feel like it came directly from this founder's story and voice.

============================================================
LINKEDIN POST (complete, ready to publish):
- Open with the most relevant hook from the library (adapt it to fit the specific story)
- 150 to 250 words total
- Short punchy paragraphs, 1-2 sentences each
- Tell a specific story or share a specific insight from the transcript
- End with a question or CTA that invites comments
- No hashtags

============================================================
TWITTER/X THREAD (complete, ready to publish):
- Tweet 1: hook (from library, adapted) - under 280 characters
- Tweets 2 to 7: body - each tweet is one idea, one sentence or two, under 280 characters
- Tweet 8: summary or CTA - under 280 characters
- Number each tweet: 1/ 2/ 3/ etc.

============================================================
SHORT-FORM VIDEO SCRIPT (complete, ready to record):
- Hook (first 3 seconds, spoken): 1-2 sentences from the library adapted to this story
- Body (30-45 seconds): 3-4 short punchy points from the insights, spoken naturally
- CTA (last 5 seconds): one clear ask - follow, share, comment, or visit a link
- Write it as it would be SPOKEN, not read. Contractions, natural pauses.
- Total script should be 60 to 90 seconds when spoken at a normal pace.

============================================================
NEWSLETTER (complete, ready to send):
- Subject line: pick the most fitting one from the library (adapt it)
- Preview text: 1 sentence teaser (shown in inbox before opening)
- Body:
    Intro (2-3 sentences): personal, sets up the story
    Section 1 - The story or situation: what happened, what you noticed
    Section 2 - The insight or lesson: what it means, why it matters
    Section 3 - The takeaway: one actionable thing the reader can do
    Sign-off: short, personal, first name only
- 300 to 450 words total
- Conversational tone, not corporate

Label each section with the header shown above in all caps."

    Write-Host "[03] Generating full content from: $([System.IO.Path]::GetFileName($IPath))"
    Write-Host "     (this may take 60-90 seconds)"

    try {
        $content = $prompt | claude -p
        if (-not $content) {
            Write-Error "[03] Claude returned no output."
            return $null
        }
        Set-Content -Path $outFile -Value $content -Encoding UTF8
        Write-Host "[03] Saved to: $outFile"
        return $outFile
    }
    catch {
        Write-Error "[03] Claude CLI error: $_"
        return $null
    }
}

return Generate-Content -IPath $InsightsPath
