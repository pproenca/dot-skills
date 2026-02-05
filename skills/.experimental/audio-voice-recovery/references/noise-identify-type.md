---
title: Identify Noise Type Before Reduction
impact: CRITICAL
impactDescription: wrong algorithm can worsen audio
tags: noise, identification, stationary, transient, tonal
---

## Identify Noise Type Before Reduction

Different noise types require different algorithms. Stationary noise (hum, hiss) responds to spectral subtraction; transient noise (clicks, pops) needs time-domain repair.

**Incorrect (one-size-fits-all):**

```bash
# Using broadband denoiser on clicky audio
ffmpeg -i clicks_and_pops.wav -af "anlmdn=s=10" output.wav
# Clicks remain, speech gets muffled
```

**Correct (type-specific processing):**

```bash
# For stationary noise (hiss, hum, fan)
ffmpeg -i hissy_audio.wav -af "afftdn=nf=-25:nr=10:nt=w" denoised.wav

# For transient noise (clicks, pops)
ffmpeg -i clicky_audio.wav -af "adeclick=w=55:o=75" declicked.wav

# For tonal noise (hum, whistle)
ffmpeg -i hum_audio.wav -af "anlmf=o=3" dehum.wav

# Combined approach for mixed noise
ffmpeg -i mixed_noise.wav -af "adeclick,anlmf=o=2,afftdn=nr=8" clean.wav
```

**Noise type identification:**

```python
import numpy as np
import librosa
from scipy import signal

def identify_noise_type(audio, sr):
    """Analyze audio to identify dominant noise characteristics."""
    results = {}

    # 1. Check for tonal components (hum, whistle)
    f, psd = signal.welch(audio, sr, nperseg=4096)
    peaks, properties = signal.find_peaks(psd, prominence=np.max(psd)/10)
    peak_freqs = f[peaks]

    # Common hum frequencies
    mains_freqs = [50, 60, 100, 120, 150, 180, 200, 240]  # Hz
    detected_hum = [pf for pf in peak_freqs if any(abs(pf - mf) < 5 for mf in mains_freqs)]
    results['tonal_hum'] = len(detected_hum) > 0
    results['hum_frequencies'] = detected_hum

    # 2. Check for transient noise (clicks)
    # High derivative indicates sudden amplitude changes
    diff = np.abs(np.diff(audio))
    threshold = np.mean(diff) + 5 * np.std(diff)
    transients = np.sum(diff > threshold)
    results['transient_clicks'] = transients > len(audio) / sr  # More than 1 per second
    results['click_count'] = transients

    # 3. Check for broadband noise (hiss)
    # High-frequency energy relative to mid-frequency
    high_freq_energy = np.mean(psd[f > 4000])
    mid_freq_energy = np.mean(psd[(f > 500) & (f < 4000)])
    results['broadband_hiss'] = high_freq_energy > mid_freq_energy * 0.3
    results['hiss_ratio'] = high_freq_energy / (mid_freq_energy + 1e-10)

    # 4. Check for rumble (low-frequency noise)
    low_freq_energy = np.mean(psd[f < 100])
    results['low_freq_rumble'] = low_freq_energy > mid_freq_energy * 0.5

    return results

def recommend_processing(noise_analysis):
    """Recommend processing chain based on noise analysis."""
    chain = []

    if noise_analysis['transient_clicks']:
        chain.append(f"adeclick (detected {noise_analysis['click_count']} transients)")

    if noise_analysis['low_freq_rumble']:
        chain.append("highpass=f=80 (rumble removal)")

    if noise_analysis['tonal_hum']:
        freqs = noise_analysis['hum_frequencies']
        chain.append(f"notch filters at {freqs[:3]} Hz")

    if noise_analysis['broadband_hiss']:
        chain.append(f"afftdn (hiss ratio: {noise_analysis['hiss_ratio']:.2f})")

    return chain

# Usage
audio, sr = librosa.load('recording.wav', sr=None)
analysis = identify_noise_type(audio, sr)
recommendations = recommend_processing(analysis)
print("Recommended processing chain:")
for step in recommendations:
    print(f"  - {step}")
```

**Noise type reference:**

| Noise Type | Characteristics | Best Algorithm |
|------------|-----------------|----------------|
| Hiss | Broadband, stationary | Spectral subtraction, Wiener filter |
| Hum | Tonal at 50/60 Hz + harmonics | Notch filter, adaptive filter |
| Clicks/Pops | Short transients | Declicker, interpolation |
| Rumble | Low frequency | High-pass filter |
| Wind | Non-stationary broadband | Adaptive filter |
| Reverb | Delayed copies | Dereverb algorithms |

Reference: [iZotope Audio Repair Guide](https://www.izotope.com/en/learn/audio-repair.html)
