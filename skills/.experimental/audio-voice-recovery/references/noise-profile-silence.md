---
title: Extract Noise Profile from Silent Segments
impact: CRITICAL
impactDescription: 2-5× better noise reduction accuracy
tags: noise, profile, estimation, silence, reference
---

## Extract Noise Profile from Silent Segments

Noise reduction algorithms need a pure noise sample. Extract from segments where no speech occurs for accurate spectral estimation.

**Incorrect (estimating from speech):**

```bash
# Using entire file including speech corrupts noise profile
ffmpeg -i recording.wav -af "afftdn=nr=20" denoised.wav
# Adaptive mode may include speech harmonics in noise estimate
```

**Correct (profile from silence):**

```bash
# Step 1: Find silent segments
ffmpeg -i recording.wav -af "silencedetect=noise=-35dB:d=0.5" -f null - 2>&1 | grep silence_start

# Step 2: Extract pure noise segment (e.g., first 2 seconds of silence)
ffmpeg -i recording.wav -ss 0.5 -t 2.0 noise_sample.wav

# Step 3: Use noise sample for profile-based reduction
# With SoX:
sox recording.wav -n noiseprof noise.prof
sox recording.wav denoised.wav noisered noise.prof 0.21
```

**Python noise profiling:**

```python
import numpy as np
import librosa
from scipy import signal

def find_noise_segments(audio, sr, threshold_db=-40, min_duration=0.3):
    """Find segments containing only noise (no speech)."""
    frame_length = int(0.025 * sr)
    hop_length = frame_length // 4

    # Calculate RMS energy per frame
    rms = librosa.feature.rms(y=audio, frame_length=frame_length, hop_length=hop_length)[0]
    rms_db = 20 * np.log10(rms + 1e-10)

    # Find frames below threshold
    quiet_frames = rms_db < threshold_db

    # Convert to time segments
    frame_times = librosa.frames_to_time(np.arange(len(rms)), sr=sr, hop_length=hop_length)

    segments = []
    start = None
    for i, is_quiet in enumerate(quiet_frames):
        if is_quiet and start is None:
            start = frame_times[i]
        elif not is_quiet and start is not None:
            if frame_times[i] - start >= min_duration:
                segments.append((start, frame_times[i]))
            start = None

    return segments

def extract_noise_profile(audio, sr, segments):
    """Extract average noise spectrum from silent segments."""
    noise_samples = []
    for start, end in segments:
        start_sample = int(start * sr)
        end_sample = int(end * sr)
        noise_samples.append(audio[start_sample:end_sample])

    if not noise_samples:
        raise ValueError("No silent segments found for noise profiling")

    # Concatenate and compute average spectrum
    noise_audio = np.concatenate(noise_samples)
    f, noise_psd = signal.welch(noise_audio, sr, nperseg=2048)

    return f, noise_psd

# Usage
audio, sr = librosa.load('recording.wav', sr=None)
segments = find_noise_segments(audio, sr, threshold_db=-35)
print(f"Found {len(segments)} noise segments")

if segments:
    freqs, noise_profile = extract_noise_profile(audio, sr, segments)
```

**Best noise segment locations:**

| Location | Quality | Notes |
|----------|---------|-------|
| Recording start (before speech) | Excellent | Captures initial room tone |
| Natural pauses | Good | May have breath/movement |
| Recording end | Good | May have handling noise |
| Very quiet words | Poor | Contains speech remnants |

Reference: [SoX Noise Reduction](http://sox.sourceforge.net/sox.html)
