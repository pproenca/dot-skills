---
title: Detect and Filter ASR Hallucinations
impact: MEDIUM
impactDescription: prevents false content in transcripts
tags: transcribe, hallucination, detection, filtering, validation
---

## Detect and Filter ASR Hallucinations

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
