---
title: Never Modify Original Recording
impact: CRITICAL
impactDescription: prevents permanent evidence destruction
tags: signal, preservation, forensics, evidence, chain-of-custody
---

## Never Modify Original Recording

Always work on copies of audio evidence. The original recording is legally irreplaceable and any modification—even "enhancement"—can render it inadmissible in court.

**Incorrect (destructive workflow):**

```bash
# Directly modifying evidence file
ffmpeg -i evidence.wav -af "highpass=f=200,lowpass=f=3000" evidence.wav
# Original is now permanently altered
```

**Correct (preservation workflow):**

```bash
# Create forensic copy with checksum
cp evidence.wav evidence_working_copy.wav
sha256sum evidence.wav > evidence.sha256

# All processing on copy only
ffmpeg -i evidence_working_copy.wav -af "highpass=f=200,lowpass=f=3000" evidence_enhanced.wav

# Verify original unchanged
sha256sum -c evidence.sha256
```

**Chain of custody documentation:**

```bash
# Document every processing step
echo "$(date -Iseconds) | Created working copy from evidence.wav (SHA256: $(sha256sum evidence.wav | cut -d' ' -f1))" >> processing_log.txt
```

**Benefits:**
- Maintains legal admissibility
- Allows comparison with original
- Enables different enhancement approaches
- Provides audit trail for court

Reference: [SWGDE Guidelines for Forensic Audio](https://www.swgde.org/)
