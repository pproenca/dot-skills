---
title: Use Adaptive Noise Estimation for Non-Stationary Noise
impact: CRITICAL
impactDescription: handles varying noise without manual profiles
tags: noise, adaptive, estimation, non-stationary, real-time
---

## Use Adaptive Noise Estimation for Non-Stationary Noise

Static noise profiles fail when noise changes over time (traffic, crowd, wind). Adaptive algorithms continuously update their noise estimate.

**Incorrect (static profile on dynamic noise):**

```bash
# Static profile from start of recording
sox recording.wav -n trim 0 2 noiseprof static.prof
sox recording.wav output.wav noisered static.prof 0.21
# Noise that appears later isn't removed; early noise may be over-reduced
```

**Correct (adaptive estimation):**

```bash
# FFmpeg adaptive frequency-domain denoiser
ffmpeg -i recording.wav -af "afftdn=nt=w:om=o:tr=1" adaptive_denoised.wav
# nt=w: Wiener filter
# om=o: Output only cleaned signal
# tr=1: Track noise in real-time

# For varying noise levels, use adaptive mode
ffmpeg -i recording.wav -af "afftdn=nr=10:nf=-25:tn=1" output.wav
# tn=1: Enable noise floor tracking
```

**RNNoise for ML-based adaptive denoising:**

```bash
# RNNoise via FFmpeg (if compiled with ladspa support)
ffmpeg -i recording.wav -af "arnndn=m=rnnoise-models/bd.rnnn" denoised.wav

# Or using standalone rnnoise
rnnoise_demo recording.raw denoised.raw
```

**Python adaptive noise reduction:**

```python
import numpy as np
from scipy import signal
import librosa

def adaptive_spectral_subtraction(audio, sr, frame_ms=25, hop_ms=10,
                                   noise_frames=10, alpha=2.0, beta=0.01):
    """
    Adaptive spectral subtraction that tracks noise over time.

    Parameters:
    - noise_frames: Number of initial frames to estimate noise
    - alpha: Over-subtraction factor (higher = more aggressive)
    - beta: Spectral floor (prevents negative values)
    """
    frame_length = int(frame_ms * sr / 1000)
    hop_length = int(hop_ms * sr / 1000)
    n_fft = 2 ** int(np.ceil(np.log2(frame_length)))

    # STFT
    stft = librosa.stft(audio, n_fft=n_fft, hop_length=hop_length,
                        win_length=frame_length)
    magnitude = np.abs(stft)
    phase = np.angle(stft)

    # Initial noise estimate from first N frames
    noise_estimate = np.mean(magnitude[:, :noise_frames], axis=1, keepdims=True)

    # Process each frame with adaptive update
    output_magnitude = np.zeros_like(magnitude)
    smoothing = 0.98  # Noise estimate smoothing factor

    for i in range(magnitude.shape[1]):
        frame_mag = magnitude[:, i:i+1]

        # Spectral subtraction
        subtracted = frame_mag - alpha * noise_estimate
        floored = np.maximum(subtracted, beta * frame_mag)
        output_magnitude[:, i:i+1] = floored

        # Adaptive noise update during quiet frames
        frame_energy = np.mean(frame_mag)
        noise_energy = np.mean(noise_estimate)

        # If frame is likely noise-only, update estimate
        if frame_energy < noise_energy * 1.5:
            noise_estimate = smoothing * noise_estimate + (1 - smoothing) * frame_mag

    # Reconstruct
    output_stft = output_magnitude * np.exp(1j * phase)
    output_audio = librosa.istft(output_stft, hop_length=hop_length,
                                  win_length=frame_length)

    return output_audio

# Usage
audio, sr = librosa.load('variable_noise.wav', sr=None)
cleaned = adaptive_spectral_subtraction(audio, sr, alpha=2.5)
```

**When to use adaptive vs static:**

| Scenario | Approach |
|----------|----------|
| Controlled environment, consistent noise | Static profile |
| Outdoor recording, traffic | Adaptive |
| Moving source/microphone | Adaptive |
| Multiple noise sources | Adaptive |
| Very short recording | Static (not enough data to adapt) |

Reference: [Adaptive Noise Reduction Techniques](https://www.sciencedirect.com/science/article/pii/S1877050916300758)
