---
title: Use Voice Activity Detection for Targeted Processing
impact: HIGH
impactDescription: focuses enhancement on speech, preserves context
tags: voice, vad, segmentation, speech-detection, energy
---

## Use Voice Activity Detection for Targeted Processing

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
