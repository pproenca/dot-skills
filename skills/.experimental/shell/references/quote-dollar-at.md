---
title: Use "$@" for Argument Passing
impact: MEDIUM-HIGH
impactDescription: preserves arguments with spaces correctly
tags: quote, arguments, dollar-at, dollar-star
---

## Use "$@" for Argument Passing

`$*` joins all arguments into a single string. `$@` unquoted splits on spaces. Only `"$@"` preserves argument boundaries, handling spaces and special characters correctly.

**Incorrect (using $* or unquoted $@):**

```bash
#!/bin/bash
# $* joins everything into one argument
wrapper() {
  my_command $*  # "arg with space" becomes three args
}
wrapper "arg with space" second

# Unquoted $@ also splits
wrapper() {
  my_command $@  # Same problem
}

# "$*" joins with IFS
wrapper() {
  my_command "$*"  # All args become ONE argument
}
wrapper one two three  # my_command receives "one two three"
```

**Correct (use "$@"):**

```bash
#!/bin/bash
# "$@" preserves each argument exactly
wrapper() {
  my_command "$@"  # Arguments passed through correctly
}
wrapper "arg with space" second  # Two args: "arg with space", "second"

# Iterate over arguments
process_all() {
  for arg in "$@"; do
    echo "Processing: $arg"
  done
}
process_all "file one.txt" "file two.txt"  # Two iterations
```

**Common patterns:**

```bash
#!/bin/bash
# Pass all arguments to another command
exec_wrapper() {
  exec "$@"
}

# Add arguments before/after
run_with_prefix() {
  local prefix="$1"
  shift
  echo "$prefix: $*"
  command "$@"
}

# Filter arguments
run_verbose() {
  local verbose=false
  local -a args=()

  for arg in "$@"; do
    case "$arg" in
      -v|--verbose) verbose=true ;;
      *) args+=("$arg") ;;
    esac
  done

  if [[ "$verbose" == true ]]; then
    set -x
  fi
  my_command "${args[@]}"
}
```

**Using shift with arguments:**

```bash
#!/bin/bash
process() {
  local first="$1"
  shift  # Remove first argument

  echo "First: $first"
  echo "Remaining: $@"

  # Pass remaining to another command
  sub_command "$@"
}
```

**Difference summary:**

| Syntax | Result |
|--------|--------|
| `$*` | All args as separate words (split on spaces) |
| `$@` | Same as $* |
| `"$*"` | All args as ONE string, joined by first char of IFS |
| `"$@"` | Each arg as separate quoted string (preserves spaces) |

Reference: [Google Shell Style Guide - Quoting](https://google.github.io/styleguide/shellguide.html)
