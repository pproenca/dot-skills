---
title: Use Return Values Correctly
impact: MEDIUM
impactDescription: enables proper error propagation and testing
tags: func, return, exit-status, output
---

## Use Return Values Correctly

Functions communicate results via exit status (return code) and stdout. Mixing status and output or ignoring return values causes silent failures.

**Incorrect (mixed output and status):**

```bash
#!/bin/bash
# Returns data AND error message on same channel
get_value() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Error: File not found"  # Goes to stdout!
    return 1
  fi
  cat "$file"
}

# Caller gets error message as data
value=$(get_value missing.txt)
echo "Value: $value"  # Prints "Value: Error: File not found"
```

**Correct (separate status and output):**

```bash
#!/bin/bash
# Status via return, errors to stderr, data to stdout
get_value() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Error: File not found: $file" >&2  # stderr
    return 1  # Non-zero status
  fi
  cat "$file"  # stdout
}

# Caller checks status and captures output
if value=$(get_value missing.txt); then
  echo "Value: $value"
else
  echo "Failed to get value" >&2
fi
```

**Return values for different scenarios:**

```bash
#!/bin/bash
# Boolean check - use return directly
is_valid_email() {
  local email="$1"
  [[ "$email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]
  # Return status of [[ ]] implicitly
}

if is_valid_email "$input"; then
  echo "Valid"
fi

# Computation - output to stdout
calculate_sum() {
  local a="$1"
  local b="$2"
  echo "$((a + b))"
}

result=$(calculate_sum 5 3)

# Multiple outputs - use arrays or delimiter
get_file_info() {
  local file="$1"
  local size name
  size=$(stat -f%z "$file" 2>/dev/null) || return 1
  name=$(basename "$file")
  echo "$size:$name"  # Colon-separated
}

# Read multiple values
IFS=: read -r size name < <(get_file_info "/path/to/file")
```

**Preserve exit status:**

```bash
#!/bin/bash
# Exit status is lost after any command
run_and_log() {
  local result
  result=$(some_command)
  local status=$?  # Capture IMMEDIATELY

  echo "Result: $result" >> log.txt
  return "$status"  # Propagate original status
}

# Or use || for error handling
run_safely() {
  some_command || {
    local status=$?
    echo "Failed with status $status" >&2
    return "$status"
  }
}
```

**Avoid return with command output:**

```bash
#!/bin/bash
# WRONG: return with command output
bad_function() {
  return $(some_command)  # Word splitting issues!
}

# CORRECT: Store in variable first
good_function() {
  local status
  some_command
  status=$?
  return "$status"
}

# CORRECT: Implicit return of last command
simple_function() {
  some_command
  # Exit status of some_command is returned
}
```

Reference: [Google Shell Style Guide - Calling Functions](https://google.github.io/styleguide/shellguide.html)
