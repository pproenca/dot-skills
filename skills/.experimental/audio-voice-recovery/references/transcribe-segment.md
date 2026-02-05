---
title: Segment Audio for Targeted Transcription
impact: MEDIUM
impactDescription: focuses ASR on speech segments, reduces hallucinations
tags: transcribe, segmentation, vad, chunks, timestamps
---

## Segment Audio for Targeted Transcription

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
