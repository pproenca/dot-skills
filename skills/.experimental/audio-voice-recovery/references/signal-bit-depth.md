---
title: Use Maximum Bit Depth for Processing
impact: CRITICAL
impactDescription: prevents quantization noise accumulation
tags: signal, bit-depth, quantization, dynamic-range, headroom
---

## Use Maximum Bit Depth for Processing

Each arithmetic operation on low bit-depth audio accumulates quantization errors. Process in 32-bit float to preserve precision across multiple operations.

**Incorrect (precision loss):**

```bash
# 16-bit processing accumulates rounding errors
ffmpeg -i input_16bit.wav -af "volume=0.5,highpass=f=100,volume=2,lowpass=f=4000" output.wav
# Each filter introduces quantization noise at 16-bit precision
```

**Correct (high-precision processing):**

```bash
# Convert to 32-bit float for processing
ffmpeg -i input_16bit.wav -c:a pcm_f32le working_32float.wav

# All intermediate processing maintains full precision
ffmpeg -i working_32float.wav -af "volume=0.5,highpass=f=100,volume=2,lowpass=f=4000" -c:a pcm_f32le processed_32float.wav

# Dither when reducing bit depth for final output
ffmpeg -i processed_32float.wav -af "dither=method=triangular_hp" -c:a pcm_s16le final_16bit.wav
```

**Python high-precision workflow:**

```python
import numpy as np
import soundfile as sf

# Always read as float64 for maximum precision
audio, sr = sf.read('input.wav', dtype='float64')

# All operations in float64
audio = audio * 0.5  # Gain reduction
audio = apply_highpass(audio, sr, cutoff=100)
audio = audio * 2.0  # Gain boost
audio = apply_lowpass(audio, sr, cutoff=4000)

# Proper dithering for bit depth reduction
def triangular_dither(audio, target_bits=16):
    """Apply triangular dither before quantization."""
    scale = 2 ** (target_bits - 1)
    dither = (np.random.triangular(-1, 0, 1, audio.shape) / scale)
    return audio + dither

audio_dithered = triangular_dither(audio)
sf.write('output.wav', audio_dithered, sr, subtype='PCM_16')
```

**Bit depth reference:**

| Bit Depth | Dynamic Range | Use Case |
|-----------|---------------|----------|
| 16-bit | 96 dB | Final delivery |
| 24-bit | 144 dB | Professional recording |
| 32-bit float | 1528 dB | Processing headroom |

Reference: [Digital Audio Fundamentals](https://www.izotope.com/en/learn/digital-audio-basics-sample-rate-and-bit-depth.html)
