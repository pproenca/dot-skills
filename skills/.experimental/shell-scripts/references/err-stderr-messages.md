---
title: Send Error Messages to stderr
impact: HIGH
impactDescription: enables proper output piping and filtering
tags: err, stderr, stdout, output, messages
---

## Send Error Messages to stderr

Error messages sent to stdout mix with program output, breaking pipes and making automation fail. Always separate errors (stderr) from data (stdout).

**Incorrect (errors to stdout):**

```bash
#!/bin/bash
# Error messages go to stdout, breaking pipelines
if [[ ! -f "$file" ]]; then
  echo "Error: File not found"  # Goes to stdout
fi

# This breaks:
# ./script.sh | process_output
# Error message gets piped to process_output!
```

**Correct (errors to stderr):**

```bash
#!/bin/bash
# Redirect error messages to stderr
if [[ ! -f "$file" ]]; then
  echo "Error: File not found" >&2
fi

# Define error function for consistency
err() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
}

warn() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] WARN: $*" >&2
}

# Use throughout script
if [[ ! -d "$output_dir" ]]; then
  err "Output directory does not exist: $output_dir"
  exit 1
fi
```

**Complete logging pattern:**

```bash
#!/bin/bash
set -euo pipefail

# Log levels
readonly LOG_ERROR=0
readonly LOG_WARN=1
readonly LOG_INFO=2
readonly LOG_DEBUG=3

LOG_LEVEL=${LOG_LEVEL:-$LOG_INFO}

log() {
  local level=$1
  shift
  local msg="$*"

  if [[ $level -le $LOG_LEVEL ]]; then
    local prefix
    case $level in
      $LOG_ERROR) prefix="ERROR" ;;
      $LOG_WARN)  prefix="WARN"  ;;
      $LOG_INFO)  prefix="INFO"  ;;
      $LOG_DEBUG) prefix="DEBUG" ;;
    esac
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $prefix: $msg" >&2
  fi
}

# Usage
log $LOG_INFO "Starting process"
log $LOG_ERROR "Failed to connect"
```

**Proper output separation:**

```bash
#!/bin/bash
# stdout: Data output (can be piped)
# stderr: Progress, status, errors (goes to terminal)

process_files() {
  for file in "$@"; do
    echo "Processing: $file" >&2  # Status to stderr
    cat "$file"                    # Data to stdout
  done
}

# Usage: ./script.sh file1 file2 > output.txt
# Status messages appear on terminal, data goes to file
```

Reference: [Google Shell Style Guide - STDOUT vs STDERR](https://google.github.io/styleguide/shellguide.html)
