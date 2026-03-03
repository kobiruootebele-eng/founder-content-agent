# Founder Content Agent

A local multi-agent pipeline that turns a founder transcript into platform-ready content hooks — LinkedIn posts, Twitter/X threads, newsletter intros, and video hooks.

---

## How It Works

```
inputs/your-transcript.txt
        │
        ▼
[00] Input Detector      ← detects file type
        │
        ▼
[01] Transcriber         ← reads your transcript
        │
        ▼
[02] Insight Extractor   ← pulls key insights, quotes, themes (via Claude)
        │
        ▼
[03] Hook Generator      ← writes LinkedIn / Twitter / Newsletter / Video hooks (via Claude)
        │
        ▼
[04] Content Packager    ← bundles everything into outputs/content/
```

---

## Requirements

- **Windows** (PowerShell 5.1+)
- **[Claude Code](https://claude.ai/code)** — installed and logged in
  - Install: `npm install -g @anthropic-ai/claude-code`
  - Login: `claude` (follow the prompts)

---

## Setup

**1. Clone the repo**
```bash
git clone https://github.com/kobiruootebele-eng/founder-content-agent.git
cd founder-content-agent
```

**2. Create the required folders**
```powershell
mkdir inputs
mkdir outputs\transcripts
mkdir outputs\insights
mkdir outputs\hooks
mkdir outputs\content
```

---

## Usage

**1. Add your transcript**

Drop a `.txt` file into the `inputs/` folder. This should be a plain text transcript of your founder recording.

> Audio/video files (.mp3, .mp4, etc.) are not directly processed. Export a transcript first using a free tool like [Descript](https://descript.com) or [Otter.ai](https://otter.ai), then drop the `.txt` into `inputs/`.

**2. Run the pipeline**

Open PowerShell and run:
```powershell
.\run.ps1
```

> Run this from inside a Claude Code terminal session so the pipeline can access Claude.

**3. Get your content**

When complete, find your packaged content in:
```
outputs/content/<your-file>_<timestamp>/
```

It will include your transcript, insights, and all generated hooks in one folder.

---

## Supported Input Formats

| Type | Extensions |
|------|-----------|
| Text | `.txt`, `.md`, `.vtt`, `.srt` |
| Audio* | `.mp3`, `.wav`, `.m4a`, `.ogg`, `.flac` |
| Video* | `.mp4`, `.mov`, `.mkv`, `.webm`, `.avi` |

*Audio/video files must be exported as `.txt` transcripts first.

---

## Output

For each run you get:
- `outputs/transcripts/` — cleaned transcript
- `outputs/insights/` — extracted key insights and quotes
- `outputs/hooks/` — LinkedIn, Twitter, Newsletter, and Video hooks
- `outputs/content/` — full bundled package with a `_SUMMARY.txt`
