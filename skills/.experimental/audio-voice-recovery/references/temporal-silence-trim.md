---
title: Trim Silence and Normalize Before Export
impact: MEDIUM-HIGH
impactDescription: cleaner output for transcription and review
tags: temporal, silence, trim, normalize, export
---

## Trim Silence and Normalize Before Export

Remove leading/trailing silence and normalize levels for consistent playback. Essential for transcription workflows and evidence presentation.

**Incorrect (raw export with dead air):**

```bash
# Export without cleanup
cp processed.wav final.wav
# 30 seconds of silence at start, variable levels throughout
```

**Correct (trimmed and normalized):**

```bash
# Trim silence from start/end
ffmpeg -i processed.wav -af "silenceremove=start_periods=1:start_threshold=-50dB:start_duration=0.5,areverse,silenceremove=start_periods=1:start_threshold=-50dB:start_duration=0.5,areverse" trimmed.wav

# Normalize to standard loudness
ffmpeg -i trimmed.wav -af "loudnorm=I=-16:TP=-1.5:LRA=11" final.wav

# Combined pipeline
ffmpeg -i input.wav -af "\
  silenceremove=start_periods=1:start_threshold=-50dB,\
  areverse,\
  silenceremove=start_periods=1:start_threshold=-50dB,\
  areverse,\
  loudnorm=I=-16:TP=-1.5:LRA=11\
" final.wav
```

**Python trim and normalize:**

```python
import numpy as np
import librosa
import soundfile as sf

def trim_silence(audio, sr, threshold_db=-50, min_silence_ms=500):
    """
    Trim silence from start and end of audio.
    """
    threshold = 10 ** (threshold_db / 20)
    min_samples = int(min_silence_ms * sr / 1000)

    # Find non-silent regions
    non_silent = np.abs(audio) > threshold

    # Smoothe to avoid trimming brief quiet moments
    from scipy.ndimage import binary_dilation
    non_silent = binary_dilation(non_silent, iterations=min_samples)

    # Find first and last non-silent samples
    non_silent_indices = np.where(non_silent)[0]

    if len(non_silent_indices) == 0:
        return audio  # All silent, return original

    start = non_silent_indices[0]
    end = non_silent_indices[-1] + 1

    return audio[start:end]

def trim_with_padding(audio, sr, threshold_db=-50, pad_ms=100):
    """
    Trim silence but keep small padding for natural sound.
    """
    trimmed = trim_silence(audio, sr, threshold_db)

    # Add padding
    pad_samples = int(pad_ms * sr / 1000)
    silence = np.zeros(pad_samples)

    return np.concatenate([silence, trimmed, silence])

def peak_normalize(audio, target_db=-3):
    """
    Normalize audio so peak reaches target level.
    """
    peak = np.max(np.abs(audio))
    if peak == 0:
        return audio

    target_linear = 10 ** (target_db / 20)
    gain = target_linear / peak

    return audio * gain

def rms_normalize(audio, target_db=-20):
    """
    Normalize audio so RMS reaches target level.
    """
    rms = np.sqrt(np.mean(audio ** 2))
    if rms == 0:
        return audio

    target_linear = 10 ** (target_db / 20)
    gain = target_linear / rms

    # Limit gain to prevent clipping
    max_gain = 0.95 / np.max(np.abs(audio))
    gain = min(gain, max_gain)

    return audio * gain

def lufs_normalize(audio, sr, target_lufs=-16):
    """
    Normalize to target LUFS (broadcast standard).
    """
    try:
        import pyloudnorm as pyln

        meter = pyln.Meter(sr)
        current_lufs = meter.integrated_loudness(audio)

        if np.isinf(current_lufs):
            return audio

        normalized = pyln.normalize.loudness(audio, current_lufs, target_lufs)

        # True peak limiting
        peak = np.max(np.abs(normalized))
        if peak > 0.95:
            normalized = normalized * 0.95 / peak

        return normalized

    except ImportError:
        # Fallback to RMS normalization
        return rms_normalize(audio, target_db=target_lufs + 10)

def export_for_transcription(audio, sr, output_path, target_lufs=-16):
    """
    Prepare audio for optimal transcription.
    """
    # Trim silence
    trimmed = trim_with_padding(audio, sr, threshold_db=-45, pad_ms=200)

    # Normalize
    normalized = lufs_normalize(trimmed, sr, target_lufs)

    # Export as 16-bit WAV
    sf.write(output_path, normalized, sr, subtype='PCM_16')

    # Report stats
    duration = len(normalized) / sr
    final_lufs = calculate_lufs(normalized, sr)
    print(f"Exported: {output_path}")
    print(f"Duration: {duration:.1f}s")
    print(f"Loudness: {final_lufs:.1f} LUFS")

def calculate_lufs(audio, sr):
    """Calculate LUFS loudness."""
    try:
        import pyloudnorm as pyln
        meter = pyln.Meter(sr)
        return meter.integrated_loudness(audio)
    except:
        rms_db = 20 * np.log10(np.sqrt(np.mean(audio ** 2)) + 1e-10)
        return rms_db - 10  # Rough approximation

def batch_normalize(input_dir, output_dir, target_lufs=-16):
    """
    Batch normalize multiple files to same loudness.
    """
    import os
    from pathlib import Path

    os.makedirs(output_dir, exist_ok=True)

    for filepath in Path(input_dir).glob('*.wav'):
        audio, sr = sf.read(filepath)
        normalized = lufs_normalize(audio, sr, target_lufs)
        trimmed = trim_with_padding(normalized, sr)

        output_path = os.path.join(output_dir, filepath.name)
        sf.write(output_path, trimmed, sr, subtype='PCM_16')
        print(f"Processed: {filepath.name}")

# Usage
if __name__ == '__main__':
    audio, sr = sf.read('processed_speech.wav')

    # Full export pipeline
    export_for_transcription(audio, sr, 'ready_for_transcription.wav')

    # Batch process
    # batch_normalize('input_folder/', 'output_folder/', target_lufs=-16)
```

**Loudness standards:**

| Standard | LUFS | Use Case |
|----------|------|----------|
| Podcast | -16 | General listening |
| Broadcast (EU) | -23 | TV/Radio |
| Broadcast (US) | -24 | TV/Radio |
| YouTube | -14 | Online video |
| Forensic | -16 to -20 | Clear without distortion |

Reference: [EBU R 128 Loudness Standard](https://tech.ebu.ch/docs/r/r128.pdf)
