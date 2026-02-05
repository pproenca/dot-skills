---
title: Apply Dereverberation for Room Echo
impact: HIGH
impactDescription: 5-15 dB clarity improvement in reverberant recordings
tags: voice, dereverb, reverb, echo, room-acoustics
---

## Apply Dereverberation for Room Echo

Reverb (room echo) smears speech and reduces intelligibility. Dereverberation algorithms suppress late reflections while preserving direct sound.

**Incorrect (EQ cannot remove reverb):**

```bash
# Filtering doesn't address time-domain smearing
ffmpeg -i reverb_room.wav -af "highpass=f=200" still_reverby.wav
# Reverb remains at all frequencies
```

**Correct (dedicated dereverberation):**

```bash
# FFmpeg arnndn can help with reverb (trained model)
ffmpeg -i reverb.wav -af "arnndn=m=/path/to/dereverb.rnnn" dereverberated.wav

# iZotope RX (commercial) has dedicated De-reverb module
```

**Python dereverberation:**

```python
import numpy as np
import librosa
from scipy import signal

def estimate_rt60(audio, sr):
    """
    Estimate room reverberation time (RT60).

    RT60 is the time for sound to decay by 60 dB.
    """
    # Use energy decay curve
    frame_length = int(0.025 * sr)
    hop_length = frame_length // 2

    # Calculate energy per frame
    rms = librosa.feature.rms(y=audio, frame_length=frame_length,
                              hop_length=hop_length)[0]
    energy_db = 20 * np.log10(rms + 1e-10)

    # Find decay from peak
    peak_idx = np.argmax(energy_db)
    decay_curve = energy_db[peak_idx:]

    # Estimate RT60 from decay slope
    if len(decay_curve) < 10:
        return 0.5  # Default estimate

    # Linear fit to decay
    x = np.arange(len(decay_curve)) * hop_length / sr
    try:
        slope, intercept = np.polyfit(x[:len(x)//2], decay_curve[:len(x)//2], 1)
        rt60 = -60 / slope if slope < 0 else 1.0
        rt60 = np.clip(rt60, 0.1, 5.0)
    except:
        rt60 = 0.5

    return rt60

def spectral_subtraction_dereverb(audio, sr, rt60=0.5):
    """
    Simple dereverberation using spectral subtraction of late reverb.
    """
    n_fft = 2048
    hop_length = 512

    stft = librosa.stft(audio, n_fft=n_fft, hop_length=hop_length)
    magnitude = np.abs(stft)
    phase = np.angle(stft)

    # Estimate late reverb energy
    # Late reverb arrives after ~50ms
    late_reverb_frames = int(0.05 * sr / hop_length)

    # Moving average of past frames as reverb estimate
    reverb_estimate = np.zeros_like(magnitude)
    for i in range(late_reverb_frames, magnitude.shape[1]):
        reverb_estimate[:, i] = np.mean(
            magnitude[:, i-late_reverb_frames:i],
            axis=1
        ) * 0.5  # Reverb decay factor

    # Subtract reverb
    alpha = 1.5  # Over-subtraction
    beta = 0.01  # Spectral floor

    dereverbed = magnitude - alpha * reverb_estimate
    dereverbed = np.maximum(dereverbed, beta * magnitude)

    # Reconstruct
    output_stft = dereverbed * np.exp(1j * phase)
    output = librosa.istft(output_stft, hop_length=hop_length)

    return output

def weighted_prediction_error_dereverb(audio, sr, filter_length=512):
    """
    Weighted Prediction Error (WPE) dereverberation.

    This is a more sophisticated approach used in professional tools.
    """
    try:
        from nara_wpe import wpe
        from nara_wpe.wpe import get_power

        # WPE expects (channels, samples)
        if audio.ndim == 1:
            audio = audio.reshape(1, -1)

        # STFT
        stft_options = dict(
            size=512,
            shift=128,
            window_length=None,
            fading=True,
            pad=True,
        )

        from nara_wpe.utils import stft, istft
        Y = stft(audio, **stft_options)

        # WPE dereverberation
        Z = wpe(
            Y,
            taps=filter_length // 128,
            delay=3,
            iterations=5,
        )

        # Inverse STFT
        dereverbed = istft(Z, size=512, shift=128)

        return dereverbed.flatten()

    except ImportError:
        print("nara_wpe not installed, using simple method")
        return spectral_subtraction_dereverb(audio, sr)

def estimate_direct_to_reverb_ratio(audio, sr):
    """
    Estimate the Direct-to-Reverberant Ratio (DRR).

    Lower DRR = more reverb = harder to understand.
    """
    # Energy in first 10ms (direct sound)
    direct_samples = int(0.010 * sr)
    direct_energy = np.sum(audio[:direct_samples] ** 2)

    # Energy after 50ms (reverb)
    reverb_start = int(0.050 * sr)
    reverb_energy = np.sum(audio[reverb_start:] ** 2)

    drr = 10 * np.log10(direct_energy / (reverb_energy + 1e-10))

    return drr

# Usage
if __name__ == '__main__':
    import soundfile as sf

    audio, sr = sf.read('reverberant_speech.wav')

    # Estimate reverb parameters
    rt60 = estimate_rt60(audio, sr)
    drr = estimate_direct_to_reverb_ratio(audio, sr)
    print(f"Estimated RT60: {rt60:.2f}s, DRR: {drr:.1f} dB")

    # Apply dereverberation
    dereverbed = spectral_subtraction_dereverb(audio, sr, rt60)

    sf.write('dereverbed.wav', dereverbed, sr)
```

**Install WPE dereverberation:**

```bash
pip install nara_wpe
```

**Reverb severity guide:**

| RT60 | DRR | Severity | Approach |
|------|-----|----------|----------|
| < 0.3s | > 10 dB | Mild | Light spectral subtraction |
| 0.3-0.6s | 0-10 dB | Moderate | WPE or RNN dereverb |
| 0.6-1.0s | -10-0 dB | Heavy | Multi-pass dereverb |
| > 1.0s | < -10 dB | Extreme | May be unrecoverable |

Reference: [WPE Dereverberation](https://github.com/fgnt/nara_wpe)
