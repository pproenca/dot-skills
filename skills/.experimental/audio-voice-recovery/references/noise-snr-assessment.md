---
title: Measure Signal-to-Noise Ratio Before and After
impact: CRITICAL
impactDescription: validates enhancement effectiveness
tags: noise, snr, measurement, validation, metrics
---

## Measure Signal-to-Noise Ratio Before and After

Without SNR measurement, you cannot verify improvement. Always quantify before/after to ensure processing helped rather than harmed.

**Incorrect (subjective evaluation only):**

```bash
# Just listening and guessing
ffmpeg -i noisy.wav -af "afftdn=nr=30" enhanced.wav
# "Sounds better" is not forensically defensible
```

**Correct (measured improvement):**

```bash
# Measure input levels
ffmpeg -i noisy.wav -af "astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.Overall.RMS_level" -f null - 2>&1 | grep RMS

# Get noise floor from silent segment
ffmpeg -i noisy.wav -ss 0 -t 1 -af "astats=metadata=1" -f null - 2>&1 | grep RMS

# Calculate approximate SNR
# SNR = Speech_RMS - Noise_RMS (in dB)
```

**Python SNR measurement:**

```python
import numpy as np
import librosa

def estimate_snr(audio, sr, speech_segments=None, noise_segments=None):
    """
    Estimate Signal-to-Noise Ratio.

    If segments not provided, uses energy-based detection.
    """
    frame_length = int(0.025 * sr)
    hop_length = frame_length // 2

    # Calculate RMS energy per frame
    rms = librosa.feature.rms(y=audio, frame_length=frame_length,
                               hop_length=hop_length)[0]

    if speech_segments is None or noise_segments is None:
        # Automatic detection using histogram
        rms_db = 20 * np.log10(rms + 1e-10)

        # Noise floor: bottom 20% of frames
        noise_threshold = np.percentile(rms_db, 20)
        noise_frames = rms[rms_db <= noise_threshold]

        # Speech: top 50% of frames
        speech_threshold = np.percentile(rms_db, 50)
        speech_frames = rms[rms_db >= speech_threshold]
    else:
        # Use provided segments
        noise_frames = []
        speech_frames = []
        frame_times = librosa.frames_to_time(np.arange(len(rms)), sr=sr,
                                              hop_length=hop_length)
        for i, t in enumerate(frame_times):
            for start, end in noise_segments:
                if start <= t <= end:
                    noise_frames.append(rms[i])
            for start, end in speech_segments:
                if start <= t <= end:
                    speech_frames.append(rms[i])
        noise_frames = np.array(noise_frames)
        speech_frames = np.array(speech_frames)

    if len(noise_frames) == 0 or len(speech_frames) == 0:
        return None

    # Calculate SNR
    noise_power = np.mean(noise_frames ** 2)
    speech_power = np.mean(speech_frames ** 2)

    snr_db = 10 * np.log10(speech_power / (noise_power + 1e-10))

    return snr_db

def compare_enhancement(original, enhanced, sr):
    """Compare SNR before and after enhancement."""
    snr_before = estimate_snr(original, sr)
    snr_after = estimate_snr(enhanced, sr)

    print(f"SNR before: {snr_before:.1f} dB")
    print(f"SNR after:  {snr_after:.1f} dB")
    print(f"Improvement: {snr_after - snr_before:.1f} dB")

    return {
        'snr_before': snr_before,
        'snr_after': snr_after,
        'improvement': snr_after - snr_before
    }

# Usage
original, sr = librosa.load('noisy.wav', sr=None)
enhanced, _ = librosa.load('enhanced.wav', sr=None)

results = compare_enhancement(original, enhanced, sr)

# Document for forensic report
if results['improvement'] > 0:
    print(f"Enhancement validated: {results['improvement']:.1f} dB improvement")
else:
    print("WARNING: Enhancement may have degraded audio quality")
```

**SNR interpretation:**

| SNR Range | Speech Intelligibility |
|-----------|----------------------|
| < 0 dB | Unintelligible |
| 0-5 dB | Very difficult |
| 5-10 dB | Difficult |
| 10-15 dB | Fair |
| 15-20 dB | Good |
| > 20 dB | Excellent |

**Forensic documentation template:**

```text
Audio Enhancement Report
========================
Original file: evidence_001.wav
Enhanced file: evidence_001_enhanced.wav

Measurements:
- Original SNR: 4.2 dB
- Enhanced SNR: 14.8 dB
- Improvement: 10.6 dB

Processing applied:
1. High-pass filter (80 Hz)
2. Spectral subtraction (α=2.0)
3. Wiener filter (noise tracking enabled)

Conclusion: Enhancement improved intelligibility from
"very difficult" to "fair-good" range.
```

Reference: [SNR Measurement Standards](https://en.wikipedia.org/wiki/Signal-to-noise_ratio)
