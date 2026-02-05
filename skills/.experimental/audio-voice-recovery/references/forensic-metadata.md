---
title: Extract and Verify Audio Metadata
impact: MEDIUM
impactDescription: reveals recording device, timestamps, and tampering signs
tags: forensic, metadata, exif, timestamps, provenance
---

## Extract and Verify Audio Metadata

Audio files contain metadata about recording device, date, and processing history. Essential for establishing provenance and detecting manipulation.

**Incorrect (ignoring metadata in forensic analysis):**

```bash
# Processing audio without checking metadata
ffmpeg -i evidence.wav -af "afftdn" enhanced.wav
# No record of original file properties or processing history
```

**Correct (extract metadata before and after processing):**

```bash
# Document original metadata
ffprobe -v quiet -print_format json -show_format -show_streams evidence.wav > evidence_metadata.json
exiftool -json evidence.wav > evidence_exif.json

# Process with documentation
ffmpeg -i evidence.wav -af "afftdn" enhanced.wav

# Verify changes and document
ffprobe -v quiet -print_format json -show_format enhanced.wav > enhanced_metadata.json
```

**FFprobe metadata extraction:**

```bash
# Full metadata dump
ffprobe -v quiet -print_format json -show_format -show_streams audio.wav

# Specific fields
ffprobe -v error -show_entries format=filename,duration,size,bit_rate:format_tags -of json audio.wav

# Container and codec info
ffprobe -v error -show_entries stream=codec_name,codec_long_name,sample_rate,channels,bits_per_sample audio.wav
```

**Python comprehensive metadata extraction:**

