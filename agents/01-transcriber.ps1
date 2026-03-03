# 01-transcriber.ps1
# Reads .txt/.md transcript files directly.
# For audio/video: export a transcript as .txt first (Descript, Otter.ai, etc.)

param (
    [hashtable]$InputMeta,
    [string]$OutputDir = "C:\founder-content-agent\outputs\transcripts"
)

function Transcribe-Input {
    param ([hashtable]$Meta)

    $outFile = Join-Path $OutputDir "$($Meta.Name).txt"

    if ($Meta.Type -eq "audio" -or $Meta.Type -eq "video") {
        Write-Host "[01] Audio/video files are not supported in no-API mode."
        Write-Host "     Export your transcript as a .txt file and drop that into inputs\ instead."
        Write-Host "     Free tools: Descript (descript.com), Otter.ai, YouTube auto-captions."
        return $null
    }

    Write-Host "[01] Reading: $($Meta.Name)$($Meta.Extension)"
    $content = Get-Content -Path $Meta.Path -Raw
    Set-Content -Path $outFile -Value $content -Encoding UTF8
    Write-Host "[01] Saved to: $outFile"
    return $outFile
}

return Transcribe-Input -Meta $InputMeta
