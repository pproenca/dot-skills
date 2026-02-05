---
title: Automate Batch Processing Workflows
impact: LOW-MEDIUM
impactDescription: process multiple files with consistent settings
tags: tool, batch, automation, scripting, workflow
---

## Automate Batch Processing Workflows

Batch processing ensures consistent enhancement across multiple recordings. Use shell scripts and Python for reproducible workflows.

**Bash batch processing:**

```bash
#!/bin/bash
# batch_enhance.sh - Process all audio files in directory

INPUT_DIR="${1:-.}"
OUTPUT_DIR="${2:-./enhanced}"

mkdir -p "$OUTPUT_DIR"

# Process each WAV file
for file in "$INPUT_DIR"/*.wav; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "Processing: $filename"

        ffmpeg -i "$file" \
            -af "highpass=f=80,afftdn=nr=12:nf=-30,loudnorm=I=-16:TP=-1.5" \
            -y "$OUTPUT_DIR/enhanced_$filename"
    fi
done

echo "Done. Enhanced files in: $OUTPUT_DIR"
```

**Parallel processing with GNU Parallel:**

```bash
#!/bin/bash
# parallel_enhance.sh - Process files in parallel

INPUT_DIR="${1:-.}"
OUTPUT_DIR="${2:-./enhanced}"

mkdir -p "$OUTPUT_DIR"

enhance_file() {
    file="$1"
    output_dir="$2"
    filename=$(basename "$file")

    ffmpeg -i "$file" \
        -af "highpass=f=80,afftdn=nr=12,loudnorm=I=-16" \
        -y "$output_dir/enhanced_$filename" 2>/dev/null

    echo "Done: $filename"
}

export -f enhance_file
export OUTPUT_DIR

find "$INPUT_DIR" -name "*.wav" | \
    parallel -j$(nproc) enhance_file {} "$OUTPUT_DIR"
```

**Python batch processor:**