```python
import subprocess
import json
import os
from datetime import datetime
from pathlib import Path

def extract_ffprobe_metadata(audio_path):
    """
    Extract metadata using FFprobe.
    """
    cmd = [
        'ffprobe',
        '-v', 'quiet',
        '-print_format', 'json',
        '-show_format',
        '-show_streams',
        audio_path
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode == 0:
        return json.loads(result.stdout)
    return None

def extract_mutagen_metadata(audio_path):
    """
    Extract metadata using mutagen (supports many formats).
    """
    try:
        from mutagen import File
        from mutagen.wave import WAVE
        from mutagen.mp3 import MP3
        from mutagen.flac import FLAC

        audio = File(audio_path)
        if audio is None:
            return None

        metadata = {
            'length': audio.info.length if hasattr(audio.info, 'length') else None,
            'bitrate': audio.info.bitrate if hasattr(audio.info, 'bitrate') else None,
            'sample_rate': audio.info.sample_rate if hasattr(audio.info, 'sample_rate') else None,
            'channels': audio.info.channels if hasattr(audio.info, 'channels') else None,
            'tags': dict(audio.tags) if audio.tags else {}
        }

        return metadata
    except ImportError:
        return None

def extract_exiftool_metadata(audio_path):
    """
    Extract metadata using ExifTool (most comprehensive).
    """
    try:
        cmd = ['exiftool', '-json', audio_path]
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode == 0:
            return json.loads(result.stdout)[0]
    except FileNotFoundError:
        pass
    return None

def get_filesystem_metadata(audio_path):
    """
    Get filesystem-level metadata.
    """
    stat = os.stat(audio_path)
    path = Path(audio_path)

    return {
        'filename': path.name,
        'path': str(path.absolute()),
        'size_bytes': stat.st_size,
        'created': datetime.fromtimestamp(stat.st_ctime).isoformat(),
        'modified': datetime.fromtimestamp(stat.st_mtime).isoformat(),
        'accessed': datetime.fromtimestamp(stat.st_atime).isoformat(),
    }

def comprehensive_metadata_extraction(audio_path):
    """
    Extract metadata from all available sources.
    """
    metadata = {
        'file': get_filesystem_metadata(audio_path),
        'ffprobe': extract_ffprobe_metadata(audio_path),
        'exiftool': extract_exiftool_metadata(audio_path),
        'mutagen': extract_mutagen_metadata(audio_path)
    }

    return metadata

def detect_metadata_anomalies(metadata):
    """
    Detect potential tampering indicators in metadata.
    """
    anomalies = []

    # Check for timestamp inconsistencies
    file_meta = metadata.get('file', {})
    created = file_meta.get('created')
    modified = file_meta.get('modified')

    if created and modified:
        created_dt = datetime.fromisoformat(created)
        modified_dt = datetime.fromisoformat(modified)

        if modified_dt < created_dt:
            anomalies.append({
                'type': 'timestamp',
                'severity': 'high',
                'description': 'Modified date is before created date'
            })

    # Check for software indicators
    exif = metadata.get('exiftool', {})
    if exif:
        software = exif.get('Software', '') or exif.get('Encoder', '')
        if any(editor in software.lower() for editor in ['audacity', 'adobe', 'sox', 'ffmpeg']):
            anomalies.append({
                'type': 'processing',
                'severity': 'info',
                'description': f'Audio has been processed with: {software}'
            })

    # Check for unusual sample rates
    ffprobe = metadata.get('ffprobe', {})
    if ffprobe:
        streams = ffprobe.get('streams', [])
        for stream in streams:
            sr = stream.get('sample_rate')
            if sr and int(sr) not in [8000, 11025, 16000, 22050, 44100, 48000, 96000]:
                anomalies.append({
                    'type': 'technical',
                    'severity': 'low',
                    'description': f'Unusual sample rate: {sr} Hz'
                })

    return anomalies

def generate_metadata_report(audio_path, output_path):
    """
    Generate comprehensive metadata report.
    """
    metadata = comprehensive_metadata_extraction(audio_path)
    anomalies = detect_metadata_anomalies(metadata)

    report = []
    report.append("AUDIO METADATA FORENSIC REPORT")
    report.append("=" * 60)
    report.append(f"File: {audio_path}")
    report.append(f"Report generated: {datetime.now().isoformat()}")
    report.append("")

    # File info
    report.append("FILE SYSTEM METADATA")
    report.append("-" * 40)
    file_meta = metadata.get('file', {})
    for key, value in file_meta.items():
        report.append(f"  {key}: {value}")

    # Technical info
    report.append("\nTECHNICAL METADATA (FFprobe)")
    report.append("-" * 40)
    ffprobe = metadata.get('ffprobe', {})
    if ffprobe:
        fmt = ffprobe.get('format', {})
        report.append(f"  Format: {fmt.get('format_long_name', 'Unknown')}")
        report.append(f"  Duration: {fmt.get('duration', 'Unknown')} seconds")
        report.append(f"  Bit rate: {fmt.get('bit_rate', 'Unknown')} bps")

        for stream in ffprobe.get('streams', []):
            report.append(f"  Codec: {stream.get('codec_long_name', 'Unknown')}")
            report.append(f"  Sample rate: {stream.get('sample_rate', 'Unknown')} Hz")
            report.append(f"  Channels: {stream.get('channels', 'Unknown')}")
            report.append(f"  Bit depth: {stream.get('bits_per_sample', 'Unknown')} bits")

    # ExifTool data
    exif = metadata.get('exiftool', {})
    if exif:
        report.append("\nEXTENDED METADATA (ExifTool)")
        report.append("-" * 40)
        interesting_fields = ['Software', 'Encoder', 'Artist', 'Title',
                             'CreateDate', 'ModifyDate', 'Comment']
        for field in interesting_fields:
            if field in exif:
                report.append(f"  {field}: {exif[field]}")

    # Anomalies
    report.append("\nANOMALY DETECTION")
    report.append("-" * 40)
    if anomalies:
        for anomaly in anomalies:
            report.append(f"  [{anomaly['severity'].upper()}] {anomaly['type']}: {anomaly['description']}")
    else:
        report.append("  No anomalies detected")

    report_text = '\n'.join(report)

    with open(output_path, 'w') as f:
        f.write(report_text)

    return report_text

# Usage
if __name__ == '__main__':
    report = generate_metadata_report('evidence.wav', 'metadata_report.txt')
    print(report)
```

**Install dependencies:**

```bash
pip install mutagen

# ExifTool (optional but recommended)
# macOS
brew install exiftool

# Ubuntu
apt-get install libimage-exiftool-perl
```

**Key metadata fields for forensics:**

| Field | Significance |
|-------|--------------|
| CreateDate | Original recording time |
| ModifyDate | Last modification |
| Software/Encoder | Processing tools used |
| Sample rate | Recording quality |
| Duration | Check for missing segments |
| Bit depth | Original vs processed |

Reference: [ExifTool Documentation](https://exiftool.org/)
