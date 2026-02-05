---
title: Apply Notch Filters for Tonal Interference
impact: HIGH
impactDescription: removes hum without affecting speech
tags: spectral, notch, hum, tonal, mains-frequency, harmonics
---

## Apply Notch Filters for Tonal Interference

Electrical hum (50/60 Hz) and its harmonics appear as sharp spectral lines. Notch filters surgically remove these without affecting surrounding frequencies.

**Incorrect (broadband filter removes speech):**

```bash
# High-pass removes too much, including bass voice
ffmpeg -i hum_recording.wav -af "highpass=f=200" removed_bass.wav
# Male voices lose body and warmth
```

**Correct (surgical notch removal):**

```bash
# Remove 60 Hz hum and harmonics (US power)
ffmpeg -i hum_recording.wav -af "\
  bandreject=f=60:w=2,\
  bandreject=f=120:w=2,\
  bandreject=f=180:w=2,\
  bandreject=f=240:w=2,\
  bandreject=f=300:w=2\
" dehum_us.wav

# Remove 50 Hz hum and harmonics (EU/Asia power)
ffmpeg -i hum_recording.wav -af "\
  bandreject=f=50:w=2,\
  bandreject=f=100:w=2,\
  bandreject=f=150:w=2,\
  bandreject=f=200:w=2,\
  bandreject=f=250:w=2\
" dehum_eu.wav

# Auto-detect and remove with anlmf (adaptive line noise filter)
ffmpeg -i hum_recording.wav -af "anlmf=o=3" auto_dehum.wav
```

**Python precision notch filter:**

```python
import numpy as np
from scipy import signal
import librosa

def design_notch_filter(freq, sr, Q=30):
    """
    Design a notch filter for a specific frequency.

    Parameters:
    - freq: Frequency to remove (Hz)
    - sr: Sample rate
    - Q: Quality factor (higher = narrower notch)
    """
    w0 = freq / (sr / 2)  # Normalized frequency
    b, a = signal.iirnotch(w0, Q)
    return b, a

def remove_hum_and_harmonics(audio, sr, fundamental=60, n_harmonics=5, Q=30):
    """
    Remove hum at fundamental frequency and its harmonics.
    """
    filtered = audio.copy()

    for i in range(1, n_harmonics + 1):
        freq = fundamental * i
        if freq < sr / 2:  # Below Nyquist
            b, a = design_notch_filter(freq, sr, Q)
            filtered = signal.filtfilt(b, a, filtered)
            print(f"Notched {freq} Hz")

    return filtered

def detect_hum_frequency(audio, sr):
    """
    Automatically detect the fundamental hum frequency.
    """
    # Look for peaks in the 45-65 Hz range
    n_fft = 8192  # High resolution for low frequencies
    stft = np.abs(librosa.stft(audio, n_fft=n_fft))
    freqs = librosa.fft_frequencies(sr=sr, n_fft=n_fft)

    # Average spectrum
    avg_spectrum = np.mean(stft, axis=1)

    # Search 45-65 Hz range
    mask = (freqs >= 45) & (freqs <= 65)
    search_freqs = freqs[mask]
    search_spectrum = avg_spectrum[mask]

    # Find peak
    peak_idx = np.argmax(search_spectrum)
    detected_freq = search_freqs[peak_idx]

    # Determine if 50 Hz or 60 Hz region
    if detected_freq < 55:
        return 50
    else:
        return 60

def adaptive_hum_removal(audio, sr, Q=35):
    """
    Detect and remove hum automatically.
    """
    # Detect fundamental
    fundamental = detect_hum_frequency(audio, sr)
    print(f"Detected {fundamental} Hz power line frequency")

    # Remove fundamental and harmonics
    cleaned = remove_hum_and_harmonics(audio, sr, fundamental,
                                        n_harmonics=6, Q=Q)

    return cleaned, fundamental

# Usage
audio, sr = librosa.load('hum_recording.wav', sr=None)
cleaned, detected_freq = adaptive_hum_removal(audio, sr)

# Save
import soundfile as sf
sf.write('dehum.wav', cleaned, sr)
```

**Notch filter Q factor guide:**

| Q Value | Bandwidth | Use Case |
|---------|-----------|----------|
| 10-20 | Wide | Light hum, safe for speech |
| 25-35 | Medium | Standard hum removal |
| 40-60 | Narrow | Heavy hum, precise removal |
| 60+ | Very narrow | Only when hum frequency is exact |

**When NOT to use notch filters:**

- Recording has multiple overlapping hum sources
- Hum frequency varies (poor power quality)
- Speech fundamental overlaps with hum (rare, deep voices)

Reference: [IIR Notch Filter Design](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.iirnotch.html)
