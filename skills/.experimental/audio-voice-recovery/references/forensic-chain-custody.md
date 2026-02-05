---
title: Document Chain of Custody for Evidence
impact: MEDIUM
impactDescription: ensures legal admissibility
tags: forensic, chain-of-custody, documentation, legal, evidence
---

## Document Chain of Custody for Evidence

Legal admissibility requires documented chain of custody. Record every action, preserve originals, and maintain checksums.

**Incorrect (undocumented processing):**

```bash
# Processing evidence without documentation
ffmpeg -i evidence.wav -af "afftdn" enhanced.wav
rm evidence.wav  # Original lost!
# No checksums, no log, inadmissible in court
```

**Correct (documented chain of custody):**

```bash
# Calculate checksum of original
sha256sum evidence.wav > evidence.sha256

# Create working copy
cp evidence.wav evidence_working.wav

# Document all processing steps
echo "$(date -Iseconds) | Noise reduction applied: afftdn nr=12" >> processing_log.txt
ffmpeg -i evidence_working.wav -af "afftdn=nr=12" enhanced.wav

# Verify original unchanged
sha256sum -c evidence.sha256
```

**Chain of custody template:**

```python
import hashlib
import json
import os
from datetime import datetime
from pathlib import Path

class ChainOfCustody:
    """
    Maintain chain of custody documentation for audio evidence.
    """

    def __init__(self, evidence_path, case_id=None, examiner=None):
        self.evidence_path = Path(evidence_path)
        self.case_id = case_id or f"CASE-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
        self.examiner = examiner or os.getenv('USER', 'Unknown')
        self.log = []
        self.checksums = {}

        # Initialize
        self._log_action('RECEIVED', f'Evidence received: {evidence_path}')
        self._compute_checksum(evidence_path, 'original')

    def _compute_checksum(self, filepath, label):
        """Compute and store SHA-256 checksum."""
        sha256 = hashlib.sha256()
        with open(filepath, 'rb') as f:
            for chunk in iter(lambda: f.read(8192), b''):
                sha256.update(chunk)
        checksum = sha256.hexdigest()
        self.checksums[label] = checksum
        self._log_action('CHECKSUM', f'{label}: SHA-256 = {checksum}')
        return checksum

    def _log_action(self, action_type, description, details=None):
        """Log an action in the chain of custody."""
        entry = {
            'timestamp': datetime.now().isoformat(),
            'action': action_type,
            'description': description,
            'examiner': self.examiner,
        }
        if details:
            entry['details'] = details
        self.log.append(entry)

    def create_working_copy(self, output_path):
        """Create working copy and document it."""
        import shutil

        # Verify original unchanged
        current_checksum = hashlib.sha256(
            open(self.evidence_path, 'rb').read()
        ).hexdigest()

        if current_checksum != self.checksums['original']:
            raise ValueError("Original evidence has been modified!")

        # Create copy
        shutil.copy2(self.evidence_path, output_path)
        self._log_action('COPY', f'Working copy created: {output_path}')
        self._compute_checksum(output_path, 'working_copy')

        return output_path

    def log_processing(self, input_file, output_file, processing_description,
                       tool_used=None, parameters=None):
        """Document processing step."""
        details = {
            'input_file': str(input_file),
            'output_file': str(output_file),
            'tool': tool_used,
            'parameters': parameters
        }

        self._log_action('PROCESSING', processing_description, details)
        self._compute_checksum(output_file, f'processed_{len(self.checksums)}')

    def verify_original(self):
        """Verify original evidence is unchanged."""
        current = hashlib.sha256(
            open(self.evidence_path, 'rb').read()
        ).hexdigest()

        is_valid = current == self.checksums['original']
        self._log_action('VERIFICATION',
                        f'Original integrity: {"VALID" if is_valid else "INVALID"}')
        return is_valid

    def generate_report(self, output_path):
        """Generate formal chain of custody report."""
        report = {
            'case_id': self.case_id,
            'evidence_file': str(self.evidence_path),
            'examiner': self.examiner,
            'report_generated': datetime.now().isoformat(),
            'checksums': self.checksums,
            'action_log': self.log,
            'original_verified': self.verify_original()
        }

        # JSON report
        json_path = output_path.replace('.txt', '.json')
        with open(json_path, 'w') as f:
            json.dump(report, f, indent=2)

        # Human-readable report
        lines = [
            "=" * 70,
            "CHAIN OF CUSTODY REPORT",
            "=" * 70,
            "",
            f"Case ID: {self.case_id}",
            f"Evidence: {self.evidence_path}",
            f"Examiner: {self.examiner}",
            f"Report Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "",
            "-" * 70,
            "CHECKSUMS",
            "-" * 70,
        ]

        for label, checksum in self.checksums.items():
            lines.append(f"  {label}: {checksum}")

        lines.extend([
            "",
            "-" * 70,
            "ACTION LOG",
            "-" * 70,
        ])

        for entry in self.log:
            lines.append(f"\n[{entry['timestamp']}] {entry['action']}")
            lines.append(f"  {entry['description']}")
            if 'details' in entry:
                for key, value in entry['details'].items():
                    lines.append(f"    {key}: {value}")

        lines.extend([
            "",
            "-" * 70,
            "VERIFICATION",
            "-" * 70,
            f"  Original evidence integrity: {'VALID' if report['original_verified'] else 'INVALID'}",
            "",
            "=" * 70,
            f"End of Report - {self.case_id}",
            "=" * 70,
        ])

        report_text = '\n'.join(lines)

        with open(output_path, 'w') as f:
            f.write(report_text)

        return report_text

def forensic_processing_workflow(evidence_path, case_id=None):
    """
    Example forensic processing workflow with chain of custody.
    """
    import subprocess
    from pathlib import Path

    # Initialize chain of custody
    coc = ChainOfCustody(evidence_path, case_id)

    # Create working directory
    work_dir = Path(f'forensic_work_{coc.case_id}')
    work_dir.mkdir(exist_ok=True)

    # Create working copy
    working_copy = work_dir / 'working_copy.wav'
    coc.create_working_copy(working_copy)

    # Processing step 1: Analyze
    coc.log_processing(
        working_copy, working_copy,
        'Initial audio analysis - no modification',
        tool_used='ffprobe',
        parameters={'command': 'ffprobe -v quiet -print_format json -show_format'}
    )

    # Processing step 2: Enhancement
    enhanced_path = work_dir / 'enhanced.wav'
    subprocess.run([
        'ffmpeg', '-i', str(working_copy),
        '-af', 'highpass=f=80,afftdn=nr=10',
        str(enhanced_path)
    ], capture_output=True)

    coc.log_processing(
        working_copy, enhanced_path,
        'Noise reduction applied for intelligibility enhancement',
        tool_used='FFmpeg',
        parameters={'filters': 'highpass=f=80,afftdn=nr=10'}
    )

    # Final verification and report
    coc.verify_original()
    report = coc.generate_report(str(work_dir / 'chain_of_custody.txt'))

    print(f"Processing complete. Report saved to: {work_dir}/chain_of_custody.txt")
    return coc

# Usage
if __name__ == '__main__':
    coc = forensic_processing_workflow('evidence.wav', case_id='2024-001')
```

**Chain of custody checklist:**

| Step | Action | Documentation |
|------|--------|---------------|
| 1 | Receive evidence | Date, time, source, condition |
| 2 | Calculate checksum | SHA-256 of original |
| 3 | Create working copy | Verify checksum matches |
| 4 | Each processing step | Tool, parameters, input/output |
| 5 | Final verification | Confirm original unchanged |
| 6 | Generate report | Complete documentation |

Reference: [SWGDE Digital Evidence Guidelines](https://www.swgde.org/)
