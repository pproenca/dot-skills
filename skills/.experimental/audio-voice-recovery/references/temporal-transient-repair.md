---
title: Repair Transient Damage (Clicks, Pops, Dropouts)
impact: MEDIUM-HIGH
impactDescription: recovers words obscured by transient noise
tags: temporal, transient, click, pop, dropout, repair
---

## Repair Transient Damage (Clicks, Pops, Dropouts)

Transient damage (clicks, pops, digital dropouts) obscures speech. Repair by detecting anomalies and interpolating from surrounding audio.

**Incorrect (filtering affects entire signal):**

```bash
# Low-pass doesn't remove clicks
ffmpeg -i clicky.wav -af "lowpass=f=8000" still_clicky.wav
# Clicks are broadband, filtering removes clarity not clicks
```

**Correct (targeted click removal):**

```bash
# FFmpeg declicker
ffmpeg -i clicky.wav -af "adeclick=w=55:o=75" declicked.wav
# w: window size, o: overlap percentage

# For dropout repair
ffmpeg -i dropout.wav -af "adenorm" repaired.wav

# Combined repair chain
ffmpeg -i damaged.wav -af "adeclick,acrusher=level_in=1:level_out=1:bits=16:mode=log:aa=1" repaired.wav
```

**Python transient repair:**

```python
import numpy as np
from scipy import signal, interpolate
import librosa
import soundfile as sf

def detect_clicks(audio, sr, threshold_factor=5):
    """
    Detect clicks based on sudden amplitude changes.
    """
    # First derivative (velocity)
    diff1 = np.abs(np.diff(audio))

    # Second derivative (acceleration)
    diff2 = np.abs(np.diff(diff1))

    # Threshold based on statistics
    mean_diff = np.mean(diff1)
    std_diff = np.std(diff1)
    threshold = mean_diff + threshold_factor * std_diff

    # Find click locations
    clicks = np.where(diff1 > threshold)[0]

    # Cluster nearby clicks
    click_regions = []
    if len(clicks) > 0:
        start = clicks[0]
        for i in range(1, len(clicks)):
            if clicks[i] - clicks[i-1] > 10:  # Gap between clusters
                click_regions.append((start, clicks[i-1]))
                start = clicks[i]
        click_regions.append((start, clicks[-1]))

    return click_regions

def repair_clicks_interpolate(audio, click_regions, margin=5):
    """
    Repair clicks using cubic interpolation.
    """
    repaired = audio.copy()

    for start, end in click_regions:
        # Expand region slightly
        repair_start = max(0, start - margin)
        repair_end = min(len(audio), end + margin)

        # Get surrounding samples for interpolation
        context_before = max(0, repair_start - margin * 2)
        context_after = min(len(audio), repair_end + margin * 2)

        x_known = np.concatenate([
            np.arange(context_before, repair_start),
            np.arange(repair_end, context_after)
        ])
        y_known = audio[x_known]

        if len(x_known) < 4:
            continue

        # Cubic interpolation
        try:
            f = interpolate.CubicSpline(x_known, y_known)
            x_repair = np.arange(repair_start, repair_end)
            repaired[x_repair] = f(x_repair)
        except:
            pass

    return repaired

def detect_dropouts(audio, sr, min_duration_ms=1, threshold=-60):
    """
    Detect digital dropouts (sudden silence or very low level).
    """
    threshold_lin = 10 ** (threshold / 20)
    min_samples = int(min_duration_ms * sr / 1000)

    # Find very quiet samples
    quiet = np.abs(audio) < threshold_lin

    # Find contiguous quiet regions
    diff = np.diff(quiet.astype(int))
    starts = np.where(diff == 1)[0]
    ends = np.where(diff == -1)[0]

    if quiet[0]:
        starts = np.insert(starts, 0, 0)
    if quiet[-1]:
        ends = np.append(ends, len(audio) - 1)

    dropouts = [(s, e) for s, e in zip(starts, ends)
                if e - s >= min_samples and s > 0 and e < len(audio) - 1]

    return dropouts

def repair_dropouts(audio, dropouts, sr, method='interpolate'):
    """
    Repair dropout regions.
    """
    repaired = audio.copy()

    for start, end in dropouts:
        duration = end - start

        if method == 'interpolate':
            # Simple linear interpolation
            repaired[start:end] = np.linspace(
                audio[start-1], audio[end], duration
            )

        elif method == 'crossfade':
            # Crossfade from before to after
            fade_in = np.linspace(0, 1, duration)
            fade_out = 1 - fade_in

            # Use mirrored audio from before/after
            before = audio[max(0, start - duration):start]
            after = audio[end:min(len(audio), end + duration)]

            if len(before) >= duration and len(after) >= duration:
                repaired[start:end] = (before[-duration:] * fade_out +
                                        after[:duration] * fade_in)

        elif method == 'noise':
            # Fill with low-level noise
            noise_level = np.mean(np.abs(audio)) * 0.01
            repaired[start:end] = np.random.randn(duration) * noise_level

    return repaired

def adaptive_declick(audio, sr, sensitivity=0.5):
    """
    Adaptive click removal with adjustable sensitivity.
    """
    # Adjust threshold based on sensitivity
    threshold_factor = 3 + (1 - sensitivity) * 7  # 3-10 range

    click_regions = detect_clicks(audio, sr, threshold_factor)
    print(f"Detected {len(click_regions)} click regions")

    repaired = repair_clicks_interpolate(audio, click_regions)

    return repaired

def comprehensive_transient_repair(audio, sr):
    """
    Full transient repair pipeline.
    """
    # Step 1: Remove clicks
    clicks = detect_clicks(audio, sr)
    print(f"Detected {len(clicks)} clicks")
    audio = repair_clicks_interpolate(audio, clicks)

    # Step 2: Repair dropouts
    dropouts = detect_dropouts(audio, sr)
    print(f"Detected {len(dropouts)} dropouts")
    audio = repair_dropouts(audio, dropouts, sr, method='crossfade')

    return audio

# Usage
if __name__ == '__main__':
    audio, sr = sf.read('damaged_audio.wav')

    repaired = comprehensive_transient_repair(audio, sr)

    sf.write('repaired.wav', repaired, sr)
```

**FFmpeg click repair settings:**

| Setting | Light | Standard | Aggressive |
|---------|-------|----------|------------|
| Window (w) | 30 | 55 | 100 |
| Overlap (o) | 50 | 75 | 95 |
| Use for | Vinyl, light damage | Most clicks | Heavy damage |

Reference: [Audio Restoration Techniques](https://www.izotope.com/en/learn/audio-restoration.html)
