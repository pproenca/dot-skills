---
title: Use Multi-Pass Transcription for Difficult Audio
impact: MEDIUM
impactDescription: catches words missed in single pass
tags: transcribe, multi-pass, comparison, consensus, verification
---

## Use Multi-Pass Transcription for Difficult Audio

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
