---
title: Apply Noise Gate to Silence Non-Speech Segments
impact: MEDIUM-HIGH
impactDescription: eliminates background noise during pauses
tags: temporal, gate, silence, threshold, noise-floor
---

## Apply Noise Gate to Silence Non-Speech Segments

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
