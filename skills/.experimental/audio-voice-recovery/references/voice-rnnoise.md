---
title: Use RNNoise for Real-Time ML Denoising
impact: HIGH
impactDescription: 10-20 dB reduction with natural speech preservation
tags: voice, rnnoise, neural-network, deep-learning, real-time
---

## Use RNNoise for Real-Time ML Denoising

RNNoise uses a recurrent neural network trained on diverse noise types. Superior to traditional methods for complex, non-stationary noise (crowds, traffic, wind).

**Incorrect (traditional filter on complex noise):**

```bash
# Spectral subtraction struggles with varying crowd noise
ffmpeg -i crowd_noise.wav -af "afftdn=nr=20" still_noisy.wav
# Result has musical artifacts and residual noise
```

**Correct (neural network denoising):**

```bash
# FFmpeg with RNNoise (if built with ladspa/arnndn support)
ffmpeg -i crowd_noise.wav -af "arnndn=m=/path/to/rnnoise-models/bd.rnnn" cleaned.wav

# Alternative: Use RNNoise standalone
# First convert to raw 48kHz mono
ffmpeg -i input.wav -f s16le -ar 48000 -ac 1 input.raw
./rnnoise_demo input.raw output.raw
ffmpeg -f s16le -ar 48000 -ac 1 -i output.raw output.wav
```

**Python RNNoise wrapper:**

```python
import subprocess
import numpy as np
import soundfile as sf
from pathlib import Path
import tempfile

def apply_rnnoise(audio, sr, rnnoise_path='rnnoise_demo'):
    """
    Apply RNNoise denoising to audio.

    Requires rnnoise_demo binary compiled from https://github.com/xiph/rnnoise
    """
    # RNNoise requires 48kHz mono
    if sr != 48000:
        import librosa
        audio_48k = librosa.resample(audio, orig_sr=sr, target_sr=48000)
    else:
        audio_48k = audio

    # Ensure mono
    if audio_48k.ndim > 1:
        audio_48k = audio_48k.mean(axis=1)

    with tempfile.TemporaryDirectory() as tmpdir:
        input_path = Path(tmpdir) / 'input.raw'
        output_path = Path(tmpdir) / 'output.raw'

        # Write raw PCM
        audio_int16 = (audio_48k * 32767).astype(np.int16)
        audio_int16.tofile(input_path)

        # Run RNNoise
        subprocess.run([rnnoise_path, str(input_path), str(output_path)],
                      check=True, capture_output=True)

        # Read result
        denoised_int16 = np.fromfile(output_path, dtype=np.int16)
        denoised = denoised_int16.astype(np.float32) / 32767

    # Resample back if needed
    if sr != 48000:
        denoised = librosa.resample(denoised, orig_sr=48000, target_sr=sr)

    return denoised

# Alternative: Use noisereduce library (Python RNNoise-like)
def apply_noisereduce(audio, sr):
    """
    Use noisereduce library for ML-based denoising.

    pip install noisereduce
    """
    import noisereduce as nr

    # Reduce noise with default settings
    reduced = nr.reduce_noise(y=audio, sr=sr)

    return reduced

def apply_noisereduce_stationary(audio, sr, noise_clip=None):
    """
    Use noisereduce with explicit noise sample for stationary noise.
    """
    import noisereduce as nr

    if noise_clip is not None:
        # Use provided noise sample
        reduced = nr.reduce_noise(
            y=audio,
            sr=sr,
            y_noise=noise_clip,
            stationary=True
        )
    else:
        # Auto-detect stationary noise
        reduced = nr.reduce_noise(
            y=audio,
            sr=sr,
            stationary=True,
            prop_decrease=0.8  # 80% reduction
        )

    return reduced

# Usage
audio, sr = sf.read('noisy_speech.wav')

# Option 1: Full RNNoise (requires binary)
# denoised = apply_rnnoise(audio, sr)

# Option 2: noisereduce library
denoised = apply_noisereduce(audio, sr)

sf.write('denoised.wav', denoised, sr)
```

**Install noisereduce:**

```bash
pip install noisereduce torch torchaudio
```

**RNNoise vs Traditional comparison:**

| Aspect | Traditional (afftdn) | RNNoise/noisereduce |
|--------|---------------------|---------------------|
| Stationary noise | Excellent | Good |
| Non-stationary noise | Poor | Excellent |
| Musical artifacts | Common | Rare |
| Speech naturalness | Can sound hollow | Natural |
| Computation | Light | Moderate |
| Training required | No | Pre-trained |

**When to use RNNoise:**

| Scenario | Recommendation |
|----------|---------------|
| Crowd/babble noise | RNNoise |
| Wind/outdoor | RNNoise |
| Traffic | RNNoise |
| HVAC/fan (steady) | Traditional may suffice |
| Electrical hum | Notch filter better |
| Mixed noise types | RNNoise |

Reference: [RNNoise: Learning Noise Suppression](https://jmvalin.ca/demo/rnnoise/)
