---
title: Check Command Success Explicitly
impact: HIGH
impactDescription: prevents cascading failures from silent errors
tags: err, error-handling, conditionals, exit-status
---

## Check Command Success Explicitly

Even with `set -e`, some failures don't trigger exits (in conditions, pipes, subshells). Critical operations need explicit checking to prevent cascading failures.

**Incorrect (assuming success):**

```bash
#!/bin/bash
# These don't trigger errexit:
cd "$dir" && process_files  # cd failure only skips process_files
result=$(failing_command)   # With 'local', exit status is masked
if grep -q "pattern" file; then  # grep failure is expected here

# Dangerous assumptions
cd /important/directory
rm -rf *  # Runs in WRONG directory if cd failed!
```

**Correct (explicit error handling):**

```bash
#!/bin/bash
set -euo pipefail

# Check cd explicitly
if ! cd "$dir"; then
  echo "Error: Cannot change to directory: $dir" >&2
  exit 1
fi

# Or use subshell to contain cd
(
  cd "$dir" || exit 1
  rm -rf ./*
)

# Check critical commands with ||
mv "$src" "$dst" || {
  echo "Error: Failed to move $src to $dst" >&2
  exit 1
}
```

**Handle command substitution properly:**

```bash
#!/bin/bash
set -euo pipefail

# WRONG: local masks exit status
process() {
  local result=$(failing_command)  # Always succeeds!
}

# CORRECT: Separate declaration and assignment
process() {
  local result
  result=$(failing_command)  # Exit status preserved
}

# CORRECT: Check explicitly
process() {
  local result
  if ! result=$(failing_command); then
    echo "Command failed" >&2
    return 1
  fi
  echo "$result"
}
```

**Pattern for retrying failures:**

```bash
#!/bin/bash
retry() {
  local max_attempts=$1
  local delay=$2
  shift 2
  local attempt=1

  until "$@"; do
    if ((attempt >= max_attempts)); then
      echo "Failed after $attempt attempts" >&2
      return 1
    fi
    echo "Attempt $attempt failed. Retrying in ${delay}s..." >&2
    sleep "$delay"
    ((attempt++))
  done
}

# Usage
retry 3 5 curl -f http://example.com/api
```

Reference: [ShellCheck SC2155](https://www.shellcheck.net/wiki/SC2155)
