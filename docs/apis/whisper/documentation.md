# Whisper (OpenAI) — Documentation Reference
**Source:** https://github.com/openai/whisper | https://platform.openai.com/docs/api-reference/audio
**Date:** 2026-03-01
**Version:** Local library: 20240930 (openai-whisper); OpenAI API model: whisper-1; faster-whisper: 1.1.x

## What It Is
Whisper is OpenAI's open-source speech recognition model trained on 680,000 hours of diverse multilingual audio. It handles multilingual transcription, speech-to-speech translation (to English), and language identification. Two usage modes exist: local inference via the `openai-whisper` Python package, and cloud inference via the OpenAI API endpoint.

## Install

**Local (openai-whisper):**
```bash
pip install -U openai-whisper
# also requires ffmpeg on PATH
# Ubuntu: sudo apt install ffmpeg
# macOS: brew install ffmpeg
# Windows: choco install ffmpeg
```

**Faster alternative (faster-whisper — 4x speed, less VRAM):**
```bash
pip install faster-whisper
# GPU support requires cuBLAS + cuDNN 9 (CUDA 12)
```

**OpenAI API client:**
```bash
pip install openai
```

## Key Concepts

- **Model sizes:** tiny (39M), base (74M), small (244M), medium (769M), large (1550M), turbo (809M). English-only variants (`.en` suffix) available for tiny–medium.
- **VRAM requirements:** tiny/base ~1 GB, small ~2 GB, medium ~5 GB, large ~10 GB, turbo ~6 GB.
- **Speed vs accuracy:** turbo is 8x faster than large with near-large accuracy; tiny is 10x faster but lowest accuracy.
- **Task types:** `transcribe` (default, output in source language) and `translate` (output always in English). Turbo does NOT support translation.
- **Language detection:** Whisper auto-detects language from the first 30 seconds of audio. You can override with the `language` parameter.
- **Word timestamps:** Available via `word_timestamps=True` in local API; via `timestamp_granularities[]=word` in OpenAI API.
- **Supported formats:** MP3, MP4, MPEG, MPGA, M4A, WAV, WEBM (OpenAI API); ffmpeg-decoded for local.
- **OpenAI API file size limit:** 25 MB per request.
- **faster-whisper:** Uses CTranslate2 backend, supports `int8` quantization, VAD filtering, batch inference. No ffmpeg dependency (uses PyAV).
- **Output formats:** `text`, `json`, `srt`, `tsv`, `vtt` (CLI); dict with `text`, `segments`, `language` (Python API).

## Common Patterns

**Local transcription (openai-whisper):**
```python
import whisper

model = whisper.load_model("turbo")  # or "base", "small", "medium", "large"
result = model.transcribe("audio.mp3")
print(result["text"])
# result["segments"] — list of dicts with start/end/text
# result["language"] — detected language code
```

**Local with word timestamps:**
```python
model = whisper.load_model("medium")
result = model.transcribe("audio.mp3", word_timestamps=True)
for segment in result["segments"]:
    for word in segment["words"]:
        print(f"{word['start']:.2f}s - {word['end']:.2f}s: {word['word']}")
```

**Language detection only:**
```python
model = whisper.load_model("base")
audio = whisper.load_audio("audio.mp3")
mel = whisper.log_mel_spectrogram(audio).to(model.device)
_, probs = model.detect_language(mel)
detected = max(probs, key=probs.get)
print(f"Detected language: {detected}")
```

**Translation to English:**
```python
model = whisper.load_model("medium")  # must be multilingual model, not turbo
result = model.transcribe("japanese.wav", task="translate", language="Japanese")
print(result["text"])  # English output
```

**CLI usage:**
```bash
whisper audio.mp3 --model turbo
whisper audio.mp3 --model medium --language Japanese --task translate
whisper audio.mp3 --model small --output_format srt --output_dir ./subtitles
```

**faster-whisper (recommended for production):**
```python
from faster_whisper import WhisperModel

model = WhisperModel("large-v3", device="cuda", compute_type="float16")
# CPU: device="cpu", compute_type="int8"

segments, info = model.transcribe("audio.mp3", beam_size=5, word_timestamps=True)
print(f"Detected language: {info.language} ({info.language_probability:.2f})")
for segment in segments:  # segments is a generator — iterating triggers processing
    print(f"[{segment.start:.2f}s -> {segment.end:.2f}s] {segment.text}")
    if segment.words:
        for word in segment.words:
            print(f"  {word.word}: {word.start:.2f}s - {word.end:.2f}s")
```

**faster-whisper with VAD filtering:**
```python
from faster_whisper import WhisperModel

model = WhisperModel("medium", device="cpu", compute_type="int8")
segments, info = model.transcribe(
    "audio.mp3",
    vad_filter=True,
    vad_parameters={"min_silence_duration_ms": 500}
)
```

**OpenAI API transcription:**
```python
from openai import OpenAI

client = OpenAI()  # uses OPENAI_API_KEY env var
with open("audio.mp3", "rb") as f:
    transcript = client.audio.transcriptions.create(
        model="whisper-1",
        file=f,
        response_format="json",  # or "text", "srt", "vtt", "verbose_json"
        language="en",            # optional ISO-639-1 code
    )
print(transcript.text)
```

**OpenAI API with word timestamps:**
```python
transcript = client.audio.transcriptions.create(
    model="whisper-1",
    file=open("audio.mp3", "rb"),
    response_format="verbose_json",
    timestamp_granularities=["word"]  # or ["segment"], or both
)
for word in transcript.words:
    print(f"{word.word}: {word.start:.2f}s - {word.end:.2f}s")
```

## Version Notes

- **turbo model** (added ~2024): 809M params, 8x speed of large, does NOT support translation tasks — use medium/large for translate.
- **faster-whisper large-v3** vs **large-v2**: v3 has improved accuracy on many languages.
- **whisper-timestamped** and **stable-ts** are third-party libraries that add more reliable word-level timestamps beyond the built-in `word_timestamps=True` (which can be imprecise).
- **OpenAI API only** offers `whisper-1` model — no model selection. Max 25 MB file.
- **faster-whisper BatchedInferencePipeline** available for high-throughput batch processing.
- Local `word_timestamps=True` is marked experimental and can occasionally produce misaligned timestamps.

## Key Links
- Official GitHub (openai-whisper): https://github.com/openai/whisper
- OpenAI Audio API docs: https://platform.openai.com/docs/api-reference/audio
- faster-whisper GitHub: https://github.com/SYSTRAN/faster-whisper
- whisper-timestamped: https://github.com/linto-ai/whisper-timestamped
- stable-ts: https://github.com/jianfch/stable-ts
- Model cards on HuggingFace: https://huggingface.co/openai/whisper-large-v3
