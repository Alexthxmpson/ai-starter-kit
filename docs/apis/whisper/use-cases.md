# Whisper (OpenAI) — Use Cases

## What You Can Do
- Transcribe audio files in 99+ languages to text
- Auto-detect the spoken language from audio
- Translate foreign-language audio directly to English text
- Generate SRT/VTT subtitle files from video/audio
- Extract word-level timestamps for karaoke-style highlighting or alignment
- Run locally (free, private) or via OpenAI API (paid, no GPU required)
- Filter silence with VAD to speed up transcription of sparse audio
- Batch-process large audio archives in parallel
- Transcribe meeting recordings, podcasts, lectures, interviews
- Feed transcripts into LLMs for summarization, Q&A, or structured extraction

## Practical Automation Ideas

| Use Case | Complexity | Description |
|---|---|---|
| Podcast transcription pipeline | Easy | Auto-transcribe new podcast episodes, save to Markdown/Notion |
| Meeting notes bot | Easy | Record meeting audio, transcribe with Whisper, summarize with Claude |
| Subtitle generator | Easy | Convert video files to .srt subtitles using whisper CLI |
| Multi-language lecture notes | Medium | Detect language, transcribe, translate non-English lectures to English |
| YouTube auto-captions replacement | Medium | Download audio with yt-dlp, transcribe with faster-whisper, burn in subtitles |
| Voice journal to structured notes | Medium | Daily voice memos → transcribe → Claude extracts action items |
| Customer call analytics | Medium | Transcribe support calls, extract sentiment and topics with LLM |
| Searchable audio archive | Medium | Transcribe + index audio library into vector DB for semantic search |
| Real-time transcription (streaming) | Complex | Chunk live audio every 30s, transcribe sequentially with overlap |
| Word-level karaoke sync | Complex | Extract word timestamps, align to audio waveform for LRC/karaoke files |
| Speaker diarization pipeline | Complex | Combine faster-whisper + pyannote.audio for who-said-what transcripts |
| Batch course transcription | Complex | Process 50+ video lessons in parallel (Groq API or faster-whisper workers) |

## Key Limits & Gotchas
- **OpenAI API file limit:** 25 MB per request — must chunk longer files
- **OpenAI API cost:** ~$0.006/minute (whisper-1)
- **turbo model cannot translate** — only transcribes. Use medium or large for `task="translate"`
- **Local `word_timestamps=True` is experimental** — timestamps can drift; use whisper-timestamped or stable-ts for accuracy
- **faster-whisper `transcribe()` returns a generator** — the generator is lazy; you must iterate it to process audio
- **GPU memory:** large-v3 needs ~10 GB VRAM. Use medium (5 GB) or turbo (6 GB) if constrained
- **faster-whisper GPU:** requires NVIDIA cuBLAS + cuDNN 9 — not available on all machines
- **Language detection** uses only the first 30 seconds of audio — misleading for mixed-language content
- **Hallucinations on silence:** Whisper sometimes generates phantom text for silent segments — use `vad_filter=True` to mitigate
- **English `.en` models** are slightly more accurate for English-only tasks and smaller
- **No streaming API** in OpenAI official client — full file required upfront
