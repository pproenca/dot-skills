---
title: Use Dynamic Range Compression for Level Consistency
impact: MEDIUM-HIGH
impactDescription: normalizes volume across quiet and loud segments
tags: temporal, compression, dynamics, leveling, loudness
---

## Use Dynamic Range Compression for Level Consistency

Compression reduces the gap between quiet and loud parts, making soft speech audible without clipping loud segments.

**Incorrect (simple gain increases noise):**

```bash
# Linear gain boost
ffmpeg -i quiet.wav -af "volume=15dB" loud_noise.wav
# Quiet speech louder, but noise proportionally louder too
```

**Correct (dynamic compression):**

```bash
# FFmpeg compressor
ffmpeg -i variable_level.wav -af "\
  compand=attacks=0.1:decays=0.3:\
  points=-70/-70|-40/-20|-20/-10|0/-5:\
  gain=5\
" compressed.wav

# Or use acompressor filter
ffmpeg -i input.wav -af "\
  acompressor=threshold=-20dB:ratio=4:attack=5:release=100:makeup=5dB\
" compressed.wav

# Dynamic normalization (loudnorm)
ffmpeg -i variable.wav -af "loudnorm=I=-16:TP=-1.5:LRA=11" normalized.wav
```

**Python dynamic compression:**

```python
import numpy as np
import librosa
import soundfile as sf

def simple_compressor(audio, threshold_db=-20, ratio=4, attack_ms=5, release_ms=100, sr=44100):
    """
    Simple dynamic range compressor.

    Parameters:
    - threshold_db: Level above which compression starts
    - ratio: Compression ratio (e.g., 4:1)
    - attack_ms: Attack time in milliseconds
    - release_ms: Release time in milliseconds
    """
    threshold = 10 ** (threshold_db / 20)

    # Convert times to samples
    attack_samples = int(attack_ms * sr / 1000)
    release_samples = int(release_ms * sr / 1000)

    # Attack/release coefficients
    attack_coef = np.exp(-1 / attack_samples) if attack_samples > 0 else 0
    release_coef = np.exp(-1 / release_samples) if release_samples > 0 else 0

    # Process
    output = np.zeros_like(audio)
    envelope = 0

    for i in range(len(audio)):
        # Envelope follower
        level = np.abs(audio[i])
        if level > envelope:
            envelope = attack_coef * envelope + (1 - attack_coef) * level
        else:
            envelope = release_coef * envelope + (1 - release_coef) * level

        # Calculate gain
        if envelope > threshold:
            gain_db = threshold_db + (20 * np.log10(envelope + 1e-10) - threshold_db) / ratio
            gain = 10 ** (gain_db / 20) / (envelope + 1e-10)
        else:
            gain = 1.0

        output[i] = audio[i] * gain

    return output

def multiband_compressor(audio, sr, bands=None):
    """
    Multiband compressor for better tonal balance.
    """
    from scipy import signal

    if bands is None:
        bands = [
            {'low': 0, 'high': 200, 'threshold': -25, 'ratio': 3},
            {'low': 200, 'high': 2000, 'threshold': -20, 'ratio': 4},
            {'low': 2000, 'high': 6000, 'threshold': -18, 'ratio': 3},
            {'low': 6000, 'high': sr//2, 'threshold': -15, 'ratio': 2},
        ]

    output = np.zeros_like(audio)

    for band in bands:
        # Bandpass filter
        nyquist = sr / 2
        low = max(band['low'] / nyquist, 0.001)
        high = min(band['high'] / nyquist, 0.999)

        if low < high:
            b, a = signal.butter(4, [low, high], btype='band')
            band_audio = signal.filtfilt(b, a, audio)

            # Compress this band
            compressed = simple_compressor(
                band_audio,
                threshold_db=band['threshold'],
                ratio=band['ratio'],
                sr=sr
            )

            output += compressed

    return output

def auto_gain_control(audio, sr, target_rms_db=-20, window_ms=500):
    """
    Automatic Gain Control - adapts to changing levels.
    """
    window_samples = int(window_ms * sr / 1000)
    hop = window_samples // 4
    target_rms = 10 ** (target_rms_db / 20)

    output = np.zeros_like(audio)

    for i in range(0, len(audio) - window_samples, hop):
        window = audio[i:i + window_samples]

        # Calculate RMS of window
        rms = np.sqrt(np.mean(window ** 2)) + 1e-10

        # Calculate gain needed
        gain = target_rms / rms

        # Limit gain to reasonable range
        gain = np.clip(gain, 0.1, 10)

        # Apply with crossfade
        if i == 0:
            output[i:i + window_samples] = window * gain
        else:
            fade_len = hop
            fade_in = np.linspace(0, 1, fade_len)
            fade_out = 1 - fade_in

            output[i:i + fade_len] = (output[i:i + fade_len] * fade_out +
                                       window[:fade_len] * gain * fade_in)
            output[i + fade_len:i + window_samples] = window[fade_len:] * gain

    return output

def calculate_lufs(audio, sr):
    """Calculate integrated LUFS loudness."""
    try:
        import pyloudnorm as pyln
        meter = pyln.Meter(sr)
        return meter.integrated_loudness(audio)
    except ImportError:
        # Simplified RMS-based approximation
        rms = np.sqrt(np.mean(audio ** 2))
        return 20 * np.log10(rms + 1e-10) - 10  # Rough LUFS approximation

def loudness_normalize(audio, sr, target_lufs=-16):
    """Normalize to target loudness in LUFS."""
    try:
        import pyloudnorm as pyln
        meter = pyln.Meter(sr)
        current_lufs = meter.integrated_loudness(audio)
        normalized = pyln.normalize.loudness(audio, current_lufs, target_lufs)
        return normalized
    except ImportError:
        # Fallback: simple peak normalization
        peak = np.max(np.abs(audio))
        return audio / peak * 0.9

# Usage
if __name__ == '__main__':
    audio, sr = sf.read('variable_level.wav')

    # Apply compression
    compressed = simple_compressor(audio, threshold_db=-20, ratio=4, sr=sr)

    # Then normalize
    normalized = loudness_normalize(compressed, sr, target_lufs=-16)

    sf.write('level_controlled.wav', normalized, sr)

    # Report levels
    print(f"Input LUFS: {calculate_lufs(audio, sr):.1f}")
    print(f"Output LUFS: {calculate_lufs(normalized, sr):.1f}")
```

**Compression settings guide:**

| Scenario | Threshold | Ratio | Attack | Release |
|----------|-----------|-------|--------|---------|
| Gentle leveling | -25 dB | 2:1 | 20 ms | 200 ms |
| Standard speech | -20 dB | 4:1 | 5 ms | 100 ms |
| Aggressive control | -15 dB | 8:1 | 1 ms | 50 ms |
| Limiting peaks | -3 dB | 20:1 | 0.5 ms | 100 ms |

Reference: [Loudness Normalization](https://en.wikipedia.org/wiki/Audio_normalization)
