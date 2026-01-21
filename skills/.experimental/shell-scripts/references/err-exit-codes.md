---
title: Use Meaningful Exit Codes
impact: HIGH
impactDescription: enables proper error handling by callers
tags: err, exit-codes, return, status
---

## Use Meaningful Exit Codes

Exit codes communicate success/failure to calling scripts and tools. Using `exit 0` for failures or inconsistent codes breaks automation and makes debugging difficult.

**Incorrect (ignoring exit codes):**

```bash
#!/bin/bash
# Always exits 0, even on failure
process_file "$1"
echo "Done"
# Implicit exit 0

# Generic exit code
if [[ ! -f "$file" ]]; then
  echo "File not found"
  exit 1  # Same code for all errors
fi
```

**Correct (explicit exit codes):**

```bash
#!/bin/bash
set -euo pipefail

# Define exit codes at top of script
readonly E_SUCCESS=0
readonly E_ARGS=1
readonly E_FILE_NOT_FOUND=2
readonly E_PERMISSION=3
readonly E_NETWORK=4

main() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <file>" >&2
    return $E_ARGS
  fi

  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Error: File not found: $file" >&2
    return $E_FILE_NOT_FOUND
  fi

  if [[ ! -r "$file" ]]; then
    echo "Error: Permission denied: $file" >&2
    return $E_PERMISSION
  fi

  process_file "$file"
}

main "$@"
exit $?
```

**Standard exit codes:**

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Misuse of shell command |
| 126 | Command not executable |
| 127 | Command not found |
| 128+N | Terminated by signal N |
| 130 | Ctrl+C (SIGINT) |

**Propagate exit codes:**

```bash
#!/bin/bash
# Preserve exit code through pipes
command | tee output.log
exit "${PIPESTATUS[0]}"

# Preserve across function calls
result=$(some_function) || exit $?
```

Reference: [Advanced Bash Scripting Guide - Exit Codes](https://tldp.org/LDP/abs/html/exitcodes.html)
