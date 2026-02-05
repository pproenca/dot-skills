---
title: Master Essential FFmpeg Audio Commands
impact: LOW-MEDIUM
impactDescription: enables rapid audio manipulation
tags: tool, ffmpeg, command-line, conversion, filters
---

## Master Essential FFmpeg Audio Commands

FFmpeg is the Swiss Army knife of audio processing. Master these commands for efficient forensic workflows.

**Incorrect (inefficient command usage):**

```bash
# Multiple separate commands for simple task
ffmpeg -i input.wav temp1.wav
ffmpeg -i temp1.wav -af "highpass=f=80" temp2.wav
ffmpeg -i temp2.wav -af "lowpass=f=8000" output.wav
rm temp1.wav temp2.wav
# Slow, creates temporary files, quality loss
```

**Correct (efficient filter chain):**

```bash
# Single command with filter chain
ffmpeg -i input.wav -af "highpass=f=80,lowpass=f=8000" output.wav
# Fast, no intermediates, single encode
```

**Basic information:**

```bash
# Get detailed audio info
ffprobe -v error -show_format -show_streams input.wav

# Quick format check
ffprobe -v error -select_streams a:0 -show_entries stream=codec_name,sample_rate,channels,bits_per_sample input.wav

# Duration only
ffprobe -v error -show_entries format=duration -of csv=p=0 input.wav
```

**Format conversion:**

```bash
# Lossless WAV to FLAC
ffmpeg -i input.wav -c:a flac output.flac

# MP3 to WAV (lossless preservation)
ffmpeg -i input.mp3 -c:a pcm_s24le output.wav

# Multi-channel to mono
ffmpeg -i stereo.wav -ac 1 mono.wav

# Resample to 16kHz for ASR
ffmpeg -i input.wav -ar 16000 output_16k.wav

# Combine format changes
ffmpeg -i input.mp3 -ar 16000 -ac 1 -c:a pcm_s16le whisper_ready.wav
```

**Segment extraction:**

```bash
# Extract segment (start at 10s, duration 30s)
ffmpeg -i input.wav -ss 10 -t 30 segment.wav

# Extract segment (start at 10s, end at 40s)
ffmpeg -i input.wav -ss 10 -to 40 segment.wav

# Precise frame-accurate extraction
ffmpeg -i input.wav -ss 10.500 -t 5.250 -c:a pcm_s24le segment.wav
```

**Audio filters:**

```bash
# High-pass filter (remove rumble)
ffmpeg -i input.wav -af "highpass=f=80" filtered.wav

# Low-pass filter (remove hiss)
ffmpeg -i input.wav -af "lowpass=f=8000" filtered.wav

# Band-pass for speech
ffmpeg -i input.wav -af "highpass=f=100,lowpass=f=6000" speech_band.wav

# Noise reduction (FFT-based)
ffmpeg -i noisy.wav -af "afftdn=nr=12:nf=-25:nt=w" denoised.wav

# Dynamic compression
ffmpeg -i input.wav -af "acompressor=threshold=-20dB:ratio=4:attack=5:release=100" compressed.wav

# Loudness normalization
ffmpeg -i input.wav -af "loudnorm=I=-16:TP=-1.5:LRA=11" normalized.wav

# Volume adjustment
ffmpeg -i quiet.wav -af "volume=6dB" louder.wav

# Declicking
ffmpeg -i clicky.wav -af "adeclick=w=55:o=75" declicked.wav

# Time stretching (preserve pitch)
ffmpeg -i fast.wav -af "rubberband=tempo=0.8" slower.wav
```

**Filter chains:**

```bash
# Complete enhancement pipeline
ffmpeg -i input.wav -af "\
  highpass=f=80,\
  adeclick=w=55:o=75,\
  afftdn=nr=12:nf=-25,\
  equalizer=f=2500:t=q:w=1:g=3,\
  acompressor=threshold=-20dB:ratio=3:attack=5:release=100,\
  loudnorm=I=-16:TP=-1.5:LRA=11\
" enhanced.wav

# Hum removal (60Hz + harmonics)
ffmpeg -i hum.wav -af "\
  bandreject=f=60:w=2,\
  bandreject=f=120:w=2,\
  bandreject=f=180:w=2,\
  bandreject=f=240:w=2\
" dehum.wav

# Forensic enhancement preset
ffmpeg -i evidence.wav -af "\
  highpass=f=100,\
  afftdn=nr=10:nf=-30:nt=w,\
  equalizer=f=2500:t=q:w=1:g=2,\
  loudnorm=I=-18:TP=-2:LRA=11\
" evidence_enhanced.wav
```

**Generate analysis files:**

```bash
# Spectrogram image
ffmpeg -i input.wav -lavfi showspectrumpic=s=1920x1080:mode=combined:color=intensity:scale=log spectrogram.png

# Waveform image
ffmpeg -i input.wav -filter_complex "showwavespic=s=1920x480" waveform.png

# Volume statistics
ffmpeg -i input.wav -af "volumedetect" -f null - 2>&1 | grep -E "(mean|max)_volume"

# Silence detection
ffmpeg -i input.wav -af "silencedetect=noise=-40dB:d=0.5" -f null - 2>&1 | grep silence
```

**Batch processing:**

```bash
# Process all WAV files in directory
for f in *.wav; do
  ffmpeg -i "$f" -af "highpass=f=80,afftdn=nr=10" "processed_${f}"
done

# Convert all MP3 to WAV
for f in *.mp3; do
  ffmpeg -i "$f" -c:a pcm_s24le "${f%.mp3}.wav"
done
```

**Stream operations:**

```bash
# Hash audio stream (for integrity)
ffmpeg -i input.wav -f hash -hash sha256 -

# Extract raw PCM
ffmpeg -i input.wav -f s16le -ac 1 -ar 16000 output.raw

# Raw PCM to WAV
ffmpeg -f s16le -ar 16000 -ac 1 -i input.raw output.wav
```

**FFmpeg filter quick reference:**

| Filter | Purpose | Example |
|--------|---------|---------|
| highpass | Remove low frequencies | highpass=f=80 |
| lowpass | Remove high frequencies | lowpass=f=8000 |
| bandreject | Notch filter | bandreject=f=60:w=2 |
| afftdn | FFT noise reduction | afftdn=nr=12:nf=-25 |
| adeclick | Remove clicks | adeclick=w=55:o=75 |
| acompressor | Dynamic compression | acompressor=threshold=-20dB |
| loudnorm | EBU R128 normalization | loudnorm=I=-16 |
| equalizer | Parametric EQ | equalizer=f=3000:g=3 |
| rubberband | Time/pitch stretch | rubberband=tempo=0.8 |

Reference: [FFmpeg Audio Filters](https://ffmpeg.org/ffmpeg-filters.html#Audio-Filters)
