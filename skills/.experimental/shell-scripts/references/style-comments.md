---
title: Write Useful Comments
impact: LOW
impactDescription: explains why, not what
tags: style, comments, documentation
---

## Write Useful Comments

Comments that repeat the code add noise. Good comments explain why something is done, document non-obvious behavior, and mark incomplete work.

**Incorrect (useless comments):**

```bash
#!/bin/bash
# Increment counter
((counter++))

# Check if file exists
if [[ -f "$file" ]]; then
  # Read the file
  content=$(<"$file")
fi

# Loop through items
for item in "${items[@]}"; do
  # Process item
  process "$item"
done
```

**Correct (useful comments):**

```bash
#!/bin/bash
# Retry count starts at 1 because the initial attempt isn't a "retry"
((counter++))

# Legacy systems create zero-byte marker files; treat as non-existent
if [[ -f "$file" && -s "$file" ]]; then
  content=$(<"$file")
fi

# Process in reverse order to handle dependencies correctly
# (items may reference later items in the array)
for ((i = ${#items[@]} - 1; i >= 0; i--)); do
  process "${items[i]}"
done
```

**Comment types:**

```bash
#!/bin/bash

# TODO(username): Implement retry logic for network failures (issue #123)
# FIXME: This workaround breaks on filenames with newlines
# HACK: Temporary fix until upstream patches the library
# NOTE: This assumes UTC timezone; local time will break calculations

# Explain non-obvious code
# The seemingly redundant `|| true` prevents errexit from triggering
# on expected "file not found" errors from grep
grep "pattern" file.txt || true

# Document magic numbers
readonly MAX_CONNECTIONS=100  # Limit from database license
readonly TIMEOUT_MS=30000     # Match nginx upstream timeout

# Explain regex patterns
# Pattern matches: user@domain.tld (basic email validation)
if [[ "$email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
  valid=true
fi
```

**When to comment:**

```bash
#!/bin/bash
# DO comment:
# - Why a non-obvious approach was chosen
# - Workarounds for bugs or limitations
# - Performance considerations
# - Security implications
# - External dependencies or assumptions
# - Complex regex or parameter expansion

# DON'T comment:
# - What the code literally does (read the code)
# - Every function or variable
# - Obvious operations
```

**Inline vs block comments:**

```bash
#!/bin/bash
# Block comment for multi-line explanation
# This function implements exponential backoff because the API
# rate-limits aggressive callers. The jitter prevents thundering
# herd problems when multiple instances retry simultaneously.
retry_with_backoff() {
  # ...
}

# Inline comment for single clarification
readonly BATCH_SIZE=1000  # Matches API page size limit
```

**Disabled code:**

```bash
#!/bin/bash
# Don't leave commented-out code without explanation
# BAD:
# old_function "$arg"
# new_function "$arg"

# GOOD: Remove old code entirely, use version control
new_function "$arg"

# Or if needed, explain why it's kept:
# Disabled pending migration to new API (tracking: PROJECT-456)
# old_function "$arg"
```

Reference: [Google Shell Style Guide - Comments](https://google.github.io/styleguide/shellguide.html)
