---
title: Use Explicit Empty/Non-empty String Tests
impact: MEDIUM
impactDescription: prevents misreads and silent failures
tags: test, strings, empty, explicit
---

## Use Explicit Empty/Non-empty String Tests

Implicit string tests like `[[ "$var" ]]` are ambiguous. Explicit `-z` (empty) and `-n` (non-empty) make intent clear and prevent bugs with special values.

**Incorrect (implicit tests):**

```bash
#!/bin/bash
# What does this test? Existence? Non-empty? Boolean?
if [[ "$var" ]]; then
  echo "true"  # When exactly?
fi

# Empty vs unset confusion
if [[ $var ]]; then     # False for both unset and empty
  echo "has value"
fi

# String "false" is truthy!
flag="false"
if [[ "$flag" ]]; then
  echo "truthy"  # Prints! "false" is a non-empty string
fi
```

**Correct (explicit tests):**

```bash
#!/bin/bash
# Explicit empty check
if [[ -z "$var" ]]; then
  echo "var is empty or unset"
fi

# Explicit non-empty check
if [[ -n "$var" ]]; then
  echo "var has a value"
fi

# Boolean values - compare explicitly
flag="false"
if [[ "$flag" == "true" ]]; then
  echo "flag is true"
fi

# Or use true/false commands
is_enabled=true
if "$is_enabled"; then   # Runs the command 'true'
  echo "enabled"
fi
```

**Common patterns:**

```bash
#!/bin/bash
# Check before using
input="$1"
if [[ -z "$input" ]]; then
  echo "Error: Input required" >&2
  exit 1
fi

# Default if empty
config="${CONFIG:-}"
if [[ -z "$config" ]]; then
  config="/etc/default.conf"
fi

# Or use parameter expansion
config="${CONFIG:-/etc/default.conf}"
```

**Testing for set vs unset:**

```bash
#!/bin/bash
# -z doesn't distinguish unset from empty
unset var1
var2=""

[[ -z "$var1" ]]  # True (unset)
[[ -z "$var2" ]]  # True (empty)

# To distinguish, use parameter expansion
if [[ -z "${var+x}" ]]; then
  echo "var is unset"
fi

if [[ -z "${var-}" ]]; then
  echo "var is unset or empty"
fi

# Or with set -u active:
if [[ "${var:-}" == "" ]]; then
  echo "var is unset or empty (safe with set -u)"
fi
```

**Boolean patterns:**

```bash
#!/bin/bash
# Pattern 1: String comparison
verbose="true"
if [[ "$verbose" == "true" ]]; then
  set -x
fi

# Pattern 2: Command-based (true/false are builtins)
enabled=true  # No quotes - this is the command name
if $enabled; then
  echo "Enabled"
fi

# Pattern 3: Integer (0=false, non-zero=true)
debug=1
if (( debug )); then
  echo "Debug mode"
fi
```

**Avoid double-negative:**

```bash
#!/bin/bash
# Hard to read
if [[ ! -z "$var" ]]; then
  echo "not empty"  # Double negative
fi

# Clear
if [[ -n "$var" ]]; then
  echo "has value"
fi
```

Reference: [Google Shell Style Guide - Testing Strings](https://google.github.io/styleguide/shellguide.html)
