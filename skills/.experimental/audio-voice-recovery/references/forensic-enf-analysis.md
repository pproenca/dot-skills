---
title: Use ENF Analysis for Timestamp Verification
impact: MEDIUM
impactDescription: verifies recording time within hours accuracy
tags: forensic, enf, timestamp, authentication, power-grid
---

## Use ENF Analysis for Timestamp Verification

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
