---
title: Use Forensic Equalization to Restore Intelligibility
impact: HIGH
impactDescription: recovers masked speech without adding artifacts
tags: spectral, equalization, presence, clarity, speech-enhancement
---

## Use Forensic Equalization to Restore Intelligibility

Targeted EQ boosts speech frequencies while cutting noise bands. Focus on presence (2-4 kHz) for consonant clarity and cut mud (200-400 Hz) for definition.

**Incorrect (flat boost adds noise):**

```bash
# Simple gain boost increases noise equally
ffmpeg -i quiet_speech.wav -af "volume=10dB" louder_noise.wav
# Speech and noise both louder
```

**Correct (targeted forensic EQ):**

```bash
# Forensic speech enhancement EQ
ffmpeg -i muffled.wav -af "\
  highpass=f=100,\
  equalizer=f=250:t=q:w=2:g=-3,\
  equalizer=f=800:t=q:w=1.5:g=2,\
  equalizer=f=2500:t=q:w=1:g=4,\
  equalizer=f=5000:t=q:w=2:g=2,\
  lowpass=f=8000\
" enhanced.wav
# Cuts mud at 250 Hz, boosts body at 800 Hz,
# boosts presence at 2.5 kHz, adds air at 5 kHz
```

**Python forensic EQ:**

```python
import numpy as np
from scipy import signal
import librosa

def parametric_eq(audio, sr, bands):
    """
    Apply multi-band parametric EQ.

    bands: list of dicts with {freq, gain_db, Q}
    """
    filtered = audio.copy()

    for band in bands:
        freq = band['freq']
        gain_db = band['gain_db']
        Q = band.get('Q', 1.0)

        if gain_db == 0:
            continue

        # Peak/notch filter
        w0 = freq / (sr / 2)
        if w0 >= 1:
            continue  # Skip if above Nyquist

        A = 10 ** (gain_db / 40)
        alpha = np.sin(np.pi * w0) / (2 * Q)

        b0 = 1 + alpha * A
        b1 = -2 * np.cos(np.pi * w0)
        b2 = 1 - alpha * A
        a0 = 1 + alpha / A
        a1 = -2 * np.cos(np.pi * w0)
        a2 = 1 - alpha / A

        b = np.array([b0/a0, b1/a0, b2/a0])
        a = np.array([1, a1/a0, a2/a0])

        filtered = signal.filtfilt(b, a, filtered)

    return filtered

# Forensic speech enhancement preset
FORENSIC_SPEECH_EQ = [
    {'freq': 80, 'gain_db': 0, 'Q': 0.7},      # Leave fundamentals alone
    {'freq': 200, 'gain_db': -2, 'Q': 1.5},    # Cut mud
    {'freq': 400, 'gain_db': -1, 'Q': 2.0},    # Reduce boxiness
    {'freq': 800, 'gain_db': 2, 'Q': 1.5},     # Body
    {'freq': 1500, 'gain_db': 1, 'Q': 1.0},    # Low presence
    {'freq': 2500, 'gain_db': 4, 'Q': 1.0},    # Presence/clarity
    {'freq': 4000, 'gain_db': 3, 'Q': 1.5},    # High presence
    {'freq': 6000, 'gain_db': 1, 'Q': 2.0},    # Air/sibilance
]

# Telephone/intercom preset (narrow band source)
TELEPHONE_EQ = [
    {'freq': 300, 'gain_db': 3, 'Q': 1.0},     # Boost low end (lost in phone)
    {'freq': 800, 'gain_db': 2, 'Q': 1.5},     # Body
    {'freq': 2000, 'gain_db': 4, 'Q': 1.0},    # Intelligibility
    {'freq': 3000, 'gain_db': 2, 'Q': 1.5},    # Upper clarity
]

def adaptive_forensic_eq(audio, sr):
    """
    Analyze audio and apply appropriate forensic EQ.
    """
    # Analyze spectral balance
    n_fft = 2048
    stft = np.abs(librosa.stft(audio, n_fft=n_fft))
    freqs = librosa.fft_frequencies(sr=sr, n_fft=n_fft)
    avg_spectrum = np.mean(stft, axis=1)

    # Check for common problems
    low_energy = np.mean(avg_spectrum[(freqs > 100) & (freqs < 400)])
    mid_energy = np.mean(avg_spectrum[(freqs > 800) & (freqs < 2000)])
    high_energy = np.mean(avg_spectrum[(freqs > 2000) & (freqs < 5000)])

    eq_bands = []

    # Muddy (too much low-mid)
    if low_energy > mid_energy * 1.5:
        eq_bands.append({'freq': 250, 'gain_db': -3, 'Q': 1.5})
        print("Detected: muddy, cutting 250 Hz")

    # Dull (lacking presence)
    if high_energy < mid_energy * 0.5:
        eq_bands.append({'freq': 2500, 'gain_db': 4, 'Q': 1.0})
        eq_bands.append({'freq': 4000, 'gain_db': 2, 'Q': 1.5})
        print("Detected: dull, boosting presence")

    # Thin (lacking body)
    if low_energy < mid_energy * 0.3:
        eq_bands.append({'freq': 200, 'gain_db': 2, 'Q': 1.5})
        eq_bands.append({'freq': 800, 'gain_db': 2, 'Q': 1.0})
        print("Detected: thin, boosting body")

    if not eq_bands:
        eq_bands = FORENSIC_SPEECH_EQ
        print("Using standard forensic EQ")

    return parametric_eq(audio, sr, eq_bands)

# Usage
audio, sr = librosa.load('muffled_speech.wav', sr=None)
enhanced = adaptive_forensic_eq(audio, sr)
```

**Forensic EQ frequency guide:**

| Frequency | Character | Adjustment |
|-----------|-----------|------------|
| 80-150 Hz | Rumble, fundamental | Cut if noisy |
| 200-400 Hz | Mud, boxiness | Usually cut |
| 500-1000 Hz | Body, warmth | Boost for thin audio |
| 1-2 kHz | Honk, nasal | Cut if harsh |
| 2-4 kHz | Presence, clarity | Boost for intelligibility |
| 4-8 kHz | Air, sibilance | Gentle boost for definition |

Reference: [Forensic Audio Enhancement](https://www.izotope.com/en/learn/forensic-audio-enhancement.html)
