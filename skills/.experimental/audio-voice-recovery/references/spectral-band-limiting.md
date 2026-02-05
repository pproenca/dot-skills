---
title: Apply Frequency Band Limiting for Speech
impact: HIGH
impactDescription: removes out-of-band noise without affecting intelligibility
tags: spectral, bandpass, highpass, lowpass, speech-frequencies
---

## Apply Frequency Band Limiting for Speech

Human speech occupies 80 Hz to 8 kHz. Filtering outside this range removes noise without affecting intelligibility. Telephone-band (300-3400 Hz) often sufficient for recognition.

**Incorrect (too aggressive filtering):**

```bash
# Cutting above 3 kHz removes consonant clarity
ffmpeg -i recording.wav -af "lowpass=f=2500" muffled.wav
# 's', 'f', 'th' sounds become indistinguishable
```

**Correct (speech-appropriate band limiting):**

```bash
# Full speech bandwidth (80 Hz - 8 kHz)
ffmpeg -i noisy.wav -af "highpass=f=80,lowpass=f=8000" full_speech.wav

# Telephone bandwidth (for severely degraded audio)
ffmpeg -i noisy.wav -af "highpass=f=300,lowpass=f=3400" telephone_band.wav

# Presence boost for clarity (2-4 kHz emphasis)
ffmpeg -i dull_speech.wav -af "\
  highpass=f=80,\
  equalizer=f=3000:t=q:w=1:g=3,\
  lowpass=f=8000\
" presence_boost.wav
```

**Python smart band limiting:**

```python
import numpy as np
from scipy import signal
import librosa

def speech_bandpass(audio, sr, low_freq=80, high_freq=8000, order=5):
    """
    Apply Butterworth bandpass filter optimized for speech.
    """
    nyquist = sr / 2

    # Ensure frequencies are within valid range
    low = max(low_freq, 20) / nyquist
    high = min(high_freq, nyquist - 100) / nyquist

    b, a = signal.butter(order, [low, high], btype='band')
    filtered = signal.filtfilt(b, a, audio)

    return filtered

def adaptive_band_limiting(audio, sr, target='intelligibility'):
    """
    Apply band limiting based on target use case.
    """
    configs = {
        'full_speech': {'low': 80, 'high': 8000},
        'telephone': {'low': 300, 'high': 3400},
        'intelligibility': {'low': 150, 'high': 6000},
        'male_voice': {'low': 80, 'high': 5000},
        'female_voice': {'low': 150, 'high': 8000},
        'whisper': {'low': 200, 'high': 6000},
    }

    config = configs.get(target, configs['intelligibility'])
    return speech_bandpass(audio, sr, config['low'], config['high'])

def detect_speech_band(audio, sr, threshold_db=-40):
    """
    Detect the actual frequency range containing speech energy.
    """
    n_fft = 2048
    stft = np.abs(librosa.stft(audio, n_fft=n_fft))
    freqs = librosa.fft_frequencies(sr=sr, n_fft=n_fft)

    # Average spectrum
    avg_spectrum = np.mean(stft, axis=1)
    avg_spectrum_db = 20 * np.log10(avg_spectrum + 1e-10)

    # Normalize
    avg_spectrum_db -= np.max(avg_spectrum_db)

    # Find frequency range above threshold
    active = avg_spectrum_db > threshold_db
    active_freqs = freqs[active]

    if len(active_freqs) > 0:
        low_freq = max(active_freqs[0], 50)
        high_freq = min(active_freqs[-1], sr / 2 - 100)
    else:
        low_freq, high_freq = 80, 8000  # Default

    return low_freq, high_freq

def smart_band_limit(audio, sr, margin_low=0.8, margin_high=1.2):
    """
    Detect speech band and apply filtering with safety margins.
    """
    detected_low, detected_high = detect_speech_band(audio, sr)

    # Apply margins
    filter_low = detected_low * margin_low
    filter_high = detected_high * margin_high

    print(f"Detected speech band: {detected_low:.0f} - {detected_high:.0f} Hz")
    print(f"Filtering: {filter_low:.0f} - {filter_high:.0f} Hz")

    return speech_bandpass(audio, sr, filter_low, filter_high)

# Usage
audio, sr = librosa.load('noisy_speech.wav', sr=None)
filtered = smart_band_limit(audio, sr)
```

**Speech frequency reference:**

| Phoneme Type | Frequency Range | Examples |
|--------------|-----------------|----------|
| Fundamental (F0) | 80-300 Hz | Voice pitch |
| Vowels | 300-3000 Hz | a, e, i, o, u |
| Nasals | 200-2500 Hz | m, n, ng |
| Fricatives | 2000-8000 Hz | s, f, sh, th |
| Plosives | Broadband burst | p, t, k, b, d, g |

**Band limiting strategy by noise type:**

| Noise Location | Filter Approach |
|---------------|-----------------|
| Low rumble (< 100 Hz) | High-pass at 80-120 Hz |
| High hiss (> 6 kHz) | Low-pass at 6-8 kHz |
| Both | Bandpass 100-6000 Hz |
| Mid-frequency noise | Use spectral subtraction instead |

Reference: [Speech Frequency Characteristics](https://en.wikipedia.org/wiki/Voice_frequency)
