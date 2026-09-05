# Groq API — Use Cases & Practical Summary

**Date:** 2026-02-28
**Focus:** Audio transcription (whisper-large-v3-turbo) + general LLM inference

---

## What You Can Do

### Free Tier (no credit card)
- Transcribe audio files up to 25MB per file
- ~7,200 transcription requests per day (Whisper)
- ~14,400 LLM chat requests per day
- Access to all models (Whisper, Llama, Gemma, etc.)
- Hard cap at 429 error — no surprise charges

### Developer Tier (credit card required, pay-as-you-go)
- Transcribe audio files up to 100MB per file
- ~10x higher daily/minute limits vs free
- Access to Batch API (50% discount on all models)
- Prompt caching (50% discount on repeated inputs)

---

## Free vs Paid vs Complex Matrix

| Capability | Free | Paid | Complexity |
|------------|------|------|------------|
| Transcribe MP3/MP4/WAV/M4A | Yes | Yes | Easy |
| Get word-level timestamps | Yes | Yes | Easy |
| Translate non-English audio to English | Yes | Yes | Easy |
| Chat completions (Llama, Gemma, etc.) | Yes | Yes | Easy |
| Streaming responses | Yes | Yes | Easy |
| JSON/structured output | Yes | Yes | Medium |
| Function calling / tool use | Yes | Yes | Medium |
| 100MB+ audio files | No | Yes | Easy |
| Batch transcription (50% cheaper) | No | Yes | Medium |
| Compound models (web search + code exec) | Yes | Yes | Easy |
| Text-to-speech (PlayAI) | Yes | Yes | Easy |

---

## Practical Automation Ideas

| Use Case | Model | Cost | Notes |
|----------|-------|------|-------|
| Transcribe video course MP4s | whisper-large-v3-turbo | $0.04/hr audio | Replaces local Whisper, 164x real-time speed |
| Meeting/podcast transcription pipeline | whisper-large-v3-turbo | $0.04/hr audio | Fastest option, near-instant output |
| High-accuracy transcription (noisy audio) | whisper-large-v3 | $0.111/hr audio | Use when turbo fails on quality |
| English-only fast transcription | distil-whisper-large-v3-en | ~$0.02/hr audio | Fastest + cheapest for English |
| Translate foreign-language audio to English | whisper-large-v3 | $0.111/hr audio | Uses /audio/translations endpoint |
| Batch transcribe a full course library | whisper-large-v3-turbo + Batch API | $0.02/hr audio | 50% batch discount |
| AI-clean transcripts (remove filler words) | llama-3.1-8b-instant | $0.05/$0.08 per MTok | Very cheap for post-processing |
| Summarize transcripts into notes | llama-3.3-70b-versatile | $0.59/$0.79 per MTok | Better reasoning for summaries |
| Auto-chapter a long video transcript | llama-3.3-70b-versatile | $0.59/$0.79 per MTok | Use structured output for JSON chapters |
| Notion page builder from transcript | llama-3.1-8b-instant | $0.05/$0.08 per MTok | Already done in mega-transcriber project |
| Voice assistant (STT + LLM + TTS loop) | whisper + llama + playai-tts | Variable | Real-time pipeline possible |
| Real-time live transcription via streaming | whisper-large-v3-turbo | $0.04/hr | Stream chunks as audio comes in |
| Multilingual subtitle generation | whisper-large-v3 | $0.111/hr | Set language param, get verbose_json |
| Customer call analysis + sentiment | whisper + llama-3.3-70b | ~$0.05–0.15/hr | Transcribe then analyze |

---

## Audio Transcription Focus: whisper-large-v3-turbo

This is the primary model for the mega-transcriber project.

**Why use it over local Whisper:**
- 164x real-time speed (local Whisper on CPU is slow)
- No GPU required on your machine
- $0.04/hour = roughly $0.0007 per minute of audio — extremely cheap
- No segfault issues (runs in Groq's cloud, not locally)

**Request flow:**
1. Open MP4/MP3 file
2. POST to `https://api.groq.com/openai/v1/audio/transcriptions`
3. Set `model=whisper-large-v3-turbo`, `response_format=verbose_json`
4. Get back full text + word/segment timestamps in ~1-2 seconds

**Python snippet for mega-transcriber:**
```python
from groq import Groq
import os

client = Groq(api_key=os.environ["GROQ_API_KEY"])

def transcribe_file(filepath: str, language: str = "en") -> dict:
    with open(filepath, "rb") as f:
        filename = os.path.basename(filepath)
        result = client.audio.transcriptions.create(
            file=(filename, f.read()),
            model="whisper-large-v3-turbo",
            language=language,
            response_format="verbose_json",
            timestamp_granularities=["segment"],
            temperature=0.0
        )
    return {
        "text": result.text,
        "duration": result.duration,
        "segments": result.segments
    }
```

---

## Key Limits and Gotchas

| Limit | Value | Notes |
|-------|-------|-------|
| Max file size (free) | 25MB | ~15-25 min of MP3 at typical bitrate |
| Max file size (dev tier) | 100MB | ~60-90 min of MP3 |
| Rate limit on 429 | Hard stop | No charge, but you must retry — use exponential backoff |
| Streaming + Structured Output | Not supported together | Pick one |
| Translation target | English only | /audio/translations always outputs English |
| Downsampling | Auto 16KHz mono | You don't need to pre-process audio |
| Timestamp granularities | Requires verbose_json | Will error if you set timestamps without verbose_json |
| Free tier audio requests/day | ~7,200 | Shared across all Whisper models |
| Batch API turnaround | Up to 24 hours | Not real-time, but half the price |
| Prompt caching | Exact match only | Must send identical prefix to get 50% discount |
| Compound-beta web search | Non-deterministic | Can hallucinate search results; validate outputs |
| File formats | mp3, mp4, mpeg, mpga, m4a, wav, webm | No flac, ogg, or opus |

---

## Scripts and Tools Already Available

| Tool | Description | Link |
|------|-------------|------|
| `mega-transcriber/` | Full pipeline: download Mega.nz → transcribe → clean → Notion upload | Local project |
| `groq` Python SDK | Official SDK with full API coverage | `pip install groq` |
| `groq-sdk` npm | Official Node.js SDK | `npm install groq-sdk` |
| `llm-groq-whisper` | Simon Willison's LLM plugin for Groq Whisper | https://github.com/simonw/llm-groq-whisper |
| `groq_whisperer` | Background script that transcribes into any active app | https://github.com/KennyVaneetvelde/groq_whisperer |
| `groq-api-cookbook` | Official examples: tool use, structured output, audio, vision | https://github.com/groq/groq-api-cookbook |

---

## Migration from Local Whisper to Groq (mega-transcriber)

The current mega-transcriber uses local Whisper (causing segfaults). Switching to Groq API:

1. Add `GROQ_API_KEY` to `.env`
2. Replace `whisper.load_model()` + `model.transcribe()` calls with `client.audio.transcriptions.create()`
3. Remove `whisper` and `torch` dependencies entirely
4. Results are identical (same underlying Whisper model), but ~164x faster and no local GPU/memory issues
5. Cost for 59 MP4 files (assume ~60 min each = ~60 hours total): ~$2.40 at $0.04/hr
