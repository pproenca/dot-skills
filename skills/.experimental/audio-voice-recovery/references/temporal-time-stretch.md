---
title: Use Time Stretching for Intelligibility
impact: MEDIUM-HIGH
impactDescription: 20-30% slower playback dramatically improves comprehension
tags: temporal, time-stretch, playback, speed, intelligibility
---

## Use Time Stretching for Intelligibility

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
