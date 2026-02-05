---
title: Detect Audio Tampering and Splices
impact: MEDIUM
impactDescription: identifies edits, deletions, and insertions
tags: forensic, tampering, splice, detection, authentication
---

## Detect Audio Tampering and Splices

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
