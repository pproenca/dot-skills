---
title: Avoid Over-Processing and Musical Artifacts
impact: CRITICAL
impactDescription: prevents speech degradation and "underwater" sound
tags: noise, artifacts, over-processing, musical-noise, distortion
---

## Avoid Over-Processing and Musical Artifacts

Aggressive noise reduction creates "musical noise" (twinkling artifacts) and removes speech harmonics. Use the minimum reduction that achieves intelligibility.

**Incorrect (over-aggressive reduction):**

```bash
# Maximum noise reduction
ffmpeg -i noisy.wav -af "afftdn=nr=97:nf=-70" over_processed.wav
# Results in robotic, underwater-sounding speech with musical artifacts
```

**Correct (conservative, iterative approach):**

```bash
# Start conservative, increase only if needed
# Pass 1: Light reduction
ffmpeg -i noisy.wav -af "afftdn=nr=10:nf=-30" pass1.wav

# Listen, measure SNR, then if needed:
# Pass 2: Moderate reduction
ffmpeg -i noisy.wav -af "afftdn=nr=20:nf=-35" pass2.wav

# Pass 3: Stronger reduction (only if absolutely necessary)
ffmpeg -i noisy.wav -af "afftdn=nr=30:nf=-40" pass3.wav
```

**Python artifact detection:**

```python
import numpy as np
import librosa
from scipy import signal

def detect_musical_artifacts(original, processed, sr):
    """
    Detect musical noise artifacts introduced by processing.

    Musical noise appears as isolated spectral peaks that weren't
    in the original recording.
    """
    frame_length = 2048
    hop_length = 512

    # STFT of both signals
    orig_stft = np.abs(librosa.stft(original, n_fft=frame_length,
                                     hop_length=hop_length))
    proc_stft = np.abs(librosa.stft(processed, n_fft=frame_length,
                                     hop_length=hop_length))

    # Musical artifacts appear as isolated spectral peaks
    # that are louder in processed than original
    artifact_mask = proc_stft > orig_stft * 1.5

    # Check temporal isolation (artifacts appear/disappear rapidly)
    artifact_changes = np.diff(artifact_mask.astype(int), axis=1)
    rapid_changes = np.sum(np.abs(artifact_changes), axis=1)

    # High rapid changes in mid-frequencies indicate musical noise
    mid_freq_bins = slice(int(500 * frame_length / sr),
                          int(4000 * frame_length / sr))
    artifact_score = np.mean(rapid_changes[mid_freq_bins])

    return {
        'artifact_score': artifact_score,
        'has_musical_noise': artifact_score > 50,
        'severity': 'high' if artifact_score > 100 else
                    'medium' if artifact_score > 50 else 'low'
    }

def find_optimal_reduction(audio, sr, max_nr=50, step=5):
    """
    Find optimal noise reduction level that maximizes SNR
    without introducing artifacts.
    """
    from adaptive_spectral_subtraction import adaptive_spectral_subtraction

    best_snr = -np.inf
    best_nr = 0
    results = []

    for nr in range(0, max_nr + 1, step):
        alpha = 1 + nr / 25  # Map to over-subtraction factor

        processed = adaptive_spectral_subtraction(audio, sr, alpha=alpha)

        # Measure SNR
        snr = estimate_snr(processed, sr)

        # Check for artifacts
        artifacts = detect_musical_artifacts(audio, processed, sr)

        results.append({
            'noise_reduction': nr,
            'snr': snr,
            'artifacts': artifacts['severity']
        })

        # Stop if artifacts become significant
        if artifacts['has_musical_noise']:
            print(f"Artifacts detected at NR={nr}, stopping")
            break

        if snr > best_snr:
            best_snr = snr
            best_nr = nr

    print(f"Optimal noise reduction: {best_nr}% (SNR: {best_snr:.1f} dB)")
    return best_nr, results

# Usage
audio, sr = librosa.load('noisy_speech.wav', sr=None)
optimal_nr, scan_results = find_optimal_reduction(audio, sr)
```

**Processing order to minimize artifacts:**

```bash
# Correct order (from least to most aggressive)
ffmpeg -i input.wav -af "\
  highpass=f=80,\                    # 1. Remove DC and rumble
  adeclick=w=55:o=75,\               # 2. Fix transients first
  afftdn=nr=15:nf=-30,\              # 3. Conservative spectral reduction
  dynaudnorm=f=150:g=15\             # 4. Gentle normalization last
" output.wav
```

**Artifact warning signs:**

| Symptom | Cause | Solution |
|---------|-------|----------|
| Twinkling/warbling | Musical noise | Reduce NR strength |
| Underwater sound | Over-smoothing | Reduce smoothing time |
| Robotic quality | Harmonic removal | Lower frequency threshold |
| Pumping/breathing | Aggressive gating | Increase attack/release |

Reference: [Spectral Subtraction Artifacts](https://www.sciencedirect.com/science/article/pii/S1877050915013903)
