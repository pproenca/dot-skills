---
title: Use Source Separation for Complex Backgrounds
impact: HIGH
impactDescription: isolates speech from overlapping audio sources
tags: voice, source-separation, dialogue-isolate, music-removal, blind-source-separation
---

## Use Source Separation for Complex Backgrounds

When noise includes other voices, music, or complex sounds, source separation AI models can isolate the target speaker more effectively than traditional filtering.

**Incorrect (filtering mixed sources):**

```bash
# EQ can't separate overlapping voices
ffmpeg -i two_speakers.wav -af "highpass=f=200,lowpass=f=4000" still_mixed.wav
# Both voices still present
```

**Correct (AI source separation):**

```bash
# Using Demucs for voice separation
python -m demucs --two-stems=vocals input.wav
# Creates separated/htdemucs/input/vocals.wav

# Using Spleeter
spleeter separate -p spleeter:2stems -o output input.wav
# Creates output/input/vocals.wav
```

**Python source separation:**

```python
import torch
import torchaudio
from pathlib import Path

def separate_with_demucs(audio_path, output_dir='separated'):
    """
    Use Demucs for high-quality source separation.

    pip install demucs
    """
    import demucs.separate

    # Separate vocals from other sources
    demucs.separate.main([
        '--two-stems', 'vocals',
        '-o', output_dir,
        str(audio_path)
    ])

    # Load separated vocals
    output_path = Path(output_dir) / 'htdemucs' / Path(audio_path).stem / 'vocals.wav'
    vocals, sr = torchaudio.load(output_path)

    return vocals.numpy(), sr

def separate_with_asteroid(audio, sr, model_name='ConvTasNet_Libri2Mix_sepclean_8k'):
    """
    Use Asteroid library for speaker separation.

    pip install asteroid
    """
    from asteroid.models import ConvTasNet
    from asteroid.utils.hub_utils import cached_download

    # Load pretrained model
    model = ConvTasNet.from_pretrained(model_name)
    model.eval()

    # Ensure correct sample rate (8kHz for this model)
    if sr != 8000:
        import librosa
        audio = librosa.resample(audio, orig_sr=sr, target_sr=8000)

    # Convert to tensor
    audio_tensor = torch.tensor(audio).unsqueeze(0).unsqueeze(0).float()

    # Separate
    with torch.no_grad():
        separated = model(audio_tensor)

    # Convert back to numpy
    separated_np = separated.squeeze().numpy()

    return separated_np  # Shape: (n_sources, time)

def isolate_speech_simple(audio, sr):
    """
    Simple approach using frequency masking for speech isolation.

    Less effective than ML methods but no dependencies required.
    """
    import numpy as np
    import librosa

    # STFT
    stft = librosa.stft(audio, n_fft=2048, hop_length=512)
    magnitude = np.abs(stft)
    phase = np.angle(stft)

    # Speech typically dominates in 200-4000 Hz range
    freqs = librosa.fft_frequencies(sr=sr, n_fft=2048)

    # Create speech mask
    speech_mask = np.zeros_like(magnitude)
    speech_band = (freqs >= 200) & (freqs <= 4000)
    speech_mask[speech_band, :] = 1.0

    # Soft masking based on local energy
    frame_energy = np.sum(magnitude ** 2, axis=0)
    energy_threshold = np.percentile(frame_energy, 30)

    # Boost frames likely containing speech
    speech_frames = frame_energy > energy_threshold
    speech_mask[:, speech_frames] *= 1.5
    speech_mask = np.clip(speech_mask, 0, 1)

    # Apply mask
    isolated_magnitude = magnitude * speech_mask
    isolated_stft = isolated_magnitude * np.exp(1j * phase)
    isolated = librosa.istft(isolated_stft, hop_length=512)

    return isolated

# Example usage
if __name__ == '__main__':
    import soundfile as sf

    audio, sr = sf.read('mixed_audio.wav')

    # Option 1: Demucs (best quality, requires model download)
    # vocals, _ = separate_with_demucs('mixed_audio.wav')

    # Option 2: Simple isolation (no ML)
    isolated = isolate_speech_simple(audio, sr)

    sf.write('isolated_speech.wav', isolated, sr)
```

**Install source separation tools:**

```bash
# Demucs (Facebook/Meta)
pip install demucs

# Spleeter (Deezer)
pip install spleeter

# Asteroid (speech separation)
pip install asteroid-filterbanks asteroid
```

**Source separation model comparison:**

| Model | Best For | Quality | Speed |
|-------|----------|---------|-------|
| Demucs | Music/vocals | Excellent | Slow |
| Spleeter | Music/vocals | Good | Fast |
| Asteroid ConvTasNet | Speaker separation | Excellent | Medium |
| OpenUnmix | Music stems | Good | Medium |

**When to use source separation:**

| Scenario | Recommended Approach |
|----------|---------------------|
| Speech + music | Demucs or Spleeter |
| Two overlapping speakers | Asteroid ConvTasNet |
| Speech + TV/radio | Demucs vocals stem |
| Single speaker + noise | RNNoise instead |
| Real-time processing | Not suitable (too slow) |

Reference: [Demucs Music Source Separation](https://github.com/facebookresearch/demucs)
