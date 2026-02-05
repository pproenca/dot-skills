---
title: Boost Frequency Regions for Specific Phonemes
impact: HIGH
impactDescription: recovers masked consonants and improves word recognition
tags: voice, phoneme, consonant, frequency, intelligibility
---

## Boost Frequency Regions for Specific Phonemes

Different phonemes occupy different frequency ranges. Target boosting based on what's missing to recover specific sounds.

**Incorrect (flat presence boost):**

```bash
# Generic boost may not target the right frequencies
ffmpeg -i muffled.wav -af "equalizer=f=3000:t=q:w=2:g=6" generic_boost.wav
# May boost noise along with target phonemes
```

**Correct (phoneme-targeted enhancement):**

```python
import numpy as np
from scipy import signal
import librosa
import soundfile as sf

# Phoneme frequency bands
PHONEME_BANDS = {
    # Vowels (F1, F2 formant ranges)
    'vowels': {'low': 300, 'high': 3000, 'Q': 0.5},

    # Fricatives - high frequency content
    's': {'low': 4000, 'high': 8000, 'Q': 1.0},
    'f': {'low': 2500, 'high': 6000, 'Q': 1.0},
    'sh': {'low': 2000, 'high': 6000, 'Q': 0.8},
    'th': {'low': 3000, 'high': 7000, 'Q': 1.0},

    # Plosives - transient bursts
    'p_t_k': {'low': 2000, 'high': 5000, 'Q': 0.7},
    'b_d_g': {'low': 1000, 'high': 3000, 'Q': 0.7},

    # Nasals
    'm_n': {'low': 200, 'high': 2500, 'Q': 0.5},

    # General intelligibility
    'presence': {'low': 2000, 'high': 4000, 'Q': 1.0},
    'clarity': {'low': 4000, 'high': 6000, 'Q': 1.5},
}

def boost_phoneme_band(audio, sr, phoneme_type, gain_db=3):
    """
    Boost specific frequency band for phoneme recovery.
    """
    if phoneme_type not in PHONEME_BANDS:
        raise ValueError(f"Unknown phoneme type: {phoneme_type}")

    band = PHONEME_BANDS[phoneme_type]
    nyquist = sr / 2

    # Check if band is within Nyquist
    if band['high'] >= nyquist:
        band['high'] = nyquist * 0.9

    # Design bandpass boost
    center_freq = (band['low'] + band['high']) / 2
    bandwidth = band['high'] - band['low']
    Q = center_freq / bandwidth

    # Peak filter for boost
    w0 = center_freq / nyquist
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

    boosted = signal.filtfilt(b, a, audio)

    return boosted

def analyze_missing_phonemes(audio, sr):
    """
    Analyze which phoneme frequency regions are weak.
    """
    n_fft = 2048
    stft = np.abs(librosa.stft(audio, n_fft=n_fft))
    freqs = librosa.fft_frequencies(sr=sr, n_fft=n_fft)
    avg_spectrum = np.mean(stft, axis=1)
    avg_spectrum_db = 20 * np.log10(avg_spectrum + 1e-10)

    analysis = {}

    for phoneme, band in PHONEME_BANDS.items():
        if band['high'] >= sr / 2:
            continue

        mask = (freqs >= band['low']) & (freqs <= band['high'])
        band_energy = np.mean(avg_spectrum_db[mask])
        analysis[phoneme] = band_energy

    # Find weak regions
    median_energy = np.median(list(analysis.values()))
    weak_regions = {k: v for k, v in analysis.items()
                    if v < median_energy - 6}  # 6 dB below median

    return analysis, weak_regions

def auto_phoneme_enhancement(audio, sr, target_boost_db=4):
    """
    Automatically boost weak phoneme regions.
    """
    analysis, weak_regions = analyze_missing_phonemes(audio, sr)

    print("Phoneme region analysis:")
    for phoneme, energy in sorted(analysis.items(), key=lambda x: x[1]):
        status = "WEAK" if phoneme in weak_regions else "OK"
        print(f"  {phoneme:12s}: {energy:6.1f} dB [{status}]")

    enhanced = audio.copy()
    for phoneme in weak_regions:
        enhanced = boost_phoneme_band(enhanced, sr, phoneme, gain_db=target_boost_db)
        print(f"Boosted: {phoneme} by {target_boost_db} dB")

    return enhanced

def enhance_sibilants(audio, sr, gain_db=4):
    """
    Specifically enhance sibilant sounds (s, sh, f, th).
    """
    enhanced = audio.copy()
    enhanced = boost_phoneme_band(enhanced, sr, 's', gain_db)
    enhanced = boost_phoneme_band(enhanced, sr, 'f', gain_db * 0.7)

    return enhanced

def enhance_clarity(audio, sr, presence_db=3, clarity_db=2):
    """
    General clarity enhancement for speech.
    """
    enhanced = audio.copy()
    enhanced = boost_phoneme_band(enhanced, sr, 'presence', presence_db)
    enhanced = boost_phoneme_band(enhanced, sr, 'clarity', clarity_db)

    return enhanced

# FFmpeg equivalent commands
def print_ffmpeg_commands(weak_regions):
    """Generate FFmpeg commands for detected weak regions."""
    filters = []

    for phoneme in weak_regions:
        band = PHONEME_BANDS[phoneme]
        center = (band['low'] + band['high']) / 2
        filters.append(f"equalizer=f={center}:t=q:w={band['Q']}:g=4")

    cmd = f"ffmpeg -i input.wav -af \"{','.join(filters)}\" enhanced.wav"
    print(f"\nFFmpeg command:\n{cmd}")

# Usage
if __name__ == '__main__':
    audio, sr = sf.read('muffled_speech.wav')

    # Auto-enhance weak regions
    enhanced = auto_phoneme_enhancement(audio, sr)

    # Or specific enhancement for sibilants
    # enhanced = enhance_sibilants(audio, sr, gain_db=5)

    sf.write('phoneme_enhanced.wav', enhanced, sr)
```

**FFmpeg phoneme enhancement:**

```bash
# Enhance sibilants (s, f, sh sounds)
ffmpeg -i muffled.wav -af "\
  equalizer=f=5000:t=q:w=1:g=4,\
  equalizer=f=6500:t=q:w=1.5:g=3\
" sibilants_enhanced.wav

# Enhance general presence
ffmpeg -i dull.wav -af "\
  equalizer=f=2500:t=q:w=1:g=3,\
  equalizer=f=4000:t=q:w=1.5:g=2\
" presence_enhanced.wav
```

**Phoneme frequency quick reference:**

| Sound | Example | Frequency Range |
|-------|---------|-----------------|
| /s/ | "see" | 4-8 kHz |
| /ʃ/ | "she" | 2-6 kHz |
| /f/ | "fee" | 2.5-6 kHz |
| /θ/ | "think" | 3-7 kHz |
| /t/ | "tea" | 2-5 kHz burst |
| /k/ | "key" | 2-4 kHz burst |
| Vowels | all | 300-3000 Hz |

Reference: [Speech Acoustics](https://en.wikipedia.org/wiki/Formant)
