---
title: Apply Spectral Subtraction for Stationary Noise
impact: HIGH
impactDescription: 10-20 dB noise reduction for consistent noise
tags: spectral, subtraction, frequency-domain, stationary-noise, fft
---

## Apply Spectral Subtraction for Stationary Noise

Spectral subtraction removes noise by subtracting the estimated noise spectrum from each frame. Effective for consistent background noise (HVAC, hiss, fan).

**Incorrect (time-domain approach for frequency noise):**

```bash
# Simple filtering doesn't target specific noise spectrum
ffmpeg -i hvac_noise.wav -af "lowpass=f=3000,highpass=f=200" filtered.wav
# Removes speech frequencies along with noise
```

**Correct (spectral subtraction):**

```bash
# FFmpeg FFT-based denoiser
ffmpeg -i hvac_noise.wav -af "afftdn=nr=12:nf=-25:nt=w" spectral_cleaned.wav
# nr: noise reduction amount
# nf: noise floor in dB
# nt=w: Wiener filter mode (better than simple subtraction)

# SoX spectral approach with noise profile
sox noisy.wav -n trim 0 2 noiseprof noise.prof
sox noisy.wav cleaned.wav noisered noise.prof 0.21
```

**Python spectral subtraction implementation:**

```python
import numpy as np
import librosa

def spectral_subtraction(audio, sr, noise_profile, alpha=2.0, beta=0.01):
    """
    Classic spectral subtraction with over-subtraction.

    Parameters:
    - noise_profile: Magnitude spectrum of noise (from silent segment)
    - alpha: Over-subtraction factor (1.0-4.0, higher = more aggressive)
    - beta: Spectral floor to prevent negative values (0.001-0.1)
    """
    n_fft = 2048
    hop_length = 512
    win_length = n_fft

    # STFT of noisy signal
    stft = librosa.stft(audio, n_fft=n_fft, hop_length=hop_length,
                        win_length=win_length)
    magnitude = np.abs(stft)
    phase = np.angle(stft)

    # Ensure noise profile matches FFT size
    if len(noise_profile) != magnitude.shape[0]:
        noise_profile = np.interp(
            np.linspace(0, 1, magnitude.shape[0]),
            np.linspace(0, 1, len(noise_profile)),
            noise_profile
        )

    # Over-subtraction: S = |Y| - α|N|
    noise_profile = noise_profile.reshape(-1, 1)
    subtracted = magnitude - alpha * noise_profile

    # Spectral floor: prevent negative/very small values
    # S = max(S, β|Y|)
    floored = np.maximum(subtracted, beta * magnitude)

    # Reconstruct
    output_stft = floored * np.exp(1j * phase)
    output_audio = librosa.istft(output_stft, hop_length=hop_length,
                                  win_length=win_length)

    return output_audio

def estimate_noise_spectrum(audio, sr, start_sec=0, duration_sec=1):
    """Estimate noise spectrum from a segment."""
    start = int(start_sec * sr)
    end = int((start_sec + duration_sec) * sr)
    noise_segment = audio[start:end]

    # Average magnitude spectrum
    stft = librosa.stft(noise_segment, n_fft=2048, hop_length=512)
    noise_profile = np.mean(np.abs(stft), axis=1)

    return noise_profile

# Usage
audio, sr = librosa.load('noisy_speech.wav', sr=None)

# Extract noise profile from first second (assumed silent)
noise_profile = estimate_noise_spectrum(audio, sr, start_sec=0, duration_sec=1)

# Apply spectral subtraction with moderate aggression
cleaned = spectral_subtraction(audio, sr, noise_profile, alpha=2.0, beta=0.02)

# Save result
import soundfile as sf
sf.write('cleaned.wav', cleaned, sr)
```

**Over-subtraction factor guide:**

| Alpha Value | Use Case |
|-------------|----------|
| 1.0 | Minimal reduction, preserve naturalness |
| 2.0 | Standard, good balance |
| 3.0 | Aggressive, for high noise |
| 4.0+ | Very aggressive, risk of artifacts |

Reference: [Speech Enhancement using Spectral Subtraction](https://www.sciencedirect.com/science/article/pii/S1877050915013903)
