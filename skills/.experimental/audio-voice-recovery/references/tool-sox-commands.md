---
title: Use SoX for Advanced Audio Manipulation
impact: LOW-MEDIUM
impactDescription: specialized audio operations and batch processing
tags: tool, sox, command-line, effects, noise-reduction
---

## Use SoX for Advanced Audio Manipulation

SoX (Sound eXchange) excels at precise audio manipulation, especially noise reduction with profiles and effects chaining.

**Incorrect (FFmpeg for noise profiling):**

```bash
# FFmpeg adaptive noise reduction (no profile)
ffmpeg -i noisy.wav -af "afftdn=nr=20" denoised.wav
# Works but can't target specific noise signature
```

**Correct (SoX profile-based reduction):**

```bash
# SoX noise profiling for targeted reduction
sox noisy.wav -n trim 0 2 noiseprof noise.prof
sox noisy.wav denoised.wav noisered noise.prof 0.21
# Precisely targets the actual noise in recording
```

**Basic operations:**

```bash
# Get audio info
soxi input.wav

# Format conversion
sox input.mp3 output.wav

# Resample
sox input.wav -r 16000 output.wav

# Convert to mono
sox input.wav output.wav channels 1

# Combine multiple operations
sox input.mp3 -r 16000 -c 1 output.wav
```

**Noise reduction (SoX specialty):**

```bash
# Step 1: Create noise profile from silent segment
sox noisy.wav -n trim 0 2 noiseprof noise.prof

# Step 2: Apply noise reduction
sox noisy.wav cleaned.wav noisered noise.prof 0.21
# 0.21 = reduction amount (0.0-1.0, higher = more aggressive)

# One-liner if noise is at start
sox noisy.wav cleaned.wav noisered <(sox noisy.wav -n trim 0 1 noiseprof -) 0.21
```

**Effects:**

```bash
# High-pass filter
sox input.wav output.wav highpass 80

# Low-pass filter
sox input.wav output.wav lowpass 8000

# Band-pass
sox input.wav output.wav sinc 100-6000

# Normalize to 0dB
sox input.wav output.wav norm

# Normalize to specific level (-3dB)
sox input.wav output.wav gain -n -3

# Compressor
sox input.wav output.wav compand 0.3,1 6:-70,-60,-20 -5 -90 0.2

# Equalization
sox input.wav output.wav equalizer 3000 1q 3

# Reverb removal (not true dereverb, but reduces)
sox input.wav output.wav reverb -w
```

**Segment operations:**

```bash
# Trim (start at 10s, take 30s)
sox input.wav output.wav trim 10 30

# Trim from end (remove last 5s)
sox input.wav output.wav trim 0 -5

# Pad with silence
sox input.wav output.wav pad 1 1  # 1s at start and end

# Fade in/out
sox input.wav output.wav fade t 0.5 0 0.5
```

**Silence operations:**

```bash
# Remove silence from start
sox input.wav output.wav silence 1 0.1 -50d

# Remove silence from both ends
sox input.wav output.wav silence 1 0.1 -50d reverse silence 1 0.1 -50d reverse

# Remove all silence (including middle)
sox input.wav output.wav silence 1 0.1 -50d 1 0.1 -50d
```

**Speed and pitch:**

```bash
# Change speed (also changes pitch)
sox input.wav output.wav speed 0.8

# Change tempo (preserve pitch)
sox input.wav output.wav tempo 0.8

# Change pitch (preserve tempo)
sox input.wav output.wav pitch 200  # Shift up 200 cents
```

**Analysis and statistics:**

```bash
# Audio statistics
sox input.wav -n stat 2>&1

# Detailed stats
sox input.wav -n stats

# Spectrogram image
sox input.wav -n spectrogram -o spectrogram.png
```

**Concatenation and mixing:**

```bash
# Concatenate files
sox file1.wav file2.wav file3.wav combined.wav

# Mix files (overlay)
sox -m file1.wav file2.wav mixed.wav

# Mix with volume adjustment
sox -m -v 1.0 voice.wav -v 0.3 background.wav mixed.wav
```

**Complete forensic pipeline:**

```bash
#!/bin/bash
# forensic_enhance.sh

INPUT="$1"
OUTPUT="${INPUT%.wav}_enhanced.wav"

# Step 1: Extract noise profile from first 2 seconds
sox "$INPUT" -n trim 0 2 noiseprof /tmp/noise.prof

# Step 2: Apply enhancement chain
sox "$INPUT" "$OUTPUT" \
    noisered /tmp/noise.prof 0.21 \
    highpass 80 \
    lowpass 8000 \
    equalizer 2500 1q 3 \
    compand 0.1,0.3 -70,-70,-60,-20,0,-10 -5 -90 0.1 \
    norm -3

echo "Enhanced: $OUTPUT"
soxi "$OUTPUT"
```

**Batch processing:**

```bash
# Process all files with same noise profile
sox reference_noise.wav -n noiseprof global_noise.prof

for f in *.wav; do
    sox "$f" "cleaned_${f}" noisered global_noise.prof 0.21
done

# Parallel processing
find . -name "*.wav" | parallel -j4 'sox {} cleaned_{/} noisered noise.prof 0.21'
```

**SoX effects quick reference:**

| Effect | Purpose | Example |
|--------|---------|---------|
| noisered | Noise reduction | noisered noise.prof 0.21 |
| highpass | Remove low freq | highpass 80 |
| lowpass | Remove high freq | lowpass 8000 |
| sinc | Bandpass filter | sinc 100-6000 |
| norm | Normalize | norm -3 |
| gain | Adjust volume | gain -n -6 |
| compand | Compression | compand 0.3,1 ... |
| equalizer | Parametric EQ | equalizer 3000 1q 3 |
| tempo | Time stretch | tempo 0.8 |
| pitch | Pitch shift | pitch 200 |
| silence | Remove silence | silence 1 0.1 -50d |

Reference: [SoX Manual](http://sox.sourceforge.net/sox.html)
