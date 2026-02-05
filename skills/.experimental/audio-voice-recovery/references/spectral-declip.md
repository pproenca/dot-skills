---
title: Repair Clipped Audio Before Other Processing
impact: HIGH
impactDescription: recovers 3-6 dB of dynamic range
tags: spectral, declip, clipping, distortion, reconstruction
---

## Repair Clipped Audio Before Other Processing

Clipped audio has flattened peaks that create harmonic distortion. Declipping algorithms reconstruct the original waveform shape using interpolation or sparse reconstruction.

**Incorrect (processing clipped audio):**

```bash
# Noise reduction on clipped audio
ffmpeg -i clipped.wav -af "afftdn=nr=15" still_distorted.wav
# Clipping harmonics remain, processed as if they were speech
```

**Correct (declip first, then process):**

```bash
# FFmpeg declipping
ffmpeg -i clipped.wav -af "declip=w=50:o=50" declipped.wav
# w: window size, o: overlap

# Then apply other processing
ffmpeg -i declipped.wav -af "afftdn=nr=12" final.wav
```

**Python declipping with cubic interpolation:**

```python
import numpy as np
from scipy import interpolate, signal
import librosa

def detect_clipping(audio, threshold=0.99):
    """
    Detect clipped samples in audio.

    Returns indices and segments of clipped audio.
    """
    clipped_mask = np.abs(audio) >= threshold

    # Find contiguous clipped regions
    diff = np.diff(clipped_mask.astype(int))
    starts = np.where(diff == 1)[0] + 1
    ends = np.where(diff == -1)[0] + 1

    # Handle edge cases
    if clipped_mask[0]:
        starts = np.insert(starts, 0, 0)
    if clipped_mask[-1]:
        ends = np.append(ends, len(audio))

    segments = list(zip(starts, ends))

    clip_percentage = 100 * np.sum(clipped_mask) / len(audio)
    return segments, clip_percentage

def cubic_declip(audio, threshold=0.99, margin=5):
    """
    Declip audio using cubic spline interpolation.

    For each clipped segment, uses surrounding unclipped samples
    to reconstruct the waveform.
    """
    segments, clip_pct = detect_clipping(audio, threshold)
    print(f"Detected {len(segments)} clipped segments ({clip_pct:.2f}% of audio)")

    if len(segments) == 0:
        return audio

    declipped = audio.copy()

    for start, end in segments:
        segment_len = end - start

        # Get context samples
        context_start = max(0, start - margin)
        context_end = min(len(audio), end + margin)

        # Indices for interpolation (exclude clipped region)
        x_known = np.concatenate([
            np.arange(context_start, start),
            np.arange(end, context_end)
        ])
        y_known = audio[x_known]

        if len(x_known) < 4:
            continue  # Not enough context

        # Fit cubic spline
        try:
            spline = interpolate.CubicSpline(x_known, y_known)

            # Reconstruct clipped region
            x_clipped = np.arange(start, end)
            declipped[x_clipped] = spline(x_clipped)
        except Exception as e:
            print(f"Could not declip segment {start}-{end}: {e}")

    return declipped

def sparse_declip(audio, sr, threshold=0.99, iterations=50):
    """
    Advanced declipping using sparse reconstruction.

    Uses the assumption that audio is sparse in frequency domain
    to reconstruct clipped portions.
    """
    from scipy.fft import dct, idct

    segments, _ = detect_clipping(audio, threshold)

    if len(segments) == 0:
        return audio

    declipped = audio.copy()

    # Process in overlapping frames
    frame_length = 1024
    hop_length = 256

    for i in range(0, len(audio) - frame_length, hop_length):
        frame = audio[i:i + frame_length]
        clipped_in_frame = np.abs(frame) >= threshold

        if not np.any(clipped_in_frame):
            continue

        # Iterative hard thresholding
        reconstructed = frame.copy()
        for _ in range(iterations):
            # Transform to DCT domain
            coeffs = dct(reconstructed, norm='ortho')

            # Keep only significant coefficients (sparsity)
            threshold_coeff = np.percentile(np.abs(coeffs), 90)
            coeffs[np.abs(coeffs) < threshold_coeff] = 0

            # Transform back
            reconstructed = idct(coeffs, norm='ortho')

            # Keep original unclipped samples
            reconstructed[~clipped_in_frame] = frame[~clipped_in_frame]

        # Overlap-add
        declipped[i:i + frame_length] = reconstructed

    return declipped

def assess_clipping_severity(audio, threshold=0.99):
    """
    Assess how severe the clipping is.
    """
    segments, clip_pct = detect_clipping(audio, threshold)

    if len(segments) == 0:
        return 'none', 0

    # Average clipped segment length
    avg_len = np.mean([end - start for start, end in segments])

    if clip_pct < 0.1 and avg_len < 10:
        return 'mild', clip_pct
    elif clip_pct < 1.0 and avg_len < 50:
        return 'moderate', clip_pct
    else:
        return 'severe', clip_pct

# Usage
audio, sr = librosa.load('clipped_recording.wav', sr=None)

severity, pct = assess_clipping_severity(audio)
print(f"Clipping severity: {severity} ({pct:.2f}%)")

if severity != 'none':
    declipped = cubic_declip(audio, threshold=0.99)
    # Or for severe clipping:
    # declipped = sparse_declip(audio, sr, threshold=0.99)
```

**Clipping severity guide:**

| Severity | Percentage | Approach |
|----------|------------|----------|
| Mild (< 0.1%) | Occasional peaks | Cubic interpolation |
| Moderate (0.1-1%) | Regular clipping | Sparse reconstruction |
| Severe (> 1%) | Heavy distortion | May be unrecoverable |

Reference: [Audio Declipping Algorithms](https://ieeexplore.ieee.org/document/6854318)
