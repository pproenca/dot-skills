---
title: Analyze Before Processing
impact: CRITICAL
impactDescription: prevents wrong enhancement approach
tags: signal, analysis, spectrogram, waveform, assessment
---

## Analyze Before Processing

Blind enhancement can worsen audio. Always analyze the recording first to identify noise types, frequency content, and clipping before selecting processing strategy.

**Incorrect (blind processing):**

```bash
# Applying random filters without analysis
ffmpeg -i unknown.wav -af "highpass=f=300,lowpass=f=3000,anlmdn" enhanced.wav
# May remove important speech frequencies or leave dominant noise untouched
```

**Correct (analysis-driven processing):**

```bash
# Step 1: Get format and duration info
ffprobe -v error -show_entries format=duration,bit_rate:stream=codec_name,sample_rate,channels,bits_per_sample -of json input.wav

# Step 2: Generate spectrogram for visual analysis
ffmpeg -i input.wav -lavfi showspectrumpic=s=1920x1080:mode=combined:color=intensity:scale=log spectrogram.png

# Step 3: Analyze peak levels and potential clipping
ffmpeg -i input.wav -af "volumedetect" -f null - 2>&1 | grep -E "(max_volume|mean_volume)"

# Step 4: Detect silence/noise floor
ffmpeg -i input.wav -af "silencedetect=noise=-50dB:d=0.5" -f null - 2>&1 | grep silence
```

**Python comprehensive analysis:**

```python
import librosa
import librosa.display
import numpy as np
import matplotlib.pyplot as plt

def analyze_audio(filepath):
    """Complete audio analysis for forensic processing."""
    audio, sr = librosa.load(filepath, sr=None, mono=False)

    # Basic stats
    print(f"Sample rate: {sr} Hz")
    print(f"Duration: {len(audio)/sr:.2f} seconds")
    print(f"Channels: {1 if audio.ndim == 1 else audio.shape[0]}")

    if audio.ndim > 1:
        audio = audio[0]  # Analyze first channel

    # Peak and RMS levels
    peak_db = 20 * np.log10(np.max(np.abs(audio)) + 1e-10)
    rms_db = 20 * np.log10(np.sqrt(np.mean(audio**2)) + 1e-10)
    print(f"Peak level: {peak_db:.1f} dB")
    print(f"RMS level: {rms_db:.1f} dB")
    print(f"Crest factor: {peak_db - rms_db:.1f} dB")

    # Clipping detection
    clip_threshold = 0.99
    clipped_samples = np.sum(np.abs(audio) > clip_threshold)
    print(f"Clipped samples: {clipped_samples} ({100*clipped_samples/len(audio):.4f}%)")

    # Noise floor estimation (using quietest 10%)
    frame_length = int(0.025 * sr)  # 25ms frames
    rms_frames = librosa.feature.rms(y=audio, frame_length=frame_length)[0]
    noise_floor = np.percentile(rms_frames, 10)
    noise_floor_db = 20 * np.log10(noise_floor + 1e-10)
    print(f"Estimated noise floor: {noise_floor_db:.1f} dB")

    # Spectral centroid (brightness indicator)
    spectral_centroid = np.mean(librosa.feature.spectral_centroid(y=audio, sr=sr))
    print(f"Spectral centroid: {spectral_centroid:.0f} Hz")

    # Generate spectrogram
    plt.figure(figsize=(14, 8))
    D = librosa.amplitude_to_db(np.abs(librosa.stft(audio)), ref=np.max)
    librosa.display.specshow(D, sr=sr, x_axis='time', y_axis='log')
    plt.colorbar(format='%+2.0f dB')
    plt.title('Spectrogram Analysis')
    plt.savefig('analysis_spectrogram.png', dpi=150)

    return {
        'sample_rate': sr,
        'peak_db': peak_db,
        'rms_db': rms_db,
        'noise_floor_db': noise_floor_db,
        'clipped_samples': clipped_samples,
        'spectral_centroid': spectral_centroid
    }

# Usage
analysis = analyze_audio('evidence.wav')
```

**Decision matrix based on analysis:**

| Finding | Recommended Action |
|---------|-------------------|
| Noise floor > -40 dB | Aggressive noise reduction needed |
| Clipping detected | De-clip before other processing |
| Low spectral centroid | Voice may be muffled, use presence boost |
| High-frequency noise | Low-pass filter or spectral subtraction |
| 50/60 Hz hum | Notch filter at mains frequency |

Reference: [Audio Analysis Best Practices](https://www.izotope.com/en/learn/audio-analysis.html)
