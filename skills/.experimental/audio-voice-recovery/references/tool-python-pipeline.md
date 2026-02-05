---
title: Build Python Audio Processing Pipelines
impact: LOW-MEDIUM
impactDescription: enables custom analysis and batch automation
tags: tool, python, librosa, soundfile, pipeline, automation
---

## Build Python Audio Processing Pipelines

Python with librosa, soundfile, and scipy enables custom analysis and processing pipelines for forensic workflows.

**Incorrect (shell script for complex processing):**

```bash
# Shell script with limited error handling
for f in *.wav; do
  ffmpeg -i "$f" -af "afftdn" "out_$f"
done
# No logging, no checksums, hard to customize
```

**Correct (Python pipeline with logging):**

```python
# Python with full documentation and error handling
pipeline = AudioForensicPipeline()
pipeline.load('evidence.wav')
pipeline.run_default_pipeline()
pipeline.save('enhanced.wav')
pipeline.save_log('processing_log.json')  # Full audit trail
```

**Essential libraries setup:**

```bash
pip install librosa soundfile scipy numpy matplotlib pydub noisereduce
```

**Basic audio I/O:**

```python
import librosa
import soundfile as sf
import numpy as np

# Read audio (librosa - always returns float, resamples by default)
audio, sr = librosa.load('input.wav', sr=None)  # sr=None preserves original rate
audio, sr = librosa.load('input.wav', sr=16000)  # Resample to 16kHz
audio, sr = librosa.load('input.wav', sr=None, mono=False)  # Preserve stereo

# Read audio (soundfile - preserves dtype)
audio, sr = sf.read('input.wav')  # Returns original dtype
audio, sr = sf.read('input.wav', dtype='float32')

# Write audio
sf.write('output.wav', audio, sr)  # Infers format from extension
sf.write('output.wav', audio, sr, subtype='PCM_24')  # 24-bit
sf.write('output.wav', audio, sr, subtype='PCM_16')  # 16-bit
sf.write('output.flac', audio, sr)  # FLAC
```

**Complete processing pipeline class:**

