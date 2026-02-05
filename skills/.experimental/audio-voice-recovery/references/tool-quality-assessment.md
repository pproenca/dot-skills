---
title: Measure Audio Quality Metrics
impact: LOW-MEDIUM
impactDescription: quantifies enhancement effectiveness
tags: tool, quality, metrics, assessment, validation
---

## Measure Audio Quality Metrics

Objective quality metrics validate that enhancement improved the audio. Measure before and after processing.

**Incorrect (subjective assessment only):**

```python
# Listening test only
# "The enhanced version sounds better"
# Subjective, not reproducible, not defensible
```

**Correct (objective measurement):**

```python
# Measure SNR, PESQ, STOI before and after
results = comprehensive_quality_assessment('original.wav', 'enhanced.wav')

print(f"SNR improvement: {results['comparison']['snr_improvement']:.1f} dB")
print(f"PESQ score: {results['comparison']['pesq']:.2f}")
# Objective, reproducible, defensible metrics
```

**Python quality assessment:**

```python
import numpy as np
import librosa
from scipy import signal
import soundfile as sf

def calculate_snr(audio, sr, speech_segments=None):
    """
    Estimate Signal-to-Noise Ratio.
    """
    frame_length = int(0.025 * sr)
    rms = librosa.feature.rms(y=audio, frame_length=frame_length)[0]
    rms_db = 20 * np.log10(rms + 1e-10)

    # Use percentiles to estimate speech vs noise
    noise_level = np.percentile(rms_db, 20)  # Bottom 20% = noise
    speech_level = np.percentile(rms_db, 80)  # Top 20% = speech

    snr = speech_level - noise_level
    return snr

def calculate_pesq(original, enhanced, sr):
    """
    Calculate PESQ (Perceptual Evaluation of Speech Quality).
    Requires: pip install pesq
    """
    try:
        from pesq import pesq as pesq_score

        # PESQ requires 8kHz or 16kHz
        if sr not in [8000, 16000]:
            original = librosa.resample(original, orig_sr=sr, target_sr=16000)
            enhanced = librosa.resample(enhanced, orig_sr=sr, target_sr=16000)
            sr = 16000

        # Ensure same length
        min_len = min(len(original), len(enhanced))
        original = original[:min_len]
        enhanced = enhanced[:min_len]

        score = pesq_score(sr, original, enhanced, 'wb')  # Wideband
        return score  # Range: -0.5 to 4.5 (higher = better)
    except ImportError:
        return None

def calculate_stoi(original, enhanced, sr):
    """
    Calculate STOI (Short-Time Objective Intelligibility).
    Requires: pip install pystoi
    """
    try:
        from pystoi import stoi

        # Ensure same length
        min_len = min(len(original), len(enhanced))
        original = original[:min_len]
        enhanced = enhanced[:min_len]

        score = stoi(original, enhanced, sr, extended=False)
        return score  # Range: 0 to 1 (higher = better)
    except ImportError:
        return None

def calculate_segmental_snr(audio, sr, frame_ms=30):
    """
    Calculate segmental SNR (more robust than global SNR).
    """
    frame_length = int(frame_ms * sr / 1000)
    hop_length = frame_length // 2

    frames = librosa.util.frame(audio, frame_length=frame_length,
                                 hop_length=hop_length)

    snrs = []
    for frame in frames.T:
        frame_power = np.mean(frame ** 2)
        if frame_power > 1e-10:
            noise_estimate = np.percentile(np.abs(frame), 10) ** 2
            snr = 10 * np.log10(frame_power / (noise_estimate + 1e-10))
            snr = np.clip(snr, -10, 35)  # Clip to reasonable range
            snrs.append(snr)

    return np.mean(snrs) if snrs else 0

def calculate_spectral_distortion(original, enhanced, sr):
    """
    Calculate spectral distortion between original and enhanced.
    Lower = less distortion = better.
    """
    n_fft = 2048

    orig_spec = np.abs(librosa.stft(original, n_fft=n_fft))
    enh_spec = np.abs(librosa.stft(enhanced, n_fft=n_fft))

    # Ensure same size
    min_frames = min(orig_spec.shape[1], enh_spec.shape[1])
    orig_spec = orig_spec[:, :min_frames]
    enh_spec = enh_spec[:, :min_frames]

    # Log spectral distortion
    orig_log = 10 * np.log10(orig_spec ** 2 + 1e-10)
    enh_log = 10 * np.log10(enh_spec ** 2 + 1e-10)

    distortion = np.sqrt(np.mean((orig_log - enh_log) ** 2))
    return distortion

def comprehensive_quality_assessment(original_path, enhanced_path):
    """
    Calculate all quality metrics.
    """
    original, sr_orig = sf.read(original_path)
    enhanced, sr_enh = sf.read(enhanced_path)

    # Ensure same sample rate
    if sr_orig != sr_enh:
        enhanced = librosa.resample(enhanced, orig_sr=sr_enh, target_sr=sr_orig)
        sr_enh = sr_orig

    sr = sr_orig

    results = {
        'original': {
            'file': original_path,
            'snr': calculate_snr(original, sr),
            'segmental_snr': calculate_segmental_snr(original, sr),
            'peak_db': 20 * np.log10(np.max(np.abs(original)) + 1e-10),
            'rms_db': 20 * np.log10(np.sqrt(np.mean(original**2)) + 1e-10),
        },
        'enhanced': {
            'file': enhanced_path,
            'snr': calculate_snr(enhanced, sr),
            'segmental_snr': calculate_segmental_snr(enhanced, sr),
            'peak_db': 20 * np.log10(np.max(np.abs(enhanced)) + 1e-10),
            'rms_db': 20 * np.log10(np.sqrt(np.mean(enhanced**2)) + 1e-10),
        },
        'comparison': {
            'snr_improvement': calculate_snr(enhanced, sr) - calculate_snr(original, sr),
            'pesq': calculate_pesq(original, enhanced, sr),
            'stoi': calculate_stoi(original, enhanced, sr),
            'spectral_distortion': calculate_spectral_distortion(original, enhanced, sr),
        }
    }

    return results

def print_quality_report(results):
    """Print formatted quality report."""
    print("=" * 60)
    print("AUDIO QUALITY ASSESSMENT REPORT")
    print("=" * 60)

    print("\nOriginal Audio:")
    print(f"  SNR: {results['original']['snr']:.1f} dB")
    print(f"  Segmental SNR: {results['original']['segmental_snr']:.1f} dB")
    print(f"  Peak level: {results['original']['peak_db']:.1f} dB")
    print(f"  RMS level: {results['original']['rms_db']:.1f} dB")

    print("\nEnhanced Audio:")
    print(f"  SNR: {results['enhanced']['snr']:.1f} dB")
    print(f"  Segmental SNR: {results['enhanced']['segmental_snr']:.1f} dB")
    print(f"  Peak level: {results['enhanced']['peak_db']:.1f} dB")
    print(f"  RMS level: {results['enhanced']['rms_db']:.1f} dB")

    print("\nImprovement Metrics:")
    print(f"  SNR improvement: {results['comparison']['snr_improvement']:.1f} dB")

    if results['comparison']['pesq'] is not None:
        print(f"  PESQ score: {results['comparison']['pesq']:.2f} (scale: -0.5 to 4.5)")

    if results['comparison']['stoi'] is not None:
        print(f"  STOI score: {results['comparison']['stoi']:.3f} (scale: 0 to 1)")

    print(f"  Spectral distortion: {results['comparison']['spectral_distortion']:.1f} dB")

    # Interpretation
    print("\nInterpretation:")
    if results['comparison']['snr_improvement'] > 5:
        print("  ✓ Significant SNR improvement")
    elif results['comparison']['snr_improvement'] > 0:
        print("  ○ Moderate SNR improvement")
    else:
        print("  ✗ No SNR improvement (enhancement may have degraded audio)")

    if results['comparison']['spectral_distortion'] < 10:
        print("  ✓ Low spectral distortion (natural sound preserved)")
    else:
        print("  ○ High spectral distortion (may sound processed)")

# Usage
if __name__ == '__main__':
    results = comprehensive_quality_assessment('original.wav', 'enhanced.wav')
    print_quality_report(results)
```

**Install quality metrics:**

```bash
pip install pesq pystoi
```

**Quality metric interpretation:**

| Metric | Good | Fair | Poor |
|--------|------|------|------|
| SNR improvement | > 5 dB | 2-5 dB | < 2 dB |
| PESQ | > 3.5 | 2.5-3.5 | < 2.5 |
| STOI | > 0.85 | 0.65-0.85 | < 0.65 |
| Spectral distortion | < 5 dB | 5-15 dB | > 15 dB |

Reference: [PESQ ITU-T P.862](https://www.itu.int/rec/T-REC-P.862)
