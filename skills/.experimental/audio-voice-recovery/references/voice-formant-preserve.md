---
title: Preserve Formants During Pitch Manipulation
impact: HIGH
impactDescription: maintains natural voice quality during time/pitch changes
tags: voice, formant, pitch-shift, time-stretch, psola
---

## Preserve Formants During Pitch Manipulation

Formants (resonant frequencies) define voice character. Pitch shifting without formant preservation creates unnatural "chipmunk" or "Darth Vader" effects.

**Incorrect (pitch shift without formant preservation):**

```bash
# Basic pitch shift changes formants
ffmpeg -i recording.wav -af "rubberband=pitch=1.2" chipmunk.wav
# Higher pitch = higher formants = unnatural
```

**Correct (formant-preserving pitch shift):**

```bash
# Rubberband with formant preservation
ffmpeg -i recording.wav -af "rubberband=pitch=1.2:formant=1" natural.wav
# pitch changed but formants preserved

# SoX with formant preservation
sox input.wav output.wav pitch 200 # Shift up 200 cents with formant preservation
```

**Python formant-preserving manipulation:**

```python
import numpy as np
import librosa
import soundfile as sf

def pitch_shift_preserve_formants(audio, sr, semitones):
    """
    Pitch shift while preserving formants using librosa.

    Uses PSOLA-like approach: time-stretch then resample.
    """
    # Calculate rate
    rate = 2 ** (semitones / 12.0)

    # Time stretch to compensate for pitch change
    stretched = librosa.effects.time_stretch(audio, rate=rate)

    # Resample to change pitch
    shifted = librosa.resample(stretched, orig_sr=sr, target_sr=int(sr * rate))

    # Trim or pad to original length
    if len(shifted) > len(audio):
        shifted = shifted[:len(audio)]
    else:
        shifted = np.pad(shifted, (0, len(audio) - len(shifted)))

    return shifted

def time_stretch_preserve_quality(audio, sr, rate):
    """
    Time stretch with phase vocoder for quality.

    rate > 1 = faster (shorter)
    rate < 1 = slower (longer)
    """
    # Use librosa's phase vocoder
    stretched = librosa.effects.time_stretch(audio, rate=rate)

    return stretched

def analyze_formants(audio, sr, n_formants=4):
    """
    Analyze formant frequencies using LPC.
    """
    from scipy.signal import lfilter

    # Pre-emphasis
    pre_emphasis = 0.97
    emphasized = np.append(audio[0], audio[1:] - pre_emphasis * audio[:-1])

    # Frame the signal
    frame_length = int(0.025 * sr)  # 25ms
    hop_length = int(0.010 * sr)    # 10ms

    frames = librosa.util.frame(emphasized, frame_length=frame_length,
                                 hop_length=hop_length)

    formants = []
    for frame in frames.T:
        # Apply window
        windowed = frame * np.hamming(len(frame))

        # LPC analysis
        lpc_order = 2 + sr // 1000
        try:
            from scipy.signal import lpc
            lpc_coeffs = lpc(windowed, lpc_order)

            # Find roots of LPC polynomial
            roots = np.roots(lpc_coeffs)

            # Keep roots inside unit circle with positive imaginary part
            roots = roots[np.imag(roots) >= 0]
            roots = roots[np.abs(roots) < 1]

            # Convert to frequencies
            angles = np.arctan2(np.imag(roots), np.real(roots))
            freqs = angles * sr / (2 * np.pi)

            # Sort and keep first n formants
            freqs = np.sort(freqs[freqs > 50])[:n_formants]
            formants.append(freqs)
        except:
            formants.append([])

    return formants

def rubberband_stretch(input_path, output_path, time_ratio=1.0, pitch_shift=0,
                       preserve_formants=True):
    """
    Use Rubberband library for high-quality time/pitch manipulation.

    Requires rubberband-cli or pyrubberband.
    """
    import subprocess

    cmd = ['rubberband']

    if time_ratio != 1.0:
        cmd.extend(['-t', str(time_ratio)])

    if pitch_shift != 0:
        cmd.extend(['-p', str(pitch_shift)])

    if preserve_formants:
        cmd.append('-F')  # Formant preservation

    cmd.extend([input_path, output_path])

    subprocess.run(cmd, check=True)

# Usage example
if __name__ == '__main__':
    audio, sr = librosa.load('speech.wav', sr=None)

    # Slow down for clarity (0.8x speed)
    slowed = time_stretch_preserve_quality(audio, sr, rate=0.8)
    sf.write('slowed.wav', slowed, sr)

    # Pitch up to match reference voice (preserve formants)
    pitched = pitch_shift_preserve_formants(audio, sr, semitones=2)
    sf.write('pitched_natural.wav', pitched, sr)

    # Analyze formants
    formants = analyze_formants(audio, sr)
    avg_f1 = np.mean([f[0] for f in formants if len(f) > 0])
    avg_f2 = np.mean([f[1] for f in formants if len(f) > 1])
    print(f"Average F1: {avg_f1:.0f} Hz, F2: {avg_f2:.0f} Hz")
```

**Install Rubberband:**

```bash
# macOS
brew install rubberband

# Ubuntu/Debian
apt-get install rubberband-cli

# Python wrapper
pip install pyrubberband
```

**Formant frequency reference:**

| Vowel | F1 (Hz) | F2 (Hz) | F3 (Hz) |
|-------|---------|---------|---------|
| /i/ (beat) | 270 | 2300 | 3000 |
| /u/ (boot) | 300 | 870 | 2250 |
| /a/ (father) | 730 | 1100 | 2450 |
| /e/ (bet) | 530 | 1850 | 2500 |
| /o/ (boat) | 570 | 850 | 2400 |

**Use cases:**

| Task | Settings |
|------|----------|
| Slow for transcription | time_ratio=0.7-0.8, preserve formants |
| Match speaker pitch | pitch_shift=±3 semitones, preserve formants |
| Speed up background | time_ratio=1.5, formants less critical |

Reference: [Rubberband Audio Time Stretcher](https://breakfastquay.com/rubberband/)
