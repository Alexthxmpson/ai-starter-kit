# ElevenLabs — Full Technical Documentation

**Source:** https://elevenlabs.io/docs/api-reference
**Last Updated:** 2026-02-28

---

## Overview

ElevenLabs is an AI voice generation platform. It converts text to speech using AI-generated or cloned voices with high quality and naturalness.

---

## Authentication

```
Header: xi-api-key: YOUR_API_KEY
```
Environment variable: `ELEVENLABS_API_KEY`

Base URL: `https://api.elevenlabs.io/v1`

---

## Core Endpoints

### Text-to-Speech

#### Generate Speech (Stream or Download)
```
POST /text-to-speech/{voice_id}

Body: {
  text: "Text to convert to speech",
  model_id: "eleven_multilingual_v2",
  voice_settings: {
    stability: 0.5,
    similarity_boost: 0.75,
    style: 0.0,
    use_speaker_boost: true
  }
}

Response: Binary audio stream (MP3 by default)
Query params: output_format=mp3_44100_128|pcm_16000|ulaw_8000
```

#### Stream Speech (Real-time)
```
POST /text-to-speech/{voice_id}/stream
Same body as above
Response: Streaming audio chunks
```

#### With Timestamps
```
POST /text-to-speech/{voice_id}/with-timestamps
Response: { audio_base64: "...", alignment: { characters, character_start_times_seconds, character_end_times_seconds } }
```

---

### Voices

#### List All Voices
```
GET /voices
Response: {
  voices: [{
    voice_id: "21m00Tcm4TlvDq8ikWAM",
    name: "Rachel",
    category: "premade",
    labels: { accent: "american", description: "calm", ... },
    preview_url: "https://...",
    settings: { stability: 0.75, similarity_boost: 0.75 }
  }]
}
```

#### Get Voice
```
GET /voices/{voice_id}
```

#### Get Voice Settings
```
GET /voices/{voice_id}/settings
```

#### Update Voice Settings
```
POST /voices/{voice_id}/settings/edit
Body: { stability: 0.5, similarity_boost: 0.75 }
```

#### Clone a Voice (from audio samples)
```
POST /voices/add
Body: multipart/form-data
  name: "My Cloned Voice"
  description: "Voice cloned from recordings"
  files: [audio_file_1.mp3, audio_file_2.mp3]  (min 1, ideal 10-30 samples)
  labels: {"language": "nl", "accent": "dutch"}
```

#### Delete Voice
```
DELETE /voices/{voice_id}
```

---

### Models

```
GET /models
Response: [{
  model_id: "eleven_multilingual_v2",
  name: "Eleven Multilingual v2",
  description: "...",
  languages: [{ language_id: "en", name: "English" }, ...],
  can_be_finetuned: true,
  can_do_text_to_speech: true,
  can_do_voice_conversion: true,
  max_characters_request_free_user: 2000,
  max_characters_request_subscribed_user: 5000
}]
```

#### Available Models
| Model ID | Description |
|----------|-------------|
| `eleven_multilingual_v2` | Best quality, 29 languages |
| `eleven_turbo_v2` | Fastest, lowest latency |
| `eleven_turbo_v2_5` | Turbo with multilingual |
| `eleven_monolingual_v1` | English only, legacy |
| `eleven_multilingual_v1` | Multilingual, legacy |

---

### Speech-to-Speech (Voice Conversion)

```
POST /speech-to-speech/{voice_id}
Body: multipart/form-data
  audio: [input_audio_file]
  model_id: eleven_multilingual_v2
  voice_settings: {"stability": 0.5, "similarity_boost": 0.75}
```

---

### Sound Effects (Text to Sound)

```
POST /sound-generation
Body: {
  text: "thunder crack with rumbling echo",
  duration_seconds: 5.0,
  prompt_influence: 0.3
}
Response: Binary audio
```

---

### Dubbing (Auto-translate & dub video/audio)

```
POST /dubbing
Body: multipart/form-data
  file: [video_or_audio_file]  OR  source_url: "https://youtube.com/..."
  source_lang: "en"
  target_lang: "nl"
  num_speakers: 2
  watermark: false

Response: { dubbing_id: "...", expected_duration_sec: 30 }

GET /dubbing/{dubbing_id}
Response: { dubbing_id, name, status: "dubbing"|"dubbed"|"failed", ... }

GET /dubbing/{dubbing_id}/audio/{language_code}
Response: Audio stream of dubbed content
```

---

### History (Previous Generations)

```
GET /history
Query: page_size=100, start_after_history_item_id=...
Response: { history: [{ history_item_id, voice_id, voice_name, text, date_unix, character_count_change_from, character_count_change_to }] }

GET /history/{history_item_id}/audio
Response: Audio stream

DELETE /history/{history_item_id}

POST /history/download
Body: { history_item_ids: ["id1", "id2"] }
Response: ZIP file with MP3s
```

---

### User & Subscription Info

```
GET /user
Response: { xi_api_key, subscription: { tier, character_count, character_limit, ... } }

GET /user/subscription
Response: { tier: "starter|creator|pro|scale|enterprise", character_count, character_limit, ... }
```

---

## Voice Settings

| Setting | Range | Effect |
|---------|-------|--------|
| `stability` | 0.0–1.0 | Low = more expressive/varied, High = more consistent/robotic |
| `similarity_boost` | 0.0–1.0 | How closely to match original voice style |
| `style` | 0.0–1.0 | Exaggerate style/emotion (only multilingual v2+) |
| `use_speaker_boost` | boolean | Boost similarity to original speaker |

---

## Languages Supported (Multilingual v2)
English, Spanish, French, German, Italian, Portuguese, Polish, Hindi, Arabic, Chinese, Japanese, Korean, Dutch, Turkish, Swedish, Indonesian, Filipino, Ukrainian, Greek, Czech, Finnish, Romanian, Danish, Bulgarian, Slovak, Croatian, Malay, Tamil, Russian

---

## Pricing / Limits

| Plan | Characters/Month | Cost |
|------|-----------------|------|
| Free | 10,000 | $0 |
| Starter | 30,000 | $5/mo |
| Creator | 100,000 | $22/mo |
| Pro | 500,000 | $99/mo |

- 1 character ≈ 1 character of text (spaces count)
- Average spoken minute ≈ 800–1,000 characters

---

## Python SDK

```python
from elevenlabs import ElevenLabs, Voice, VoiceSettings

client = ElevenLabs(api_key="your_key")

# Generate speech
audio = client.generate(
    text="Hello, this is a test",
    voice="Rachel",  # name or voice_id
    model="eleven_multilingual_v2"
)

# Save to file
with open("output.mp3", "wb") as f:
    for chunk in audio:
        f.write(chunk)

# List voices
voices = client.voices.get_all()
```
