---
title: Extract Speaker Characteristics for Identification
impact: MEDIUM
impactDescription: enables speaker comparison and verification
tags: forensic, speaker, identification, voice-print, biometrics
---

## Extract Speaker Characteristics for Identification

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
