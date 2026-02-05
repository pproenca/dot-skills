---
name: audio-voice-recovery
description: Audio forensics and voice recovery guidelines for CSI-level audio analysis. This skill should be used when recovering voice from low-quality or low-volume audio, enhancing degraded recordings, performing forensic audio analysis, or transcribing difficult audio. Triggers on tasks involving audio enhancement, noise reduction, voice isolation, forensic authentication, or audio transcription.
---

# Forensic Audio Research Audio Voice Recovery Best Practices

Comprehensive audio forensics and voice recovery guide providing CSI-level capabilities for recovering voice from low-quality, low-volume, or damaged audio recordings. Contains 45 rules across 8 categories, prioritized by impact to guide audio enhancement, forensic analysis, and transcription workflows.

## When to Apply

Reference these guidelines when:
- Recovering voice from noisy or low-quality recordings
- Enhancing audio for transcription or legal evidence
- Performing forensic audio authentication
- Analyzing recordings for tampering or splices
- Building automated audio processing pipelines
- Transcribing difficult or degraded speech

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | Signal Preservation & Analysis | CRITICAL | `signal-` | 5 |
| 2 | Noise Profiling & Estimation | CRITICAL | `noise-` | 5 |
| 3 | Spectral Processing | HIGH | `spectral-` | 6 |
| 4 | Voice Isolation & Enhancement | HIGH | `voice-` | 7 |
| 5 | Temporal Processing | MEDIUM-HIGH | `temporal-` | 5 |
| 6 | Transcription & Recognition | MEDIUM | `transcribe-` | 5 |
| 7 | Forensic Authentication | MEDIUM | `forensic-` | 5 |
| 8 | Tool Integration & Automation | LOW-MEDIUM | `tool-` | 7 |

## Quick Reference

### 1. Signal Preservation & Analysis (CRITICAL)

- [`signal-preserve-original`](references/signal-preserve-original.md) - Never modify original recording
- [`signal-lossless-format`](references/signal-lossless-format.md) - Use lossless formats for processing
- [`signal-sample-rate`](references/signal-sample-rate.md) - Preserve native sample rate
- [`signal-bit-depth`](references/signal-bit-depth.md) - Use maximum bit depth for processing
- [`signal-analyze-first`](references/signal-analyze-first.md) - Analyze before processing

### 2. Noise Profiling & Estimation (CRITICAL)

- [`noise-profile-silence`](references/noise-profile-silence.md) - Extract noise profile from silent segments
- [`noise-identify-type`](references/noise-identify-type.md) - Identify noise type before reduction
- [`noise-adaptive-estimation`](references/noise-adaptive-estimation.md) - Use adaptive estimation for non-stationary noise
- [`noise-snr-assessment`](references/noise-snr-assessment.md) - Measure SNR before and after
- [`noise-avoid-overprocessing`](references/noise-avoid-overprocessing.md) - Avoid over-processing and musical artifacts

### 3. Spectral Processing (HIGH)

- [`spectral-subtraction`](references/spectral-subtraction.md) - Apply spectral subtraction for stationary noise
- [`spectral-wiener-filter`](references/spectral-wiener-filter.md) - Use Wiener filter for optimal noise estimation
- [`spectral-notch-filter`](references/spectral-notch-filter.md) - Apply notch filters for tonal interference
- [`spectral-band-limiting`](references/spectral-band-limiting.md) - Apply frequency band limiting for speech
- [`spectral-equalization`](references/spectral-equalization.md) - Use forensic equalization to restore intelligibility
- [`spectral-declip`](references/spectral-declip.md) - Repair clipped audio before other processing

### 4. Voice Isolation & Enhancement (HIGH)

- [`voice-rnnoise`](references/voice-rnnoise.md) - Use RNNoise for real-time ML denoising
- [`voice-dialogue-isolate`](references/voice-dialogue-isolate.md) - Use source separation for complex backgrounds
- [`voice-formant-preserve`](references/voice-formant-preserve.md) - Preserve formants during pitch manipulation
- [`voice-dereverb`](references/voice-dereverb.md) - Apply dereverberation for room echo
- [`voice-enhance-speech`](references/voice-enhance-speech.md) - Use AI speech enhancement services for quick results
- [`voice-vad-segment`](references/voice-vad-segment.md) - Use VAD for targeted processing
- [`voice-frequency-boost`](references/voice-frequency-boost.md) - Boost frequency regions for specific phonemes

