# Founder Content Agent — Pipeline Design

## Overview

A local multi-agent PowerShell pipeline that turns a raw founder recording or
transcript into platform-ready content hooks and a packaged content bundle.

```
inputs/
  └── your-file.mp3 (or .mp4, .txt, .md, etc.)
         │
         ▼
  [00] Input Detector        ← detects file type & metadata
         │
         ▼
  [01] Transcriber           ← Whisper API (audio/video) or direct read (text)
         │ outputs/transcripts/<name>.txt
         ▼
  [02] Insight Extractor     ← Claude API → key insights, quotes, themes
         │ outputs/insights/<name>.txt
         ▼
  [03] Hook Generator        ← Claude API → LinkedIn / Twitter / Video / Newsletter hooks
         │ outputs/hooks/<name>.txt
         ▼
  [04] Content Packager      ← bundles all files + master _SUMMARY.txt
         │ outputs/content/<name>_<timestamp>/
         ▼
         DONE
```

---

## Setup

### 1. Set API keys (run once per session, or add to your PowerShell profile)

```powershell
$env:ANTHROPIC_API_KEY = "sk-ant-..."   # Required — for insight + hook agents
$env:OPENAI_API_KEY    = "sk-..."       # Required only for audio/video input
```

To persist across sessions, add to your PowerShell profile:
```powershell
notepad $PROFILE
```

### 2. Drop a file into `inputs/`

Supported formats:
| Type  | Extensions                        |
|-------|-----------------------------------|
| Audio | .mp3 .wav .m4a .ogg .flac         |
| Video | .mp4 .mov .mkv .webm .avi         |
| Text  | .txt .md .vtt .srt                |

### 3. Run the pipeline

```powershell
cd C:\founder-content-agent
.\run.ps1
```

---

## Agents

### `00-input-detector.ps1`
- Scans `inputs/` for the oldest unprocessed file
- Returns a metadata hashtable: `Path`, `Name`, `Extension`, `Type`, `SizeKB`
- No API calls

### `01-transcriber.ps1`
- **Text files**: reads content directly, saves as-is to `outputs/transcripts/`
- **Audio/Video**: calls `OpenAI Whisper API` (`whisper-1` model) via multipart POST
- Output: `outputs/transcripts/<name>.txt`

### `02-insight-extractor.ps1`
- Calls `Claude claude-sonnet-4-6` with a structured prompt
- Extracts: Key Insights, Memorable Quotes, Core Themes, Founder Story Moments, Underlying Belief
- Output: `outputs/insights/<name>.txt`

### `03-hook-generator.ps1`
- Calls `Claude claude-sonnet-4-6` with the insights as input
- Generates hooks for: LinkedIn (3), Twitter/X Thread (3), Short-Form Video (3), Newsletter Subject Lines (5)
- Output: `outputs/hooks/<name>.txt`

### `04-content-packager.ps1`
- Creates a timestamped folder under `outputs/content/`
- Copies `transcript.txt`, `insights.txt`, `hooks.txt` into it
- Generates `_SUMMARY.txt` — a single file with all content combined for easy review/copy-paste

---

## Output Structure

After a successful run on a file named `interview.mp3`:

```
outputs/
  transcripts/
    interview.txt
  insights/
    interview.txt
  hooks/
    interview.txt
  content/
    interview_2026-03-02_0916/
      transcript.txt
      insights.txt
      hooks.txt
      _SUMMARY.txt          ← open this for the full content package
```

---

## Extending the Pipeline

| Add-on idea                  | Where to plug in                          |
|------------------------------|-------------------------------------------|
| Auto-post to LinkedIn        | After `04`, call LinkedIn API             |
| Schedule for Twitter          | After `04`, call Buffer or Typefully API  |
| Watch folder (run on drop)   | Wrap `run.ps1` in a `FileSystemWatcher`   |
| Multiple input files         | Loop `run.ps1` over all files in `inputs/`|
| Custom Claude prompts        | Edit system/user prompts in `02` and `03` |
| Notion/Airtable output       | Add a `05-publisher.ps1` agent            |

---

## Cost Estimates (approximate)

| Step        | Model         | Tokens (typical) | Cost/run   |
|-------------|---------------|-----------------|------------|
| Transcribe  | Whisper-1     | ~5 min audio    | ~$0.05     |
| Insights    | claude-sonnet-4-6 | ~3k in / 2k out | ~$0.03  |
| Hooks       | claude-sonnet-4-6 | ~2k in / 2k out | ~$0.02  |
| **Total**   |               |                 | **~$0.10** |

---

## Troubleshooting

| Error                              | Fix                                                        |
|------------------------------------|------------------------------------------------------------|
| `ANTHROPIC_API_KEY not set`        | Set `$env:ANTHROPIC_API_KEY` in your terminal              |
| `OPENAI_API_KEY not set`           | Set `$env:OPENAI_API_KEY` (only needed for audio/video)    |
| `No supported input files found`   | Check file extension is in the supported list              |
| `Whisper API error: 400`           | File may be too large (>25MB) — compress or split it first |
| `Claude API error: 401`            | API key is wrong or expired                                |
