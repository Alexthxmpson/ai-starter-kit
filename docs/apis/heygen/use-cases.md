# HeyGen — Capabilities & Use Cases

**API:** HeyGen AI Video Generation
**Access:** HEYGEN_API_KEY
**Last updated:** 2026-02-28

---

## What You Can Do

HeyGen generates AI avatar videos from text scripts. Upload a photo or choose from preset avatars, add a script, and get a professional-looking talking-head video.

### Core Features
- Generate video with AI avatar speaking a script
- Choose from 100+ preset avatars or create your own
- Text-to-speech in 40+ languages (or use ElevenLabs voice)
- Clone your own avatar from a short video recording
- Video translation (dub existing video to another language)
- Talking photo (animate any portrait photo)

---

## Use Cases

| Use Case | Feature | Difficulty |
|----------|---------|------------|
| Create product explainer video from script | Avatar video generation | Easy |
| Generate personalized sales video per lead | Avatar + dynamic text | Medium |
| Translate training video to Dutch/Spanish | Video translation | Easy |
| Create social media content videos at scale | Bulk video generation | Medium |
| Animate a logo/mascot photo | Talking photo | Easy |
| Build avatar video for YouTube channel | Custom avatar + script | Medium |
| Generate onboarding videos automatically | Avatar + script template | Medium |
| Localize marketing videos for EU markets | Video translation | Easy |
| Create course content videos from transcripts | Avatar + script | Medium |
| Produce news-style announcement videos | Avatar + teleprompter | Easy |

---

## API Workflow

```
1. POST /v2/video/generate — create video with avatar + script
   { video_inputs: [{ character: { avatar_id }, voice: {...}, background: {...} }],
     dimension: { width: 1280, height: 720 } }
   → Returns: { video_id }

2. GET /v1/video_status.get?video_id={id} — poll for completion
   → Returns: { status: processing|completed|failed, video_url }

3. Download video_url when status = completed
```

---

## Key Notes

- Video generation takes 2–10 minutes depending on length
- Free tier: limited credits (1 free video/month roughly)
- Paid plans: $29+/month
- Best use: when you need a talking-head video without filming
- Combine with Claude (write script) + ElevenLabs voice for full AI video pipeline
- Custom avatar requires uploading a ~2-minute consent video
- Video translation preserves lip sync in target language
