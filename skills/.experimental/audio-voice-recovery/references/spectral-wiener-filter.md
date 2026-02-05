---
title: Use Wiener Filter for Optimal Noise Estimation
impact: HIGH
impactDescription: minimizes mean squared error between clean and enhanced
tags: spectral, wiener, optimal-filter, estimation, mmse
---

## Use Wiener Filter for Optimal Noise Estimation

The Wiener filter provides mathematically optimal noise reduction by minimizing mean squared error. Superior to basic spectral subtraction for varying SNR.

**Incorrect (fixed subtraction regardless of SNR):**

```python
# Simple subtraction doesn't adapt to local SNR
cleaned = magnitude - noise_estimate  # Same reduction everywhere
```

**Correct (Wiener filter adapts to local SNR):**

```python
import numpy as np
import librosa

def wiener_filter(audio, sr, noise_psd, n_fft=2048, hop_length=512):
    """
    Apply Wiener filter for optimal noise reduction.

    The Wiener filter gain is: H(f) = S(f) / (S(f) + N(f))
    where S(f) is signal PSD and N(f) is noise PSD.

    This naturally applies more reduction where SNR is low
    and preserves signal where SNR is high.
    """
    # STFT
    stft = librosa.stft(audio, n_fft=n_fft, hop_length=hop_length)
    magnitude = np.abs(stft)
    phase = np.angle(stft)

    # Estimate signal PSD (noisy magnitude squared minus noise)
    noisy_psd = magnitude ** 2

    # Ensure noise_psd shape matches
    if noise_psd.ndim == 1:
        noise_psd = noise_psd.reshape(-1, 1)

    # A priori SNR estimation (decision-directed approach)
    # Initial estimate
    signal_psd_est = np.maximum(noisy_psd - noise_psd, 0)

    # Wiener filter gain
    # H = signal_psd / (signal_psd + noise_psd)
    # With flooring to prevent divide-by-zero
    epsilon = 1e-10
    wiener_gain = signal_psd_est / (signal_psd_est + noise_psd + epsilon)

    # Apply gain
    enhanced_magnitude = wiener_gain * magnitude

    # Reconstruct
    enhanced_stft = enhanced_magnitude * np.exp(1j * phase)
    enhanced_audio = librosa.istft(enhanced_stft, hop_length=hop_length)

    return enhanced_audio, wiener_gain

def decision_directed_wiener(audio, sr, noise_psd, alpha=0.98):
    """
    Decision-directed Wiener filter with temporal smoothing.

    The alpha parameter controls smoothing between frames,
    reducing musical noise artifacts.
    """
    n_fft = 2048
    hop_length = 512

    stft = librosa.stft(audio, n_fft=n_fft, hop_length=hop_length)
    magnitude = np.abs(stft)
    phase = np.angle(stft)
    n_frames = magnitude.shape[1]

    if noise_psd.ndim == 1:
        noise_psd = noise_psd.reshape(-1, 1)

    enhanced_magnitude = np.zeros_like(magnitude)
    prev_xi = np.ones((magnitude.shape[0], 1))  # Previous a priori SNR

    for i in range(n_frames):
        frame_mag = magnitude[:, i:i+1]
        noisy_psd = frame_mag ** 2

        # A posteriori SNR
        gamma = noisy_psd / (noise_psd + 1e-10)

        # Decision-directed a priori SNR estimate
        # Combines previous estimate with current ML estimate
        if i == 0:
            xi = np.maximum(gamma - 1, 0)
        else:
            prev_enhanced = enhanced_magnitude[:, i-1:i]
            xi_ml = np.maximum(gamma - 1, 0)
            xi_dd = (prev_enhanced ** 2) / (noise_psd + 1e-10)
            xi = alpha * xi_dd + (1 - alpha) * xi_ml

        # Wiener gain
        gain = xi / (xi + 1)

        # Apply and store
        enhanced_magnitude[:, i:i+1] = gain * frame_mag
        prev_xi = xi

    enhanced_stft = enhanced_magnitude * np.exp(1j * phase)
    enhanced_audio = librosa.istft(enhanced_stft, hop_length=hop_length)

    return enhanced_audio

# Usage
audio, sr = librosa.load('noisy.wav', sr=None)

# Estimate noise PSD from silent segment
noise_segment = audio[:int(sr * 1.0)]  # First second
noise_stft = librosa.stft(noise_segment, n_fft=2048, hop_length=512)
noise_psd = np.mean(np.abs(noise_stft) ** 2, axis=1)

# Apply decision-directed Wiener filter
cleaned = decision_directed_wiener(audio, sr, noise_psd, alpha=0.98)
```

**FFmpeg Wiener filter:**

```bash
# Enable Wiener mode in afftdn
ffmpeg -i noisy.wav -af "afftdn=nt=w:nr=12:nf=-25" wiener_cleaned.wav
# nt=w enables Wiener filter mode
```

**Wiener vs Spectral Subtraction comparison:**

| Aspect | Spectral Subtraction | Wiener Filter |
|--------|---------------------|---------------|
| Computation | Simpler | More complex |
| Artifacts | More musical noise | Less artifacts |
| Adaptability | Fixed reduction | Adapts to local SNR |
| Low SNR | Over-subtracts | Graceful degradation |
| High SNR | May under-reduce | Preserves signal |

Reference: [Wiener Filter Theory](https://en.wikipedia.org/wiki/Wiener_filter)