```python
#!/usr/bin/env python
"""
batch_processor.py - Batch audio enhancement with logging
"""

import argparse
import json
import subprocess
from pathlib import Path
from datetime import datetime
from concurrent.futures import ProcessPoolExecutor, as_completed
import hashlib

def calculate_hash(filepath):
    """Calculate SHA-256 hash of file."""
    sha256 = hashlib.sha256()
    with open(filepath, 'rb') as f:
        for chunk in iter(lambda: f.read(8192), b''):
            sha256.update(chunk)
    return sha256.hexdigest()

def process_file(input_path, output_dir, config):
    """Process a single audio file."""
    input_path = Path(input_path)
    output_path = output_dir / f"enhanced_{input_path.name}"

    # Build filter chain
    filters = []
    if config.get('highpass'):
        filters.append(f"highpass=f={config['highpass']}")
    if config.get('noise_reduction'):
        filters.append(f"afftdn=nr={config['noise_reduction']}:nf=-30")
    if config.get('lowpass'):
        filters.append(f"lowpass=f={config['lowpass']}")
    if config.get('normalize'):
        filters.append("loudnorm=I=-16:TP=-1.5:LRA=11")

    filter_str = ','.join(filters) if filters else 'anull'

    # Run FFmpeg
    cmd = [
        'ffmpeg', '-i', str(input_path),
        '-af', filter_str,
        '-y', str(output_path)
    ]

    start_time = datetime.now()
    result = subprocess.run(cmd, capture_output=True, text=True)
    end_time = datetime.now()

    # Log entry
    log_entry = {
        'input_file': str(input_path),
        'input_hash': calculate_hash(input_path),
        'output_file': str(output_path),
        'output_hash': calculate_hash(output_path) if output_path.exists() else None,
        'config': config,
        'filter_chain': filter_str,
        'success': result.returncode == 0,
        'processing_time': (end_time - start_time).total_seconds(),
        'timestamp': start_time.isoformat(),
    }

    if result.returncode != 0:
        log_entry['error'] = result.stderr

    return log_entry

def batch_process(input_dir, output_dir, config, max_workers=4):
    """Process all audio files in directory."""
    input_dir = Path(input_dir)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Find audio files
    audio_files = list(input_dir.glob('*.wav')) + list(input_dir.glob('*.mp3'))
    print(f"Found {len(audio_files)} audio files")

    results = []

    with ProcessPoolExecutor(max_workers=max_workers) as executor:
        futures = {
            executor.submit(process_file, f, output_dir, config): f
            for f in audio_files
        }

        for future in as_completed(futures):
            filepath = futures[future]
            try:
                result = future.result()
                results.append(result)
                status = "✓" if result['success'] else "✗"
                print(f"{status} {filepath.name} ({result['processing_time']:.1f}s)")
            except Exception as e:
                print(f"✗ {filepath.name}: {e}")
                results.append({
                    'input_file': str(filepath),
                    'success': False,
                    'error': str(e)
                })

    # Save batch log
    batch_log = {
        'batch_id': datetime.now().strftime('%Y%m%d_%H%M%S'),
        'input_directory': str(input_dir),
        'output_directory': str(output_dir),
        'config': config,
        'total_files': len(audio_files),
        'successful': sum(1 for r in results if r.get('success')),
        'failed': sum(1 for r in results if not r.get('success')),
        'results': results
    }

    log_path = output_dir / 'batch_processing_log.json'
    with open(log_path, 'w') as f:
        json.dump(batch_log, f, indent=2)

    print(f"\nBatch complete: {batch_log['successful']}/{batch_log['total_files']} successful")
    print(f"Log saved: {log_path}")

    return batch_log

def main():
    parser = argparse.ArgumentParser(description='Batch audio enhancement')
    parser.add_argument('input_dir', help='Input directory')
    parser.add_argument('output_dir', help='Output directory')
    parser.add_argument('--highpass', type=int, default=80, help='High-pass frequency')
    parser.add_argument('--lowpass', type=int, default=8000, help='Low-pass frequency')
    parser.add_argument('--noise-reduction', type=int, default=12, help='Noise reduction (0-50)')
    parser.add_argument('--normalize', action='store_true', default=True, help='Normalize audio')
    parser.add_argument('--workers', type=int, default=4, help='Parallel workers')

    args = parser.parse_args()

    config = {
        'highpass': args.highpass,
        'lowpass': args.lowpass,
        'noise_reduction': args.noise_reduction,
        'normalize': args.normalize
    }

    batch_process(args.input_dir, args.output_dir, config, args.workers)

if __name__ == '__main__':
    main()
```

**Make file for common tasks:**

```makefile
# Makefile for audio forensic processing

INPUT_DIR ?= input
OUTPUT_DIR ?= output
ENHANCED_DIR ?= enhanced

.PHONY: all clean analyze enhance transcribe

all: analyze enhance transcribe

# Create output directories
$(OUTPUT_DIR) $(ENHANCED_DIR):
	mkdir -p $@

# Analyze all input files
analyze: $(OUTPUT_DIR)
	@echo "Analyzing audio files..."
	@for f in $(INPUT_DIR)/*.wav; do \
		echo "$$f:"; \
		ffprobe -v error -show_entries format=duration:stream=sample_rate,channels $$f; \
	done > $(OUTPUT_DIR)/analysis.txt

# Enhance all files
enhance: $(ENHANCED_DIR)
	@echo "Enhancing audio files..."
	@for f in $(INPUT_DIR)/*.wav; do \
		filename=$$(basename $$f); \
		ffmpeg -i $$f -af "highpass=f=80,afftdn=nr=12,loudnorm=I=-16" \
			-y $(ENHANCED_DIR)/enhanced_$$filename; \
	done

# Transcribe enhanced files
transcribe: enhance
	@echo "Transcribing..."
	@for f in $(ENHANCED_DIR)/*.wav; do \
		whisper $$f --model small --language en --output_dir $(OUTPUT_DIR); \
	done

clean:
	rm -rf $(OUTPUT_DIR) $(ENHANCED_DIR)
```

**Usage:**

```bash
# Process with Makefile
make analyze      # Analyze only
make enhance      # Enhance only
make transcribe   # Full pipeline
make clean        # Clean up

# Python batch processor
python batch_processor.py input_folder/ output_folder/ \
    --highpass 100 --noise-reduction 15 --workers 8
```

Reference: [GNU Parallel](https://www.gnu.org/software/parallel/)
