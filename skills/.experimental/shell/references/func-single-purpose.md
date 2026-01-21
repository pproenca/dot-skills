---
title: Write Single-Purpose Functions
impact: MEDIUM
impactDescription: improves testability and reusability
tags: func, design, single-responsibility, modularity
---

## Write Single-Purpose Functions

Functions that do multiple things are hard to test, reuse, and debug. Each function should do one thing well and compose with others for complex operations.

**Incorrect (multi-purpose function):**

```bash
#!/bin/bash
# Does too many things: parse args, validate, process, output
process_file() {
  local file="$1"
  local verbose="$2"
  local output="$3"

  # Validation
  if [[ ! -f "$file" ]]; then
    echo "Error: File not found" >&2
    return 1
  fi

  # Processing
  local result
  result=$(grep -c "pattern" "$file")

  # Output (mixed concerns)
  if [[ "$verbose" == "true" ]]; then
    echo "Processing $file..."
  fi

  if [[ -n "$output" ]]; then
    echo "$result" > "$output"
  else
    echo "$result"
  fi
}
```

**Correct (focused functions):**

```bash
#!/bin/bash
# Each function does one thing

validate_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Error: File not found: $file" >&2
    return 1
  fi
  if [[ ! -r "$file" ]]; then
    echo "Error: File not readable: $file" >&2
    return 1
  fi
}

count_pattern() {
  local file="$1"
  local pattern="$2"
  grep -c "$pattern" "$file"
}

log_verbose() {
  local message="$1"
  if [[ "${VERBOSE:-false}" == "true" ]]; then
    echo "$message" >&2
  fi
}

write_output() {
  local content="$1"
  local output_file="${2:-}"

  if [[ -n "$output_file" ]]; then
    echo "$content" > "$output_file"
  else
    echo "$content"
  fi
}

# Compose functions
process_file() {
  local file="$1"
  local pattern="${2:-pattern}"
  local output="${3:-}"

  validate_file "$file" || return 1
  log_verbose "Processing $file..."

  local result
  result=$(count_pattern "$file" "$pattern")
  write_output "$result" "$output"
}
```

**Function naming guidelines:**

```bash
#!/bin/bash
# Use verb_noun format
get_config()      # Retrieves something
set_option()      # Sets something
validate_input()  # Validates something
process_file()    # Processes something
check_status()    # Checks something

# Boolean functions: use is_, has_, can_, should_
is_valid()
has_permission()
can_write()
should_retry()

# Private/internal functions: prefix with underscore
_parse_internal()
_helper_function()
```

**Short functions are better:**

```bash
#!/bin/bash
# Aim for functions that fit on one screen (~20-30 lines)
# If longer, break into smaller functions

# Too long? Extract helpers:
process_all() {
  local -a files
  gather_files files
  validate_all files
  transform_all files
  output_results files
}
```

Reference: [Google Shell Style Guide - Function Comments](https://google.github.io/styleguide/shellguide.html)