### 5. Temporal Processing (MEDIUM-HIGH)

- [`temporal-dynamic-range`](references/temporal-dynamic-range.md) - Use dynamic range compression for level consistency
- [`temporal-noise-gate`](references/temporal-noise-gate.md) - Apply noise gate to silence non-speech segments
- [`temporal-time-stretch`](references/temporal-time-stretch.md) - Use time stretching for intelligibility
- [`temporal-transient-repair`](references/temporal-transient-repair.md) - Repair transient damage (clicks, pops, dropouts)
- [`temporal-silence-trim`](references/temporal-silence-trim.md) - Trim silence and normalize before export

### 6. Transcription & Recognition (MEDIUM)

- [`transcribe-whisper`](references/transcribe-whisper.md) - Use Whisper for noise-robust transcription
- [`transcribe-multipass`](references/transcribe-multipass.md) - Use multi-pass transcription for difficult audio
- [`transcribe-segment`](references/transcribe-segment.md) - Segment audio for targeted transcription
- [`transcribe-confidence`](references/transcribe-confidence.md) - Track confidence scores for uncertain words
- [`transcribe-hallucination`](references/transcribe-hallucination.md) - Detect and filter ASR hallucinations

### 7. Forensic Authentication (MEDIUM)

- [`forensic-enf-analysis`](references/forensic-enf-analysis.md) - Use ENF analysis for timestamp verification
- [`forensic-metadata`](references/forensic-metadata.md) - Extract and verify audio metadata
- [`forensic-tampering`](references/forensic-tampering.md) - Detect audio tampering and splices
- [`forensic-chain-custody`](references/forensic-chain-custody.md) - Document chain of custody for evidence
- [`forensic-speaker-id`](references/forensic-speaker-id.md) - Extract speaker characteristics for identification

### 8. Tool Integration & Automation (LOW-MEDIUM)

- [`tool-ffmpeg-essentials`](references/tool-ffmpeg-essentials.md) - Master essential FFmpeg audio commands
- [`tool-sox-commands`](references/tool-sox-commands.md) - Use SoX for advanced audio manipulation
- [`tool-python-pipeline`](references/tool-python-pipeline.md) - Build Python audio processing pipelines
- [`tool-audacity-workflow`](references/tool-audacity-workflow.md) - Use Audacity for visual analysis and manual editing
- [`tool-install-guide`](references/tool-install-guide.md) - Install audio forensic toolchain
- [`tool-batch-automation`](references/tool-batch-automation.md) - Automate batch processing workflows
- [`tool-quality-assessment`](references/tool-quality-assessment.md) - Measure audio quality metrics

## Essential Tools

| Tool | Purpose | Install |
|------|---------|---------|
| FFmpeg | Format conversion, filtering | `brew install ffmpeg` |
| SoX | Noise profiling, effects | `brew install sox` |
| Whisper | Speech transcription | `pip install openai-whisper` |
| librosa | Python audio analysis | `pip install librosa` |
| noisereduce | ML noise reduction | `pip install noisereduce` |
| Audacity | Visual editing | `brew install audacity` |

## Quick Enhancement Pipeline

```bash
# 1. Analyze original
ffprobe -v error -show_format -show_streams evidence.wav

# 2. Create working copy with checksum
cp evidence.wav working.wav
sha256sum evidence.wav > evidence.sha256

# 3. Apply enhancement
ffmpeg -i working.wav -af "\
  highpass=f=80,\
  adeclick=w=55:o=75,\
  afftdn=nr=12:nf=-30:nt=w,\
  equalizer=f=2500:t=q:w=1:g=3,\
  loudnorm=I=-16:TP=-1.5:LRA=11\
" enhanced.wav

# 4. Transcribe
whisper enhanced.wav --model large-v3 --language en

# 5. Verify original unchanged
sha256sum -c evidence.sha256
```

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [AGENTS.md](AGENTS.md) | Complete compiled guide with all rules |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
