---
title: Preserve Native Sample Rate
impact: CRITICAL
impactDescription: prevents aliasing and interpolation artifacts
tags: signal, sample-rate, resampling, nyquist, aliasing
---

## Preserve Native Sample Rate

Resampling introduces interpolation errors. Process at the original sample rate; only resample for final delivery requirements.

**Incorrect (unnecessary resampling):**

```bash
# Upsampling doesn't add information, just artifacts
ffmpeg -i phone_call_8khz.wav -ar 48000 upsampled.wav
# Processing at 48kHz wastes CPU and can introduce ringing

# Downsampling loses frequencies permanently
ffmpeg -i studio_48khz.wav -ar 16000 downsampled.wav
# All content above 8kHz is gone forever
```

**Correct (native rate processing):**

```bash
# Check original sample rate first
ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of csv=p=0 input.wav
# Output: 8000

# Process at native rate
ffmpeg -i phone_call_8khz.wav -af "highpass=f=200,anlmdn" enhanced_8khz.wav

# Only resample for specific tool requirements
ffmpeg -i enhanced_8khz.wav -ar 16000 for_whisper.wav  # Whisper expects 16kHz
```

**When resampling is necessary:**

```python
import librosa

# High-quality resampling with librosa
audio, sr = librosa.load('recording.wav', sr=None)  # Native rate
print(f"Original sample rate: {sr}")

# Only if target tool requires specific rate
if sr != 16000:
    audio_resampled = librosa.resample(audio, orig_sr=sr, target_sr=16000,
                                        res_type='kaiser_best')  # Highest quality
```

**Sample rate reference:**

| Source | Typical Rate | Nyquist Limit |
|--------|--------------|---------------|
| Phone (narrowband) | 8 kHz | 4 kHz |
| Phone (wideband) | 16 kHz | 8 kHz |
| Voice recorder | 22.05-44.1 kHz | 11-22 kHz |
| Professional | 48-96 kHz | 24-48 kHz |

Reference: [Nyquist-Shannon Sampling Theorem](https://en.wikipedia.org/wiki/Nyquist%E2%80%93Shannon_sampling_theorem)
