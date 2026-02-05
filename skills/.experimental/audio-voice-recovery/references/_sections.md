# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Signal Preservation & Analysis (signal)

**Impact:** CRITICAL
**Description:** First contact with audio determines maximum recoverable quality. Wrong format conversion, improper bit-depth, or lossy re-encoding permanently destroys data that no algorithm can recover.

## 2. Noise Profiling & Estimation (noise)

**Impact:** CRITICAL
**Description:** Accurate noise profile is the foundation for all enhancement algorithms. Incorrect estimation causes musical artifacts, speech distortion, or removes voice frequencies mistaken for noise.

## 3. Spectral Processing (spectral)

**Impact:** HIGH
**Description:** Frequency-domain operations (spectral subtraction, Wiener filtering, notch filters) directly target noise while preserving voice characteristics. The core of forensic audio enhancement.

## 4. Voice Isolation & Enhancement (voice)

**Impact:** HIGH
**Description:** Separating speech from complex backgrounds using ML models (RNNoise, Dialogue Isolate) and preserving formants during pitch/time manipulation for natural-sounding results.

## 5. Temporal Processing (temporal)

**Impact:** MEDIUM-HIGH
**Description:** Time-domain operations including dynamic range compression, noise gating, and time-stretching improve intelligibility without introducing pitch artifacts or pumping effects.

## 6. Transcription & Recognition (transcribe)

**Impact:** MEDIUM
**Description:** Optimal preprocessing and robust ASR models (Whisper) maximize transcription accuracy from degraded audio. Includes confidence scoring and multi-pass strategies.

## 7. Forensic Authentication (forensic)

**Impact:** MEDIUM
**Description:** ENF analysis, tampering detection, metadata verification, and chain-of-custody documentation for legal admissibility and authenticity verification.

## 8. Tool Integration & Automation (tool)

**Impact:** LOW-MEDIUM
**Description:** FFmpeg, SoX, Python pipelines, and batch processing workflows for reproducible, documented forensic audio processing at scale.
