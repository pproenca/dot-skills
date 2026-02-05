---
title: Use Lossless Formats for Processing
impact: CRITICAL
impactDescription: prevents 10-20% quality loss per re-encode
tags: signal, format, lossless, wav, flac, encoding
---

## Use Lossless Formats for Processing

Each lossy encoding cycle (MP3, AAC, OGG) permanently removes audio information. Use WAV or FLAC for all intermediate processing steps.

**Incorrect (lossy chain destroys data):**

```bash
# Each step loses ~10-20% of audio detail
ffmpeg -i recording.mp3 -af "volume=2" step1.mp3
ffmpeg -i step1.mp3 -af "highpass=f=100" step2.mp3
ffmpeg -i step2.mp3 -af "anlmdn" final.mp3
# Result: severely degraded audio with artifacts
```

**Correct (lossless processing chain):**

```bash
# Convert to lossless immediately
ffmpeg -i recording.mp3 -c:a pcm_s24le working.wav

# All processing in lossless format
ffmpeg -i working.wav -af "volume=2" step1.wav
ffmpeg -i step1.wav -af "highpass=f=100" step2.wav
ffmpeg -i step2.wav -af "anlmdn" final.wav

# Only convert to lossy for final delivery if required
ffmpeg -i final.wav -c:a libmp3lame -q:a 0 final_delivery.mp3
```

**Recommended formats:**

| Format | Use Case | Bit Depth |
|--------|----------|-----------|
| WAV (PCM) | All processing | 24-bit or 32-bit float |
| FLAC | Archival storage | 24-bit |
| RF64 | Files > 4GB | 24-bit or higher |

**Python example:**

```python
import soundfile as sf

# Read any format, work in float64 internally
audio, sr = sf.read('recording.mp3', dtype='float64')

# Process...

# Save as 24-bit WAV for maximum quality
sf.write('processed.wav', audio, sr, subtype='PCM_24')
```

Reference: [FFmpeg Audio Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/HighQualityAudio)
