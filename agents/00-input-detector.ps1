# 00-input-detector.ps1
# Scans inputs/ folder, detects file type, returns metadata hashtable for the pipeline.

param (
    [string]$InputDir = "C:\founder-content-agent\inputs"
)

$supportedAudio = @(".mp3", ".wav", ".m4a", ".ogg", ".flac")
$supportedVideo = @(".mp4", ".mov", ".mkv", ".webm", ".avi")
$supportedText  = @(".txt", ".md", ".vtt", ".srt")
$allSupported   = $supportedAudio + $supportedVideo + $supportedText

function Detect-InputFile {
    param ([string]$Dir)

    $files = Get-ChildItem -Path $Dir -File |
             Where-Object { $allSupported -contains $_.Extension.ToLower() } |
             Sort-Object LastWriteTime

    if ($files.Count -eq 0) {
        Write-Host "[00] No supported input files found in: $Dir"
        return $null
    }

    $file = $files[0]
    $ext  = $file.Extension.ToLower()

    $type = if     ($supportedAudio -contains $ext) { "audio" }
            elseif ($supportedVideo -contains $ext) { "video" }
            else                                    { "text"  }

    $meta = @{
        Path      = $file.FullName
        Name      = $file.BaseName
        Extension = $ext
        Type      = $type
        SizeKB    = [math]::Round($file.Length / 1KB, 2)
        Detected  = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    }

    Write-Host "[00] Detected : $($meta.Name)$ext"
    Write-Host "     Type     : $type"
    Write-Host "     Size     : $($meta.SizeKB) KB"
    return $meta
}

return Detect-InputFile -Dir $InputDir
