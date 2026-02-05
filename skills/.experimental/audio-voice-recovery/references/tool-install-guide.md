---
title: Install Audio Forensic Toolchain
impact: LOW-MEDIUM
impactDescription: sets up complete processing environment
tags: tool, installation, setup, dependencies, environment
---

## Install Audio Forensic Toolchain

Complete installation guide for audio forensic tools on macOS, Linux, and Windows.

**Incorrect (ad-hoc installation):**

```bash
# Installing tools as needed, version conflicts
pip install librosa
pip install some-other-lib  # Conflicts with librosa
brew install ffmpeg  # Missing codecs
# Inconsistent environment, reproducibility issues
```

**Correct (managed environment):**

```bash
# Create dedicated virtual environment
python -m venv audio_forensics
source audio_forensics/bin/activate

# Install all dependencies at once
pip install librosa soundfile scipy numpy noisereduce openai-whisper
brew install ffmpeg sox  # With all codecs

# Verify installation
python -c "import librosa; import whisper; print('Ready')"
```

**macOS (Homebrew):**

```bash
# Core tools
brew install ffmpeg sox audacity

# With all codecs
brew install ffmpeg --with-libvorbis --with-libvpx --with-opus

# Rubberband for time-stretching
brew install rubberband

# ExifTool for metadata
brew install exiftool

# Python audio libraries
pip install librosa soundfile scipy numpy matplotlib
pip install noisereduce pydub praat-parselmouth
pip install openai-whisper  # Or: pip install faster-whisper

# Optional: ML tools
pip install torch torchaudio
pip install demucs spleeter
```

**Ubuntu/Debian:**

```bash
# Core tools
sudo apt-get update
sudo apt-get install ffmpeg sox audacity

# Audio development libraries
sudo apt-get install libsndfile1-dev portaudio19-dev

# Rubberband
sudo apt-get install rubberband-cli librubberband-dev

# ExifTool
sudo apt-get install libimage-exiftool-perl

# Python dependencies
pip install librosa soundfile scipy numpy matplotlib
pip install noisereduce pydub praat-parselmouth
pip install openai-whisper
```

**Windows (with Chocolatey):**

```powershell
# Install Chocolatey first (if not installed)
# Run PowerShell as Admin

# Core tools
choco install ffmpeg sox audacity

# Python (if not installed)
choco install python

# Python packages
pip install librosa soundfile scipy numpy matplotlib
pip install noisereduce pydub praat-parselmouth
pip install openai-whisper
```

**Python virtual environment setup:**

```bash
# Create dedicated environment
python -m venv audio_forensics
source audio_forensics/bin/activate  # Linux/macOS
# or: audio_forensics\Scripts\activate  # Windows

# Install all dependencies
pip install --upgrade pip

# Core audio
pip install librosa soundfile scipy numpy matplotlib

# Noise reduction
pip install noisereduce

# ASR
pip install openai-whisper
# or faster version:
pip install faster-whisper

# Voice analysis
pip install praat-parselmouth

# Source separation (optional, large)
pip install demucs

# ML/Deep learning (optional)
pip install torch torchaudio
```

**Verify installation:**

```bash
# Check FFmpeg
ffmpeg -version

# Check SoX
sox --version

# Check Python libraries
python -c "
import librosa
import soundfile
import numpy
import scipy
import noisereduce
print('All core libraries installed')
"

# Check Whisper
python -c "import whisper; print(f'Whisper version: {whisper.__version__}')"
```

**Docker setup (reproducible environment):**

```dockerfile
# Dockerfile
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    sox \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --no-cache-dir \
    librosa \
    soundfile \
    scipy \
    numpy \
    noisereduce \
    openai-whisper

WORKDIR /audio
```

```bash
# Build and run
docker build -t audio-forensics .
docker run -it -v $(pwd):/audio audio-forensics bash
```

**Conda environment:**

```yaml
# environment.yml
name: audio_forensics
channels:
  - conda-forge
  - pytorch
dependencies:
  - python=3.10
  - ffmpeg
  - sox
  - numpy
  - scipy
  - matplotlib
  - pip
  - pip:
    - librosa
    - soundfile
    - noisereduce
    - openai-whisper
    - praat-parselmouth
```

```bash
conda env create -f environment.yml
conda activate audio_forensics
```

**GPU support for ML tools:**

```bash
# CUDA support for Whisper/PyTorch
pip install torch torchaudio --index-url https://download.pytorch.org/whl/cu118

# Verify GPU
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

**Tool verification script:**

```python
#!/usr/bin/env python
"""Verify audio forensic toolchain installation."""

import subprocess
import sys

def check_command(cmd, name):
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        print(f"✓ {name} installed")
        return True
    except FileNotFoundError:
        print(f"✗ {name} NOT FOUND")
        return False

def check_python_lib(lib, name=None):
    name = name or lib
    try:
        __import__(lib)
        print(f"✓ {name} installed")
        return True
    except ImportError:
        print(f"✗ {name} NOT FOUND")
        return False

print("=== Command-line tools ===")
check_command(['ffmpeg', '-version'], 'FFmpeg')
check_command(['sox', '--version'], 'SoX')
check_command(['ffprobe', '-version'], 'FFprobe')

print("\n=== Python libraries ===")
check_python_lib('librosa')
check_python_lib('soundfile')
check_python_lib('scipy')
check_python_lib('numpy')
check_python_lib('noisereduce')
check_python_lib('whisper', 'openai-whisper')

print("\n=== Optional tools ===")
check_python_lib('parselmouth', 'praat-parselmouth')
check_python_lib('demucs')
check_command(['exiftool', '-ver'], 'ExifTool')

# Check GPU
try:
    import torch
    if torch.cuda.is_available():
        print(f"✓ GPU available: {torch.cuda.get_device_name(0)}")
    else:
        print("○ GPU not available (CPU only)")
except ImportError:
    print("○ PyTorch not installed (GPU check skipped)")
```

**Minimum requirements:**

| Tool | Required | Purpose |
|------|----------|---------|
| FFmpeg | Yes | Format conversion, filters |
| Python 3.8+ | Yes | Analysis, automation |
| librosa | Yes | Audio analysis |
| soundfile | Yes | Audio I/O |
| scipy | Yes | Signal processing |
| noisereduce | Yes | ML noise reduction |
| Whisper | Recommended | Transcription |
| SoX | Recommended | Noise profiling |

Reference: [FFmpeg Download](https://ffmpeg.org/download.html)
