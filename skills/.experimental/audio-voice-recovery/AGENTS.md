# Audio Voice Recovery

**Version 0.1.0**  
Forensic Audio Research  
February 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive audio forensics and voice recovery guide designed for AI agents and LLMs. Contains 45 rules across 8 categories, prioritized by impact from critical (signal preservation, noise profiling) to operational (tool integration, batch automation). Each rule includes detailed explanations, production-realistic code examples comparing incorrect vs. correct implementations, and specific impact metrics. Covers the complete pipeline from evidence handling through noise reduction, voice enhancement, transcription, and forensic authentication using tools like FFmpeg, SoX, Whisper, RNNoise, and Python audio libraries.

---

## Table of Contents

1. [Signal Preservation & Analysis](#1-signal-preservation-analysis) — **CRITICAL**
   - 1.1 [Analyze Before Processing](#11-analyze-before-processing)
   - 1.2 [Never Modify Original Recording](#12-never-modify-original-recording)
   - 1.3 [Preserve Native Sample Rate](#13-preserve-native-sample-rate)
   - 1.4 [Use Lossless Formats for Processing](#14-use-lossless-formats-for-processing)
   - 1.5 [Use Maximum Bit Depth for Processing](#15-use-maximum-bit-depth-for-processing)
2. [Noise Profiling & Estimation](#2-noise-profiling-estimation) — **CRITICAL**
   - 2.1 [Avoid Over-Processing and Musical Artifacts](#21-avoid-over-processing-and-musical-artifacts)
   - 2.2 [Extract Noise Profile from Silent Segments](#22-extract-noise-profile-from-silent-segments)
   - 2.3 [Identify Noise Type Before Reduction](#23-identify-noise-type-before-reduction)
   - 2.4 [Measure Signal-to-Noise Ratio Before and After](#24-measure-signal-to-noise-ratio-before-and-after)
   - 2.5 [Use Adaptive Noise Estimation for Non-Stationary Noise](#25-use-adaptive-noise-estimation-for-non-stationary-noise)
3. [Spectral Processing](#3-spectral-processing) — **HIGH**
   - 3.1 [Apply Frequency Band Limiting for Speech](#31-apply-frequency-band-limiting-for-speech)
   - 3.2 [Apply Notch Filters for Tonal Interference](#32-apply-notch-filters-for-tonal-interference)
   - 3.3 [Apply Spectral Subtraction for Stationary Noise](#33-apply-spectral-subtraction-for-stationary-noise)
   - 3.4 [Repair Clipped Audio Before Other Processing](#34-repair-clipped-audio-before-other-processing)
   - 3.5 [Use Forensic Equalization to Restore Intelligibility](#35-use-forensic-equalization-to-restore-intelligibility)
   - 3.6 [Use Wiener Filter for Optimal Noise Estimation](#36-use-wiener-filter-for-optimal-noise-estimation)
4. [Voice Isolation & Enhancement](#4-voice-isolation-enhancement) — **HIGH**
   - 4.1 [Apply Dereverberation for Room Echo](#41-apply-dereverberation-for-room-echo)
   - 4.2 [Boost Frequency Regions for Specific Phonemes](#42-boost-frequency-regions-for-specific-phonemes)
   - 4.3 [Preserve Formants During Pitch Manipulation](#43-preserve-formants-during-pitch-manipulation)
   - 4.4 [Use AI Speech Enhancement Services for Quick Results](#44-use-ai-speech-enhancement-services-for-quick-results)
   - 4.5 [Use RNNoise for Real-Time ML Denoising](#45-use-rnnoise-for-real-time-ml-denoising)
   - 4.6 [Use Source Separation for Complex Backgrounds](#46-use-source-separation-for-complex-backgrounds)
   - 4.7 [Use Voice Activity Detection for Targeted Processing](#47-use-voice-activity-detection-for-targeted-processing)
5. [Temporal Processing](#5-temporal-processing) — **MEDIUM-HIGH**
   - 5.1 [Apply Noise Gate to Silence Non-Speech Segments](#51-apply-noise-gate-to-silence-non-speech-segments)
   - 5.2 [Repair Transient Damage (Clicks, Pops, Dropouts)](#52-repair-transient-damage-clicks-pops-dropouts)
   - 5.3 [Trim Silence and Normalize Before Export](#53-trim-silence-and-normalize-before-export)
   - 5.4 [Use Dynamic Range Compression for Level Consistency](#54-use-dynamic-range-compression-for-level-consistency)
   - 5.5 [Use Time Stretching for Intelligibility](#55-use-time-stretching-for-intelligibility)
6. [Transcription & Recognition](#6-transcription-recognition) — **MEDIUM**
   - 6.1 [Detect and Filter ASR Hallucinations](#61-detect-and-filter-asr-hallucinations)
   - 6.2 [Segment Audio for Targeted Transcription](#62-segment-audio-for-targeted-transcription)
   - 6.3 [Track Confidence Scores for Uncertain Words](#63-track-confidence-scores-for-uncertain-words)
   - 6.4 [Use Multi-Pass Transcription for Difficult Audio](#64-use-multi-pass-transcription-for-difficult-audio)
   - 6.5 [Use Whisper for Noise-Robust Transcription](#65-use-whisper-for-noise-robust-transcription)
7. [Forensic Authentication](#7-forensic-authentication) — **MEDIUM**
   - 7.1 [Detect Audio Tampering and Splices](#71-detect-audio-tampering-and-splices)
   - 7.2 [Document Chain of Custody for Evidence](#72-document-chain-of-custody-for-evidence)
   - 7.3 [Extract and Verify Audio Metadata](#73-extract-and-verify-audio-metadata)
   - 7.4 [Extract Speaker Characteristics for Identification](#74-extract-speaker-characteristics-for-identification)
   - 7.5 [Use ENF Analysis for Timestamp Verification](#75-use-enf-analysis-for-timestamp-verification)
8. [Tool Integration & Automation](#8-tool-integration-automation) — **LOW-MEDIUM**
   - 8.1 [Automate Batch Processing Workflows](#81-automate-batch-processing-workflows)
   - 8.2 [Build Python Audio Processing Pipelines](#82-build-python-audio-processing-pipelines)
   - 8.3 [Install Audio Forensic Toolchain](#83-install-audio-forensic-toolchain)
   - 8.4 [Master Essential FFmpeg Audio Commands](#84-master-essential-ffmpeg-audio-commands)
   - 8.5 [Measure Audio Quality Metrics](#85-measure-audio-quality-metrics)
   - 8.6 [Use Audacity for Visual Analysis and Manual Editing](#86-use-audacity-for-visual-analysis-and-manual-editing)
   - 8.7 [Use SoX for Advanced Audio Manipulation](#87-use-sox-for-advanced-audio-manipulation)

---

## 1. Signal Preservation & Analysis

**Impact: CRITICAL**

First contact with audio determines maximum recoverable quality. Wrong format conversion, improper bit-depth, or lossy re-encoding permanently destroys data that no algorithm can recover.

### 1.1 Analyze Before Processing

**Impact: CRITICAL (prevents wrong enhancement approach)**

Blind enhancement can worsen audio. Always analyze the recording first to identify noise types, frequency content, and clipping before selecting processing strategy.

**Incorrect (blind processing):**

```bash
# Applying random filters without analysis
ffmpeg -i unknown.wav -af "highpass=f=300,lowpass=f=3000,anlmdn" enhanced.wav
# May remove important speech frequencies or leave dominant noise untouched
```

**Correct (analysis-driven processing):**

```bash
# Step 1: Get format and duration info
ffprobe -v error -show_entries format=duration,bit_rate:stream=codec_name,sample_rate,channels,bits_per_sample -of json input.wav

# Step 2: Generate spectrogram for visual analysis
ffmpeg -i input.wav -lavfi showspectrumpic=s=1920x1080:mode=combined:color=intensity:scale=log spectrogram.png

# Step 3: Analyze peak levels and potential clipping
ffmpeg -i input.wav -af "volumedetect" -f null - 2>&1 | grep -E "(max_volume|mean_volume)"

# Step 4: Detect silence/noise floor
ffmpeg -i input.wav -af "silencedetect=noise=-50dB:d=0.5" -f null - 2>&1 | grep silence
```

**Python comprehensive analysis:**

```python
import librosa
import librosa.display
import numpy as np
import matplotlib.pyplot as plt

def analyze_audio(filepath):
    """Complete audio analysis for forensic processing."""
    audio, sr = librosa.load(filepath, sr=None, mono=False)

    # Basic stats
    print(f"Sample rate: {sr} Hz")
    print(f"Duration: {len(audio)/sr:.2f} seconds")
    print(f"Channels: {1 if audio.ndim == 1 else audio.shape[0]}")

    if audio.ndim > 1:
        audio = audio[0]  # Analyze first channel

    # Peak and RMS levels
    peak_db = 20 * np.log10(np.max(np.abs(audio)) + 1e-10)
    rms_db = 20 * np.log10(np.sqrt(np.mean(audio**2)) + 1e-10)
    print(f"Peak level: {peak_db:.1f} dB")
    print(f"RMS level: {rms_db:.1f} dB")
    print(f"Crest factor: {peak_db - rms_db:.1f} dB")

    # Clipping detection
    clip_threshold = 0.99
    clipped_samples = np.sum(np.abs(audio) > clip_threshold)
    print(f"Clipped samples: {clipped_samples} ({100*clipped_samples/len(audio):.4f}%)")

    # Noise floor estimation (using quietest 10%)
    frame_length = int(0.025 * sr)  # 25ms frames
    rms_frames = librosa.feature.rms(y=audio, frame_length=frame_length)[0]
    noise_floor = np.percentile(rms_frames, 10)
    noise_floor_db = 20 * np.log10(noise_floor + 1e-10)
    print(f"Estimated noise floor: {noise_floor_db:.1f} dB")

    # Spectral centroid (brightness indicator)
    spectral_centroid = np.mean(librosa.feature.spectral_centroid(y=audio, sr=sr))
    print(f"Spectral centroid: {spectral_centroid:.0f} Hz")

    # Generate spectrogram
    plt.figure(figsize=(14, 8))
    D = librosa.amplitude_to_db(np.abs(librosa.stft(audio)), ref=np.max)
    librosa.display.specshow(D, sr=sr, x_axis='time', y_axis='log')
    plt.colorbar(format='%+2.0f dB')
    plt.title('Spectrogram Analysis')
    plt.savefig('analysis_spectrogram.png', dpi=150)

    return {
        'sample_rate': sr,
        'peak_db': peak_db,
        'rms_db': rms_db,
        'noise_floor_db': noise_floor_db,
        'clipped_samples': clipped_samples,
        'spectral_centroid': spectral_centroid
    }

# Usage
analysis = analyze_audio('evidence.wav')
```

**Decision matrix based on analysis:**

| Finding | Recommended Action |
|---------|-------------------|
| Noise floor > -40 dB | Aggressive noise reduction needed |
| Clipping detected | De-clip before other processing |
| Low spectral centroid | Voice may be muffled, use presence boost |
| High-frequency noise | Low-pass filter or spectral subtraction |
| 50/60 Hz hum | Notch filter at mains frequency |

Reference: [Audio Analysis Best Practices](https://www.izotope.com/en/learn/audio-analysis.html)

### 1.2 Never Modify Original Recording

**Impact: CRITICAL (prevents permanent evidence destruction)**

Always work on copies of audio evidence. The original recording is legally irreplaceable and any modification—even "enhancement"—can render it inadmissible in court.

**Incorrect (destructive workflow):**

```bash
# Directly modifying evidence file
ffmpeg -i evidence.wav -af "highpass=f=200,lowpass=f=3000" evidence.wav
# Original is now permanently altered
```

**Correct (preservation workflow):**

```bash
# Create forensic copy with checksum
cp evidence.wav evidence_working_copy.wav
sha256sum evidence.wav > evidence.sha256

# All processing on copy only
ffmpeg -i evidence_working_copy.wav -af "highpass=f=200,lowpass=f=3000" evidence_enhanced.wav

# Verify original unchanged
sha256sum -c evidence.sha256
```

**Chain of custody documentation:**

```bash
# Document every processing step
echo "$(date -Iseconds) | Created working copy from evidence.wav (SHA256: $(sha256sum evidence.wav | cut -d' ' -f1))" >> processing_log.txt
```

**Benefits:**
- Maintains legal admissibility
- Allows comparison with original
- Enables different enhancement approaches
- Provides audit trail for court

Reference: [SWGDE Guidelines for Forensic Audio](https://www.swgde.org/)

### 1.3 Preserve Native Sample Rate

**Impact: CRITICAL (prevents aliasing and interpolation artifacts)**

Resampling introduces interpolation errors. Process at the original sample rate; only resample for final delivery requirements.

**Incorrect (unnecessary resampling):**

```bash
# Upsampling doesn't add information, just artifacts
ffmpeg -i phone_call_8khz.wav -ar 48000 upsampled.wav
# Processing at 48kHz wastes CPU and can introduce ringing

# Downsampling loses frequencies permanently
ffmpeg -i studio_48khz.wav -ar 16000 downsampled.wav
# All content above 8kHz is gone forever
```

**Correct (native rate processing):**

```bash
# Check original sample rate first
ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of csv=p=0 input.wav
# Output: 8000

# Process at native rate
ffmpeg -i phone_call_8khz.wav -af "highpass=f=200,anlmdn" enhanced_8khz.wav

# Only resample for specific tool requirements
ffmpeg -i enhanced_8khz.wav -ar 16000 for_whisper.wav  # Whisper expects 16kHz
```

**When resampling is necessary:**

```python
import librosa

# High-quality resampling with librosa
audio, sr = librosa.load('recording.wav', sr=None)  # Native rate
print(f"Original sample rate: {sr}")

# Only if target tool requires specific rate
if sr != 16000:
    audio_resampled = librosa.resample(audio, orig_sr=sr, target_sr=16000,
                                        res_type='kaiser_best')  # Highest quality
```

**Sample rate reference:**

| Source | Typical Rate | Nyquist Limit |
|--------|--------------|---------------|
| Phone (narrowband) | 8 kHz | 4 kHz |
| Phone (wideband) | 16 kHz | 8 kHz |
| Voice recorder | 22.05-44.1 kHz | 11-22 kHz |
| Professional | 48-96 kHz | 24-48 kHz |

Reference: [Nyquist-Shannon Sampling Theorem](https://en.wikipedia.org/wiki/Nyquist%E2%80%93Shannon_sampling_theorem)

### 1.4 Use Lossless Formats for Processing

**Impact: CRITICAL (prevents 10-20% quality loss per re-encode)**

Each lossy encoding cycle (MP3, AAC, OGG) permanently removes audio information. Use WAV or FLAC for all intermediate processing steps.

**Incorrect (lossy chain destroys data):**

```bash
# Each step loses ~10-20% of audio detail
ffmpeg -i recording.mp3 -af "volume=2" step1.mp3
ffmpeg -i step1.mp3 -af "highpass=f=100" step2.mp3
ffmpeg -i step2.mp3 -af "anlmdn" final.mp3
# Result: severely degraded audio with artifacts
```

**Correct (lossless processing chain):**

```bash
# Convert to lossless immediately
ffmpeg -i recording.mp3 -c:a pcm_s24le working.wav

# All processing in lossless format
ffmpeg -i working.wav -af "volume=2" step1.wav
ffmpeg -i step1.wav -af "highpass=f=100" step2.wav
ffmpeg -i step2.wav -af "anlmdn" final.wav

# Only convert to lossy for final delivery if required
ffmpeg -i final.wav -c:a libmp3lame -q:a 0 final_delivery.mp3
```

**Recommended formats:**

| Format | Use Case | Bit Depth |
|--------|----------|-----------|
| WAV (PCM) | All processing | 24-bit or 32-bit float |
| FLAC | Archival storage | 24-bit |
| RF64 | Files > 4GB | 24-bit or higher |

**Python example:**

```python
import soundfile as sf

# Read any format, work in float64 internally
audio, sr = sf.read('recording.mp3', dtype='float64')

# Process...

# Save as 24-bit WAV for maximum quality
sf.write('processed.wav', audio, sr, subtype='PCM_24')
```

Reference: [FFmpeg Audio Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/HighQualityAudio)

### 1.5 Use Maximum Bit Depth for Processing

**Impact: CRITICAL (prevents quantization noise accumulation)**

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

---

## 2. Noise Profiling & Estimation

**Impact: CRITICAL**

Accurate noise profile is the foundation for all enhancement algorithms. Incorrect estimation causes musical artifacts, speech distortion, or removes voice frequencies mistaken for noise.

### 2.1 Avoid Over-Processing and Musical Artifacts

**Impact: CRITICAL (prevents speech degradation and "underwater" sound)**

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

### 2.2 Extract Noise Profile from Silent Segments

**Impact: CRITICAL (2-5× better noise reduction accuracy)**

Noise reduction algorithms need a pure noise sample. Extract from segments where no speech occurs for accurate spectral estimation.

**Incorrect (estimating from speech):**

```bash
# Using entire file including speech corrupts noise profile
ffmpeg -i recording.wav -af "afftdn=nr=20" denoised.wav
# Adaptive mode may include speech harmonics in noise estimate
```

**Correct (profile from silence):**

```bash
# Step 1: Find silent segments
ffmpeg -i recording.wav -af "silencedetect=noise=-35dB:d=0.5" -f null - 2>&1 | grep silence_start

# Step 2: Extract pure noise segment (e.g., first 2 seconds of silence)
ffmpeg -i recording.wav -ss 0.5 -t 2.0 noise_sample.wav

# Step 3: Use noise sample for profile-based reduction
# With SoX:
sox recording.wav -n noiseprof noise.prof
sox recording.wav denoised.wav noisered noise.prof 0.21
```

**Python noise profiling:**

```python
import numpy as np
import librosa
from scipy import signal

def find_noise_segments(audio, sr, threshold_db=-40, min_duration=0.3):
    """Find segments containing only noise (no speech)."""
    frame_length = int(0.025 * sr)
    hop_length = frame_length // 4

    # Calculate RMS energy per frame
    rms = librosa.feature.rms(y=audio, frame_length=frame_length, hop_length=hop_length)[0]
    rms_db = 20 * np.log10(rms + 1e-10)

    # Find frames below threshold
    quiet_frames = rms_db < threshold_db

    # Convert to time segments
    frame_times = librosa.frames_to_time(np.arange(len(rms)), sr=sr, hop_length=hop_length)

    segments = []
    start = None
    for i, is_quiet in enumerate(quiet_frames):
        if is_quiet and start is None:
            start = frame_times[i]
        elif not is_quiet and start is not None:
            if frame_times[i] - start >= min_duration:
                segments.append((start, frame_times[i]))
            start = None

    return segments

def extract_noise_profile(audio, sr, segments):
    """Extract average noise spectrum from silent segments."""
    noise_samples = []
    for start, end in segments:
        start_sample = int(start * sr)
        end_sample = int(end * sr)
        noise_samples.append(audio[start_sample:end_sample])

    if not noise_samples:
        raise ValueError("No silent segments found for noise profiling")

    # Concatenate and compute average spectrum
    noise_audio = np.concatenate(noise_samples)
    f, noise_psd = signal.welch(noise_audio, sr, nperseg=2048)

    return f, noise_psd

# Usage
audio, sr = librosa.load('recording.wav', sr=None)
segments = find_noise_segments(audio, sr, threshold_db=-35)
print(f"Found {len(segments)} noise segments")

if segments:
    freqs, noise_profile = extract_noise_profile(audio, sr, segments)
```

**Best noise segment locations:**

| Location | Quality | Notes |
|----------|---------|-------|
| Recording start (before speech) | Excellent | Captures initial room tone |
| Natural pauses | Good | May have breath/movement |
| Recording end | Good | May have handling noise |
| Very quiet words | Poor | Contains speech remnants |

Reference: [SoX Noise Reduction](http://sox.sourceforge.net/sox.html)

### 2.3 Identify Noise Type Before Reduction

**Impact: CRITICAL (wrong algorithm can worsen audio)**

Different noise types require different algorithms. Stationary noise (hum, hiss) responds to spectral subtraction; transient noise (clicks, pops) needs time-domain repair.

**Incorrect (one-size-fits-all):**

```bash
# Using broadband denoiser on clicky audio
ffmpeg -i clicks_and_pops.wav -af "anlmdn=s=10" output.wav
# Clicks remain, speech gets muffled
```

**Correct (type-specific processing):**

```bash
# For stationary noise (hiss, hum, fan)
ffmpeg -i hissy_audio.wav -af "afftdn=nf=-25:nr=10:nt=w" denoised.wav

# For transient noise (clicks, pops)
ffmpeg -i clicky_audio.wav -af "adeclick=w=55:o=75" declicked.wav

# For tonal noise (hum, whistle)
ffmpeg -i hum_audio.wav -af "anlmf=o=3" dehum.wav

# Combined approach for mixed noise
ffmpeg -i mixed_noise.wav -af "adeclick,anlmf=o=2,afftdn=nr=8" clean.wav
```

**Noise type identification:**

```python
import numpy as np
import librosa
from scipy import signal

def identify_noise_type(audio, sr):
    """Analyze audio to identify dominant noise characteristics."""
    results = {}

    # 1. Check for tonal components (hum, whistle)
    f, psd = signal.welch(audio, sr, nperseg=4096)
    peaks, properties = signal.find_peaks(psd, prominence=np.max(psd)/10)
    peak_freqs = f[peaks]

    # Common hum frequencies
    mains_freqs = [50, 60, 100, 120, 150, 180, 200, 240]  # Hz
    detected_hum = [pf for pf in peak_freqs if any(abs(pf - mf) < 5 for mf in mains_freqs)]
    results['tonal_hum'] = len(detected_hum) > 0
    results['hum_frequencies'] = detected_hum

    # 2. Check for transient noise (clicks)
    # High derivative indicates sudden amplitude changes
    diff = np.abs(np.diff(audio))
    threshold = np.mean(diff) + 5 * np.std(diff)
    transients = np.sum(diff > threshold)
    results['transient_clicks'] = transients > len(audio) / sr  # More than 1 per second
    results['click_count'] = transients

    # 3. Check for broadband noise (hiss)
    # High-frequency energy relative to mid-frequency
    high_freq_energy = np.mean(psd[f > 4000])
    mid_freq_energy = np.mean(psd[(f > 500) & (f < 4000)])
    results['broadband_hiss'] = high_freq_energy > mid_freq_energy * 0.3
    results['hiss_ratio'] = high_freq_energy / (mid_freq_energy + 1e-10)

    # 4. Check for rumble (low-frequency noise)
    low_freq_energy = np.mean(psd[f < 100])
    results['low_freq_rumble'] = low_freq_energy > mid_freq_energy * 0.5

    return results

def recommend_processing(noise_analysis):
    """Recommend processing chain based on noise analysis."""
    chain = []

    if noise_analysis['transient_clicks']:
        chain.append(f"adeclick (detected {noise_analysis['click_count']} transients)")

    if noise_analysis['low_freq_rumble']:
        chain.append("highpass=f=80 (rumble removal)")

    if noise_analysis['tonal_hum']:
        freqs = noise_analysis['hum_frequencies']
        chain.append(f"notch filters at {freqs[:3]} Hz")

    if noise_analysis['broadband_hiss']:
        chain.append(f"afftdn (hiss ratio: {noise_analysis['hiss_ratio']:.2f})")

    return chain

# Usage
audio, sr = librosa.load('recording.wav', sr=None)
analysis = identify_noise_type(audio, sr)
recommendations = recommend_processing(analysis)
print("Recommended processing chain:")
for step in recommendations:
    print(f"  - {step}")
```

**Noise type reference:**

| Noise Type | Characteristics | Best Algorithm |
|------------|-----------------|----------------|
| Hiss | Broadband, stationary | Spectral subtraction, Wiener filter |
| Hum | Tonal at 50/60 Hz + harmonics | Notch filter, adaptive filter |
| Clicks/Pops | Short transients | Declicker, interpolation |
| Rumble | Low frequency | High-pass filter |
| Wind | Non-stationary broadband | Adaptive filter |
| Reverb | Delayed copies | Dereverb algorithms |

Reference: [iZotope Audio Repair Guide](https://www.izotope.com/en/learn/audio-repair.html)

### 2.4 Measure Signal-to-Noise Ratio Before and After

**Impact: CRITICAL (validates enhancement effectiveness)**

Without SNR measurement, you cannot verify improvement. Always quantify before/after to ensure processing helped rather than harmed.

**Incorrect (subjective evaluation only):**

```bash
# Just listening and guessing
ffmpeg -i noisy.wav -af "afftdn=nr=30" enhanced.wav
# "Sounds better" is not forensically defensible
```

**Correct (measured improvement):**

```bash
# Measure input levels
ffmpeg -i noisy.wav -af "astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.Overall.RMS_level" -f null - 2>&1 | grep RMS

# Get noise floor from silent segment
ffmpeg -i noisy.wav -ss 0 -t 1 -af "astats=metadata=1" -f null - 2>&1 | grep RMS

# Calculate approximate SNR
# SNR = Speech_RMS - Noise_RMS (in dB)
```

**Python SNR measurement:**

```python
import numpy as np
import librosa

def estimate_snr(audio, sr, speech_segments=None, noise_segments=None):
    """
    Estimate Signal-to-Noise Ratio.

    If segments not provided, uses energy-based detection.
    """
    frame_length = int(0.025 * sr)
    hop_length = frame_length // 2

    # Calculate RMS energy per frame
    rms = librosa.feature.rms(y=audio, frame_length=frame_length,
                               hop_length=hop_length)[0]

    if speech_segments is None or noise_segments is None:
        # Automatic detection using histogram
        rms_db = 20 * np.log10(rms + 1e-10)

        # Noise floor: bottom 20% of frames
        noise_threshold = np.percentile(rms_db, 20)
        noise_frames = rms[rms_db <= noise_threshold]

        # Speech: top 50% of frames
        speech_threshold = np.percentile(rms_db, 50)
        speech_frames = rms[rms_db >= speech_threshold]
    else:
        # Use provided segments
        noise_frames = []
        speech_frames = []
        frame_times = librosa.frames_to_time(np.arange(len(rms)), sr=sr,
                                              hop_length=hop_length)
        for i, t in enumerate(frame_times):
            for start, end in noise_segments:
                if start <= t <= end:
                    noise_frames.append(rms[i])
            for start, end in speech_segments:
                if start <= t <= end:
                    speech_frames.append(rms[i])
        noise_frames = np.array(noise_frames)
        speech_frames = np.array(speech_frames)

    if len(noise_frames) == 0 or len(speech_frames) == 0:
        return None

    # Calculate SNR
    noise_power = np.mean(noise_frames ** 2)
    speech_power = np.mean(speech_frames ** 2)

    snr_db = 10 * np.log10(speech_power / (noise_power + 1e-10))

    return snr_db

def compare_enhancement(original, enhanced, sr):
    """Compare SNR before and after enhancement."""
    snr_before = estimate_snr(original, sr)
    snr_after = estimate_snr(enhanced, sr)

    print(f"SNR before: {snr_before:.1f} dB")
    print(f"SNR after:  {snr_after:.1f} dB")
    print(f"Improvement: {snr_after - snr_before:.1f} dB")

    return {
        'snr_before': snr_before,
        'snr_after': snr_after,
        'improvement': snr_after - snr_before
    }

# Usage
original, sr = librosa.load('noisy.wav', sr=None)
enhanced, _ = librosa.load('enhanced.wav', sr=None)

results = compare_enhancement(original, enhanced, sr)

# Document for forensic report
if results['improvement'] > 0:
    print(f"Enhancement validated: {results['improvement']:.1f} dB improvement")
else:
    print("WARNING: Enhancement may have degraded audio quality")
```

**SNR interpretation:**

| SNR Range | Speech Intelligibility |
|-----------|----------------------|
| < 0 dB | Unintelligible |
| 0-5 dB | Very difficult |
| 5-10 dB | Difficult |
| 10-15 dB | Fair |
| 15-20 dB | Good |
| > 20 dB | Excellent |

**Forensic documentation template:**

```text
Audio Enhancement Report
========================
Original file: evidence_001.wav
Enhanced file: evidence_001_enhanced.wav

Measurements:
- Original SNR: 4.2 dB
- Enhanced SNR: 14.8 dB
- Improvement: 10.6 dB

Processing applied:
1. High-pass filter (80 Hz)
2. Spectral subtraction (α=2.0)
3. Wiener filter (noise tracking enabled)

Conclusion: Enhancement improved intelligibility from
"very difficult" to "fair-good" range.
```

Reference: [SNR Measurement Standards](https://en.wikipedia.org/wiki/Signal-to-noise_ratio)

### 2.5 Use Adaptive Noise Estimation for Non-Stationary Noise

**Impact: CRITICAL (handles varying noise without manual profiles)**

Static noise profiles fail when noise changes over time (traffic, crowd, wind). Adaptive algorithms continuously update their noise estimate.

**Incorrect (static profile on dynamic noise):**

```bash
# Static profile from start of recording
sox recording.wav -n trim 0 2 noiseprof static.prof
sox recording.wav output.wav noisered static.prof 0.21
# Noise that appears later isn't removed; early noise may be over-reduced
```

**Correct (adaptive estimation):**

```bash
# FFmpeg adaptive frequency-domain denoiser
ffmpeg -i recording.wav -af "afftdn=nt=w:om=o:tr=1" adaptive_denoised.wav
# nt=w: Wiener filter
# om=o: Output only cleaned signal
# tr=1: Track noise in real-time

# For varying noise levels, use adaptive mode
ffmpeg -i recording.wav -af "afftdn=nr=10:nf=-25:tn=1" output.wav
# tn=1: Enable noise floor tracking
```

**RNNoise for ML-based adaptive denoising:**

```bash
# RNNoise via FFmpeg (if compiled with ladspa support)
ffmpeg -i recording.wav -af "arnndn=m=rnnoise-models/bd.rnnn" denoised.wav

# Or using standalone rnnoise
rnnoise_demo recording.raw denoised.raw
```

**Python adaptive noise reduction:**

```python
import numpy as np
from scipy import signal
import librosa

def adaptive_spectral_subtraction(audio, sr, frame_ms=25, hop_ms=10,
                                   noise_frames=10, alpha=2.0, beta=0.01):
    """
    Adaptive spectral subtraction that tracks noise over time.

    Parameters:
    - noise_frames: Number of initial frames to estimate noise
    - alpha: Over-subtraction factor (higher = more aggressive)
    - beta: Spectral floor (prevents negative values)
    """
    frame_length = int(frame_ms * sr / 1000)
    hop_length = int(hop_ms * sr / 1000)
    n_fft = 2 ** int(np.ceil(np.log2(frame_length)))

    # STFT
    stft = librosa.stft(audio, n_fft=n_fft, hop_length=hop_length,
                        win_length=frame_length)
    magnitude = np.abs(stft)
    phase = np.angle(stft)

    # Initial noise estimate from first N frames
    noise_estimate = np.mean(magnitude[:, :noise_frames], axis=1, keepdims=True)

    # Process each frame with adaptive update
    output_magnitude = np.zeros_like(magnitude)
    smoothing = 0.98  # Noise estimate smoothing factor

    for i in range(magnitude.shape[1]):
        frame_mag = magnitude[:, i:i+1]

        # Spectral subtraction
        subtracted = frame_mag - alpha * noise_estimate
        floored = np.maximum(subtracted, beta * frame_mag)
        output_magnitude[:, i:i+1] = floored

        # Adaptive noise update during quiet frames
        frame_energy = np.mean(frame_mag)
        noise_energy = np.mean(noise_estimate)

        # If frame is likely noise-only, update estimate
        if frame_energy < noise_energy * 1.5:
            noise_estimate = smoothing * noise_estimate + (1 - smoothing) * frame_mag

    # Reconstruct
    output_stft = output_magnitude * np.exp(1j * phase)
    output_audio = librosa.istft(output_stft, hop_length=hop_length,
                                  win_length=frame_length)

    return output_audio

# Usage
audio, sr = librosa.load('variable_noise.wav', sr=None)
cleaned = adaptive_spectral_subtraction(audio, sr, alpha=2.5)
```

**When to use adaptive vs static:**

| Scenario | Approach |
|----------|----------|
| Controlled environment, consistent noise | Static profile |
| Outdoor recording, traffic | Adaptive |
| Moving source/microphone | Adaptive |
| Multiple noise sources | Adaptive |
| Very short recording | Static (not enough data to adapt) |

Reference: [Adaptive Noise Reduction Techniques](https://www.sciencedirect.com/science/article/pii/S1877050916300758)

---

## 3. Spectral Processing

**Impact: HIGH**

Frequency-domain operations (spectral subtraction, Wiener filtering, notch filters) directly target noise while preserving voice characteristics. The core of forensic audio enhancement.

### 3.1 Apply Frequency Band Limiting for Speech

**Impact: HIGH (removes out-of-band noise without affecting intelligibility)**

Human speech occupies 80 Hz to 8 kHz. Filtering outside this range removes noise without affecting intelligibility. Telephone-band (300-3400 Hz) often sufficient for recognition.

**Incorrect (too aggressive filtering):**

```bash
# Cutting above 3 kHz removes consonant clarity
ffmpeg -i recording.wav -af "lowpass=f=2500" muffled.wav
# 's', 'f', 'th' sounds become indistinguishable
```

**Correct (speech-appropriate band limiting):**

```bash
# Full speech bandwidth (80 Hz - 8 kHz)
ffmpeg -i noisy.wav -af "highpass=f=80,lowpass=f=8000" full_speech.wav

# Telephone bandwidth (for severely degraded audio)
ffmpeg -i noisy.wav -af "highpass=f=300,lowpass=f=3400" telephone_band.wav

# Presence boost for clarity (2-4 kHz emphasis)
ffmpeg -i dull_speech.wav -af "\
  highpass=f=80,\
  equalizer=f=3000:t=q:w=1:g=3,\
  lowpass=f=8000\
" presence_boost.wav
```

**Python smart band limiting:**

```python
import numpy as np
from scipy import signal
import librosa

def speech_bandpass(audio, sr, low_freq=80, high_freq=8000, order=5):
    """
    Apply Butterworth bandpass filter optimized for speech.
    """
    nyquist = sr / 2

    # Ensure frequencies are within valid range
    low = max(low_freq, 20) / nyquist
    high = min(high_freq, nyquist - 100) / nyquist

    b, a = signal.butter(order, [low, high], btype='band')
    filtered = signal.filtfilt(b, a, audio)

    return filtered

def adaptive_band_limiting(audio, sr, target='intelligibility'):
    """
    Apply band limiting based on target use case.
    """
    configs = {
        'full_speech': {'low': 80, 'high': 8000},
        'telephone': {'low': 300, 'high': 3400},
        'intelligibility': {'low': 150, 'high': 6000},
        'male_voice': {'low': 80, 'high': 5000},
        'female_voice': {'low': 150, 'high': 8000},
        'whisper': {'low': 200, 'high': 6000},
    }

    config = configs.get(target, configs['intelligibility'])
    return speech_bandpass(audio, sr, config['low'], config['high'])

def detect_speech_band(audio, sr, threshold_db=-40):
    """
    Detect the actual frequency range containing speech energy.
    """
    n_fft = 2048
    stft = np.abs(librosa.stft(audio, n_fft=n_fft))
    freqs = librosa.fft_frequencies(sr=sr, n_fft=n_fft)

    # Average spectrum
    avg_spectrum = np.mean(stft, axis=1)
    avg_spectrum_db = 20 * np.log10(avg_spectrum + 1e-10)

    # Normalize
    avg_spectrum_db -= np.max(avg_spectrum_db)

    # Find frequency range above threshold
    active = avg_spectrum_db > threshold_db
    active_freqs = freqs[active]

    if len(active_freqs) > 0:
        low_freq = max(active_freqs[0], 50)
        high_freq = min(active_freqs[-1], sr / 2 - 100)
    else:
        low_freq, high_freq = 80, 8000  # Default

    return low_freq, high_freq

def smart_band_limit(audio, sr, margin_low=0.8, margin_high=1.2):
    """
    Detect speech band and apply filtering with safety margins.
    """
    detected_low, detected_high = detect_speech_band(audio, sr)

    # Apply margins
    filter_low = detected_low * margin_low
    filter_high = detected_high * margin_high

    print(f"Detected speech band: {detected_low:.0f} - {detected_high:.0f} Hz")
    print(f"Filtering: {filter_low:.0f} - {filter_high:.0f} Hz")

    return speech_bandpass(audio, sr, filter_low, filter_high)

# Usage
audio, sr = librosa.load('noisy_speech.wav', sr=None)
filtered = smart_band_limit(audio, sr)
```

**Speech frequency reference:**

| Phoneme Type | Frequency Range | Examples |
|--------------|-----------------|----------|
| Fundamental (F0) | 80-300 Hz | Voice pitch |
| Vowels | 300-3000 Hz | a, e, i, o, u |
| Nasals | 200-2500 Hz | m, n, ng |
| Fricatives | 2000-8000 Hz | s, f, sh, th |
| Plosives | Broadband burst | p, t, k, b, d, g |

**Band limiting strategy by noise type:**

| Noise Location | Filter Approach |
|---------------|-----------------|
| Low rumble (< 100 Hz) | High-pass at 80-120 Hz |
| High hiss (> 6 kHz) | Low-pass at 6-8 kHz |
| Both | Bandpass 100-6000 Hz |
| Mid-frequency noise | Use spectral subtraction instead |

Reference: [Speech Frequency Characteristics](https://en.wikipedia.org/wiki/Voice_frequency)

### 3.2 Apply Notch Filters for Tonal Interference

**Impact: HIGH (removes hum without affecting speech)**

Electrical hum (50/60 Hz) and its harmonics appear as sharp spectral lines. Notch filters surgically remove these without affecting surrounding frequencies.

**Incorrect (broadband filter removes speech):**

```bash
# High-pass removes too much, including bass voice
ffmpeg -i hum_recording.wav -af "highpass=f=200" removed_bass.wav
# Male voices lose body and warmth
```

**Correct (surgical notch removal):**

```bash
# Remove 60 Hz hum and harmonics (US power)
ffmpeg -i hum_recording.wav -af "\
  bandreject=f=60:w=2,\
  bandreject=f=120:w=2,\
  bandreject=f=180:w=2,\
  bandreject=f=240:w=2,\
  bandreject=f=300:w=2\
" dehum_us.wav

# Remove 50 Hz hum and harmonics (EU/Asia power)
ffmpeg -i hum_recording.wav -af "\
  bandreject=f=50:w=2,\
  bandreject=f=100:w=2,\
  bandreject=f=150:w=2,\
  bandreject=f=200:w=2,\
  bandreject=f=250:w=2\
" dehum_eu.wav

# Auto-detect and remove with anlmf (adaptive line noise filter)
ffmpeg -i hum_recording.wav -af "anlmf=o=3" auto_dehum.wav
```

**Python precision notch filter:**

```python
import numpy as np
from scipy import signal
import librosa

def design_notch_filter(freq, sr, Q=30):
    """
    Design a notch filter for a specific frequency.

    Parameters:
    - freq: Frequency to remove (Hz)
    - sr: Sample rate
    - Q: Quality factor (higher = narrower notch)
    """
    w0 = freq / (sr / 2)  # Normalized frequency
    b, a = signal.iirnotch(w0, Q)
    return b, a

def remove_hum_and_harmonics(audio, sr, fundamental=60, n_harmonics=5, Q=30):
    """
    Remove hum at fundamental frequency and its harmonics.
    """
    filtered = audio.copy()

    for i in range(1, n_harmonics + 1):
        freq = fundamental * i
        if freq < sr / 2:  # Below Nyquist
            b, a = design_notch_filter(freq, sr, Q)
            filtered = signal.filtfilt(b, a, filtered)
            print(f"Notched {freq} Hz")

    return filtered

def detect_hum_frequency(audio, sr):
    """
    Automatically detect the fundamental hum frequency.
    """
    # Look for peaks in the 45-65 Hz range
    n_fft = 8192  # High resolution for low frequencies
    stft = np.abs(librosa.stft(audio, n_fft=n_fft))
    freqs = librosa.fft_frequencies(sr=sr, n_fft=n_fft)

    # Average spectrum
    avg_spectrum = np.mean(stft, axis=1)

    # Search 45-65 Hz range
    mask = (freqs >= 45) & (freqs <= 65)
    search_freqs = freqs[mask]
    search_spectrum = avg_spectrum[mask]

    # Find peak
    peak_idx = np.argmax(search_spectrum)
    detected_freq = search_freqs[peak_idx]

    # Determine if 50 Hz or 60 Hz region
    if detected_freq < 55:
        return 50
    else:
        return 60

def adaptive_hum_removal(audio, sr, Q=35):
    """
    Detect and remove hum automatically.
    """
    # Detect fundamental
    fundamental = detect_hum_frequency(audio, sr)
    print(f"Detected {fundamental} Hz power line frequency")

    # Remove fundamental and harmonics
    cleaned = remove_hum_and_harmonics(audio, sr, fundamental,
                                        n_harmonics=6, Q=Q)

    return cleaned, fundamental

# Usage
audio, sr = librosa.load('hum_recording.wav', sr=None)
cleaned, detected_freq = adaptive_hum_removal(audio, sr)

# Save
import soundfile as sf
sf.write('dehum.wav', cleaned, sr)
```

**Notch filter Q factor guide:**

| Q Value | Bandwidth | Use Case |
|---------|-----------|----------|
| 10-20 | Wide | Light hum, safe for speech |
| 25-35 | Medium | Standard hum removal |
| 40-60 | Narrow | Heavy hum, precise removal |
| 60+ | Very narrow | Only when hum frequency is exact |

**When NOT to use notch filters:**

- Recording has multiple overlapping hum sources
- Hum frequency varies (poor power quality)
- Speech fundamental overlaps with hum (rare, deep voices)

Reference: [IIR Notch Filter Design](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.iirnotch.html)

### 3.3 Apply Spectral Subtraction for Stationary Noise

**Impact: HIGH (10-20 dB noise reduction for consistent noise)**

Spectral subtraction removes noise by subtracting the estimated noise spectrum from each frame. Effective for consistent background noise (HVAC, hiss, fan).

**Incorrect (time-domain approach for frequency noise):**

```bash
# Simple filtering doesn't target specific noise spectrum
ffmpeg -i hvac_noise.wav -af "lowpass=f=3000,highpass=f=200" filtered.wav
# Removes speech frequencies along with noise
```

**Correct (spectral subtraction):**

```bash
# FFmpeg FFT-based denoiser
ffmpeg -i hvac_noise.wav -af "afftdn=nr=12:nf=-25:nt=w" spectral_cleaned.wav
# nr: noise reduction amount
# nf: noise floor in dB
# nt=w: Wiener filter mode (better than simple subtraction)

# SoX spectral approach with noise profile
sox noisy.wav -n trim 0 2 noiseprof noise.prof
sox noisy.wav cleaned.wav noisered noise.prof 0.21
```

**Python spectral subtraction implementation:**

```python
import numpy as np
import librosa

def spectral_subtraction(audio, sr, noise_profile, alpha=2.0, beta=0.01):
    """
    Classic spectral subtraction with over-subtraction.

    Parameters:
    - noise_profile: Magnitude spectrum of noise (from silent segment)
    - alpha: Over-subtraction factor (1.0-4.0, higher = more aggressive)
    - beta: Spectral floor to prevent negative values (0.001-0.1)
    """
    n_fft = 2048
    hop_length = 512
    win_length = n_fft

    # STFT of noisy signal
    stft = librosa.stft(audio, n_fft=n_fft, hop_length=hop_length,
                        win_length=win_length)
    magnitude = np.abs(stft)
    phase = np.angle(stft)

    # Ensure noise profile matches FFT size
    if len(noise_profile) != magnitude.shape[0]:
        noise_profile = np.interp(
            np.linspace(0, 1, magnitude.shape[0]),
            np.linspace(0, 1, len(noise_profile)),
            noise_profile
        )

    # Over-subtraction: S = |Y| - α|N|
    noise_profile = noise_profile.reshape(-1, 1)
    subtracted = magnitude - alpha * noise_profile

    # Spectral floor: prevent negative/very small values
    # S = max(S, β|Y|)
    floored = np.maximum(subtracted, beta * magnitude)

    # Reconstruct
    output_stft = floored * np.exp(1j * phase)
    output_audio = librosa.istft(output_stft, hop_length=hop_length,
                                  win_length=win_length)

    return output_audio

def estimate_noise_spectrum(audio, sr, start_sec=0, duration_sec=1):
    """Estimate noise spectrum from a segment."""
    start = int(start_sec * sr)
    end = int((start_sec + duration_sec) * sr)
    noise_segment = audio[start:end]

    # Average magnitude spectrum
    stft = librosa.stft(noise_segment, n_fft=2048, hop_length=512)
    noise_profile = np.mean(np.abs(stft), axis=1)

    return noise_profile

# Usage
audio, sr = librosa.load('noisy_speech.wav', sr=None)

# Extract noise profile from first second (assumed silent)
noise_profile = estimate_noise_spectrum(audio, sr, start_sec=0, duration_sec=1)

# Apply spectral subtraction with moderate aggression
cleaned = spectral_subtraction(audio, sr, noise_profile, alpha=2.0, beta=0.02)

# Save result
import soundfile as sf
sf.write('cleaned.wav', cleaned, sr)
```

**Over-subtraction factor guide:**

| Alpha Value | Use Case |
|-------------|----------|
| 1.0 | Minimal reduction, preserve naturalness |
| 2.0 | Standard, good balance |
| 3.0 | Aggressive, for high noise |
| 4.0+ | Very aggressive, risk of artifacts |

Reference: [Speech Enhancement using Spectral Subtraction](https://www.sciencedirect.com/science/article/pii/S1877050915013903)

### 3.4 Repair Clipped Audio Before Other Processing

**Impact: HIGH (recovers 3-6 dB of dynamic range)**

Clipped audio has flattened peaks that create harmonic distortion. Declipping algorithms reconstruct the original waveform shape using interpolation or sparse reconstruction.

**Incorrect (processing clipped audio):**

```bash
# Noise reduction on clipped audio
ffmpeg -i clipped.wav -af "afftdn=nr=15" still_distorted.wav
# Clipping harmonics remain, processed as if they were speech
```

**Correct (declip first, then process):**

```bash
# FFmpeg declipping
ffmpeg -i clipped.wav -af "declip=w=50:o=50" declipped.wav
# w: window size, o: overlap

# Then apply other processing
ffmpeg -i declipped.wav -af "afftdn=nr=12" final.wav
```

**Python declipping with cubic interpolation:**

```python
import numpy as np
from scipy import interpolate, signal
import librosa

def detect_clipping(audio, threshold=0.99):
    """
    Detect clipped samples in audio.

    Returns indices and segments of clipped audio.
    """
    clipped_mask = np.abs(audio) >= threshold

    # Find contiguous clipped regions
    diff = np.diff(clipped_mask.astype(int))
    starts = np.where(diff == 1)[0] + 1
    ends = np.where(diff == -1)[0] + 1

    # Handle edge cases
    if clipped_mask[0]:
        starts = np.insert(starts, 0, 0)
    if clipped_mask[-1]:
        ends = np.append(ends, len(audio))

    segments = list(zip(starts, ends))

    clip_percentage = 100 * np.sum(clipped_mask) / len(audio)
    return segments, clip_percentage

def cubic_declip(audio, threshold=0.99, margin=5):
    """
    Declip audio using cubic spline interpolation.

    For each clipped segment, uses surrounding unclipped samples
    to reconstruct the waveform.
    """
    segments, clip_pct = detect_clipping(audio, threshold)
    print(f"Detected {len(segments)} clipped segments ({clip_pct:.2f}% of audio)")

    if len(segments) == 0:
        return audio

    declipped = audio.copy()

    for start, end in segments:
        segment_len = end - start

        # Get context samples
        context_start = max(0, start - margin)
        context_end = min(len(audio), end + margin)

        # Indices for interpolation (exclude clipped region)
        x_known = np.concatenate([
            np.arange(context_start, start),
            np.arange(end, context_end)
        ])
        y_known = audio[x_known]

        if len(x_known) < 4:
            continue  # Not enough context

        # Fit cubic spline
        try:
            spline = interpolate.CubicSpline(x_known, y_known)

            # Reconstruct clipped region
            x_clipped = np.arange(start, end)
            declipped[x_clipped] = spline(x_clipped)
        except Exception as e:
            print(f"Could not declip segment {start}-{end}: {e}")

    return declipped

def sparse_declip(audio, sr, threshold=0.99, iterations=50):
    """
    Advanced declipping using sparse reconstruction.

    Uses the assumption that audio is sparse in frequency domain
    to reconstruct clipped portions.
    """
    from scipy.fft import dct, idct

    segments, _ = detect_clipping(audio, threshold)

    if len(segments) == 0:
        return audio

    declipped = audio.copy()

    # Process in overlapping frames
    frame_length = 1024
    hop_length = 256

    for i in range(0, len(audio) - frame_length, hop_length):
        frame = audio[i:i + frame_length]
        clipped_in_frame = np.abs(frame) >= threshold

        if not np.any(clipped_in_frame):
            continue

        # Iterative hard thresholding
        reconstructed = frame.copy()
        for _ in range(iterations):
            # Transform to DCT domain
            coeffs = dct(reconstructed, norm='ortho')

            # Keep only significant coefficients (sparsity)
            threshold_coeff = np.percentile(np.abs(coeffs), 90)
            coeffs[np.abs(coeffs) < threshold_coeff] = 0

            # Transform back
            reconstructed = idct(coeffs, norm='ortho')

            # Keep original unclipped samples
            reconstructed[~clipped_in_frame] = frame[~clipped_in_frame]

        # Overlap-add
        declipped[i:i + frame_length] = reconstructed

    return declipped

def assess_clipping_severity(audio, threshold=0.99):
    """
    Assess how severe the clipping is.
    """
    segments, clip_pct = detect_clipping(audio, threshold)

    if len(segments) == 0:
        return 'none', 0

    # Average clipped segment length
    avg_len = np.mean([end - start for start, end in segments])

    if clip_pct < 0.1 and avg_len < 10:
        return 'mild', clip_pct
    elif clip_pct < 1.0 and avg_len < 50:
        return 'moderate', clip_pct
    else:
        return 'severe', clip_pct

# Usage
audio, sr = librosa.load('clipped_recording.wav', sr=None)

severity, pct = assess_clipping_severity(audio)
print(f"Clipping severity: {severity} ({pct:.2f}%)")

if severity != 'none':
    declipped = cubic_declip(audio, threshold=0.99)
    # Or for severe clipping:
    # declipped = sparse_declip(audio, sr, threshold=0.99)
```

**Clipping severity guide:**

| Severity | Percentage | Approach |
|----------|------------|----------|
| Mild (< 0.1%) | Occasional peaks | Cubic interpolation |
| Moderate (0.1-1%) | Regular clipping | Sparse reconstruction |
| Severe (> 1%) | Heavy distortion | May be unrecoverable |

Reference: [Audio Declipping Algorithms](https://ieeexplore.ieee.org/document/6854318)

### 3.5 Use Forensic Equalization to Restore Intelligibility

**Impact: HIGH (recovers masked speech without adding artifacts)**

Targeted EQ boosts speech frequencies while cutting noise bands. Focus on presence (2-4 kHz) for consonant clarity and cut mud (200-400 Hz) for definition.

**Incorrect (flat boost adds noise):**

```bash
# Simple gain boost increases noise equally
ffmpeg -i quiet_speech.wav -af "volume=10dB" louder_noise.wav
# Speech and noise both louder
```

**Correct (targeted forensic EQ):**

```bash
# Forensic speech enhancement EQ
ffmpeg -i muffled.wav -af "\
  highpass=f=100,\
  equalizer=f=250:t=q:w=2:g=-3,\
  equalizer=f=800:t=q:w=1.5:g=2,\
  equalizer=f=2500:t=q:w=1:g=4,\
  equalizer=f=5000:t=q:w=2:g=2,\
  lowpass=f=8000\
" enhanced.wav
# Cuts mud at 250 Hz, boosts body at 800 Hz,
# boosts presence at 2.5 kHz, adds air at 5 kHz
```

**Python forensic EQ:**

```python
import numpy as np
from scipy import signal
import librosa

def parametric_eq(audio, sr, bands):
    """
    Apply multi-band parametric EQ.

    bands: list of dicts with {freq, gain_db, Q}
    """
    filtered = audio.copy()

    for band in bands:
        freq = band['freq']
        gain_db = band['gain_db']
        Q = band.get('Q', 1.0)

        if gain_db == 0:
            continue

        # Peak/notch filter
        w0 = freq / (sr / 2)
        if w0 >= 1:
            continue  # Skip if above Nyquist

        A = 10 ** (gain_db / 40)
        alpha = np.sin(np.pi * w0) / (2 * Q)

        b0 = 1 + alpha * A
        b1 = -2 * np.cos(np.pi * w0)
        b2 = 1 - alpha * A
        a0 = 1 + alpha / A
        a1 = -2 * np.cos(np.pi * w0)
        a2 = 1 - alpha / A

        b = np.array([b0/a0, b1/a0, b2/a0])
        a = np.array([1, a1/a0, a2/a0])

        filtered = signal.filtfilt(b, a, filtered)

    return filtered

# Forensic speech enhancement preset
FORENSIC_SPEECH_EQ = [
    {'freq': 80, 'gain_db': 0, 'Q': 0.7},      # Leave fundamentals alone
    {'freq': 200, 'gain_db': -2, 'Q': 1.5},    # Cut mud
    {'freq': 400, 'gain_db': -1, 'Q': 2.0},    # Reduce boxiness
    {'freq': 800, 'gain_db': 2, 'Q': 1.5},     # Body
    {'freq': 1500, 'gain_db': 1, 'Q': 1.0},    # Low presence
    {'freq': 2500, 'gain_db': 4, 'Q': 1.0},    # Presence/clarity
    {'freq': 4000, 'gain_db': 3, 'Q': 1.5},    # High presence
    {'freq': 6000, 'gain_db': 1, 'Q': 2.0},    # Air/sibilance
]

# Telephone/intercom preset (narrow band source)
TELEPHONE_EQ = [
    {'freq': 300, 'gain_db': 3, 'Q': 1.0},     # Boost low end (lost in phone)
    {'freq': 800, 'gain_db': 2, 'Q': 1.5},     # Body
    {'freq': 2000, 'gain_db': 4, 'Q': 1.0},    # Intelligibility
    {'freq': 3000, 'gain_db': 2, 'Q': 1.5},    # Upper clarity
]

def adaptive_forensic_eq(audio, sr):
    """
    Analyze audio and apply appropriate forensic EQ.
    """
    # Analyze spectral balance
    n_fft = 2048
    stft = np.abs(librosa.stft(audio, n_fft=n_fft))
    freqs = librosa.fft_frequencies(sr=sr, n_fft=n_fft)
    avg_spectrum = np.mean(stft, axis=1)

    # Check for common problems
    low_energy = np.mean(avg_spectrum[(freqs > 100) & (freqs < 400)])
    mid_energy = np.mean(avg_spectrum[(freqs > 800) & (freqs < 2000)])
    high_energy = np.mean(avg_spectrum[(freqs > 2000) & (freqs < 5000)])

    eq_bands = []

    # Muddy (too much low-mid)
    if low_energy > mid_energy * 1.5:
        eq_bands.append({'freq': 250, 'gain_db': -3, 'Q': 1.5})
        print("Detected: muddy, cutting 250 Hz")

    # Dull (lacking presence)
    if high_energy < mid_energy * 0.5:
        eq_bands.append({'freq': 2500, 'gain_db': 4, 'Q': 1.0})
        eq_bands.append({'freq': 4000, 'gain_db': 2, 'Q': 1.5})
        print("Detected: dull, boosting presence")

    # Thin (lacking body)
    if low_energy < mid_energy * 0.3:
        eq_bands.append({'freq': 200, 'gain_db': 2, 'Q': 1.5})
        eq_bands.append({'freq': 800, 'gain_db': 2, 'Q': 1.0})
        print("Detected: thin, boosting body")

    if not eq_bands:
        eq_bands = FORENSIC_SPEECH_EQ
        print("Using standard forensic EQ")

    return parametric_eq(audio, sr, eq_bands)

# Usage
audio, sr = librosa.load('muffled_speech.wav', sr=None)
enhanced = adaptive_forensic_eq(audio, sr)
```

**Forensic EQ frequency guide:**

| Frequency | Character | Adjustment |
|-----------|-----------|------------|
| 80-150 Hz | Rumble, fundamental | Cut if noisy |
| 200-400 Hz | Mud, boxiness | Usually cut |
| 500-1000 Hz | Body, warmth | Boost for thin audio |
| 1-2 kHz | Honk, nasal | Cut if harsh |
| 2-4 kHz | Presence, clarity | Boost for intelligibility |
| 4-8 kHz | Air, sibilance | Gentle boost for definition |

Reference: [Forensic Audio Enhancement](https://www.izotope.com/en/learn/forensic-audio-enhancement.html)

### 3.6 Use Wiener Filter for Optimal Noise Estimation

**Impact: HIGH (minimizes mean squared error between clean and enhanced)**

The Wiener filter provides mathematically optimal noise reduction by minimizing mean squared error. Superior to basic spectral subtraction for varying SNR.

**Incorrect (fixed subtraction regardless of SNR):**

```python
# Simple subtraction doesn't adapt to local SNR
cleaned = magnitude - noise_estimate  # Same reduction everywhere
```

**Correct (Wiener filter adapts to local SNR):**

```python
import numpy as np
import librosa

def wiener_filter(audio, sr, noise_psd, n_fft=2048, hop_length=512):
    """
    Apply Wiener filter for optimal noise reduction.

    The Wiener filter gain is: H(f) = S(f) / (S(f) + N(f))
    where S(f) is signal PSD and N(f) is noise PSD.

    This naturally applies more reduction where SNR is low
    and preserves signal where SNR is high.
    """
    # STFT
    stft = librosa.stft(audio, n_fft=n_fft, hop_length=hop_length)
    magnitude = np.abs(stft)
    phase = np.angle(stft)

    # Estimate signal PSD (noisy magnitude squared minus noise)
    noisy_psd = magnitude ** 2

    # Ensure noise_psd shape matches
    if noise_psd.ndim == 1:
        noise_psd = noise_psd.reshape(-1, 1)

    # A priori SNR estimation (decision-directed approach)
    # Initial estimate
    signal_psd_est = np.maximum(noisy_psd - noise_psd, 0)

    # Wiener filter gain
    # H = signal_psd / (signal_psd + noise_psd)
    # With flooring to prevent divide-by-zero
    epsilon = 1e-10
    wiener_gain = signal_psd_est / (signal_psd_est + noise_psd + epsilon)

    # Apply gain
    enhanced_magnitude = wiener_gain * magnitude

    # Reconstruct
    enhanced_stft = enhanced_magnitude * np.exp(1j * phase)
    enhanced_audio = librosa.istft(enhanced_stft, hop_length=hop_length)

    return enhanced_audio, wiener_gain

def decision_directed_wiener(audio, sr, noise_psd, alpha=0.98):
    """
    Decision-directed Wiener filter with temporal smoothing.

    The alpha parameter controls smoothing between frames,
    reducing musical noise artifacts.
    """
    n_fft = 2048
    hop_length = 512

    stft = librosa.stft(audio, n_fft=n_fft, hop_length=hop_length)
    magnitude = np.abs(stft)
    phase = np.angle(stft)
    n_frames = magnitude.shape[1]

    if noise_psd.ndim == 1:
        noise_psd = noise_psd.reshape(-1, 1)

    enhanced_magnitude = np.zeros_like(magnitude)
    prev_xi = np.ones((magnitude.shape[0], 1))  # Previous a priori SNR

    for i in range(n_frames):
        frame_mag = magnitude[:, i:i+1]
        noisy_psd = frame_mag ** 2

        # A posteriori SNR
        gamma = noisy_psd / (noise_psd + 1e-10)

        # Decision-directed a priori SNR estimate
        # Combines previous estimate with current ML estimate
        if i == 0:
            xi = np.maximum(gamma - 1, 0)
        else:
            prev_enhanced = enhanced_magnitude[:, i-1:i]
            xi_ml = np.maximum(gamma - 1, 0)
            xi_dd = (prev_enhanced ** 2) / (noise_psd + 1e-10)
            xi = alpha * xi_dd + (1 - alpha) * xi_ml

        # Wiener gain
        gain = xi / (xi + 1)

        # Apply and store
        enhanced_magnitude[:, i:i+1] = gain * frame_mag
        prev_xi = xi

    enhanced_stft = enhanced_magnitude * np.exp(1j * phase)
    enhanced_audio = librosa.istft(enhanced_stft, hop_length=hop_length)

    return enhanced_audio

# Usage
audio, sr = librosa.load('noisy.wav', sr=None)

# Estimate noise PSD from silent segment
noise_segment = audio[:int(sr * 1.0)]  # First second
noise_stft = librosa.stft(noise_segment, n_fft=2048, hop_length=512)
noise_psd = np.mean(np.abs(noise_stft) ** 2, axis=1)

# Apply decision-directed Wiener filter
cleaned = decision_directed_wiener(audio, sr, noise_psd, alpha=0.98)
```

**FFmpeg Wiener filter:**

```bash
# Enable Wiener mode in afftdn
ffmpeg -i noisy.wav -af "afftdn=nt=w:nr=12:nf=-25" wiener_cleaned.wav
# nt=w enables Wiener filter mode
```

**Wiener vs Spectral Subtraction comparison:**

| Aspect | Spectral Subtraction | Wiener Filter |
|--------|---------------------|---------------|
| Computation | Simpler | More complex |
| Artifacts | More musical noise | Less artifacts |
| Adaptability | Fixed reduction | Adapts to local SNR |
| Low SNR | Over-subtracts | Graceful degradation |
| High SNR | May under-reduce | Preserves signal |

Reference: [Wiener Filter Theory](https://en.wikipedia.org/wiki/Wiener_filter)

---

## 4. Voice Isolation & Enhancement

**Impact: HIGH**

Separating speech from complex backgrounds using ML models (RNNoise, Dialogue Isolate) and preserving formants during pitch/time manipulation for natural-sounding results.

### 4.1 Apply Dereverberation for Room Echo

**Impact: HIGH (5-15 dB clarity improvement in reverberant recordings)**

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

### 4.2 Boost Frequency Regions for Specific Phonemes

**Impact: HIGH (recovers masked consonants and improves word recognition)**

Different phonemes occupy different frequency ranges. Target boosting based on what's missing to recover specific sounds.

**Incorrect (flat presence boost):**

```bash
# Generic boost may not target the right frequencies
ffmpeg -i muffled.wav -af "equalizer=f=3000:t=q:w=2:g=6" generic_boost.wav
# May boost noise along with target phonemes
```

**Correct (phoneme-targeted enhancement):**

```python
import numpy as np
from scipy import signal
import librosa
import soundfile as sf

# Phoneme frequency bands
PHONEME_BANDS = {
    # Vowels (F1, F2 formant ranges)
    'vowels': {'low': 300, 'high': 3000, 'Q': 0.5},

    # Fricatives - high frequency content
    's': {'low': 4000, 'high': 8000, 'Q': 1.0},
    'f': {'low': 2500, 'high': 6000, 'Q': 1.0},
    'sh': {'low': 2000, 'high': 6000, 'Q': 0.8},
    'th': {'low': 3000, 'high': 7000, 'Q': 1.0},

    # Plosives - transient bursts
    'p_t_k': {'low': 2000, 'high': 5000, 'Q': 0.7},
    'b_d_g': {'low': 1000, 'high': 3000, 'Q': 0.7},

    # Nasals
    'm_n': {'low': 200, 'high': 2500, 'Q': 0.5},

    # General intelligibility
    'presence': {'low': 2000, 'high': 4000, 'Q': 1.0},
    'clarity': {'low': 4000, 'high': 6000, 'Q': 1.5},
}

def boost_phoneme_band(audio, sr, phoneme_type, gain_db=3):
    """
    Boost specific frequency band for phoneme recovery.
    """
    if phoneme_type not in PHONEME_BANDS:
        raise ValueError(f"Unknown phoneme type: {phoneme_type}")

    band = PHONEME_BANDS[phoneme_type]
    nyquist = sr / 2

    # Check if band is within Nyquist
    if band['high'] >= nyquist:
        band['high'] = nyquist * 0.9

    # Design bandpass boost
    center_freq = (band['low'] + band['high']) / 2
    bandwidth = band['high'] - band['low']
    Q = center_freq / bandwidth

    # Peak filter for boost
    w0 = center_freq / nyquist
    A = 10 ** (gain_db / 40)
    alpha = np.sin(np.pi * w0) / (2 * Q)

    b0 = 1 + alpha * A
    b1 = -2 * np.cos(np.pi * w0)
    b2 = 1 - alpha * A
    a0 = 1 + alpha / A
    a1 = -2 * np.cos(np.pi * w0)
    a2 = 1 - alpha / A

    b = np.array([b0/a0, b1/a0, b2/a0])
    a = np.array([1, a1/a0, a2/a0])

    boosted = signal.filtfilt(b, a, audio)

    return boosted

def analyze_missing_phonemes(audio, sr):
    """
    Analyze which phoneme frequency regions are weak.
    """
    n_fft = 2048
    stft = np.abs(librosa.stft(audio, n_fft=n_fft))
    freqs = librosa.fft_frequencies(sr=sr, n_fft=n_fft)
    avg_spectrum = np.mean(stft, axis=1)
    avg_spectrum_db = 20 * np.log10(avg_spectrum + 1e-10)

    analysis = {}

    for phoneme, band in PHONEME_BANDS.items():
        if band['high'] >= sr / 2:
            continue

        mask = (freqs >= band['low']) & (freqs <= band['high'])
        band_energy = np.mean(avg_spectrum_db[mask])
        analysis[phoneme] = band_energy

    # Find weak regions
    median_energy = np.median(list(analysis.values()))
    weak_regions = {k: v for k, v in analysis.items()
                    if v < median_energy - 6}  # 6 dB below median

    return analysis, weak_regions

def auto_phoneme_enhancement(audio, sr, target_boost_db=4):
    """
    Automatically boost weak phoneme regions.
    """
    analysis, weak_regions = analyze_missing_phonemes(audio, sr)

    print("Phoneme region analysis:")
    for phoneme, energy in sorted(analysis.items(), key=lambda x: x[1]):
        status = "WEAK" if phoneme in weak_regions else "OK"
        print(f"  {phoneme:12s}: {energy:6.1f} dB [{status}]")

    enhanced = audio.copy()
    for phoneme in weak_regions:
        enhanced = boost_phoneme_band(enhanced, sr, phoneme, gain_db=target_boost_db)
        print(f"Boosted: {phoneme} by {target_boost_db} dB")

    return enhanced

def enhance_sibilants(audio, sr, gain_db=4):
    """
    Specifically enhance sibilant sounds (s, sh, f, th).
    """
    enhanced = audio.copy()
    enhanced = boost_phoneme_band(enhanced, sr, 's', gain_db)
    enhanced = boost_phoneme_band(enhanced, sr, 'f', gain_db * 0.7)

    return enhanced

def enhance_clarity(audio, sr, presence_db=3, clarity_db=2):
    """
    General clarity enhancement for speech.
    """
    enhanced = audio.copy()
    enhanced = boost_phoneme_band(enhanced, sr, 'presence', presence_db)
    enhanced = boost_phoneme_band(enhanced, sr, 'clarity', clarity_db)

    return enhanced

# FFmpeg equivalent commands
def print_ffmpeg_commands(weak_regions):
    """Generate FFmpeg commands for detected weak regions."""
    filters = []

    for phoneme in weak_regions:
        band = PHONEME_BANDS[phoneme]
        center = (band['low'] + band['high']) / 2
        filters.append(f"equalizer=f={center}:t=q:w={band['Q']}:g=4")

    cmd = f"ffmpeg -i input.wav -af \"{','.join(filters)}\" enhanced.wav"
    print(f"\nFFmpeg command:\n{cmd}")

# Usage
if __name__ == '__main__':
    audio, sr = sf.read('muffled_speech.wav')

    # Auto-enhance weak regions
    enhanced = auto_phoneme_enhancement(audio, sr)

    # Or specific enhancement for sibilants
    # enhanced = enhance_sibilants(audio, sr, gain_db=5)

    sf.write('phoneme_enhanced.wav', enhanced, sr)
```

**FFmpeg phoneme enhancement:**

```bash
# Enhance sibilants (s, f, sh sounds)
ffmpeg -i muffled.wav -af "\
  equalizer=f=5000:t=q:w=1:g=4,\
  equalizer=f=6500:t=q:w=1.5:g=3\
" sibilants_enhanced.wav

# Enhance general presence
ffmpeg -i dull.wav -af "\
  equalizer=f=2500:t=q:w=1:g=3,\
  equalizer=f=4000:t=q:w=1.5:g=2\
" presence_enhanced.wav
```

**Phoneme frequency quick reference:**

| Sound | Example | Frequency Range |
|-------|---------|-----------------|
| /s/ | "see" | 4-8 kHz |
| /ʃ/ | "she" | 2-6 kHz |
| /f/ | "fee" | 2.5-6 kHz |
| /θ/ | "think" | 3-7 kHz |
| /t/ | "tea" | 2-5 kHz burst |
| /k/ | "key" | 2-4 kHz burst |
| Vowels | all | 300-3000 Hz |

Reference: [Speech Acoustics](https://en.wikipedia.org/wiki/Formant)

### 4.3 Preserve Formants During Pitch Manipulation

**Impact: HIGH (maintains natural voice quality during time/pitch changes)**

Formants (resonant frequencies) define voice character. Pitch shifting without formant preservation creates unnatural "chipmunk" or "Darth Vader" effects.

**Incorrect (pitch shift without formant preservation):**

```bash
# Basic pitch shift changes formants
ffmpeg -i recording.wav -af "rubberband=pitch=1.2" chipmunk.wav
# Higher pitch = higher formants = unnatural
```

**Correct (formant-preserving pitch shift):**

```bash
# Rubberband with formant preservation
ffmpeg -i recording.wav -af "rubberband=pitch=1.2:formant=1" natural.wav
# pitch changed but formants preserved

# SoX with formant preservation
sox input.wav output.wav pitch 200 # Shift up 200 cents with formant preservation
```

**Python formant-preserving manipulation:**

```python
import numpy as np
import librosa
import soundfile as sf

def pitch_shift_preserve_formants(audio, sr, semitones):
    """
    Pitch shift while preserving formants using librosa.

    Uses PSOLA-like approach: time-stretch then resample.
    """
    # Calculate rate
    rate = 2 ** (semitones / 12.0)

    # Time stretch to compensate for pitch change
    stretched = librosa.effects.time_stretch(audio, rate=rate)

    # Resample to change pitch
    shifted = librosa.resample(stretched, orig_sr=sr, target_sr=int(sr * rate))

    # Trim or pad to original length
    if len(shifted) > len(audio):
        shifted = shifted[:len(audio)]
    else:
        shifted = np.pad(shifted, (0, len(audio) - len(shifted)))

    return shifted

def time_stretch_preserve_quality(audio, sr, rate):
    """
    Time stretch with phase vocoder for quality.

    rate > 1 = faster (shorter)
    rate < 1 = slower (longer)
    """
    # Use librosa's phase vocoder
    stretched = librosa.effects.time_stretch(audio, rate=rate)

    return stretched

def analyze_formants(audio, sr, n_formants=4):
    """
    Analyze formant frequencies using LPC.
    """
    from scipy.signal import lfilter

    # Pre-emphasis
    pre_emphasis = 0.97
    emphasized = np.append(audio[0], audio[1:] - pre_emphasis * audio[:-1])

    # Frame the signal
    frame_length = int(0.025 * sr)  # 25ms
    hop_length = int(0.010 * sr)    # 10ms

    frames = librosa.util.frame(emphasized, frame_length=frame_length,
                                 hop_length=hop_length)

    formants = []
    for frame in frames.T:
        # Apply window
        windowed = frame * np.hamming(len(frame))

        # LPC analysis
        lpc_order = 2 + sr // 1000
        try:
            from scipy.signal import lpc
            lpc_coeffs = lpc(windowed, lpc_order)

            # Find roots of LPC polynomial
            roots = np.roots(lpc_coeffs)

            # Keep roots inside unit circle with positive imaginary part
            roots = roots[np.imag(roots) >= 0]
            roots = roots[np.abs(roots) < 1]

            # Convert to frequencies
            angles = np.arctan2(np.imag(roots), np.real(roots))
            freqs = angles * sr / (2 * np.pi)

            # Sort and keep first n formants
            freqs = np.sort(freqs[freqs > 50])[:n_formants]
            formants.append(freqs)
        except:
            formants.append([])

    return formants

def rubberband_stretch(input_path, output_path, time_ratio=1.0, pitch_shift=0,
                       preserve_formants=True):
    """
    Use Rubberband library for high-quality time/pitch manipulation.

    Requires rubberband-cli or pyrubberband.
    """
    import subprocess

    cmd = ['rubberband']

    if time_ratio != 1.0:
        cmd.extend(['-t', str(time_ratio)])

    if pitch_shift != 0:
        cmd.extend(['-p', str(pitch_shift)])

    if preserve_formants:
        cmd.append('-F')  # Formant preservation

    cmd.extend([input_path, output_path])

    subprocess.run(cmd, check=True)

# Usage example
if __name__ == '__main__':
    audio, sr = librosa.load('speech.wav', sr=None)

    # Slow down for clarity (0.8x speed)
    slowed = time_stretch_preserve_quality(audio, sr, rate=0.8)
    sf.write('slowed.wav', slowed, sr)

    # Pitch up to match reference voice (preserve formants)
    pitched = pitch_shift_preserve_formants(audio, sr, semitones=2)
    sf.write('pitched_natural.wav', pitched, sr)

    # Analyze formants
    formants = analyze_formants(audio, sr)
    avg_f1 = np.mean([f[0] for f in formants if len(f) > 0])
    avg_f2 = np.mean([f[1] for f in formants if len(f) > 1])
    print(f"Average F1: {avg_f1:.0f} Hz, F2: {avg_f2:.0f} Hz")
```

**Install Rubberband:**

```bash
# macOS
brew install rubberband

# Ubuntu/Debian
apt-get install rubberband-cli

# Python wrapper
pip install pyrubberband
```

**Formant frequency reference:**

| Vowel | F1 (Hz) | F2 (Hz) | F3 (Hz) |
|-------|---------|---------|---------|
| /i/ (beat) | 270 | 2300 | 3000 |
| /u/ (boot) | 300 | 870 | 2250 |
| /a/ (father) | 730 | 1100 | 2450 |
| /e/ (bet) | 530 | 1850 | 2500 |
| /o/ (boat) | 570 | 850 | 2400 |

**Use cases:**

| Task | Settings |
|------|----------|
| Slow for transcription | time_ratio=0.7-0.8, preserve formants |
| Match speaker pitch | pitch_shift=±3 semitones, preserve formants |
| Speed up background | time_ratio=1.5, formants less critical |

Reference: [Rubberband Audio Time Stretcher](https://breakfastquay.com/rubberband/)

### 4.4 Use AI Speech Enhancement Services for Quick Results

**Impact: HIGH (studio-quality enhancement with minimal effort)**

Cloud AI services (Adobe Enhance, Descript) provide studio-quality enhancement without technical expertise. Useful for quick processing when forensic documentation isn't required.

**Incorrect (manual enhancement for non-forensic use):**

```bash
# Complex manual pipeline for a podcast
ffmpeg -i podcast.wav -af "highpass=f=80,afftdn=nr=15,equalizer=f=2500:g=3,loudnorm" output.wav
# Time-consuming, requires expertise, may not match AI quality
```

**Correct (AI service for quick results):**

```python
# Use Adobe Enhance or similar AI service
# 1. Upload to https://podcast.adobe.com/enhance
# 2. Download studio-quality result in seconds

# Or use local AI: noisereduce + speechbrain
audio = local_ai_enhance('podcast.wav', 'enhanced.wav')
# Studio quality with minimal effort
```

**When to use cloud services:**

- Non-forensic use (podcasts, meetings, personal)
- Quick turnaround needed
- No specialized software available
- Audio doesn't contain sensitive information

**When NOT to use cloud services:**

- Legal/forensic evidence
- Confidential recordings
- Need for reproducible processing
- Offline processing required

**Adobe Podcast Enhance Speech:**

```python
import requests
import time

def enhance_with_adobe(input_path, output_path, api_key=None):
    """
    Use Adobe Podcast Enhance Speech API.

    Note: As of 2024, this is a web service.
    Visit: https://podcast.adobe.com/enhance
    """
    print("Adobe Enhance Speech is a web service.")
    print("1. Go to https://podcast.adobe.com/enhance")
    print("2. Upload your audio file")
    print("3. Download the enhanced result")
    print(f"\nInput file: {input_path}")

# Alternative: Use local AI enhancement with Silero
def enhance_with_silero(audio, sr):
    """
    Use Silero VAD + enhancement for local processing.
    """
    import torch

    # Load Silero VAD
    model, utils = torch.hub.load(
        repo_or_dir='snakers4/silero-vad',
        model='silero_vad',
        force_reload=False
    )

    (get_speech_timestamps,
     save_audio,
     read_audio,
     VADIterator,
     collect_chunks) = utils

    # Detect speech segments
    speech_timestamps = get_speech_timestamps(
        torch.tensor(audio),
        model,
        sampling_rate=sr
    )

    return speech_timestamps

# Local AI enhancement with speechbrain
def enhance_with_speechbrain(audio, sr):
    """
    Use SpeechBrain for local AI enhancement.

    pip install speechbrain
    """
    try:
        from speechbrain.pretrained import SepformerSeparation

        # Load model
        model = SepformerSeparation.from_hparams(
            source="speechbrain/sepformer-wham16k-enhancement",
            savedir="pretrained_models/sepformer-enhancement"
        )

        # Resample if needed
        if sr != 16000:
            import librosa
            audio = librosa.resample(audio, orig_sr=sr, target_sr=16000)

        # Enhance
        import torch
        audio_tensor = torch.tensor(audio).unsqueeze(0)
        enhanced = model.separate_batch(audio_tensor)

        return enhanced.squeeze().numpy()

    except ImportError:
        print("speechbrain not installed. Install with: pip install speechbrain")
        return audio
```

**Local alternatives comparison:**

| Tool | Quality | Speed | Privacy | Setup Complexity |
|------|---------|-------|---------|------------------|
| Adobe Enhance | Excellent | Fast | Cloud | None (web) |
| SpeechBrain | Good | Medium | Local | Medium |
| noisereduce | Good | Fast | Local | Easy |
| RNNoise | Good | Very Fast | Local | Medium |
| Silero | Good | Fast | Local | Easy |

**Python local enhancement pipeline:**

```python
import numpy as np
import librosa
import soundfile as sf

def local_ai_enhance(input_path, output_path):
    """
    Complete local AI enhancement pipeline.
    """
    # Load audio
    audio, sr = librosa.load(input_path, sr=None)
    print(f"Loaded: {len(audio)/sr:.1f}s at {sr}Hz")

    # Step 1: Noise reduction with noisereduce
    import noisereduce as nr
    audio = nr.reduce_noise(y=audio, sr=sr, stationary=False)
    print("Noise reduction applied")

    # Step 2: Normalize levels
    peak = np.max(np.abs(audio))
    if peak > 0:
        audio = audio / peak * 0.9
    print("Normalized")

    # Step 3: Apply presence boost for clarity
    from scipy import signal

    # Gentle presence boost at 2-4 kHz
    nyquist = sr / 2
    if nyquist > 4000:
        b, a = signal.iirpeak(3000 / nyquist, Q=2)
        audio = signal.filtfilt(b, a, audio) * 1.1
        audio = np.clip(audio, -1, 1)
        print("Presence boost applied")

    # Save
    sf.write(output_path, audio, sr)
    print(f"Saved: {output_path}")

# Usage
local_ai_enhance('noisy_speech.wav', 'enhanced_local.wav')
```

**Command-line quick enhancement:**

```bash
# Quick local enhancement with FFmpeg + noisereduce
# Step 1: Convert to standard format
ffmpeg -i input.mp3 -ar 16000 -ac 1 temp.wav

# Step 2: Python one-liner for noise reduction
python -c "
import noisereduce as nr
import soundfile as sf
audio, sr = sf.read('temp.wav')
cleaned = nr.reduce_noise(y=audio, sr=sr)
sf.write('enhanced.wav', cleaned, sr)
"

# Step 3: Normalize
ffmpeg -i enhanced.wav -af "loudnorm=I=-16:TP=-1.5:LRA=11" final.wav
```

Reference: [Adobe Podcast Enhance Speech](https://podcast.adobe.com/enhance)

### 4.5 Use RNNoise for Real-Time ML Denoising

**Impact: HIGH (10-20 dB reduction with natural speech preservation)**

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

### 4.6 Use Source Separation for Complex Backgrounds

**Impact: HIGH (isolates speech from overlapping audio sources)**

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

### 4.7 Use Voice Activity Detection for Targeted Processing

**Impact: HIGH (focuses enhancement on speech, preserves context)**

Voice Activity Detection (VAD) identifies speech vs. silence/noise segments. Apply aggressive processing only to non-speech segments to preserve speech quality.

**Incorrect (uniform processing):**

```bash
# Same noise reduction everywhere
ffmpeg -i recording.wav -af "afftdn=nr=25" uniformly_processed.wav
# Speech segments may be over-processed
```

**Correct (VAD-guided processing):**

```python
import numpy as np
import librosa
import soundfile as sf

def energy_based_vad(audio, sr, frame_ms=25, threshold_db=-40):
    """
    Simple energy-based Voice Activity Detection.
    """
    frame_length = int(frame_ms * sr / 1000)
    hop_length = frame_length // 2

    # Calculate RMS energy
    rms = librosa.feature.rms(y=audio, frame_length=frame_length,
                              hop_length=hop_length)[0]
    rms_db = 20 * np.log10(rms + 1e-10)

    # Classify frames
    speech_frames = rms_db > threshold_db

    # Convert to sample-level mask
    speech_mask = np.repeat(speech_frames, hop_length)
    speech_mask = speech_mask[:len(audio)]

    # Pad if needed
    if len(speech_mask) < len(audio):
        speech_mask = np.pad(speech_mask, (0, len(audio) - len(speech_mask)))

    return speech_mask

def silero_vad(audio, sr):
    """
    Use Silero VAD for robust speech detection.
    """
    import torch

    model, utils = torch.hub.load(
        'snakers4/silero-vad',
        'silero_vad',
        force_reload=False
    )

    get_speech_timestamps, _, read_audio, _, _ = utils

    # Silero expects 16kHz
    if sr != 16000:
        audio_16k = librosa.resample(audio, orig_sr=sr, target_sr=16000)
    else:
        audio_16k = audio

    # Get speech timestamps
    speech_timestamps = get_speech_timestamps(
        torch.tensor(audio_16k),
        model,
        sampling_rate=16000,
        threshold=0.5
    )

    # Convert to original sample rate mask
    speech_mask = np.zeros(len(audio), dtype=bool)
    for ts in speech_timestamps:
        start = int(ts['start'] * sr / 16000)
        end = int(ts['end'] * sr / 16000)
        speech_mask[start:end] = True

    return speech_mask, speech_timestamps

def vad_guided_processing(audio, sr, speech_processor, noise_processor):
    """
    Apply different processing to speech vs non-speech segments.

    speech_processor: function(audio, sr) for speech segments
    noise_processor: function(audio, sr) for non-speech segments
    """
    # Get VAD mask
    try:
        speech_mask, _ = silero_vad(audio, sr)
    except:
        speech_mask = energy_based_vad(audio, sr)

    output = np.zeros_like(audio)

    # Process speech segments with light enhancement
    speech_audio = audio.copy()
    speech_audio[~speech_mask] = 0
    if speech_processor:
        processed_speech = speech_processor(speech_audio, sr)
    else:
        processed_speech = speech_audio

    # Process non-speech with aggressive noise reduction
    noise_audio = audio.copy()
    noise_audio[speech_mask] = 0
    if noise_processor:
        processed_noise = noise_processor(noise_audio, sr)
    else:
        processed_noise = noise_audio

    # Combine
    output = processed_speech + processed_noise

    return output, speech_mask

def light_speech_enhancement(audio, sr):
    """Light processing for speech segments."""
    import noisereduce as nr
    return nr.reduce_noise(y=audio, sr=sr, prop_decrease=0.5)

def aggressive_noise_reduction(audio, sr):
    """Aggressive processing for non-speech segments."""
    import noisereduce as nr
    return nr.reduce_noise(y=audio, sr=sr, prop_decrease=0.95)

def extract_speech_segments(audio, sr, min_duration=0.5, padding=0.1):
    """
    Extract only speech segments for transcription.
    """
    try:
        speech_mask, timestamps = silero_vad(audio, sr)
    except:
        speech_mask = energy_based_vad(audio, sr)
        # Convert mask to timestamps
        timestamps = mask_to_timestamps(speech_mask, sr)

    segments = []
    for ts in timestamps:
        start = max(0, ts['start'] - int(padding * sr))
        end = min(len(audio), ts['end'] + int(padding * sr))

        duration = (end - start) / sr
        if duration >= min_duration:
            segments.append({
                'audio': audio[start:end],
                'start_time': start / sr,
                'end_time': end / sr
            })

    return segments

def mask_to_timestamps(mask, sr):
    """Convert boolean mask to timestamp list."""
    diff = np.diff(mask.astype(int))
    starts = np.where(diff == 1)[0]
    ends = np.where(diff == -1)[0]

    if mask[0]:
        starts = np.insert(starts, 0, 0)
    if mask[-1]:
        ends = np.append(ends, len(mask) - 1)

    return [{'start': s, 'end': e} for s, e in zip(starts, ends)]

# Usage
if __name__ == '__main__':
    audio, sr = sf.read('recording.wav')

    # VAD-guided enhancement
    enhanced, mask = vad_guided_processing(
        audio, sr,
        speech_processor=light_speech_enhancement,
        noise_processor=aggressive_noise_reduction
    )

    sf.write('vad_enhanced.wav', enhanced, sr)

    # Extract speech for transcription
    speech_segments = extract_speech_segments(audio, sr)
    print(f"Found {len(speech_segments)} speech segments")
```

**Install Silero VAD:**

```bash
pip install torch torchaudio
# Model downloads automatically on first use
```

**VAD comparison:**

| Method | Accuracy | Speed | Robustness |
|--------|----------|-------|------------|
| Energy-based | Good | Very fast | Low noise tolerance |
| Silero VAD | Excellent | Fast | High noise tolerance |
| WebRTC VAD | Good | Very fast | Medium |
| pyannote | Excellent | Slow | Very high |

Reference: [Silero VAD](https://github.com/snakers4/silero-vad)

---

## 5. Temporal Processing

**Impact: MEDIUM-HIGH**

Time-domain operations including dynamic range compression, noise gating, and time-stretching improve intelligibility without introducing pitch artifacts or pumping effects.

### 5.1 Apply Noise Gate to Silence Non-Speech Segments

**Impact: MEDIUM-HIGH (eliminates background noise during pauses)**

Noise gates mute audio below a threshold, eliminating background noise during pauses while preserving speech.

**Incorrect (aggressive gate clips speech):**

```bash
# Gate threshold too high, cuts soft speech
ffmpeg -i noisy.wav -af "agate=threshold=-30dB:attack=5:release=50" clipped_speech.wav
# Quiet words get silenced
```

**Correct (gentle gate with proper timing):**

```bash
# Noise gate with appropriate settings
ffmpeg -i noisy.wav -af "\
  agate=threshold=-45dB:\
  attack=10:\
  release=150:\
  ratio=2:\
  range=-20dB\
" gated.wav

# Combine with expander for more natural results
ffmpeg -i noisy.wav -af "\
  agate=threshold=-50dB:range=-15dB:attack=5:release=200\
" naturally_gated.wav
```

**Python adaptive noise gate:**

```python
import numpy as np
import librosa
import soundfile as sf

def simple_noise_gate(audio, sr, threshold_db=-45, attack_ms=10, release_ms=150, range_db=-60):
    """
    Simple noise gate implementation.

    Parameters:
    - threshold_db: Level below which gating occurs
    - attack_ms: Time for gate to open
    - release_ms: Time for gate to close
    - range_db: Maximum attenuation when gate is closed
    """
    threshold = 10 ** (threshold_db / 20)
    range_lin = 10 ** (range_db / 20)

    attack_samples = int(attack_ms * sr / 1000)
    release_samples = int(release_ms * sr / 1000)

    attack_coef = np.exp(-1 / attack_samples) if attack_samples > 0 else 0
    release_coef = np.exp(-1 / release_samples) if release_samples > 0 else 0

    output = np.zeros_like(audio)
    gate_level = 0  # 0 = closed, 1 = open

    for i in range(len(audio)):
        level = np.abs(audio[i])

        # Gate logic
        if level > threshold:
            # Open gate (attack)
            gate_level = attack_coef * gate_level + (1 - attack_coef) * 1.0
        else:
            # Close gate (release)
            gate_level = release_coef * gate_level + (1 - release_coef) * 0.0

        # Apply gate
        gain = range_lin + gate_level * (1 - range_lin)
        output[i] = audio[i] * gain

    return output

def adaptive_noise_gate(audio, sr, percentile=10, margin_db=6,
                        attack_ms=10, release_ms=200):
    """
    Noise gate with automatic threshold based on noise floor.
    """
    # Estimate noise floor
    frame_length = int(0.025 * sr)
    rms = librosa.feature.rms(y=audio, frame_length=frame_length)[0]
    noise_floor = np.percentile(rms, percentile)
    noise_floor_db = 20 * np.log10(noise_floor + 1e-10)

    # Set threshold above noise floor
    threshold_db = noise_floor_db + margin_db
    print(f"Estimated noise floor: {noise_floor_db:.1f} dB")
    print(f"Gate threshold: {threshold_db:.1f} dB")

    return simple_noise_gate(audio, sr, threshold_db=threshold_db,
                             attack_ms=attack_ms, release_ms=release_ms)

def lookahead_gate(audio, sr, threshold_db=-45, lookahead_ms=5,
                   attack_ms=1, release_ms=150):
    """
    Noise gate with lookahead to prevent clipping transients.
    """
    lookahead_samples = int(lookahead_ms * sr / 1000)

    # Create envelope with lookahead
    envelope = np.zeros(len(audio))
    for i in range(len(audio) - lookahead_samples):
        envelope[i] = np.max(np.abs(audio[i:i + lookahead_samples]))

    # Gate based on lookahead envelope
    threshold = 10 ** (threshold_db / 20)

    attack_samples = int(attack_ms * sr / 1000)
    release_samples = int(release_ms * sr / 1000)
    attack_coef = np.exp(-1 / attack_samples) if attack_samples > 0 else 0
    release_coef = np.exp(-1 / release_samples) if release_samples > 0 else 0

    output = np.zeros_like(audio)
    gate_level = 0

    for i in range(len(audio)):
        if envelope[i] > threshold:
            gate_level = attack_coef * gate_level + (1 - attack_coef) * 1.0
        else:
            gate_level = release_coef * gate_level + (1 - release_coef) * 0.0

        output[i] = audio[i] * gate_level

    return output

def crossfade_gate(audio, sr, vad_mask, crossfade_ms=20):
    """
    Gate audio based on VAD mask with smooth crossfades.
    """
    crossfade_samples = int(crossfade_ms * sr / 1000)

    output = np.zeros_like(audio)
    gain_envelope = np.zeros(len(audio))

    # Find transitions
    diff = np.diff(vad_mask.astype(int))
    open_points = np.where(diff == 1)[0]
    close_points = np.where(diff == -1)[0]

    # Build gain envelope
    current_gain = float(vad_mask[0])
    for i in range(len(audio)):
        # Check for transitions
        if i in open_points:
            # Fade in
            fade = np.linspace(0, 1, crossfade_samples)
            end_idx = min(i + crossfade_samples, len(audio))
            gain_envelope[i:end_idx] = fade[:end_idx - i]
            current_gain = 1.0
        elif i in close_points:
            # Fade out
            fade = np.linspace(1, 0, crossfade_samples)
            end_idx = min(i + crossfade_samples, len(audio))
            gain_envelope[i:end_idx] = fade[:end_idx - i]
            current_gain = 0.0
        else:
            gain_envelope[i] = current_gain

    output = audio * gain_envelope

    return output

# Usage
if __name__ == '__main__':
    audio, sr = sf.read('noisy_with_pauses.wav')

    # Adaptive gate
    gated = adaptive_noise_gate(audio, sr, percentile=15, margin_db=8)

    sf.write('gated.wav', gated, sr)
```

**Gate settings guide:**

| Scenario | Threshold | Attack | Release | Range |
|----------|-----------|--------|---------|-------|
| Light gating | -50 dB | 20 ms | 300 ms | -10 dB |
| Standard | -45 dB | 10 ms | 150 ms | -20 dB |
| Aggressive | -40 dB | 5 ms | 100 ms | -inf |
| Preserve ambience | -55 dB | 15 ms | 500 ms | -15 dB |

Reference: [Audio Dynamics Processing](https://en.wikipedia.org/wiki/Noise_gate)

### 5.2 Repair Transient Damage (Clicks, Pops, Dropouts)

**Impact: MEDIUM-HIGH (recovers words obscured by transient noise)**

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

### 5.3 Trim Silence and Normalize Before Export

**Impact: MEDIUM-HIGH (cleaner output for transcription and review)**

Remove leading/trailing silence and normalize levels for consistent playback. Essential for transcription workflows and evidence presentation.

**Incorrect (raw export with dead air):**

```bash
# Export without cleanup
cp processed.wav final.wav
# 30 seconds of silence at start, variable levels throughout
```

**Correct (trimmed and normalized):**

```bash
# Trim silence from start/end
ffmpeg -i processed.wav -af "silenceremove=start_periods=1:start_threshold=-50dB:start_duration=0.5,areverse,silenceremove=start_periods=1:start_threshold=-50dB:start_duration=0.5,areverse" trimmed.wav

# Normalize to standard loudness
ffmpeg -i trimmed.wav -af "loudnorm=I=-16:TP=-1.5:LRA=11" final.wav

# Combined pipeline
ffmpeg -i input.wav -af "\
  silenceremove=start_periods=1:start_threshold=-50dB,\
  areverse,\
  silenceremove=start_periods=1:start_threshold=-50dB,\
  areverse,\
  loudnorm=I=-16:TP=-1.5:LRA=11\
" final.wav
```

**Python trim and normalize:**

```python
import numpy as np
import librosa
import soundfile as sf

def trim_silence(audio, sr, threshold_db=-50, min_silence_ms=500):
    """
    Trim silence from start and end of audio.
    """
    threshold = 10 ** (threshold_db / 20)
    min_samples = int(min_silence_ms * sr / 1000)

    # Find non-silent regions
    non_silent = np.abs(audio) > threshold

    # Smoothe to avoid trimming brief quiet moments
    from scipy.ndimage import binary_dilation
    non_silent = binary_dilation(non_silent, iterations=min_samples)

    # Find first and last non-silent samples
    non_silent_indices = np.where(non_silent)[0]

    if len(non_silent_indices) == 0:
        return audio  # All silent, return original

    start = non_silent_indices[0]
    end = non_silent_indices[-1] + 1

    return audio[start:end]

def trim_with_padding(audio, sr, threshold_db=-50, pad_ms=100):
    """
    Trim silence but keep small padding for natural sound.
    """
    trimmed = trim_silence(audio, sr, threshold_db)

    # Add padding
    pad_samples = int(pad_ms * sr / 1000)
    silence = np.zeros(pad_samples)

    return np.concatenate([silence, trimmed, silence])

def peak_normalize(audio, target_db=-3):
    """
    Normalize audio so peak reaches target level.
    """
    peak = np.max(np.abs(audio))
    if peak == 0:
        return audio

    target_linear = 10 ** (target_db / 20)
    gain = target_linear / peak

    return audio * gain

def rms_normalize(audio, target_db=-20):
    """
    Normalize audio so RMS reaches target level.
    """
    rms = np.sqrt(np.mean(audio ** 2))
    if rms == 0:
        return audio

    target_linear = 10 ** (target_db / 20)
    gain = target_linear / rms

    # Limit gain to prevent clipping
    max_gain = 0.95 / np.max(np.abs(audio))
    gain = min(gain, max_gain)

    return audio * gain

def lufs_normalize(audio, sr, target_lufs=-16):
    """
    Normalize to target LUFS (broadcast standard).
    """
    try:
        import pyloudnorm as pyln

        meter = pyln.Meter(sr)
        current_lufs = meter.integrated_loudness(audio)

        if np.isinf(current_lufs):
            return audio

        normalized = pyln.normalize.loudness(audio, current_lufs, target_lufs)

        # True peak limiting
        peak = np.max(np.abs(normalized))
        if peak > 0.95:
            normalized = normalized * 0.95 / peak

        return normalized

    except ImportError:
        # Fallback to RMS normalization
        return rms_normalize(audio, target_db=target_lufs + 10)

def export_for_transcription(audio, sr, output_path, target_lufs=-16):
    """
    Prepare audio for optimal transcription.
    """
    # Trim silence
    trimmed = trim_with_padding(audio, sr, threshold_db=-45, pad_ms=200)

    # Normalize
    normalized = lufs_normalize(trimmed, sr, target_lufs)

    # Export as 16-bit WAV
    sf.write(output_path, normalized, sr, subtype='PCM_16')

    # Report stats
    duration = len(normalized) / sr
    final_lufs = calculate_lufs(normalized, sr)
    print(f"Exported: {output_path}")
    print(f"Duration: {duration:.1f}s")
    print(f"Loudness: {final_lufs:.1f} LUFS")

def calculate_lufs(audio, sr):
    """Calculate LUFS loudness."""
    try:
        import pyloudnorm as pyln
        meter = pyln.Meter(sr)
        return meter.integrated_loudness(audio)
    except:
        rms_db = 20 * np.log10(np.sqrt(np.mean(audio ** 2)) + 1e-10)
        return rms_db - 10  # Rough approximation

def batch_normalize(input_dir, output_dir, target_lufs=-16):
    """
    Batch normalize multiple files to same loudness.
    """
    import os
    from pathlib import Path

    os.makedirs(output_dir, exist_ok=True)

    for filepath in Path(input_dir).glob('*.wav'):
        audio, sr = sf.read(filepath)
        normalized = lufs_normalize(audio, sr, target_lufs)
        trimmed = trim_with_padding(normalized, sr)

        output_path = os.path.join(output_dir, filepath.name)
        sf.write(output_path, trimmed, sr, subtype='PCM_16')
        print(f"Processed: {filepath.name}")

# Usage
if __name__ == '__main__':
    audio, sr = sf.read('processed_speech.wav')

    # Full export pipeline
    export_for_transcription(audio, sr, 'ready_for_transcription.wav')

    # Batch process
    # batch_normalize('input_folder/', 'output_folder/', target_lufs=-16)
```

**Loudness standards:**

| Standard | LUFS | Use Case |
|----------|------|----------|
| Podcast | -16 | General listening |
| Broadcast (EU) | -23 | TV/Radio |
| Broadcast (US) | -24 | TV/Radio |
| YouTube | -14 | Online video |
| Forensic | -16 to -20 | Clear without distortion |

Reference: [EBU R 128 Loudness Standard](https://tech.ebu.ch/docs/r/r128.pdf)

### 5.4 Use Dynamic Range Compression for Level Consistency

**Impact: MEDIUM-HIGH (normalizes volume across quiet and loud segments)**

Compression reduces the gap between quiet and loud parts, making soft speech audible without clipping loud segments.

**Incorrect (simple gain increases noise):**

```bash
# Linear gain boost
ffmpeg -i quiet.wav -af "volume=15dB" loud_noise.wav
# Quiet speech louder, but noise proportionally louder too
```

**Correct (dynamic compression):**

```bash
# FFmpeg compressor
ffmpeg -i variable_level.wav -af "\
  compand=attacks=0.1:decays=0.3:\
  points=-70/-70|-40/-20|-20/-10|0/-5:\
  gain=5\
" compressed.wav

# Or use acompressor filter
ffmpeg -i input.wav -af "\
  acompressor=threshold=-20dB:ratio=4:attack=5:release=100:makeup=5dB\
" compressed.wav

# Dynamic normalization (loudnorm)
ffmpeg -i variable.wav -af "loudnorm=I=-16:TP=-1.5:LRA=11" normalized.wav
```

**Python dynamic compression:**

```python
import numpy as np
import librosa
import soundfile as sf

def simple_compressor(audio, threshold_db=-20, ratio=4, attack_ms=5, release_ms=100, sr=44100):
    """
    Simple dynamic range compressor.

    Parameters:
    - threshold_db: Level above which compression starts
    - ratio: Compression ratio (e.g., 4:1)
    - attack_ms: Attack time in milliseconds
    - release_ms: Release time in milliseconds
    """
    threshold = 10 ** (threshold_db / 20)

    # Convert times to samples
    attack_samples = int(attack_ms * sr / 1000)
    release_samples = int(release_ms * sr / 1000)

    # Attack/release coefficients
    attack_coef = np.exp(-1 / attack_samples) if attack_samples > 0 else 0
    release_coef = np.exp(-1 / release_samples) if release_samples > 0 else 0

    # Process
    output = np.zeros_like(audio)
    envelope = 0

    for i in range(len(audio)):
        # Envelope follower
        level = np.abs(audio[i])
        if level > envelope:
            envelope = attack_coef * envelope + (1 - attack_coef) * level
        else:
            envelope = release_coef * envelope + (1 - release_coef) * level

        # Calculate gain
        if envelope > threshold:
            gain_db = threshold_db + (20 * np.log10(envelope + 1e-10) - threshold_db) / ratio
            gain = 10 ** (gain_db / 20) / (envelope + 1e-10)
        else:
            gain = 1.0

        output[i] = audio[i] * gain

    return output

def multiband_compressor(audio, sr, bands=None):
    """
    Multiband compressor for better tonal balance.
    """
    from scipy import signal

    if bands is None:
        bands = [
            {'low': 0, 'high': 200, 'threshold': -25, 'ratio': 3},
            {'low': 200, 'high': 2000, 'threshold': -20, 'ratio': 4},
            {'low': 2000, 'high': 6000, 'threshold': -18, 'ratio': 3},
            {'low': 6000, 'high': sr//2, 'threshold': -15, 'ratio': 2},
        ]

    output = np.zeros_like(audio)

    for band in bands:
        # Bandpass filter
        nyquist = sr / 2
        low = max(band['low'] / nyquist, 0.001)
        high = min(band['high'] / nyquist, 0.999)

        if low < high:
            b, a = signal.butter(4, [low, high], btype='band')
            band_audio = signal.filtfilt(b, a, audio)

            # Compress this band
            compressed = simple_compressor(
                band_audio,
                threshold_db=band['threshold'],
                ratio=band['ratio'],
                sr=sr
            )

            output += compressed

    return output

def auto_gain_control(audio, sr, target_rms_db=-20, window_ms=500):
    """
    Automatic Gain Control - adapts to changing levels.
    """
    window_samples = int(window_ms * sr / 1000)
    hop = window_samples // 4
    target_rms = 10 ** (target_rms_db / 20)

    output = np.zeros_like(audio)

    for i in range(0, len(audio) - window_samples, hop):
        window = audio[i:i + window_samples]

        # Calculate RMS of window
        rms = np.sqrt(np.mean(window ** 2)) + 1e-10

        # Calculate gain needed
        gain = target_rms / rms

        # Limit gain to reasonable range
        gain = np.clip(gain, 0.1, 10)

        # Apply with crossfade
        if i == 0:
            output[i:i + window_samples] = window * gain
        else:
            fade_len = hop
            fade_in = np.linspace(0, 1, fade_len)
            fade_out = 1 - fade_in

            output[i:i + fade_len] = (output[i:i + fade_len] * fade_out +
                                       window[:fade_len] * gain * fade_in)
            output[i + fade_len:i + window_samples] = window[fade_len:] * gain

    return output

def calculate_lufs(audio, sr):
    """Calculate integrated LUFS loudness."""
    try:
        import pyloudnorm as pyln
        meter = pyln.Meter(sr)
        return meter.integrated_loudness(audio)
    except ImportError:
        # Simplified RMS-based approximation
        rms = np.sqrt(np.mean(audio ** 2))
        return 20 * np.log10(rms + 1e-10) - 10  # Rough LUFS approximation

def loudness_normalize(audio, sr, target_lufs=-16):
    """Normalize to target loudness in LUFS."""
    try:
        import pyloudnorm as pyln
        meter = pyln.Meter(sr)
        current_lufs = meter.integrated_loudness(audio)
        normalized = pyln.normalize.loudness(audio, current_lufs, target_lufs)
        return normalized
    except ImportError:
        # Fallback: simple peak normalization
        peak = np.max(np.abs(audio))
        return audio / peak * 0.9

# Usage
if __name__ == '__main__':
    audio, sr = sf.read('variable_level.wav')

    # Apply compression
    compressed = simple_compressor(audio, threshold_db=-20, ratio=4, sr=sr)

    # Then normalize
    normalized = loudness_normalize(compressed, sr, target_lufs=-16)

    sf.write('level_controlled.wav', normalized, sr)

    # Report levels
    print(f"Input LUFS: {calculate_lufs(audio, sr):.1f}")
    print(f"Output LUFS: {calculate_lufs(normalized, sr):.1f}")
```

**Compression settings guide:**

| Scenario | Threshold | Ratio | Attack | Release |
|----------|-----------|-------|--------|---------|
| Gentle leveling | -25 dB | 2:1 | 20 ms | 200 ms |
| Standard speech | -20 dB | 4:1 | 5 ms | 100 ms |
| Aggressive control | -15 dB | 8:1 | 1 ms | 50 ms |
| Limiting peaks | -3 dB | 20:1 | 0.5 ms | 100 ms |

Reference: [Loudness Normalization](https://en.wikipedia.org/wiki/Audio_normalization)

### 5.5 Use Time Stretching for Intelligibility

**Impact: MEDIUM-HIGH (20-30% slower playback dramatically improves comprehension)**

Slowing down speech (without pitch change) gives listeners more time to parse difficult audio. Critical for degraded recordings with high cognitive load.

**Incorrect (simple speed change alters pitch):**

```bash
# Changing tempo also changes pitch
ffmpeg -i fast_speech.wav -af "atempo=0.75" chipmunk.wav
# Speaker sounds unnatural
```

**Correct (phase vocoder preserves pitch):**

```bash
# Rubberband time stretch (preserves pitch and formants)
ffmpeg -i fast_speech.wav -af "rubberband=tempo=0.8:formant=1" slowed.wav

# For extreme slowdown, use multiple passes
ffmpeg -i input.wav -af "rubberband=tempo=0.7" -af "rubberband=tempo=0.85" very_slow.wav

# SoX alternative
sox input.wav output.wav tempo 0.8
```

**Python time stretching:**

```python
import numpy as np
import librosa
import soundfile as sf

def time_stretch(audio, sr, rate):
    """
    Time stretch audio using librosa.

    rate > 1 = faster (shorter duration)
    rate < 1 = slower (longer duration)
    """
    stretched = librosa.effects.time_stretch(audio, rate=rate)
    return stretched

def segment_aware_stretch(audio, sr, rate, preserve_pauses=True):
    """
    Time stretch that can preserve natural pause durations.
    """
    if not preserve_pauses:
        return time_stretch(audio, sr, rate)

    # Detect speech segments
    from voice_vad_segment import silero_vad, energy_based_vad

    try:
        speech_mask, timestamps = silero_vad(audio, sr)
    except:
        speech_mask = energy_based_vad(audio, sr)
        timestamps = None

    # Stretch only speech segments
    if timestamps:
        stretched_segments = []
        current_pos = 0

        for ts in timestamps:
            # Keep silence before speech as-is
            if ts['start'] > current_pos:
                silence = audio[current_pos:ts['start']]
                stretched_segments.append(silence)

            # Stretch speech segment
            speech = audio[ts['start']:ts['end']]
            stretched_speech = time_stretch(speech, sr, rate)
            stretched_segments.append(stretched_speech)

            current_pos = ts['end']

        # Keep trailing silence
        if current_pos < len(audio):
            stretched_segments.append(audio[current_pos:])

        return np.concatenate(stretched_segments)
    else:
        return time_stretch(audio, sr, rate)

def variable_speed_transcription(audio, sr, speeds=[1.0, 0.8, 0.6]):
    """
    Generate multiple speed versions for difficult transcription.
    """
    versions = {}

    for speed in speeds:
        stretched = time_stretch(audio, sr, speed)
        versions[f"{int(speed*100)}%"] = stretched
        print(f"Generated {int(speed*100)}% speed version: {len(stretched)/sr:.1f}s")

    return versions

def adaptive_speed(audio, sr, target_duration_ratio=1.3,
                   min_rate=0.5, max_rate=1.0):
    """
    Adaptively slow down based on detected speech density.
    """
    # Analyze speech rate
    from voice_vad_segment import energy_based_vad

    speech_mask = energy_based_vad(audio, sr)
    speech_ratio = np.mean(speech_mask)

    # More speech = slow down more
    # Less speech (more pauses) = don't need to slow as much
    rate = 1.0 / (target_duration_ratio * speech_ratio + (1 - speech_ratio))
    rate = np.clip(rate, min_rate, max_rate)

    print(f"Speech ratio: {speech_ratio:.2f}, applying rate: {rate:.2f}")

    return time_stretch(audio, sr, rate)

def export_slowed_versions(input_path, output_dir, speeds=[1.0, 0.85, 0.7, 0.5]):
    """
    Export multiple speed versions for transcription workflow.
    """
    import os
    from pathlib import Path

    audio, sr = sf.read(input_path)
    base_name = Path(input_path).stem

    os.makedirs(output_dir, exist_ok=True)

    for speed in speeds:
        stretched = time_stretch(audio, sr, speed)
        output_path = os.path.join(output_dir, f"{base_name}_{int(speed*100)}pct.wav")
        sf.write(output_path, stretched, sr)
        print(f"Saved: {output_path}")

# Usage
if __name__ == '__main__':
    audio, sr = sf.read('difficult_audio.wav')

    # Standard slowdown
    slowed = time_stretch(audio, sr, rate=0.75)
    sf.write('slowed_75pct.wav', slowed, sr)

    # Segment-aware (preserves pauses)
    slowed_natural = segment_aware_stretch(audio, sr, rate=0.8)
    sf.write('slowed_natural.wav', slowed_natural, sr)

    # Export multiple versions
    export_slowed_versions('difficult_audio.wav', 'speed_versions/')
```

**Recommended speeds:**

| Difficulty | Speed | Use Case |
|------------|-------|----------|
| Normal | 1.0x | Clear audio |
| Slightly degraded | 0.85-0.9x | Light background noise |
| Degraded | 0.7-0.8x | Significant noise/reverb |
| Very difficult | 0.5-0.6x | Heavily damaged audio |
| Near-unintelligible | 0.3-0.5x | Last resort before rejection |

**Install rubberband for FFmpeg:**

```bash
# macOS
brew install rubberband

# Then use rubberband filter in FFmpeg
ffmpeg -i input.wav -af "rubberband=tempo=0.8" output.wav
```

Reference: [Phase Vocoder Time Stretching](https://en.wikipedia.org/wiki/Phase_vocoder)

---

## 6. Transcription & Recognition

**Impact: MEDIUM**

Optimal preprocessing and robust ASR models (Whisper) maximize transcription accuracy from degraded audio. Includes confidence scoring and multi-pass strategies.

### 6.1 Detect and Filter ASR Hallucinations

**Impact: MEDIUM (prevents false content in transcripts)**

Whisper can hallucinate repeated phrases, URLs, or random text during silence. Implement detection and filtering.

**Incorrect (accepting all output):**

```python
# No hallucination filtering
result = model.transcribe(audio_with_silence)
# May contain "Thank you for watching", URLs, or repeated phrases
```

**Correct (hallucination detection and filtering):**

```python
import whisper
import re
import numpy as np
import librosa
from collections import Counter

# Common hallucination patterns
HALLUCINATION_PATTERNS = [
    r'thank you for watching',
    r'please subscribe',
    r'like and subscribe',
    r'see you next time',
    r'thanks for watching',
    r'www\.',
    r'http[s]?://',
    r'\.com',
    r'\bum+\b',
    r'\buh+\b',
    r'♪+',
    r'[🎵🎶]+',
    r'MBC\s*뉴스',  # Common Korean hallucination
    r'자막 제공',
    r'ご視聴ありがとうございました',  # Common Japanese hallucination
]

def detect_hallucinations(text):
    """
    Detect common hallucination patterns.
    """
    detected = []
    text_lower = text.lower()

    for pattern in HALLUCINATION_PATTERNS:
        matches = re.findall(pattern, text_lower, re.IGNORECASE)
        if matches:
            detected.append({
                'pattern': pattern,
                'matches': matches
            })

    return detected

def detect_repetition_hallucination(segments, threshold=3):
    """
    Detect repeated segments (common hallucination).
    """
    texts = [seg['text'].strip().lower() for seg in segments if seg['text'].strip()]

    # Count repeated phrases
    phrase_counts = Counter(texts)
    repetitions = {phrase: count for phrase, count in phrase_counts.items()
                   if count >= threshold and len(phrase) > 10}

    return repetitions

def filter_hallucinations(result):
    """
    Filter detected hallucinations from transcription result.
    """
    filtered_segments = []

    for segment in result['segments']:
        text = segment['text']

        # Check for hallucination patterns
        hallucinations = detect_hallucinations(text)

        if not hallucinations:
            filtered_segments.append(segment)
        else:
            # Keep segment but mark as potentially hallucinated
            segment['hallucination_warning'] = hallucinations
            # Optionally skip or include with warning
            # filtered_segments.append(segment)  # Include with warning
            pass  # Skip entirely

    return filtered_segments

def validate_with_audio(audio, sr, segments, energy_threshold_db=-40):
    """
    Validate that text corresponds to actual audio activity.
    """
    frame_length = int(0.025 * sr)
    rms = librosa.feature.rms(y=audio, frame_length=frame_length)[0]
    rms_db = 20 * np.log10(rms + 1e-10)
    times = librosa.frames_to_time(np.arange(len(rms)), sr=sr,
                                    n_fft=frame_length)

    validated = []

    for segment in segments:
        start = segment['start']
        end = segment['end']

        # Find corresponding audio frames
        mask = (times >= start) & (times <= end)
        segment_rms = rms_db[mask]

        if len(segment_rms) == 0:
            continue

        # Check if there's actual audio activity
        avg_energy = np.mean(segment_rms)

        if avg_energy > energy_threshold_db:
            segment['energy_validated'] = True
            validated.append(segment)
        else:
            # Likely hallucination during silence
            segment['energy_validated'] = False
            segment['hallucination_warning'] = 'Low audio energy'
            # Skip this segment

    return validated

def safe_transcribe(audio_path, model_size='large-v3'):
    """
    Transcribe with hallucination detection and filtering.
    """
    model = whisper.load_model(model_size)
    audio, sr = librosa.load(audio_path, sr=16000)

    # Initial transcription
    result = model.transcribe(
        audio_path,
        language='en',
        word_timestamps=True,
        no_speech_threshold=0.6,  # Higher threshold to skip silent parts
        compression_ratio_threshold=2.4  # Filter high compression (repetition)
    )

    # Filter pattern hallucinations
    filtered = filter_hallucinations(result)

    # Detect repetitions
    repetitions = detect_repetition_hallucination(filtered)
    if repetitions:
        print(f"Warning: Detected repeated phrases: {list(repetitions.keys())}")
        # Remove repeated hallucinations
        filtered = [seg for seg in filtered
                    if seg['text'].strip().lower() not in repetitions]

    # Validate against audio energy
    validated = validate_with_audio(audio, sr, filtered)

    # Reconstruct text
    clean_text = ' '.join([seg['text'] for seg in validated])

    return {
        'text': clean_text,
        'segments': validated,
        'warnings': {
            'repetitions': repetitions,
            'filtered_count': len(result['segments']) - len(validated)
        }
    }

def transcribe_with_vad_verification(audio_path):
    """
    Use VAD to verify transcription alignment.
    """
    import torch

    # Load VAD
    vad_model, utils = torch.hub.load('snakers4/silero-vad', 'silero_vad')
    get_speech_timestamps = utils[0]

    audio, sr = librosa.load(audio_path, sr=16000)

    # Get speech timestamps
    speech_timestamps = get_speech_timestamps(
        torch.tensor(audio),
        vad_model,
        sampling_rate=16000
    )

    # Transcribe
    model = whisper.load_model('large-v3')
    result = model.transcribe(audio_path, language='en')

    # Validate each segment overlaps with VAD speech
    validated = []
    for segment in result['segments']:
        seg_start = segment['start']
        seg_end = segment['end']

        # Check overlap with any speech timestamp
        overlaps = False
        for ts in speech_timestamps:
            vad_start = ts['start'] / 16000
            vad_end = ts['end'] / 16000

            # Check for overlap
            if seg_start < vad_end and seg_end > vad_start:
                overlaps = True
                break

        if overlaps:
            validated.append(segment)
        else:
            print(f"Filtered (no VAD overlap): [{seg_start:.1f}s] {segment['text']}")

    return validated

# Usage
if __name__ == '__main__':
    result = safe_transcribe('audio.wav')

    print("Clean transcript:")
    print(result['text'])

    if result['warnings']['filtered_count'] > 0:
        print(f"\n{result['warnings']['filtered_count']} segments filtered as hallucinations")
```

**Hallucination risk factors:**

| Factor | Risk Level | Mitigation |
|--------|------------|------------|
| Long silence | High | Use VAD, higher no_speech_threshold |
| Non-English audio | High | Specify language explicitly |
| Music/noise | Medium | Pre-filter with RNNoise |
| Very short segments | Medium | Set minimum duration |
| Low audio quality | Medium | Validate with energy |

Reference: [Whisper Hallucination Research](https://arxiv.org/abs/2212.04356)

### 6.2 Segment Audio for Targeted Transcription

**Impact: MEDIUM (focuses ASR on speech segments, reduces hallucinations)**

Long audio with silence causes ASR hallucinations. Segment into speech chunks for better accuracy and timestamps.

**Incorrect (transcribe entire file):**

```python
# Transcribing file with long silences
result = whisper.transcribe('hour_long_recording.wav')
# May hallucinate content during silent portions
```

**Correct (VAD-based segmentation):**

```python
import whisper
import torch
import numpy as np
import librosa
import soundfile as sf

def segment_and_transcribe(audio_path, min_segment_sec=1, max_segment_sec=30):
    """
    Segment audio using VAD then transcribe each segment.
    """
    # Load VAD model
    vad_model, utils = torch.hub.load(
        'snakers4/silero-vad',
        'silero_vad',
        force_reload=False
    )
    get_speech_timestamps = utils[0]

    # Load audio
    audio, sr = librosa.load(audio_path, sr=16000)

    # Get speech timestamps
    speech_timestamps = get_speech_timestamps(
        torch.tensor(audio),
        vad_model,
        sampling_rate=16000,
        threshold=0.5,
        min_speech_duration_ms=500,
        min_silence_duration_ms=300
    )

    # Load Whisper
    whisper_model = whisper.load_model('large-v3')

    # Transcribe each segment
    transcription = []
    for i, ts in enumerate(speech_timestamps):
        start_sample = ts['start']
        end_sample = ts['end']

        # Check segment duration
        duration = (end_sample - start_sample) / 16000
        if duration < min_segment_sec:
            continue

        # Split very long segments
        if duration > max_segment_sec:
            # Process in chunks
            for chunk_start in range(start_sample, end_sample, int(max_segment_sec * 16000)):
                chunk_end = min(chunk_start + int(max_segment_sec * 16000), end_sample)
                segment = audio[chunk_start:chunk_end]

                result = whisper_model.transcribe(
                    segment,
                    language='en',
                    fp16=False
                )

                transcription.append({
                    'start': chunk_start / 16000,
                    'end': chunk_end / 16000,
                    'text': result['text'].strip()
                })
        else:
            segment = audio[start_sample:end_sample]

            result = whisper_model.transcribe(
                segment,
                language='en',
                fp16=False
            )

            transcription.append({
                'start': start_sample / 16000,
                'end': end_sample / 16000,
                'text': result['text'].strip()
            })

    return transcription

def intelligent_chunking(audio, sr, max_chunk_sec=30, overlap_sec=2):
    """
    Chunk audio intelligently at natural break points.
    """
    # Find potential break points (low energy moments)
    frame_length = int(0.025 * sr)
    rms = librosa.feature.rms(y=audio, frame_length=frame_length)[0]

    max_chunk_samples = int(max_chunk_sec * sr)
    overlap_samples = int(overlap_sec * sr)

    chunks = []
    start = 0

    while start < len(audio):
        # End of potential chunk
        end = min(start + max_chunk_samples, len(audio))

        if end < len(audio):
            # Find best break point (lowest energy) near end
            search_start = max(0, end - int(2 * sr))  # Search last 2 seconds
            search_region = rms[search_start // (frame_length//2):end // (frame_length//2)]

            if len(search_region) > 0:
                min_idx = np.argmin(search_region)
                end = search_start + min_idx * (frame_length // 2)

        chunks.append({
            'start_sample': start,
            'end_sample': end,
            'start_time': start / sr,
            'end_time': end / sr
        })

        # Next chunk starts with overlap
        start = max(start + 1, end - overlap_samples)

    return chunks

def transcribe_with_overlap_handling(audio_path, max_chunk_sec=30):
    """
    Transcribe with overlapping chunks and merge results.
    """
    audio, sr = librosa.load(audio_path, sr=16000)
    chunks = intelligent_chunking(audio, sr, max_chunk_sec=max_chunk_sec)

    model = whisper.load_model('large-v3')
    all_results = []

    for chunk in chunks:
        segment = audio[chunk['start_sample']:chunk['end_sample']]

        result = model.transcribe(
            segment,
            language='en',
            word_timestamps=True
        )

        for seg in result['segments']:
            all_results.append({
                'start': chunk['start_time'] + seg['start'],
                'end': chunk['start_time'] + seg['end'],
                'text': seg['text']
            })

    # Merge overlapping results
    merged = merge_overlapping_transcripts(all_results)

    return merged

def merge_overlapping_transcripts(segments):
    """
    Merge transcription segments, handling overlaps.
    """
    if not segments:
        return []

    # Sort by start time
    segments = sorted(segments, key=lambda x: x['start'])

    merged = [segments[0]]

    for seg in segments[1:]:
        last = merged[-1]

        # Check for overlap
        if seg['start'] < last['end']:
            # Overlapping - keep the one with more content or merge
            if len(seg['text']) > len(last['text']):
                merged[-1] = seg
            # Or could merge texts intelligently
        else:
            merged.append(seg)

    return merged

def create_timestamped_transcript(audio_path, output_format='srt'):
    """
    Create transcript with timestamps in various formats.
    """
    transcription = segment_and_transcribe(audio_path)

    if output_format == 'srt':
        srt_content = []
        for i, seg in enumerate(transcription, 1):
            start = format_timestamp(seg['start'], 'srt')
            end = format_timestamp(seg['end'], 'srt')
            srt_content.append(f"{i}\n{start} --> {end}\n{seg['text']}\n")
        return '\n'.join(srt_content)

    elif output_format == 'vtt':
        vtt_content = ['WEBVTT\n']
        for seg in transcription:
            start = format_timestamp(seg['start'], 'vtt')
            end = format_timestamp(seg['end'], 'vtt')
            vtt_content.append(f"{start} --> {end}\n{seg['text']}\n")
        return '\n'.join(vtt_content)

    elif output_format == 'txt':
        return '\n'.join([
            f"[{seg['start']:.2f}s] {seg['text']}"
            for seg in transcription
        ])

    return transcription

def format_timestamp(seconds, format_type='srt'):
    """Format seconds to timestamp string."""
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    millis = int((seconds % 1) * 1000)

    if format_type == 'srt':
        return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"
    else:  # vtt
        return f"{hours:02d}:{minutes:02d}:{secs:02d}.{millis:03d}"

# Usage
if __name__ == '__main__':
    # Segment and transcribe
    transcript = segment_and_transcribe('recording.wav')

    for seg in transcript:
        print(f"[{seg['start']:.1f}s - {seg['end']:.1f}s]: {seg['text']}")

    # Export as SRT
    srt = create_timestamped_transcript('recording.wav', output_format='srt')
    with open('transcript.srt', 'w') as f:
        f.write(srt)
```

**Segmentation settings:**

| Audio Type | Min Segment | Max Segment | Overlap |
|------------|-------------|-------------|---------|
| Interview | 1s | 30s | 2s |
| Meeting | 2s | 60s | 3s |
| Phone call | 1s | 20s | 1s |
| Noisy recording | 0.5s | 15s | 2s |

Reference: [Silero VAD](https://github.com/snakers4/silero-vad)

### 6.3 Track Confidence Scores for Uncertain Words

**Impact: MEDIUM (identifies unreliable transcription sections)**

ASR confidence scores identify words that need human review. Flag low-confidence sections for manual verification.

**Incorrect (accept all text equally):**

```python
# Treating all words as equally reliable
result = model.transcribe(audio)
print(result['text'])  # No indication of confidence
```

**Correct (track and flag uncertainty):**

```python
import whisper
import numpy as np
import librosa

def transcribe_with_confidence(audio_path, model_size='large-v3'):
    """
    Transcribe and extract word-level confidence scores.
    """
    model = whisper.load_model(model_size)

    result = model.transcribe(
        audio_path,
        language='en',
        word_timestamps=True
    )

    words_with_confidence = []
    for segment in result['segments']:
        if 'words' in segment:
            for word in segment['words']:
                words_with_confidence.append({
                    'word': word['word'],
                    'start': word['start'],
                    'end': word['end'],
                    'probability': word.get('probability', None)
                })

    return result['text'], words_with_confidence

def flag_uncertain_sections(words_with_confidence, threshold=0.7):
    """
    Identify sections with low confidence for human review.
    """
    uncertain_sections = []
    current_uncertain = None

    for word in words_with_confidence:
        prob = word.get('probability', 1.0)
        if prob is None:
            prob = 1.0

        if prob < threshold:
            if current_uncertain is None:
                current_uncertain = {
                    'start': word['start'],
                    'end': word['end'],
                    'words': [word['word']],
                    'avg_confidence': prob
                }
            else:
                current_uncertain['end'] = word['end']
                current_uncertain['words'].append(word['word'])
                current_uncertain['avg_confidence'] = (
                    (current_uncertain['avg_confidence'] * (len(current_uncertain['words']) - 1) + prob)
                    / len(current_uncertain['words'])
                )
        else:
            if current_uncertain is not None:
                uncertain_sections.append(current_uncertain)
                current_uncertain = None

    if current_uncertain is not None:
        uncertain_sections.append(current_uncertain)

    return uncertain_sections

def generate_review_transcript(audio_path, confidence_threshold=0.7):
    """
    Generate transcript with uncertainty markers for review.
    """
    text, words = transcribe_with_confidence(audio_path)

    # Build marked-up transcript
    marked_text = []
    current_uncertain = False

    for word in words:
        prob = word.get('probability', 1.0) or 1.0

        if prob < confidence_threshold:
            if not current_uncertain:
                marked_text.append('[?')
                current_uncertain = True
            marked_text.append(word['word'])
        else:
            if current_uncertain:
                marked_text.append('?]')
                current_uncertain = False
            marked_text.append(word['word'])

    if current_uncertain:
        marked_text.append('?]')

    return ' '.join(marked_text)

def export_uncertainty_report(audio_path, output_path):
    """
    Export detailed uncertainty report.
    """
    text, words = transcribe_with_confidence(audio_path)
    uncertain = flag_uncertain_sections(words)

    report = []
    report.append("TRANSCRIPTION UNCERTAINTY REPORT")
    report.append("=" * 50)
    report.append(f"\nFull transcript:\n{text}\n")
    report.append(f"\nUncertain sections ({len(uncertain)} found):")
    report.append("-" * 50)

    for i, section in enumerate(uncertain, 1):
        report.append(f"\n{i}. [{section['start']:.1f}s - {section['end']:.1f}s]")
        report.append(f"   Text: {' '.join(section['words'])}")
        report.append(f"   Avg confidence: {section['avg_confidence']:.1%}")

    # Overall statistics
    if words:
        probs = [w.get('probability', 1.0) or 1.0 for w in words]
        report.append(f"\n\nStatistics:")
        report.append(f"  Total words: {len(words)}")
        report.append(f"  Average confidence: {np.mean(probs):.1%}")
        report.append(f"  Low confidence words (<70%): {sum(1 for p in probs if p < 0.7)}")
        report.append(f"  Very low confidence words (<50%): {sum(1 for p in probs if p < 0.5)}")

    report_text = '\n'.join(report)

    with open(output_path, 'w') as f:
        f.write(report_text)

    return report_text

def confidence_colored_html(audio_path, output_path):
    """
    Generate HTML transcript with color-coded confidence.
    """
    text, words = transcribe_with_confidence(audio_path)

    html = ['<!DOCTYPE html><html><head>',
            '<style>',
            '.high { background-color: #90EE90; }',
            '.medium { background-color: #FFFFE0; }',
            '.low { background-color: #FFB6C1; }',
            'span { padding: 2px; margin: 1px; display: inline-block; }',
            '</style></head><body>']

    for word in words:
        prob = word.get('probability', 1.0) or 1.0

        if prob >= 0.8:
            css_class = 'high'
        elif prob >= 0.6:
            css_class = 'medium'
        else:
            css_class = 'low'

        html.append(f'<span class="{css_class}" title="{prob:.0%}">{word["word"]}</span>')

    html.append('<br><br>')
    html.append('<div>Legend: <span class="high">High (&gt;80%)</span>')
    html.append('<span class="medium">Medium (60-80%)</span>')
    html.append('<span class="low">Low (&lt;60%)</span></div>')
    html.append('</body></html>')

    html_content = '\n'.join(html)

    with open(output_path, 'w') as f:
        f.write(html_content)

    return html_content

# Usage
if __name__ == '__main__':
    # Get transcript with uncertainty markers
    marked_transcript = generate_review_transcript('difficult_audio.wav')
    print(marked_transcript)

    # Export detailed report
    report = export_uncertainty_report('difficult_audio.wav', 'uncertainty_report.txt')

    # Generate color-coded HTML
    confidence_colored_html('difficult_audio.wav', 'transcript.html')
```

**Confidence interpretation:**

| Confidence | Interpretation | Action |
|------------|----------------|--------|
| > 90% | Very reliable | Accept |
| 70-90% | Probably correct | Accept with note |
| 50-70% | Uncertain | Mark for review |
| < 50% | Likely wrong | Require human verification |

Reference: [Whisper Word Timestamps](https://github.com/openai/whisper)

### 6.4 Use Multi-Pass Transcription for Difficult Audio

**Impact: MEDIUM (catches words missed in single pass)**

Single transcription pass may miss words or hallucinate. Multiple passes with different settings or models enables consensus verification.

**Incorrect (single pass, accept as truth):**

```python
# Single pass, no verification
result = whisper.transcribe(audio)
final_transcript = result['text']  # May contain errors
```

**Correct (multi-pass with consensus):**

```python
import whisper
import numpy as np
import librosa
import soundfile as sf
from collections import Counter

def multi_pass_transcribe(audio_path, passes=3):
    """
    Transcribe multiple times with different settings,
    use consensus for final result.
    """
    model = whisper.load_model('large-v3')
    results = []

    # Pass 1: Standard
    r1 = model.transcribe(audio_path, language='en', temperature=0)
    results.append(r1['text'])

    # Pass 2: With beam search
    r2 = model.transcribe(audio_path, language='en',
                          beam_size=10, temperature=0)
    results.append(r2['text'])

    # Pass 3: Higher temperature for alternatives
    r3 = model.transcribe(audio_path, language='en', temperature=0.2)
    results.append(r3['text'])

    return results

def multi_speed_transcribe(audio_path):
    """
    Transcribe at different playback speeds.
    """
    audio, sr = librosa.load(audio_path, sr=16000)
    model = whisper.load_model('large-v3')
    results = {}

    speeds = [1.0, 0.8, 0.6]

    for speed in speeds:
        if speed == 1.0:
            audio_speed = audio
        else:
            audio_speed = librosa.effects.time_stretch(audio, rate=speed)

        temp_path = f'temp_{int(speed*100)}.wav'
        sf.write(temp_path, audio_speed, sr)

        result = model.transcribe(temp_path, language='en')
        results[f'{int(speed*100)}%'] = result['text']

    return results

def multi_enhancement_transcribe(audio_path):
    """
    Transcribe with different enhancement presets.
    """
    import noisereduce as nr

    audio, sr = librosa.load(audio_path, sr=16000)
    model = whisper.load_model('large-v3')
    results = {}

    enhancements = {
        'raw': lambda x: x,
        'light_nr': lambda x: nr.reduce_noise(y=x, sr=sr, prop_decrease=0.3),
        'medium_nr': lambda x: nr.reduce_noise(y=x, sr=sr, prop_decrease=0.6),
        'highpass': lambda x: librosa.effects.preemphasis(x, coef=0.97),
    }

    for name, enhance_fn in enhancements.items():
        enhanced = enhance_fn(audio)
        temp_path = f'temp_{name}.wav'
        sf.write(temp_path, enhanced, sr)

        result = model.transcribe(temp_path, language='en')
        results[name] = result['text']

    return results

def word_level_consensus(transcripts):
    """
    Build consensus transcript from multiple passes at word level.
    """
    # Split into words
    word_lists = [t.lower().split() for t in transcripts]

    # Find longest common subsequence for alignment
    # Simplified: use majority voting position by position
    max_len = max(len(w) for w in word_lists)

    consensus_words = []
    for i in range(max_len):
        words_at_pos = []
        for wl in word_lists:
            if i < len(wl):
                words_at_pos.append(wl[i])

        if words_at_pos:
            # Majority vote
            most_common = Counter(words_at_pos).most_common(1)[0][0]
            consensus_words.append(most_common)

    return ' '.join(consensus_words)

def segment_level_verification(audio_path):
    """
    Verify transcription segment by segment.
    """
    model = whisper.load_model('large-v3')

    # Get segments with timestamps
    result = model.transcribe(
        audio_path,
        language='en',
        word_timestamps=True
    )

    verified_segments = []
    for segment in result['segments']:
        # Re-transcribe just this segment for verification
        start = segment['start']
        end = segment['end']

        # Extract segment
        audio, sr = librosa.load(audio_path, sr=16000,
                                  offset=start, duration=end-start)

        if len(audio) < sr * 0.5:  # Skip very short segments
            verified_segments.append({
                'start': start,
                'end': end,
                'text': segment['text'],
                'confidence': 'low',
                'verified': False
            })
            continue

        # Re-transcribe segment
        sf.write('temp_segment.wav', audio, sr)
        verify_result = model.transcribe('temp_segment.wav', language='en')

        # Compare
        match = segment['text'].strip().lower() == verify_result['text'].strip().lower()

        verified_segments.append({
            'start': start,
            'end': end,
            'text': segment['text'],
            'verified_text': verify_result['text'],
            'match': match,
            'confidence': 'high' if match else 'medium'
        })

    return verified_segments

def generate_transcription_report(audio_path):
    """
    Generate comprehensive transcription with confidence indicators.
    """
    # Multi-pass
    passes = multi_pass_transcribe(audio_path)

    # Multi-enhancement
    enhancements = multi_enhancement_transcribe(audio_path)

    # Build report
    report = {
        'multi_pass_results': passes,
        'enhancement_results': enhancements,
        'consensus': word_level_consensus(passes + list(enhancements.values())),
        'agreement_score': calculate_agreement(passes)
    }

    return report

def calculate_agreement(transcripts):
    """Calculate agreement score between transcripts."""
    if len(transcripts) < 2:
        return 1.0

    # Simple word-level agreement
    word_sets = [set(t.lower().split()) for t in transcripts]

    intersect = word_sets[0]
    union = word_sets[0]
    for ws in word_sets[1:]:
        intersect = intersect & ws
        union = union | ws

    return len(intersect) / len(union) if union else 1.0

# Usage
if __name__ == '__main__':
    report = generate_transcription_report('difficult_audio.wav')

    print("Multi-pass results:")
    for i, text in enumerate(report['multi_pass_results']):
        print(f"  Pass {i+1}: {text[:100]}...")

    print(f"\nConsensus: {report['consensus']}")
    print(f"Agreement score: {report['agreement_score']:.2%}")
```

**Multi-pass strategy by difficulty:**

| Difficulty | Strategy |
|------------|----------|
| Clear | Single pass sufficient |
| Moderate noise | 2-3 passes, compare |
| Heavy noise | Multi-enhancement + multi-speed |
| Critical evidence | Full verification pipeline |

Reference: [Whisper Decoding Strategies](https://github.com/openai/whisper)

### 6.5 Use Whisper for Noise-Robust Transcription

**Impact: MEDIUM (transcribes speech at SNR below 10 dB)**

OpenAI's Whisper is trained on diverse, noisy data making it more robust than traditional ASR for degraded audio.

**Incorrect (preprocessing that hurts Whisper):**

```bash
# Aggressive denoising can remove speech cues Whisper uses
ffmpeg -i noisy.wav -af "afftdn=nr=40" over_denoised.wav
whisper over_denoised.wav
# May perform worse than raw audio
```

**Correct (minimal preprocessing for Whisper):**

```bash
# Whisper works best with 16kHz audio
ffmpeg -i input.wav -ar 16000 -ac 1 whisper_ready.wav

# Run Whisper
whisper whisper_ready.wav --model large-v3 --language en

# For very noisy audio, try medium denoising first
ffmpeg -i noisy.wav -ar 16000 -ac 1 -af "afftdn=nr=12" lightly_denoised.wav
whisper lightly_denoised.wav --model large-v3
```

**Python Whisper workflow:**

```python
import whisper
import numpy as np
import librosa
import soundfile as sf

def transcribe_with_whisper(audio_path, model_size='large-v3', language='en'):
    """
    Transcribe audio using OpenAI Whisper.
    """
    # Load model
    model = whisper.load_model(model_size)

    # Transcribe
    result = model.transcribe(
        audio_path,
        language=language,
        task='transcribe',
        verbose=True
    )

    return result

def prepare_for_whisper(audio, sr):
    """
    Prepare audio for optimal Whisper performance.
    """
    # Whisper expects 16kHz mono
    if sr != 16000:
        audio = librosa.resample(audio, orig_sr=sr, target_sr=16000)
        sr = 16000

    # Ensure mono
    if audio.ndim > 1:
        audio = audio.mean(axis=1)

    # Normalize
    peak = np.max(np.abs(audio))
    if peak > 0:
        audio = audio / peak * 0.9

    return audio, sr

def transcribe_segments(audio, sr, segment_duration=30):
    """
    Transcribe long audio in segments for better accuracy.
    """
    model = whisper.load_model('large-v3')

    segment_samples = segment_duration * sr
    segments = []

    for i in range(0, len(audio), segment_samples):
        segment = audio[i:i + segment_samples]

        # Pad if too short
        if len(segment) < sr:  # Less than 1 second
            continue

        # Transcribe segment
        result = model.transcribe(
            segment,
            language='en',
            fp16=False  # Use fp32 for better accuracy
        )

        start_time = i / sr
        for seg in result['segments']:
            segments.append({
                'start': start_time + seg['start'],
                'end': start_time + seg['end'],
                'text': seg['text']
            })

    return segments

def transcribe_with_confidence(audio_path, model_size='large-v3'):
    """
    Transcribe and return confidence scores.
    """
    model = whisper.load_model(model_size)

    result = model.transcribe(
        audio_path,
        language='en',
        word_timestamps=True
    )

    words_with_confidence = []
    for segment in result['segments']:
        if 'words' in segment:
            for word in segment['words']:
                words_with_confidence.append({
                    'word': word['word'],
                    'start': word['start'],
                    'end': word['end'],
                    'probability': word.get('probability', None)
                })

    return result['text'], words_with_confidence

def multi_model_transcription(audio_path):
    """
    Transcribe with multiple models and compare.
    """
    models = ['small', 'medium', 'large-v3']
    results = {}

    for model_name in models:
        print(f"Transcribing with {model_name}...")
        model = whisper.load_model(model_name)
        result = model.transcribe(audio_path, language='en')
        results[model_name] = result['text']

    return results

def whisper_with_preprocessing_comparison(audio_path):
    """
    Compare Whisper results with different preprocessing.
    """
    import noisereduce as nr

    audio, sr = librosa.load(audio_path, sr=16000)
    model = whisper.load_model('large-v3')

    results = {}

    # 1. Raw audio
    raw_result = model.transcribe(audio, language='en')
    results['raw'] = raw_result['text']

    # 2. Light noise reduction
    light_nr = nr.reduce_noise(y=audio, sr=sr, prop_decrease=0.3)
    sf.write('temp_light.wav', light_nr, sr)
    light_result = model.transcribe('temp_light.wav', language='en')
    results['light_nr'] = light_result['text']

    # 3. Medium noise reduction
    medium_nr = nr.reduce_noise(y=audio, sr=sr, prop_decrease=0.6)
    sf.write('temp_medium.wav', medium_nr, sr)
    medium_result = model.transcribe('temp_medium.wav', language='en')
    results['medium_nr'] = medium_result['text']

    return results

# Usage
if __name__ == '__main__':
    # Simple transcription
    result = transcribe_with_whisper('audio.wav')
    print(result['text'])

    # With word timestamps
    text, words = transcribe_with_confidence('audio.wav')
    for word in words[:10]:
        print(f"{word['start']:.2f}s: {word['word']}")
```

**Install Whisper:**

```bash
pip install openai-whisper

# Or use faster-whisper for better performance
pip install faster-whisper
```

**Whisper model comparison:**

| Model | Size | Speed | Accuracy | VRAM |
|-------|------|-------|----------|------|
| tiny | 39M | Very fast | Low | 1 GB |
| small | 244M | Fast | Good | 2 GB |
| medium | 769M | Medium | Better | 5 GB |
| large-v3 | 1550M | Slow | Best | 10 GB |

**Preprocessing recommendations:**

| Audio Quality | Preprocessing | Notes |
|--------------|---------------|-------|
| Clean | None | Whisper handles well |
| Light noise | None or light NR | Test both |
| Heavy noise | Light NR (prop=0.3-0.5) | Heavy NR can hurt |
| Very degraded | VAD + segmentation | Process speech only |

Reference: [OpenAI Whisper](https://github.com/openai/whisper)

---

## 7. Forensic Authentication

**Impact: MEDIUM**

ENF analysis, tampering detection, metadata verification, and chain-of-custody documentation for legal admissibility and authenticity verification.

### 7.1 Detect Audio Tampering and Splices

**Impact: MEDIUM (identifies edits, deletions, and insertions)**

Audio can be edited to add, remove, or rearrange content. Forensic analysis detects discontinuities in spectral, temporal, and ENF patterns.

**Incorrect (accepting recording at face value):**

```python
# Transcribing without tampering analysis
result = whisper.transcribe("evidence.wav")
# Recording may have been edited - words added, removed, or rearranged
```

**Correct (analyze for tampering before transcription):**

```python
# Run tampering detection first
analysis = comprehensive_tampering_analysis("evidence.wav")

if analysis['clustered_events']:
    print(f"WARNING: {len(analysis['clustered_events'])} potential edit points detected")
    for event in analysis['clustered_events']:
        print(f"  - {event['time']:.2f}s: {event['types_detected']}")

# Document findings before proceeding
```

**Python tampering detection:**

```python
import numpy as np
from scipy import signal
import librosa
import matplotlib.pyplot as plt

def detect_spectral_discontinuities(audio, sr, hop_ms=10, threshold_std=3):
    """
    Detect abrupt spectral changes indicating potential edits.
    """
    hop_length = int(hop_ms * sr / 1000)

    # Compute spectral features
    spectral_centroid = librosa.feature.spectral_centroid(y=audio, sr=sr,
                                                          hop_length=hop_length)[0]
    spectral_bandwidth = librosa.feature.spectral_bandwidth(y=audio, sr=sr,
                                                             hop_length=hop_length)[0]
    spectral_rolloff = librosa.feature.spectral_rolloff(y=audio, sr=sr,
                                                        hop_length=hop_length)[0]

    # Calculate frame-to-frame changes
    centroid_diff = np.abs(np.diff(spectral_centroid))
    bandwidth_diff = np.abs(np.diff(spectral_bandwidth))
    rolloff_diff = np.abs(np.diff(spectral_rolloff))

    # Detect anomalies
    discontinuities = []

    for name, diff in [('centroid', centroid_diff),
                       ('bandwidth', bandwidth_diff),
                       ('rolloff', rolloff_diff)]:
        threshold = np.mean(diff) + threshold_std * np.std(diff)
        anomaly_frames = np.where(diff > threshold)[0]

        for frame in anomaly_frames:
            time = frame * hop_length / sr
            discontinuities.append({
                'time': time,
                'type': f'spectral_{name}',
                'magnitude': diff[frame] / np.mean(diff)
            })

    return discontinuities

def detect_phase_discontinuities(audio, sr, n_fft=2048, hop_length=512):
    """
    Detect phase discontinuities indicating splices.
    """
    # STFT
    stft = librosa.stft(audio, n_fft=n_fft, hop_length=hop_length)
    phase = np.angle(stft)

    # Phase derivative
    phase_diff = np.diff(phase, axis=1)

    # Unwrap for continuity
    phase_diff_unwrapped = np.unwrap(phase_diff, axis=1)

    # Calculate frame-to-frame phase changes
    phase_change = np.sum(np.abs(np.diff(phase_diff_unwrapped, axis=1)), axis=0)

    # Detect anomalies
    threshold = np.mean(phase_change) + 3 * np.std(phase_change)
    anomaly_frames = np.where(phase_change > threshold)[0]

    discontinuities = []
    for frame in anomaly_frames:
        time = frame * hop_length / sr
        discontinuities.append({
            'time': time,
            'type': 'phase',
            'magnitude': phase_change[frame] / np.mean(phase_change)
        })

    return discontinuities

def detect_amplitude_discontinuities(audio, sr, frame_ms=25):
    """
    Detect abrupt amplitude changes.
    """
    frame_length = int(frame_ms * sr / 1000)
    hop_length = frame_length // 2

    # RMS energy
    rms = librosa.feature.rms(y=audio, frame_length=frame_length,
                              hop_length=hop_length)[0]

    # Frame-to-frame change
    rms_diff = np.abs(np.diff(rms))

    # Detect anomalies
    threshold = np.mean(rms_diff) + 4 * np.std(rms_diff)
    anomaly_frames = np.where(rms_diff > threshold)[0]

    discontinuities = []
    for frame in anomaly_frames:
        time = frame * hop_length / sr
        discontinuities.append({
            'time': time,
            'type': 'amplitude',
            'magnitude': rms_diff[frame] / np.mean(rms_diff)
        })

    return discontinuities

def detect_dc_offset_changes(audio, sr, window_sec=0.5):
    """
    Detect DC offset changes indicating separate recordings joined.
    """
    window_samples = int(window_sec * sr)
    hop = window_samples // 2

    dc_offsets = []
    times = []

    for i in range(0, len(audio) - window_samples, hop):
        window = audio[i:i + window_samples]
        dc = np.mean(window)
        dc_offsets.append(dc)
        times.append(i / sr)

    dc_offsets = np.array(dc_offsets)
    dc_diff = np.abs(np.diff(dc_offsets))

    threshold = np.mean(dc_diff) + 3 * np.std(dc_diff)
    anomaly_idx = np.where(dc_diff > threshold)[0]

    discontinuities = []
    for idx in anomaly_idx:
        discontinuities.append({
            'time': times[idx],
            'type': 'dc_offset',
            'magnitude': dc_diff[idx] / np.mean(dc_diff)
        })

    return discontinuities

def comprehensive_tampering_analysis(audio_path):
    """
    Run all tampering detection methods.
    """
    audio, sr = librosa.load(audio_path, sr=None)

    all_discontinuities = []

    # Spectral
    spectral = detect_spectral_discontinuities(audio, sr)
    all_discontinuities.extend(spectral)

    # Phase
    phase = detect_phase_discontinuities(audio, sr)
    all_discontinuities.extend(phase)

    # Amplitude
    amplitude = detect_amplitude_discontinuities(audio, sr)
    all_discontinuities.extend(amplitude)

    # DC offset
    dc = detect_dc_offset_changes(audio, sr)
    all_discontinuities.extend(dc)

    # Cluster nearby detections
    all_discontinuities.sort(key=lambda x: x['time'])
    clustered = cluster_discontinuities(all_discontinuities, tolerance_sec=0.1)

    return {
        'total_detections': len(all_discontinuities),
        'clustered_events': clustered,
        'by_type': {
            'spectral': len(spectral),
            'phase': len(phase),
            'amplitude': len(amplitude),
            'dc_offset': len(dc)
        }
    }

def cluster_discontinuities(discontinuities, tolerance_sec=0.1):
    """
    Cluster nearby detections into single events.
    """
    if not discontinuities:
        return []

    clusters = []
    current_cluster = [discontinuities[0]]

    for d in discontinuities[1:]:
        if d['time'] - current_cluster[-1]['time'] <= tolerance_sec:
            current_cluster.append(d)
        else:
            clusters.append(summarize_cluster(current_cluster))
            current_cluster = [d]

    clusters.append(summarize_cluster(current_cluster))

    return clusters

def summarize_cluster(cluster):
    """Summarize a cluster of detections."""
    times = [d['time'] for d in cluster]
    types = [d['type'] for d in cluster]
    magnitudes = [d['magnitude'] for d in cluster]

    return {
        'time': np.mean(times),
        'types_detected': list(set(types)),
        'detection_count': len(cluster),
        'max_magnitude': max(magnitudes),
        'confidence': min(len(set(types)) / 4, 1.0)  # More types = higher confidence
    }

def visualize_tampering_analysis(audio_path, output_path='tampering_analysis.png'):
    """
    Visualize audio with tampering indicators.
    """
    audio, sr = librosa.load(audio_path, sr=None)
    analysis = comprehensive_tampering_analysis(audio_path)

    fig, axes = plt.subplots(3, 1, figsize=(14, 10))

    # Waveform with markers
    times = np.arange(len(audio)) / sr
    axes[0].plot(times, audio, linewidth=0.5)
    axes[0].set_title('Waveform with Potential Edit Points')
    axes[0].set_xlabel('Time (s)')
    axes[0].set_ylabel('Amplitude')

    for event in analysis['clustered_events']:
        color = 'red' if event['confidence'] > 0.5 else 'orange'
        axes[0].axvline(x=event['time'], color=color, linestyle='--',
                       alpha=0.7, label=f"Edit? ({event['time']:.2f}s)")

    # Spectrogram
    D = librosa.amplitude_to_db(np.abs(librosa.stft(audio)), ref=np.max)
    librosa.display.specshow(D, sr=sr, x_axis='time', y_axis='log', ax=axes[1])
    axes[1].set_title('Spectrogram')

    for event in analysis['clustered_events']:
        axes[1].axvline(x=event['time'], color='red', linestyle='--', alpha=0.7)

    # Detection timeline
    for event in analysis['clustered_events']:
        axes[2].scatter(event['time'], event['confidence'],
                       s=event['detection_count'] * 50,
                       c='red' if event['confidence'] > 0.5 else 'orange')
        axes[2].annotate(f"{', '.join(event['types_detected'])}",
                        (event['time'], event['confidence']),
                        fontsize=8, rotation=45)

    axes[2].set_xlabel('Time (s)')
    axes[2].set_ylabel('Confidence')
    axes[2].set_title('Tampering Detection Confidence')
    axes[2].set_ylim(0, 1.1)

    plt.tight_layout()
    plt.savefig(output_path, dpi=150)
    plt.close()

# Usage
if __name__ == '__main__':
    analysis = comprehensive_tampering_analysis('evidence.wav')

    print(f"Total detections: {analysis['total_detections']}")
    print(f"Clustered events: {len(analysis['clustered_events'])}")

    for event in analysis['clustered_events']:
        print(f"\n  Time: {event['time']:.2f}s")
        print(f"  Types: {event['types_detected']}")
        print(f"  Confidence: {event['confidence']:.0%}")

    visualize_tampering_analysis('evidence.wav')
```

**Tampering indicators:**

| Indicator | Interpretation | Confidence |
|-----------|----------------|------------|
| Multiple types at same time | Strong evidence of edit | High |
| Phase discontinuity only | Possible edit | Medium |
| DC offset change | Different recording joined | Medium |
| Spectral jump | Content change | Low-Medium |

Reference: [Audio Forensics Tampering Detection](https://www.mdpi.com/1424-8220/23/16/7029)

### 7.2 Document Chain of Custody for Evidence

**Impact: MEDIUM (ensures legal admissibility)**

Legal admissibility requires documented chain of custody. Record every action, preserve originals, and maintain checksums.

**Incorrect (undocumented processing):**

```bash
# Processing evidence without documentation
ffmpeg -i evidence.wav -af "afftdn" enhanced.wav
rm evidence.wav  # Original lost!
# No checksums, no log, inadmissible in court
```

**Correct (documented chain of custody):**

```bash
# Calculate checksum of original
sha256sum evidence.wav > evidence.sha256

# Create working copy
cp evidence.wav evidence_working.wav

# Document all processing steps
echo "$(date -Iseconds) | Noise reduction applied: afftdn nr=12" >> processing_log.txt
ffmpeg -i evidence_working.wav -af "afftdn=nr=12" enhanced.wav

# Verify original unchanged
sha256sum -c evidence.sha256
```

**Chain of custody template:**

```python
import hashlib
import json
import os
from datetime import datetime
from pathlib import Path

class ChainOfCustody:
    """
    Maintain chain of custody documentation for audio evidence.
    """

    def __init__(self, evidence_path, case_id=None, examiner=None):
        self.evidence_path = Path(evidence_path)
        self.case_id = case_id or f"CASE-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
        self.examiner = examiner or os.getenv('USER', 'Unknown')
        self.log = []
        self.checksums = {}

        # Initialize
        self._log_action('RECEIVED', f'Evidence received: {evidence_path}')
        self._compute_checksum(evidence_path, 'original')

    def _compute_checksum(self, filepath, label):
        """Compute and store SHA-256 checksum."""
        sha256 = hashlib.sha256()
        with open(filepath, 'rb') as f:
            for chunk in iter(lambda: f.read(8192), b''):
                sha256.update(chunk)
        checksum = sha256.hexdigest()
        self.checksums[label] = checksum
        self._log_action('CHECKSUM', f'{label}: SHA-256 = {checksum}')
        return checksum

    def _log_action(self, action_type, description, details=None):
        """Log an action in the chain of custody."""
        entry = {
            'timestamp': datetime.now().isoformat(),
            'action': action_type,
            'description': description,
            'examiner': self.examiner,
        }
        if details:
            entry['details'] = details
        self.log.append(entry)

    def create_working_copy(self, output_path):
        """Create working copy and document it."""
        import shutil

        # Verify original unchanged
        current_checksum = hashlib.sha256(
            open(self.evidence_path, 'rb').read()
        ).hexdigest()

        if current_checksum != self.checksums['original']:
            raise ValueError("Original evidence has been modified!")

        # Create copy
        shutil.copy2(self.evidence_path, output_path)
        self._log_action('COPY', f'Working copy created: {output_path}')
        self._compute_checksum(output_path, 'working_copy')

        return output_path

    def log_processing(self, input_file, output_file, processing_description,
                       tool_used=None, parameters=None):
        """Document processing step."""
        details = {
            'input_file': str(input_file),
            'output_file': str(output_file),
            'tool': tool_used,
            'parameters': parameters
        }

        self._log_action('PROCESSING', processing_description, details)
        self._compute_checksum(output_file, f'processed_{len(self.checksums)}')

    def verify_original(self):
        """Verify original evidence is unchanged."""
        current = hashlib.sha256(
            open(self.evidence_path, 'rb').read()
        ).hexdigest()

        is_valid = current == self.checksums['original']
        self._log_action('VERIFICATION',
                        f'Original integrity: {"VALID" if is_valid else "INVALID"}')
        return is_valid

    def generate_report(self, output_path):
        """Generate formal chain of custody report."""
        report = {
            'case_id': self.case_id,
            'evidence_file': str(self.evidence_path),
            'examiner': self.examiner,
            'report_generated': datetime.now().isoformat(),
            'checksums': self.checksums,
            'action_log': self.log,
            'original_verified': self.verify_original()
        }

        # JSON report
        json_path = output_path.replace('.txt', '.json')
        with open(json_path, 'w') as f:
            json.dump(report, f, indent=2)

        # Human-readable report
        lines = [
            "=" * 70,
            "CHAIN OF CUSTODY REPORT",
            "=" * 70,
            "",
            f"Case ID: {self.case_id}",
            f"Evidence: {self.evidence_path}",
            f"Examiner: {self.examiner}",
            f"Report Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "",
            "-" * 70,
            "CHECKSUMS",
            "-" * 70,
        ]

        for label, checksum in self.checksums.items():
            lines.append(f"  {label}: {checksum}")

        lines.extend([
            "",
            "-" * 70,
            "ACTION LOG",
            "-" * 70,
        ])

        for entry in self.log:
            lines.append(f"\n[{entry['timestamp']}] {entry['action']}")
            lines.append(f"  {entry['description']}")
            if 'details' in entry:
                for key, value in entry['details'].items():
                    lines.append(f"    {key}: {value}")

        lines.extend([
            "",
            "-" * 70,
            "VERIFICATION",
            "-" * 70,
            f"  Original evidence integrity: {'VALID' if report['original_verified'] else 'INVALID'}",
            "",
            "=" * 70,
            f"End of Report - {self.case_id}",
            "=" * 70,
        ])

        report_text = '\n'.join(lines)

        with open(output_path, 'w') as f:
            f.write(report_text)

        return report_text

def forensic_processing_workflow(evidence_path, case_id=None):
    """
    Example forensic processing workflow with chain of custody.
    """
    import subprocess
    from pathlib import Path

    # Initialize chain of custody
    coc = ChainOfCustody(evidence_path, case_id)

    # Create working directory
    work_dir = Path(f'forensic_work_{coc.case_id}')
    work_dir.mkdir(exist_ok=True)

    # Create working copy
    working_copy = work_dir / 'working_copy.wav'
    coc.create_working_copy(working_copy)

    # Processing step 1: Analyze
    coc.log_processing(
        working_copy, working_copy,
        'Initial audio analysis - no modification',
        tool_used='ffprobe',
        parameters={'command': 'ffprobe -v quiet -print_format json -show_format'}
    )

    # Processing step 2: Enhancement
    enhanced_path = work_dir / 'enhanced.wav'
    subprocess.run([
        'ffmpeg', '-i', str(working_copy),
        '-af', 'highpass=f=80,afftdn=nr=10',
        str(enhanced_path)
    ], capture_output=True)

    coc.log_processing(
        working_copy, enhanced_path,
        'Noise reduction applied for intelligibility enhancement',
        tool_used='FFmpeg',
        parameters={'filters': 'highpass=f=80,afftdn=nr=10'}
    )

    # Final verification and report
    coc.verify_original()
    report = coc.generate_report(str(work_dir / 'chain_of_custody.txt'))

    print(f"Processing complete. Report saved to: {work_dir}/chain_of_custody.txt")
    return coc

# Usage
if __name__ == '__main__':
    coc = forensic_processing_workflow('evidence.wav', case_id='2024-001')
```

**Chain of custody checklist:**

| Step | Action | Documentation |
|------|--------|---------------|
| 1 | Receive evidence | Date, time, source, condition |
| 2 | Calculate checksum | SHA-256 of original |
| 3 | Create working copy | Verify checksum matches |
| 4 | Each processing step | Tool, parameters, input/output |
| 5 | Final verification | Confirm original unchanged |
| 6 | Generate report | Complete documentation |

Reference: [SWGDE Digital Evidence Guidelines](https://www.swgde.org/)

### 7.3 Extract and Verify Audio Metadata

**Impact: MEDIUM (reveals recording device, timestamps, and tampering signs)**

Audio files contain metadata about recording device, date, and processing history. Essential for establishing provenance and detecting manipulation.

**Incorrect (ignoring metadata in forensic analysis):**

```bash
# Processing audio without checking metadata
ffmpeg -i evidence.wav -af "afftdn" enhanced.wav
# No record of original file properties or processing history
```

**Correct (extract metadata before and after processing):**

```bash
# Document original metadata
ffprobe -v quiet -print_format json -show_format -show_streams evidence.wav > evidence_metadata.json
exiftool -json evidence.wav > evidence_exif.json

# Process with documentation
ffmpeg -i evidence.wav -af "afftdn" enhanced.wav

# Verify changes and document
ffprobe -v quiet -print_format json -show_format enhanced.wav > enhanced_metadata.json
```

**FFprobe metadata extraction:**

```bash
# Full metadata dump
ffprobe -v quiet -print_format json -show_format -show_streams audio.wav

# Specific fields
ffprobe -v error -show_entries format=filename,duration,size,bit_rate:format_tags -of json audio.wav

# Container and codec info
ffprobe -v error -show_entries stream=codec_name,codec_long_name,sample_rate,channels,bits_per_sample audio.wav
```

**Python comprehensive metadata extraction:**

```python
import subprocess
import json
import os
from datetime import datetime
from pathlib import Path

def extract_ffprobe_metadata(audio_path):
    """
    Extract metadata using FFprobe.
    """
    cmd = [
        'ffprobe',
        '-v', 'quiet',
        '-print_format', 'json',
        '-show_format',
        '-show_streams',
        audio_path
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode == 0:
        return json.loads(result.stdout)
    return None

def extract_mutagen_metadata(audio_path):
    """
    Extract metadata using mutagen (supports many formats).
    """
    try:
        from mutagen import File
        from mutagen.wave import WAVE
        from mutagen.mp3 import MP3
        from mutagen.flac import FLAC

        audio = File(audio_path)
        if audio is None:
            return None

        metadata = {
            'length': audio.info.length if hasattr(audio.info, 'length') else None,
            'bitrate': audio.info.bitrate if hasattr(audio.info, 'bitrate') else None,
            'sample_rate': audio.info.sample_rate if hasattr(audio.info, 'sample_rate') else None,
            'channels': audio.info.channels if hasattr(audio.info, 'channels') else None,
            'tags': dict(audio.tags) if audio.tags else {}
        }

        return metadata
    except ImportError:
        return None

def extract_exiftool_metadata(audio_path):
    """
    Extract metadata using ExifTool (most comprehensive).
    """
    try:
        cmd = ['exiftool', '-json', audio_path]
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode == 0:
            return json.loads(result.stdout)[0]
    except FileNotFoundError:
        pass
    return None

def get_filesystem_metadata(audio_path):
    """
    Get filesystem-level metadata.
    """
    stat = os.stat(audio_path)
    path = Path(audio_path)

    return {
        'filename': path.name,
        'path': str(path.absolute()),
        'size_bytes': stat.st_size,
        'created': datetime.fromtimestamp(stat.st_ctime).isoformat(),
        'modified': datetime.fromtimestamp(stat.st_mtime).isoformat(),
        'accessed': datetime.fromtimestamp(stat.st_atime).isoformat(),
    }

def comprehensive_metadata_extraction(audio_path):
    """
    Extract metadata from all available sources.
    """
    metadata = {
        'file': get_filesystem_metadata(audio_path),
        'ffprobe': extract_ffprobe_metadata(audio_path),
        'exiftool': extract_exiftool_metadata(audio_path),
        'mutagen': extract_mutagen_metadata(audio_path)
    }

    return metadata

def detect_metadata_anomalies(metadata):
    """
    Detect potential tampering indicators in metadata.
    """
    anomalies = []

    # Check for timestamp inconsistencies
    file_meta = metadata.get('file', {})
    created = file_meta.get('created')
    modified = file_meta.get('modified')

    if created and modified:
        created_dt = datetime.fromisoformat(created)
        modified_dt = datetime.fromisoformat(modified)

        if modified_dt < created_dt:
            anomalies.append({
                'type': 'timestamp',
                'severity': 'high',
                'description': 'Modified date is before created date'
            })

    # Check for software indicators
    exif = metadata.get('exiftool', {})
    if exif:
        software = exif.get('Software', '') or exif.get('Encoder', '')
        if any(editor in software.lower() for editor in ['audacity', 'adobe', 'sox', 'ffmpeg']):
            anomalies.append({
                'type': 'processing',
                'severity': 'info',
                'description': f'Audio has been processed with: {software}'
            })

    # Check for unusual sample rates
    ffprobe = metadata.get('ffprobe', {})
    if ffprobe:
        streams = ffprobe.get('streams', [])
        for stream in streams:
            sr = stream.get('sample_rate')
            if sr and int(sr) not in [8000, 11025, 16000, 22050, 44100, 48000, 96000]:
                anomalies.append({
                    'type': 'technical',
                    'severity': 'low',
                    'description': f'Unusual sample rate: {sr} Hz'
                })

    return anomalies

def generate_metadata_report(audio_path, output_path):
    """
    Generate comprehensive metadata report.
    """
    metadata = comprehensive_metadata_extraction(audio_path)
    anomalies = detect_metadata_anomalies(metadata)

    report = []
    report.append("AUDIO METADATA FORENSIC REPORT")
    report.append("=" * 60)
    report.append(f"File: {audio_path}")
    report.append(f"Report generated: {datetime.now().isoformat()}")
    report.append("")

    # File info
    report.append("FILE SYSTEM METADATA")
    report.append("-" * 40)
    file_meta = metadata.get('file', {})
    for key, value in file_meta.items():
        report.append(f"  {key}: {value}")

    # Technical info
    report.append("\nTECHNICAL METADATA (FFprobe)")
    report.append("-" * 40)
    ffprobe = metadata.get('ffprobe', {})
    if ffprobe:
        fmt = ffprobe.get('format', {})
        report.append(f"  Format: {fmt.get('format_long_name', 'Unknown')}")
        report.append(f"  Duration: {fmt.get('duration', 'Unknown')} seconds")
        report.append(f"  Bit rate: {fmt.get('bit_rate', 'Unknown')} bps")

        for stream in ffprobe.get('streams', []):
            report.append(f"  Codec: {stream.get('codec_long_name', 'Unknown')}")
            report.append(f"  Sample rate: {stream.get('sample_rate', 'Unknown')} Hz")
            report.append(f"  Channels: {stream.get('channels', 'Unknown')}")
            report.append(f"  Bit depth: {stream.get('bits_per_sample', 'Unknown')} bits")

    # ExifTool data
    exif = metadata.get('exiftool', {})
    if exif:
        report.append("\nEXTENDED METADATA (ExifTool)")
        report.append("-" * 40)
        interesting_fields = ['Software', 'Encoder', 'Artist', 'Title',
                             'CreateDate', 'ModifyDate', 'Comment']
        for field in interesting_fields:
            if field in exif:
                report.append(f"  {field}: {exif[field]}")

    # Anomalies
    report.append("\nANOMALY DETECTION")
    report.append("-" * 40)
    if anomalies:
        for anomaly in anomalies:
            report.append(f"  [{anomaly['severity'].upper()}] {anomaly['type']}: {anomaly['description']}")
    else:
        report.append("  No anomalies detected")

    report_text = '\n'.join(report)

    with open(output_path, 'w') as f:
        f.write(report_text)

    return report_text

# Usage
if __name__ == '__main__':
    report = generate_metadata_report('evidence.wav', 'metadata_report.txt')
    print(report)
```

**Install dependencies:**

```bash
pip install mutagen

# ExifTool (optional but recommended)
# macOS
brew install exiftool

# Ubuntu
apt-get install libimage-exiftool-perl
```

**Key metadata fields for forensics:**

| Field | Significance |
|-------|--------------|
| CreateDate | Original recording time |
| ModifyDate | Last modification |
| Software/Encoder | Processing tools used |
| Sample rate | Recording quality |
| Duration | Check for missing segments |
| Bit depth | Original vs processed |

Reference: [ExifTool Documentation](https://exiftool.org/)

### 7.4 Extract Speaker Characteristics for Identification

**Impact: MEDIUM (enables speaker comparison and verification)**

Extract voice features (pitch, formants, speaking rate) for speaker comparison. Can help identify or exclude individuals.

**Incorrect (subjective speaker comparison):**

```python
# Comparing speakers by ear
# "These two recordings sound like the same person"
# Subjective assessment is not forensically reliable
```

**Correct (objective feature extraction):**

```python
# Extract measurable voice characteristics
profile1 = comprehensive_speaker_profile('speaker1.wav')
profile2 = comprehensive_speaker_profile('speaker2.wav')

# Compare using objective metrics
similarity = compare_speakers(profile1, profile2)
print(f"Pitch similarity: {similarity['pitch_similarity']:.2f}")
print(f"Formant similarity: {similarity['formant_similarity']:.2f}")
print(f"Overall similarity: {similarity['overall']:.2f}")
```

**Python speaker feature extraction:**

```python
import numpy as np
import librosa
import parselmouth
from parselmouth.praat import call

def extract_pitch_features(audio, sr):
    """
    Extract pitch (F0) features using Praat via parselmouth.
    """
    # Convert to Praat Sound object
    sound = parselmouth.Sound(audio, sr)

    # Extract pitch
    pitch = call(sound, "To Pitch", 0.0, 75, 600)

    # Get pitch values
    pitch_values = pitch.selected_array['frequency']
    pitch_values = pitch_values[pitch_values > 0]  # Remove unvoiced

    if len(pitch_values) == 0:
        return None

    return {
        'pitch_mean': np.mean(pitch_values),
        'pitch_std': np.std(pitch_values),
        'pitch_min': np.min(pitch_values),
        'pitch_max': np.max(pitch_values),
        'pitch_range': np.max(pitch_values) - np.min(pitch_values),
    }

def extract_formant_features(audio, sr, max_formants=5):
    """
    Extract formant frequencies.
    """
    sound = parselmouth.Sound(audio, sr)

    # Extract formants
    formants = call(sound, "To Formant (burg)", 0.0, max_formants, 5500, 0.025, 50)

    n_frames = call(formants, "Get number of frames")

    f1_values, f2_values, f3_values = [], [], []

    for i in range(1, n_frames + 1):
        f1 = call(formants, "Get value at time", 1, call(formants, "Get time from frame number", i), "Hertz", "Linear")
        f2 = call(formants, "Get value at time", 2, call(formants, "Get time from frame number", i), "Hertz", "Linear")
        f3 = call(formants, "Get value at time", 3, call(formants, "Get time from frame number", i), "Hertz", "Linear")

        if not np.isnan(f1):
            f1_values.append(f1)
        if not np.isnan(f2):
            f2_values.append(f2)
        if not np.isnan(f3):
            f3_values.append(f3)

    return {
        'f1_mean': np.mean(f1_values) if f1_values else None,
        'f1_std': np.std(f1_values) if f1_values else None,
        'f2_mean': np.mean(f2_values) if f2_values else None,
        'f2_std': np.std(f2_values) if f2_values else None,
        'f3_mean': np.mean(f3_values) if f3_values else None,
        'f3_std': np.std(f3_values) if f3_values else None,
    }

def extract_mfcc_features(audio, sr, n_mfcc=13):
    """
    Extract MFCC features for speaker characterization.
    """
    mfccs = librosa.feature.mfcc(y=audio, sr=sr, n_mfcc=n_mfcc)

    return {
        f'mfcc_{i}_mean': np.mean(mfccs[i]) for i in range(n_mfcc)
    } | {
        f'mfcc_{i}_std': np.std(mfccs[i]) for i in range(n_mfcc)
    }

def extract_speaking_rate(audio, sr):
    """
    Estimate speaking rate from syllable-like events.
    """
    # Use onset detection as proxy for syllables
    onset_env = librosa.onset.onset_strength(y=audio, sr=sr)
    onsets = librosa.onset.onset_detect(onset_envelope=onset_env, sr=sr)

    duration = len(audio) / sr

    if duration > 0:
        syllables_per_second = len(onsets) / duration
    else:
        syllables_per_second = 0

    return {
        'estimated_syllables': len(onsets),
        'duration': duration,
        'syllables_per_second': syllables_per_second,
    }

def extract_voice_quality(audio, sr):
    """
    Extract voice quality measures (jitter, shimmer, HNR).
    """
    sound = parselmouth.Sound(audio, sr)

    # Point process for jitter/shimmer
    pitch = call(sound, "To Pitch", 0.0, 75, 600)
    point_process = call(sound, "To PointProcess (periodic, cc)", 75, 600)

    # Jitter
    try:
        jitter_local = call(point_process, "Get jitter (local)", 0, 0, 0.0001, 0.02, 1.3)
    except:
        jitter_local = None

    # Shimmer
    try:
        shimmer_local = call([sound, point_process], "Get shimmer (local)", 0, 0, 0.0001, 0.02, 1.3, 1.6)
    except:
        shimmer_local = None

    # Harmonics-to-Noise Ratio
    try:
        harmonicity = call(sound, "To Harmonicity (cc)", 0.01, 75, 0.1, 1.0)
        hnr = call(harmonicity, "Get mean", 0, 0)
    except:
        hnr = None

    return {
        'jitter_local': jitter_local,
        'shimmer_local': shimmer_local,
        'hnr': hnr,
    }

def comprehensive_speaker_profile(audio_path):
    """
    Extract complete speaker profile.
    """
    audio, sr = librosa.load(audio_path, sr=None)

    profile = {
        'pitch': extract_pitch_features(audio, sr),
        'formants': extract_formant_features(audio, sr),
        'mfcc': extract_mfcc_features(audio, sr),
        'speaking_rate': extract_speaking_rate(audio, sr),
        'voice_quality': extract_voice_quality(audio, sr),
    }

    return profile

def compare_speakers(profile1, profile2):
    """
    Compare two speaker profiles.
    """
    scores = {}

    # Pitch comparison
    if profile1['pitch'] and profile2['pitch']:
        pitch_diff = abs(profile1['pitch']['pitch_mean'] - profile2['pitch']['pitch_mean'])
        scores['pitch_similarity'] = max(0, 1 - pitch_diff / 100)

    # Formant comparison
    if profile1['formants'] and profile2['formants']:
        f1_diff = abs((profile1['formants']['f1_mean'] or 0) - (profile2['formants']['f1_mean'] or 0))
        f2_diff = abs((profile1['formants']['f2_mean'] or 0) - (profile2['formants']['f2_mean'] or 0))
        scores['formant_similarity'] = max(0, 1 - (f1_diff + f2_diff) / 1000)

    # MFCC comparison (cosine similarity)
    mfcc1 = np.array([profile1['mfcc'].get(f'mfcc_{i}_mean', 0) for i in range(13)])
    mfcc2 = np.array([profile2['mfcc'].get(f'mfcc_{i}_mean', 0) for i in range(13)])

    norm1, norm2 = np.linalg.norm(mfcc1), np.linalg.norm(mfcc2)
    if norm1 > 0 and norm2 > 0:
        scores['mfcc_similarity'] = np.dot(mfcc1, mfcc2) / (norm1 * norm2)

    # Overall score
    if scores:
        scores['overall'] = np.mean(list(scores.values()))

    return scores

# Usage
if __name__ == '__main__':
    # Extract speaker profile
    profile = comprehensive_speaker_profile('speaker.wav')

    print("Speaker Profile:")
    print(f"  Pitch mean: {profile['pitch']['pitch_mean']:.1f} Hz")
    print(f"  F1 mean: {profile['formants']['f1_mean']:.1f} Hz")
    print(f"  F2 mean: {profile['formants']['f2_mean']:.1f} Hz")
    print(f"  Speaking rate: {profile['speaking_rate']['syllables_per_second']:.1f} syll/s")

    # Compare two speakers
    # profile2 = comprehensive_speaker_profile('speaker2.wav')
    # similarity = compare_speakers(profile, profile2)
    # print(f"Similarity: {similarity['overall']:.1%}")
```

**Install dependencies:**

```bash
pip install praat-parselmouth librosa
```

**Speaker characteristics reference:**

| Feature | Male (typical) | Female (typical) |
|---------|---------------|------------------|
| F0 (pitch) | 85-180 Hz | 165-255 Hz |
| F1 | 350-850 Hz | 400-950 Hz |
| F2 | 900-2300 Hz | 1000-2800 Hz |
| Speaking rate | 3-5 syll/s | 3-5 syll/s |

**Note:** Speaker identification requires expert analysis and cannot definitively identify individuals from voice alone.

Reference: [Praat Voice Analysis](https://www.fon.hum.uva.nl/praat/)

### 7.5 Use ENF Analysis for Timestamp Verification

**Impact: MEDIUM (verifies recording time within hours accuracy)**

Electric Network Frequency (ENF) from power grid hum embeds a unique signature. Compare with historical ENF databases to verify when and where a recording was made.

**Incorrect (ignoring ENF for timestamp verification):**

```bash
# Trusting file metadata for timestamp
exiftool -CreateDate evidence.wav
# Output: 2024-01-15 14:30:00
# File metadata can be easily modified - not forensically reliable
```

**Correct (ENF analysis for verification):**

```python
# Extract and analyze ENF signature
times, freqs = extract_enf(audio, sr, nominal_freq=60)
# Compare extracted pattern against ENF database
# Actual recording time verified independently of metadata
```

**Overview:**

The power grid oscillates at 50 Hz (EU/Asia) or 60 Hz (US). Minor fluctuations create a unique fingerprint over time. If recording captures mains hum, ENF analysis can:
- Verify claimed timestamp
- Detect tampering (splicing changes ENF pattern)
- Approximate geographic location

**Python ENF extraction:**

```python
import numpy as np
from scipy import signal
import librosa
import matplotlib.pyplot as plt

def extract_enf(audio, sr, nominal_freq=60, bandwidth=0.1):
    """
    Extract Electric Network Frequency from audio.

    Parameters:
    - nominal_freq: 50 Hz (EU) or 60 Hz (US)
    - bandwidth: Frequency band around nominal to search
    """
    # Bandpass filter around nominal frequency
    low = nominal_freq - bandwidth
    high = nominal_freq + bandwidth
    nyquist = sr / 2

    if high >= nyquist:
        raise ValueError(f"Sample rate too low for ENF extraction. Need > {nominal_freq * 2 + 1} Hz")

    b, a = signal.butter(4, [low/nyquist, high/nyquist], btype='band')
    filtered = signal.filtfilt(b, a, audio)

    # STFT for time-frequency analysis
    frame_length = int(sr * 10)  # 10-second frames for precision
    hop_length = int(sr * 1)     # 1-second hop

    freqs = []
    times = []

    for i in range(0, len(filtered) - frame_length, hop_length):
        frame = filtered[i:i + frame_length]

        # High-resolution FFT
        n_fft = 2 ** 18  # Very high resolution
        spectrum = np.abs(np.fft.rfft(frame, n=n_fft))
        fft_freqs = np.fft.rfftfreq(n_fft, 1/sr)

        # Find peak near nominal frequency
        search_mask = (fft_freqs >= low) & (fft_freqs <= high)
        search_spectrum = spectrum[search_mask]
        search_freqs = fft_freqs[search_mask]

        if len(search_spectrum) > 0:
            peak_idx = np.argmax(search_spectrum)
            peak_freq = search_freqs[peak_idx]

            # Quadratic interpolation for sub-bin precision
            if peak_idx > 0 and peak_idx < len(search_spectrum) - 1:
                alpha = search_spectrum[peak_idx - 1]
                beta = search_spectrum[peak_idx]
                gamma = search_spectrum[peak_idx + 1]
                delta = 0.5 * (alpha - gamma) / (alpha - 2*beta + gamma)
                freq_resolution = search_freqs[1] - search_freqs[0]
                peak_freq += delta * freq_resolution

            freqs.append(peak_freq)
            times.append(i / sr)

    return np.array(times), np.array(freqs)

def detect_enf_presence(audio, sr, nominal_freq=60):
    """
    Detect if ENF signal is present in recording.
    """
    # Check energy at nominal frequency and harmonics
    n_fft = sr * 2  # 2-second window
    spectrum = np.abs(np.fft.rfft(audio[:n_fft]))
    fft_freqs = np.fft.rfftfreq(n_fft, 1/sr)

    # Check fundamental and first harmonic
    fundamentals = [nominal_freq, nominal_freq * 2]
    enf_present = False
    snr_values = []

    for freq in fundamentals:
        if freq < sr / 2:
            # Find peak near expected frequency
            mask = np.abs(fft_freqs - freq) < 2
            if np.any(mask):
                peak_energy = np.max(spectrum[mask])

                # Compare to surrounding noise
                noise_mask = (np.abs(fft_freqs - freq) > 5) & (np.abs(fft_freqs - freq) < 20)
                noise_energy = np.mean(spectrum[noise_mask])

                snr = 20 * np.log10(peak_energy / (noise_energy + 1e-10))
                snr_values.append(snr)

                if snr > 10:  # 10 dB above noise floor
                    enf_present = True

    return enf_present, snr_values

def plot_enf_analysis(times, freqs, nominal_freq=60, output_path='enf_analysis.png'):
    """
    Plot ENF analysis results.
    """
    fig, axes = plt.subplots(2, 1, figsize=(12, 8))

    # Time series
    axes[0].plot(times, freqs, 'b-', linewidth=0.5)
    axes[0].axhline(y=nominal_freq, color='r', linestyle='--', label=f'Nominal ({nominal_freq} Hz)')
    axes[0].set_xlabel('Time (s)')
    axes[0].set_ylabel('Frequency (Hz)')
    axes[0].set_title('ENF Time Series')
    axes[0].legend()

    # Deviation from nominal
    deviation = (freqs - nominal_freq) * 1000  # Convert to mHz
    axes[1].plot(times, deviation, 'g-', linewidth=0.5)
    axes[1].axhline(y=0, color='r', linestyle='--')
    axes[1].set_xlabel('Time (s)')
    axes[1].set_ylabel('Deviation from nominal (mHz)')
    axes[1].set_title('ENF Deviation')

    plt.tight_layout()
    plt.savefig(output_path, dpi=150)
    plt.close()

def detect_splice_by_enf(times, freqs, threshold_mhz=20):
    """
    Detect potential splices by ENF discontinuities.
    """
    # Calculate derivative (rate of change)
    freq_diff = np.abs(np.diff(freqs)) * 1000  # mHz

    # Normal ENF changes slowly (<5 mHz/s typically)
    # Sudden jumps indicate potential splice
    anomalies = np.where(freq_diff > threshold_mhz)[0]

    splices = []
    for idx in anomalies:
        splices.append({
            'time': times[idx],
            'jump_mhz': freq_diff[idx],
            'before_freq': freqs[idx],
            'after_freq': freqs[idx + 1]
        })

    return splices

def full_enf_analysis(audio_path, nominal_freq=60):
    """
    Complete ENF analysis pipeline.
    """
    audio, sr = librosa.load(audio_path, sr=None)

    # Check if ENF is present
    enf_present, snr = detect_enf_presence(audio, sr, nominal_freq)

    if not enf_present:
        return {
            'enf_present': False,
            'message': 'No detectable ENF signal. Recording may be digital-only or heavily processed.'
        }

    # Extract ENF
    times, freqs = extract_enf(audio, sr, nominal_freq)

    # Check for splices
    splices = detect_splice_by_enf(times, freqs)

    # Generate plot
    plot_enf_analysis(times, freqs, nominal_freq)

    return {
        'enf_present': True,
        'nominal_freq': nominal_freq,
        'mean_freq': np.mean(freqs),
        'std_freq': np.std(freqs),
        'duration': times[-1] if len(times) > 0 else 0,
        'potential_splices': splices,
        'snr_db': snr,
        'enf_data': {'times': times.tolist(), 'freqs': freqs.tolist()}
    }

# Usage
if __name__ == '__main__':
    result = full_enf_analysis('recording.wav', nominal_freq=60)

    print(f"ENF Present: {result['enf_present']}")
    if result['enf_present']:
        print(f"Mean frequency: {result['mean_freq']:.4f} Hz")
        print(f"Std deviation: {result['std_freq']*1000:.2f} mHz")
        if result['potential_splices']:
            print(f"Potential splices detected: {len(result['potential_splices'])}")
```

**ENF interpretation:**

| Finding | Interpretation |
|---------|----------------|
| No ENF detected | Recording digital, outdoor, or processed |
| Stable ENF | Continuous unedited recording |
| ENF discontinuity | Potential splice point |
| 50 Hz fundamental | EU/Asia origin |
| 60 Hz fundamental | US/Americas origin |

**Limitations:**
- Requires mains hum to be captured
- Battery-powered devices may have no ENF
- Outdoor recordings often lack ENF
- ENF databases needed for timestamp matching

Reference: [ENF Analysis Wikipedia](https://en.wikipedia.org/wiki/Electrical_network_frequency_analysis)

---

## 8. Tool Integration & Automation

**Impact: LOW-MEDIUM**

FFmpeg, SoX, Python pipelines, and batch processing workflows for reproducible, documented forensic audio processing at scale.

### 8.1 Automate Batch Processing Workflows

**Impact: LOW-MEDIUM (process multiple files with consistent settings)**

Batch processing ensures consistent enhancement across multiple recordings. Use shell scripts and Python for reproducible workflows.

**Bash batch processing:**

```bash
#!/bin/bash
# batch_enhance.sh - Process all audio files in directory

INPUT_DIR="${1:-.}"
OUTPUT_DIR="${2:-./enhanced}"

mkdir -p "$OUTPUT_DIR"

# Process each WAV file
for file in "$INPUT_DIR"/*.wav; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "Processing: $filename"

        ffmpeg -i "$file" \
            -af "highpass=f=80,afftdn=nr=12:nf=-30,loudnorm=I=-16:TP=-1.5" \
            -y "$OUTPUT_DIR/enhanced_$filename"
    fi
done

echo "Done. Enhanced files in: $OUTPUT_DIR"
```

**Parallel processing with GNU Parallel:**

```bash
#!/bin/bash
# parallel_enhance.sh - Process files in parallel

INPUT_DIR="${1:-.}"
OUTPUT_DIR="${2:-./enhanced}"

mkdir -p "$OUTPUT_DIR"

enhance_file() {
    file="$1"
    output_dir="$2"
    filename=$(basename "$file")

    ffmpeg -i "$file" \
        -af "highpass=f=80,afftdn=nr=12,loudnorm=I=-16" \
        -y "$output_dir/enhanced_$filename" 2>/dev/null

    echo "Done: $filename"
}

export -f enhance_file
export OUTPUT_DIR

find "$INPUT_DIR" -name "*.wav" | \
    parallel -j$(nproc) enhance_file {} "$OUTPUT_DIR"
```

**Python batch processor:**

```python
#!/usr/bin/env python
"""
batch_processor.py - Batch audio enhancement with logging
"""

import argparse
import json
import subprocess
from pathlib import Path
from datetime import datetime
from concurrent.futures import ProcessPoolExecutor, as_completed
import hashlib

def calculate_hash(filepath):
    """Calculate SHA-256 hash of file."""
    sha256 = hashlib.sha256()
    with open(filepath, 'rb') as f:
        for chunk in iter(lambda: f.read(8192), b''):
            sha256.update(chunk)
    return sha256.hexdigest()

def process_file(input_path, output_dir, config):
    """Process a single audio file."""
    input_path = Path(input_path)
    output_path = output_dir / f"enhanced_{input_path.name}"

    # Build filter chain
    filters = []
    if config.get('highpass'):
        filters.append(f"highpass=f={config['highpass']}")
    if config.get('noise_reduction'):
        filters.append(f"afftdn=nr={config['noise_reduction']}:nf=-30")
    if config.get('lowpass'):
        filters.append(f"lowpass=f={config['lowpass']}")
    if config.get('normalize'):
        filters.append("loudnorm=I=-16:TP=-1.5:LRA=11")

    filter_str = ','.join(filters) if filters else 'anull'

    # Run FFmpeg
    cmd = [
        'ffmpeg', '-i', str(input_path),
        '-af', filter_str,
        '-y', str(output_path)
    ]

    start_time = datetime.now()
    result = subprocess.run(cmd, capture_output=True, text=True)
    end_time = datetime.now()

    # Log entry
    log_entry = {
        'input_file': str(input_path),
        'input_hash': calculate_hash(input_path),
        'output_file': str(output_path),
        'output_hash': calculate_hash(output_path) if output_path.exists() else None,
        'config': config,
        'filter_chain': filter_str,
        'success': result.returncode == 0,
        'processing_time': (end_time - start_time).total_seconds(),
        'timestamp': start_time.isoformat(),
    }

    if result.returncode != 0:
        log_entry['error'] = result.stderr

    return log_entry

def batch_process(input_dir, output_dir, config, max_workers=4):
    """Process all audio files in directory."""
    input_dir = Path(input_dir)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Find audio files
    audio_files = list(input_dir.glob('*.wav')) + list(input_dir.glob('*.mp3'))
    print(f"Found {len(audio_files)} audio files")

    results = []

    with ProcessPoolExecutor(max_workers=max_workers) as executor:
        futures = {
            executor.submit(process_file, f, output_dir, config): f
            for f in audio_files
        }

        for future in as_completed(futures):
            filepath = futures[future]
            try:
                result = future.result()
                results.append(result)
                status = "✓" if result['success'] else "✗"
                print(f"{status} {filepath.name} ({result['processing_time']:.1f}s)")
            except Exception as e:
                print(f"✗ {filepath.name}: {e}")
                results.append({
                    'input_file': str(filepath),
                    'success': False,
                    'error': str(e)
                })

    # Save batch log
    batch_log = {
        'batch_id': datetime.now().strftime('%Y%m%d_%H%M%S'),
        'input_directory': str(input_dir),
        'output_directory': str(output_dir),
        'config': config,
        'total_files': len(audio_files),
        'successful': sum(1 for r in results if r.get('success')),
        'failed': sum(1 for r in results if not r.get('success')),
        'results': results
    }

    log_path = output_dir / 'batch_processing_log.json'
    with open(log_path, 'w') as f:
        json.dump(batch_log, f, indent=2)

    print(f"\nBatch complete: {batch_log['successful']}/{batch_log['total_files']} successful")
    print(f"Log saved: {log_path}")

    return batch_log

def main():
    parser = argparse.ArgumentParser(description='Batch audio enhancement')
    parser.add_argument('input_dir', help='Input directory')
    parser.add_argument('output_dir', help='Output directory')
    parser.add_argument('--highpass', type=int, default=80, help='High-pass frequency')
    parser.add_argument('--lowpass', type=int, default=8000, help='Low-pass frequency')
    parser.add_argument('--noise-reduction', type=int, default=12, help='Noise reduction (0-50)')
    parser.add_argument('--normalize', action='store_true', default=True, help='Normalize audio')
    parser.add_argument('--workers', type=int, default=4, help='Parallel workers')

    args = parser.parse_args()

    config = {
        'highpass': args.highpass,
        'lowpass': args.lowpass,
        'noise_reduction': args.noise_reduction,
        'normalize': args.normalize
    }

    batch_process(args.input_dir, args.output_dir, config, args.workers)

if __name__ == '__main__':
    main()
```

**Make file for common tasks:**

```makefile
# Makefile for audio forensic processing

INPUT_DIR ?= input
OUTPUT_DIR ?= output
ENHANCED_DIR ?= enhanced

.PHONY: all clean analyze enhance transcribe

all: analyze enhance transcribe

# Create output directories
$(OUTPUT_DIR) $(ENHANCED_DIR):
	mkdir -p $@

# Analyze all input files
analyze: $(OUTPUT_DIR)
	@echo "Analyzing audio files..."
	@for f in $(INPUT_DIR)/*.wav; do \
		echo "$$f:"; \
		ffprobe -v error -show_entries format=duration:stream=sample_rate,channels $$f; \
	done > $(OUTPUT_DIR)/analysis.txt

# Enhance all files
enhance: $(ENHANCED_DIR)
	@echo "Enhancing audio files..."
	@for f in $(INPUT_DIR)/*.wav; do \
		filename=$$(basename $$f); \
		ffmpeg -i $$f -af "highpass=f=80,afftdn=nr=12,loudnorm=I=-16" \
			-y $(ENHANCED_DIR)/enhanced_$$filename; \
	done

# Transcribe enhanced files
transcribe: enhance
	@echo "Transcribing..."
	@for f in $(ENHANCED_DIR)/*.wav; do \
		whisper $$f --model small --language en --output_dir $(OUTPUT_DIR); \
	done

clean:
	rm -rf $(OUTPUT_DIR) $(ENHANCED_DIR)
```

**Usage:**

```bash
# Process with Makefile
make analyze      # Analyze only
make enhance      # Enhance only
make transcribe   # Full pipeline
make clean        # Clean up

# Python batch processor
python batch_processor.py input_folder/ output_folder/ \
    --highpass 100 --noise-reduction 15 --workers 8
```

Reference: [GNU Parallel](https://www.gnu.org/software/parallel/)

### 8.2 Build Python Audio Processing Pipelines

**Impact: LOW-MEDIUM (enables custom analysis and batch automation)**

Python with librosa, soundfile, and scipy enables custom analysis and processing pipelines for forensic workflows.

**Incorrect (shell script for complex processing):**

```bash
# Shell script with limited error handling
for f in *.wav; do
  ffmpeg -i "$f" -af "afftdn" "out_$f"
done
# No logging, no checksums, hard to customize
```

**Correct (Python pipeline with logging):**

```python
# Python with full documentation and error handling
pipeline = AudioForensicPipeline()
pipeline.load('evidence.wav')
pipeline.run_default_pipeline()
pipeline.save('enhanced.wav')
pipeline.save_log('processing_log.json')  # Full audit trail
```

**Essential libraries setup:**

```bash
pip install librosa soundfile scipy numpy matplotlib pydub noisereduce
```

**Basic audio I/O:**

```python
import librosa
import soundfile as sf
import numpy as np

# Read audio (librosa - always returns float, resamples by default)
audio, sr = librosa.load('input.wav', sr=None)  # sr=None preserves original rate
audio, sr = librosa.load('input.wav', sr=16000)  # Resample to 16kHz
audio, sr = librosa.load('input.wav', sr=None, mono=False)  # Preserve stereo

# Read audio (soundfile - preserves dtype)
audio, sr = sf.read('input.wav')  # Returns original dtype
audio, sr = sf.read('input.wav', dtype='float32')

# Write audio
sf.write('output.wav', audio, sr)  # Infers format from extension
sf.write('output.wav', audio, sr, subtype='PCM_24')  # 24-bit
sf.write('output.wav', audio, sr, subtype='PCM_16')  # 16-bit
sf.write('output.flac', audio, sr)  # FLAC
```

**Complete processing pipeline class:**

```python
import librosa
import soundfile as sf
import numpy as np
from scipy import signal
import noisereduce as nr
from pathlib import Path
import json
from datetime import datetime

class AudioForensicPipeline:
    """
    Configurable audio forensic processing pipeline.
    """

    def __init__(self, config=None):
        self.config = config or self.default_config()
        self.processing_log = []

    @staticmethod
    def default_config():
        return {
            'target_sr': None,  # None = preserve original
            'normalize': True,
            'highpass_freq': 80,
            'lowpass_freq': 8000,
            'noise_reduction': 0.5,  # 0-1
            'presence_boost_db': 3,
        }

    def load(self, filepath):
        """Load audio file."""
        self.filepath = filepath
        self.audio, self.sr = librosa.load(filepath, sr=self.config['target_sr'], mono=True)
        self.original_audio = self.audio.copy()

        self._log('load', f'Loaded {filepath} ({len(self.audio)/self.sr:.1f}s at {self.sr}Hz)')
        return self

    def _log(self, action, details):
        """Log processing action."""
        self.processing_log.append({
            'timestamp': datetime.now().isoformat(),
            'action': action,
            'details': details
        })

    def analyze(self):
        """Analyze audio characteristics."""
        analysis = {
            'duration': len(self.audio) / self.sr,
            'sample_rate': self.sr,
            'peak_db': 20 * np.log10(np.max(np.abs(self.audio)) + 1e-10),
            'rms_db': 20 * np.log10(np.sqrt(np.mean(self.audio**2)) + 1e-10),
        }

        # Estimate noise floor
        rms = librosa.feature.rms(y=self.audio)[0]
        analysis['noise_floor_db'] = 20 * np.log10(np.percentile(rms, 10) + 1e-10)

        # Spectral centroid
        analysis['spectral_centroid'] = np.mean(
            librosa.feature.spectral_centroid(y=self.audio, sr=self.sr)
        )

        self._log('analyze', analysis)
        return analysis

    def highpass(self, freq=None):
        """Apply high-pass filter."""
        freq = freq or self.config['highpass_freq']
        if freq and freq > 0:
            nyquist = self.sr / 2
            b, a = signal.butter(4, freq / nyquist, btype='high')
            self.audio = signal.filtfilt(b, a, self.audio)
            self._log('highpass', f'{freq}Hz')
        return self

    def lowpass(self, freq=None):
        """Apply low-pass filter."""
        freq = freq or self.config['lowpass_freq']
        if freq and freq < self.sr / 2:
            nyquist = self.sr / 2
            b, a = signal.butter(4, freq / nyquist, btype='low')
            self.audio = signal.filtfilt(b, a, self.audio)
            self._log('lowpass', f'{freq}Hz')
        return self

    def reduce_noise(self, amount=None):
        """Apply noise reduction."""
        amount = amount or self.config['noise_reduction']
        if amount > 0:
            self.audio = nr.reduce_noise(
                y=self.audio,
                sr=self.sr,
                prop_decrease=amount
            )
            self._log('noise_reduction', f'{amount*100:.0f}%')
        return self

    def boost_presence(self, gain_db=None):
        """Boost presence frequencies (2-4kHz)."""
        gain_db = gain_db or self.config['presence_boost_db']
        if gain_db != 0:
            # Peak filter at 3kHz
            center_freq = 3000
            Q = 1.0
            A = 10 ** (gain_db / 40)
            w0 = center_freq / (self.sr / 2)
            alpha = np.sin(np.pi * w0) / (2 * Q)

            b0 = 1 + alpha * A
            b1 = -2 * np.cos(np.pi * w0)
            b2 = 1 - alpha * A
            a0 = 1 + alpha / A
            a1 = -2 * np.cos(np.pi * w0)
            a2 = 1 - alpha / A

            b = np.array([b0/a0, b1/a0, b2/a0])
            a = np.array([1, a1/a0, a2/a0])

            self.audio = signal.filtfilt(b, a, self.audio)
            self._log('presence_boost', f'{gain_db}dB at {center_freq}Hz')
        return self

    def normalize(self, target_db=-3):
        """Normalize to target peak level."""
        if self.config['normalize']:
            peak = np.max(np.abs(self.audio))
            if peak > 0:
                target = 10 ** (target_db / 20)
                self.audio = self.audio / peak * target
                self._log('normalize', f'{target_db}dB peak')
        return self

    def run_default_pipeline(self):
        """Run default enhancement pipeline."""
        return (self
                .highpass()
                .reduce_noise()
                .lowpass()
                .boost_presence()
                .normalize())

    def save(self, output_path, subtype='PCM_24'):
        """Save processed audio."""
        sf.write(output_path, self.audio, self.sr, subtype=subtype)
        self._log('save', f'{output_path} ({subtype})')
        return self

    def get_log(self):
        """Get processing log."""
        return self.processing_log

    def save_log(self, output_path):
        """Save processing log to JSON."""
        with open(output_path, 'w') as f:
            json.dump({
                'input': str(self.filepath),
                'config': self.config,
                'log': self.processing_log
            }, f, indent=2)
        return self


def batch_process(input_dir, output_dir, config=None):
    """Batch process all audio files in directory."""
    input_path = Path(input_dir)
    output_path = Path(output_dir)
    output_path.mkdir(exist_ok=True)

    for audio_file in input_path.glob('*.wav'):
        print(f"Processing: {audio_file.name}")

        pipeline = AudioForensicPipeline(config)
        pipeline.load(str(audio_file))
        pipeline.run_default_pipeline()
        pipeline.save(str(output_path / f"enhanced_{audio_file.name}"))
        pipeline.save_log(str(output_path / f"{audio_file.stem}_log.json"))


# Usage
if __name__ == '__main__':
    # Single file processing
    pipeline = AudioForensicPipeline()
    pipeline.load('evidence.wav')

    # Analyze first
    analysis = pipeline.analyze()
    print(f"Peak: {analysis['peak_db']:.1f}dB, Noise floor: {analysis['noise_floor_db']:.1f}dB")

    # Run pipeline
    pipeline.run_default_pipeline()
    pipeline.save('evidence_enhanced.wav')
    pipeline.save_log('processing_log.json')

    # Batch processing
    # batch_process('input_folder/', 'output_folder/')
```

**Key library comparison:**

| Library | Best For | Speed | Flexibility |
|---------|----------|-------|-------------|
| librosa | Analysis, features | Medium | High |
| soundfile | I/O, format handling | Fast | Medium |
| scipy.signal | Filtering, DSP | Fast | High |
| noisereduce | ML noise reduction | Medium | Low |
| pydub | Simple editing | Medium | Medium |

Reference: [Librosa Documentation](https://librosa.org/doc/)

### 8.3 Install Audio Forensic Toolchain

**Impact: LOW-MEDIUM (sets up complete processing environment)**

Complete installation guide for audio forensic tools on macOS, Linux, and Windows.

**Incorrect (ad-hoc installation):**

```bash
# Installing tools as needed, version conflicts
pip install librosa
pip install some-other-lib  # Conflicts with librosa
brew install ffmpeg  # Missing codecs
# Inconsistent environment, reproducibility issues
```

**Correct (managed environment):**

```bash
# Create dedicated virtual environment
python -m venv audio_forensics
source audio_forensics/bin/activate

# Install all dependencies at once
pip install librosa soundfile scipy numpy noisereduce openai-whisper
brew install ffmpeg sox  # With all codecs

# Verify installation
python -c "import librosa; import whisper; print('Ready')"
```

**macOS (Homebrew):**

```bash
# Core tools
brew install ffmpeg sox audacity

# With all codecs
brew install ffmpeg --with-libvorbis --with-libvpx --with-opus

# Rubberband for time-stretching
brew install rubberband

# ExifTool for metadata
brew install exiftool

# Python audio libraries
pip install librosa soundfile scipy numpy matplotlib
pip install noisereduce pydub praat-parselmouth
pip install openai-whisper  # Or: pip install faster-whisper

# Optional: ML tools
pip install torch torchaudio
pip install demucs spleeter
```

**Ubuntu/Debian:**

```bash
# Core tools
sudo apt-get update
sudo apt-get install ffmpeg sox audacity

# Audio development libraries
sudo apt-get install libsndfile1-dev portaudio19-dev

# Rubberband
sudo apt-get install rubberband-cli librubberband-dev

# ExifTool
sudo apt-get install libimage-exiftool-perl

# Python dependencies
pip install librosa soundfile scipy numpy matplotlib
pip install noisereduce pydub praat-parselmouth
pip install openai-whisper
```

**Windows (with Chocolatey):**

```powershell
# Install Chocolatey first (if not installed)
# Run PowerShell as Admin

# Core tools
choco install ffmpeg sox audacity

# Python (if not installed)
choco install python

# Python packages
pip install librosa soundfile scipy numpy matplotlib
pip install noisereduce pydub praat-parselmouth
pip install openai-whisper
```

**Python virtual environment setup:**

```bash
# Create dedicated environment
python -m venv audio_forensics
source audio_forensics/bin/activate  # Linux/macOS
# or: audio_forensics\Scripts\activate  # Windows

# Install all dependencies
pip install --upgrade pip

# Core audio
pip install librosa soundfile scipy numpy matplotlib

# Noise reduction
pip install noisereduce

# ASR
pip install openai-whisper
# or faster version:
pip install faster-whisper

# Voice analysis
pip install praat-parselmouth

# Source separation (optional, large)
pip install demucs

# ML/Deep learning (optional)
pip install torch torchaudio
```

**Verify installation:**

```bash
# Check FFmpeg
ffmpeg -version

# Check SoX
sox --version

# Check Python libraries
python -c "
import librosa
import soundfile
import numpy
import scipy
import noisereduce
print('All core libraries installed')
"

# Check Whisper
python -c "import whisper; print(f'Whisper version: {whisper.__version__}')"
```

**Docker setup (reproducible environment):**

```dockerfile
# Dockerfile
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    sox \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --no-cache-dir \
    librosa \
    soundfile \
    scipy \
    numpy \
    noisereduce \
    openai-whisper

WORKDIR /audio
```

```bash
# Build and run
docker build -t audio-forensics .
docker run -it -v $(pwd):/audio audio-forensics bash
```

**Conda environment:**

```yaml
# environment.yml
name: audio_forensics
channels:
  - conda-forge
  - pytorch
dependencies:
  - python=3.10
  - ffmpeg
  - sox
  - numpy
  - scipy
  - matplotlib
  - pip
  - pip:
    - librosa
    - soundfile
    - noisereduce
    - openai-whisper
    - praat-parselmouth
```

```bash
conda env create -f environment.yml
conda activate audio_forensics
```

**GPU support for ML tools:**

```bash
# CUDA support for Whisper/PyTorch
pip install torch torchaudio --index-url https://download.pytorch.org/whl/cu118

# Verify GPU
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

**Tool verification script:**

```python
#!/usr/bin/env python
"""Verify audio forensic toolchain installation."""

import subprocess
import sys

def check_command(cmd, name):
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        print(f"✓ {name} installed")
        return True
    except FileNotFoundError:
        print(f"✗ {name} NOT FOUND")
        return False

def check_python_lib(lib, name=None):
    name = name or lib
    try:
        __import__(lib)
        print(f"✓ {name} installed")
        return True
    except ImportError:
        print(f"✗ {name} NOT FOUND")
        return False

print("=== Command-line tools ===")
check_command(['ffmpeg', '-version'], 'FFmpeg')
check_command(['sox', '--version'], 'SoX')
check_command(['ffprobe', '-version'], 'FFprobe')

print("\n=== Python libraries ===")
check_python_lib('librosa')
check_python_lib('soundfile')
check_python_lib('scipy')
check_python_lib('numpy')
check_python_lib('noisereduce')
check_python_lib('whisper', 'openai-whisper')

print("\n=== Optional tools ===")
check_python_lib('parselmouth', 'praat-parselmouth')
check_python_lib('demucs')
check_command(['exiftool', '-ver'], 'ExifTool')

# Check GPU
try:
    import torch
    if torch.cuda.is_available():
        print(f"✓ GPU available: {torch.cuda.get_device_name(0)}")
    else:
        print("○ GPU not available (CPU only)")
except ImportError:
    print("○ PyTorch not installed (GPU check skipped)")
```

**Minimum requirements:**

| Tool | Required | Purpose |
|------|----------|---------|
| FFmpeg | Yes | Format conversion, filters |
| Python 3.8+ | Yes | Analysis, automation |
| librosa | Yes | Audio analysis |
| soundfile | Yes | Audio I/O |
| scipy | Yes | Signal processing |
| noisereduce | Yes | ML noise reduction |
| Whisper | Recommended | Transcription |
| SoX | Recommended | Noise profiling |

Reference: [FFmpeg Download](https://ffmpeg.org/download.html)

### 8.4 Master Essential FFmpeg Audio Commands

**Impact: LOW-MEDIUM (enables rapid audio manipulation)**

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

### 8.5 Measure Audio Quality Metrics

**Impact: LOW-MEDIUM (quantifies enhancement effectiveness)**

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

### 8.6 Use Audacity for Visual Analysis and Manual Editing

**Impact: LOW-MEDIUM (enables visual inspection and precise manual edits)**

Audacity provides visual waveform/spectrogram editing essential for manual forensic work that automated tools can't handle.

**Incorrect (command-line only for all tasks):**

```bash
# Trying to repair specific click at 3.5s via CLI
ffmpeg -i audio.wav -af "adeclick" repaired.wav
# Declicks entire file, may miss specific problem
# No visual confirmation of repair
```

**Correct (visual editing for targeted repair):**

```bash
# In Audacity GUI:
# 1. Open in Audacity: File > Open > audio.wav
# 2. View spectrogram: Track dropdown > Spectrogram
# 3. Zoom to problem area at 3.5s
# 4. Select specific click region
# 5. Effect > Spectral edit > Filter
# 6. Visually verify repair
# 7. Export: File > Export > Export as WAV
```

**When to use Audacity:**

- Visual inspection of spectrograms
- Manual selection of noise samples
- Precise cut/splice editing
- Interactive comparison of enhancement settings
- Training ear on what different problems sound like

**Essential keyboard shortcuts:**

| Shortcut | Action |
|----------|--------|
| Space | Play/Stop |
| Shift+Space | Loop play selection |
| Ctrl+1 | Zoom in |
| Ctrl+3 | Zoom out |
| Ctrl+E | Zoom to selection |
| Ctrl+F | Fit project in window |
| R | Record |
| Z | Find zero crossings |
| Ctrl+D | Duplicate selection |
| Ctrl+Shift+E | Export selected audio |

**Spectral analysis workflow:**

1. **View spectrogram:**
   - Track dropdown → Spectrogram
   - Or Spectrogram Settings for detailed view

2. **Configure spectrogram:**
   - Edit → Preferences → Spectrogram
   - Window Size: 2048 (higher = better frequency resolution)
   - Window Type: Hann
   - Min Frequency: 0 Hz (or 50 Hz to hide DC)
   - Max Frequency: 8000 Hz (for speech)
   - Color scheme: Grayscale or Color (V2)

3. **Analyze specific regions:**
   - Select region
   - Analyze → Plot Spectrum
   - Look for tonal noise (sharp peaks)
   - Look for speech formants

**Noise reduction workflow:**

```text
1. Find a silent segment (noise only, no speech)
   - Select 0.5-2 seconds of pure noise
   - This is your "noise profile" sample

2. Get noise profile:
   - Effect → Noise Reduction
   - Click "Get Noise Profile"

3. Select audio to clean:
   - Select entire track (Ctrl+A) or specific region

4. Apply noise reduction:
   - Effect → Noise Reduction
   - Set reduction amount (6-12 dB for light, 12-24 dB for heavy)
   - Sensitivity: 6 (higher = more aggressive)
   - Frequency smoothing: 3
   - Click "Preview" to test
   - Click "OK" to apply
```

**Forensic enhancement preset:**

```text
Order of operations:
1. High-pass filter (Effect → High-Pass Filter, 80 Hz)
2. Noise reduction (as above)
3. Equalization for presence:
   - Effect → Filter Curve EQ
   - Boost 2-4 kHz by 3-6 dB
   - Cut 200-400 Hz by 2-3 dB (reduce mud)
4. Compression (Effect → Compressor):
   - Threshold: -20 dB
   - Ratio: 4:1
   - Attack: 0.1s
   - Release: 1.0s
5. Normalize (Effect → Normalize, -3 dB)
```

**Spectral editing (repair specific frequencies):**

1. Switch to Spectrogram view
2. Use Spectral Selection tool (F4)
3. Draw selection around specific noise
4. Effect → Spectral edit multi-tool
   - Filter: removes selected frequencies
   - Affects only selection

**Declicking:**

1. Zoom in very close to click
2. Use Draw tool (F3) to manually redraw waveform
3. Or: Effect → Click Removal (automatic)
   - Select threshold: 200
   - Max spike width: 20

**Manual splice detection:**

1. Zoom to waveform level
2. Look for:
   - Sudden DC offset changes
   - Unnatural zero crossings
   - Phase discontinuities
3. In spectrogram view, look for:
   - Vertical lines (abrupt spectral change)
   - ENF frequency jumps

**Audacity CLI (scripting):**

```bash
# Audacity has limited CLI, but can use macro/scripting
# Export from GUI: File → Export → Export as MP3

# For batch, use Audacity macros:
# 1. Create macro in Tools → Macros
# 2. Save macro
# 3. Run from command line (experimental):
audacity -b "MacroName" file1.wav file2.wav
```

**Comparison with command-line tools:**

| Task | Audacity | FFmpeg/SoX |
|------|----------|------------|
| Visual analysis | ✅ Best | ❌ No |
| Manual editing | ✅ Best | ❌ No |
| Batch processing | ❌ Poor | ✅ Best |
| Reproducibility | ❌ Manual | ✅ Scriptable |
| Noise profiling | ✅ Visual | ✅ Automated |
| Spectral repair | ✅ Manual | ❌ Limited |

**Recommended workflow:**

1. **Audacity first:** Visual analysis, identify problems
2. **Command-line:** Apply consistent processing
3. **Audacity verify:** Check results visually
4. **Command-line:** Batch process all files

**Project file tips:**

- Always save .aup3 project for undo history
- Export enhanced version as separate file
- Document settings used in a text file

Reference: [Audacity Manual](https://manual.audacityteam.org/)

### 8.7 Use SoX for Advanced Audio Manipulation

**Impact: LOW-MEDIUM (specialized audio operations and batch processing)**

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

---

## References

1. [https://www.swgde.org/documents/published-complete-listing/23-a-001-technical-notes-on-ffmpeg-for-forensic-audio-examination/](https://www.swgde.org/documents/published-complete-listing/23-a-001-technical-notes-on-ffmpeg-for-forensic-audio-examination/)
2. [https://github.com/openai/whisper](https://github.com/openai/whisper)
3. [https://jmvalin.ca/demo/rnnoise/](https://jmvalin.ca/demo/rnnoise/)
4. [https://www.izotope.com/en/products/rx/features](https://www.izotope.com/en/products/rx/features)
5. [https://en.wikipedia.org/wiki/Wiener_filter](https://en.wikipedia.org/wiki/Wiener_filter)
6. [https://en.wikipedia.org/wiki/Electrical_network_frequency_analysis](https://en.wikipedia.org/wiki/Electrical_network_frequency_analysis)
7. [https://librosa.org/](https://librosa.org/)
8. [https://cedaraudio.com/](https://cedaraudio.com/)
9. [https://en.wikipedia.org/wiki/Audio_forensics](https://en.wikipedia.org/wiki/Audio_forensics)
10. [https://podcast.adobe.com/enhance](https://podcast.adobe.com/enhance)
11. [https://ffmpeg.org/ffmpeg-filters.html](https://ffmpeg.org/ffmpeg-filters.html)
12. [http://sox.sourceforge.net/sox.html](http://sox.sourceforge.net/sox.html)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |