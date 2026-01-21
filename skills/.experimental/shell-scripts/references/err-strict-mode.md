---
title: Use Strict Mode for Error Detection
impact: HIGH
impactDescription: catches 90% of common script failures
tags: err, strict-mode, errexit, nounset, pipefail
---

## Use Strict Mode for Error Detection

Without strict mode, scripts continue after failures, undefined variables expand to empty strings, and pipeline errors are hidden. This causes silent data corruption.

**Incorrect (no error checking):**

```bash
#!/bin/bash
# Script continues after failures silently
cd /nonexistent/directory
rm -rf *  # Deletes files in WRONG directory!

# Undefined variable expands to empty
rm -rf "${TEMP_DIR}/"*  # If unset: rm -rf /*

# Pipeline failure hidden
curl http://example.com | process_data
# Even if curl fails, process_data runs with empty input
```

**Correct (strict mode enabled):**

```bash
#!/bin/bash
set -euo pipefail

# -e (errexit): Exit on any command failure
# -u (nounset): Error on undefined variables
# -o pipefail: Pipeline fails if any command fails

cd /nonexistent/directory  # Script exits here
rm -rf *                   # Never reached

# Undefined variable causes error
rm -rf "${TEMP_DIR}/"*     # Error: TEMP_DIR: unbound variable

# Pipeline failure detected
curl http://example.com | process_data  # Exits if curl fails
```

**Handle intentional failures:**

```bash
#!/bin/bash
set -euo pipefail

# Method 1: || true for commands that may fail
grep "pattern" file.txt || true

# Method 2: Conditional check
if grep -q "pattern" file.txt; then
  echo "Found"
else
  echo "Not found"
fi

# Method 3: Temporarily disable errexit
set +e
risky_command
status=$?
set -e
```

**Additional safety options:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit  # Subshells inherit errexit
shopt -s nullglob         # Globs expand to nothing if no match
```

Reference: [Unofficial Bash Strict Mode](https://gist.github.com/robin-a-meade/58d60124b88b60816e8349d1e3938615)
