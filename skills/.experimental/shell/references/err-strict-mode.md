---
title: Use Strict Mode for Error Detection
impact: HIGH
impactDescription: catches 60-80% of common failures when combined with explicit checks
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

**Caveats — `set -e` does NOT catch everything:**

```bash
#!/bin/bash
set -euo pipefail

# 1. Disabled inside if/while/until conditions
if some_failing_command; then  # No exit — set -e disabled in condition
  echo "success"
fi

# 2. Disabled in left side of && / ||
failing_command && echo "ok"  # No exit — set -e disabled before &&

# 3. Does NOT propagate into command substitutions (bash < 4.4)
result=$(failing_command)  # May not exit without inherit_errexit
# Fix: shopt -s inherit_errexit (bash 4.4+)

# 4. local masks exit status (even with set -e)
my_func() {
  local config=$(cat /missing/file)  # No exit! local succeeds
}
# Fix: separate declaration and assignment (see port-export-syntax)
```

Always combine `set -e` with explicit error checks for critical operations. Do not rely on it as the sole safety mechanism.

Reference: [Greg's Wiki - BashFAQ/105](https://mywiki.wooledge.org/BashFAQ/105)