```python
import librosa
import soundfile as sf
import numpy as np
from scipy import signal
import noisereduce as nr
from pathlib import Path
import json
from datetime import datetime

class AudioForensicPipeline:
    """
    Configurable audio forensic processing pipeline.
    """

    def __init__(self, config=None):
        self.config = config or self.default_config()
        self.processing_log = []

    @staticmethod
    def default_config():
        return {
            'target_sr': None,  # None = preserve original
            'normalize': True,
            'highpass_freq': 80,
            'lowpass_freq': 8000,
            'noise_reduction': 0.5,  # 0-1
            'presence_boost_db': 3,
        }

    def load(self, filepath):
        """Load audio file."""
        self.filepath = filepath
        self.audio, self.sr = librosa.load(filepath, sr=self.config['target_sr'], mono=True)
        self.original_audio = self.audio.copy()

        self._log('load', f'Loaded {filepath} ({len(self.audio)/self.sr:.1f}s at {self.sr}Hz)')
        return self

    def _log(self, action, details):
        """Log processing action."""
        self.processing_log.append({
            'timestamp': datetime.now().isoformat(),
            'action': action,
            'details': details
        })

    def analyze(self):
        """Analyze audio characteristics."""
        analysis = {
            'duration': len(self.audio) / self.sr,
            'sample_rate': self.sr,
            'peak_db': 20 * np.log10(np.max(np.abs(self.audio)) + 1e-10),
            'rms_db': 20 * np.log10(np.sqrt(np.mean(self.audio**2)) + 1e-10),
        }

        # Estimate noise floor
        rms = librosa.feature.rms(y=self.audio)[0]
        analysis['noise_floor_db'] = 20 * np.log10(np.percentile(rms, 10) + 1e-10)

        # Spectral centroid
        analysis['spectral_centroid'] = np.mean(
            librosa.feature.spectral_centroid(y=self.audio, sr=self.sr)
        )

        self._log('analyze', analysis)
        return analysis

    def highpass(self, freq=None):
        """Apply high-pass filter."""
        freq = freq or self.config['highpass_freq']
        if freq and freq > 0:
            nyquist = self.sr / 2
            b, a = signal.butter(4, freq / nyquist, btype='high')
            self.audio = signal.filtfilt(b, a, self.audio)
            self._log('highpass', f'{freq}Hz')
        return self

    def lowpass(self, freq=None):
        """Apply low-pass filter."""
        freq = freq or self.config['lowpass_freq']
        if freq and freq < self.sr / 2:
            nyquist = self.sr / 2
            b, a = signal.butter(4, freq / nyquist, btype='low')
            self.audio = signal.filtfilt(b, a, self.audio)
            self._log('lowpass', f'{freq}Hz')
        return self

    def reduce_noise(self, amount=None):
        """Apply noise reduction."""
        amount = amount or self.config['noise_reduction']
        if amount > 0:
            self.audio = nr.reduce_noise(
                y=self.audio,
                sr=self.sr,
                prop_decrease=amount
            )
            self._log('noise_reduction', f'{amount*100:.0f}%')
        return self

    def boost_presence(self, gain_db=None):
        """Boost presence frequencies (2-4kHz)."""
        gain_db = gain_db or self.config['presence_boost_db']
        if gain_db != 0:
            # Peak filter at 3kHz
            center_freq = 3000
            Q = 1.0
            A = 10 ** (gain_db / 40)
            w0 = center_freq / (self.sr / 2)
            alpha = np.sin(np.pi * w0) / (2 * Q)

            b0 = 1 + alpha * A
            b1 = -2 * np.cos(np.pi * w0)
            b2 = 1 - alpha * A
            a0 = 1 + alpha / A
            a1 = -2 * np.cos(np.pi * w0)
            a2 = 1 - alpha / A

            b = np.array([b0/a0, b1/a0, b2/a0])
            a = np.array([1, a1/a0, a2/a0])

            self.audio = signal.filtfilt(b, a, self.audio)
            self._log('presence_boost', f'{gain_db}dB at {center_freq}Hz')
        return self

    def normalize(self, target_db=-3):
        """Normalize to target peak level."""
        if self.config['normalize']:
            peak = np.max(np.abs(self.audio))
            if peak > 0:
                target = 10 ** (target_db / 20)
                self.audio = self.audio / peak * target
                self._log('normalize', f'{target_db}dB peak')
        return self

    def run_default_pipeline(self):
        """Run default enhancement pipeline."""
        return (self
                .highpass()
                .reduce_noise()
                .lowpass()
                .boost_presence()
                .normalize())

    def save(self, output_path, subtype='PCM_24'):
        """Save processed audio."""
        sf.write(output_path, self.audio, self.sr, subtype=subtype)
        self._log('save', f'{output_path} ({subtype})')
        return self

    def get_log(self):
        """Get processing log."""
        return self.processing_log

    def save_log(self, output_path):
        """Save processing log to JSON."""
        with open(output_path, 'w') as f:
            json.dump({
                'input': str(self.filepath),
                'config': self.config,
                'log': self.processing_log
            }, f, indent=2)
        return self


def batch_process(input_dir, output_dir, config=None):
    """Batch process all audio files in directory."""
    input_path = Path(input_dir)
    output_path = Path(output_dir)
    output_path.mkdir(exist_ok=True)

    for audio_file in input_path.glob('*.wav'):
        print(f"Processing: {audio_file.name}")

        pipeline = AudioForensicPipeline(config)
        pipeline.load(str(audio_file))
        pipeline.run_default_pipeline()
        pipeline.save(str(output_path / f"enhanced_{audio_file.name}"))
        pipeline.save_log(str(output_path / f"{audio_file.stem}_log.json"))


# Usage
if __name__ == '__main__':
    # Single file processing
    pipeline = AudioForensicPipeline()
    pipeline.load('evidence.wav')

    # Analyze first
    analysis = pipeline.analyze()
    print(f"Peak: {analysis['peak_db']:.1f}dB, Noise floor: {analysis['noise_floor_db']:.1f}dB")

    # Run pipeline
    pipeline.run_default_pipeline()
    pipeline.save('evidence_enhanced.wav')
    pipeline.save_log('processing_log.json')

    # Batch processing
    # batch_process('input_folder/', 'output_folder/')
```

**Key library comparison:**

| Library | Best For | Speed | Flexibility |
|---------|----------|-------|-------------|
| librosa | Analysis, features | Medium | High |
| soundfile | I/O, format handling | Fast | Medium |
| scipy.signal | Filtering, DSP | Fast | High |
| noisereduce | ML noise reduction | Medium | Low |
| pydub | Simple editing | Medium | Medium |

Reference: [Librosa Documentation](https://librosa.org/doc/)
