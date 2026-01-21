---
title: Use Portable Export Syntax
impact: CRITICAL
impactDescription: prevents failures on strict POSIX shells
tags: port, export, environment, variables, posix
---

## Use Portable Export Syntax

The `export VAR=value` syntax is a bashism. POSIX requires separate assignment and export statements. Some shells and older systems don't support combined syntax.

**Incorrect (combined export and assignment):**

```sh
#!/bin/sh
# Not portable - fails on some systems
export PATH="/usr/local/bin:$PATH"
export CONFIG_FILE=/etc/app.conf
export DEBUG=1 VERBOSE=1

# local with assignment is also non-portable
my_func() {
  local result=$(some_command)  # Masks exit status
}
```

**Correct (separate assignment and export):**

```sh
#!/bin/sh
# POSIX-compliant - works everywhere
PATH="/usr/local/bin:$PATH"
export PATH

CONFIG_FILE=/etc/app.conf
export CONFIG_FILE

DEBUG=1
VERBOSE=1
export DEBUG VERBOSE
```

**Correct (function local variables):**

```sh
#!/bin/sh
my_func() {
  local result
  result=$(some_command)
  local status=$?  # Capture exit status

  if [ "$status" -ne 0 ]; then
    return "$status"
  fi
  echo "$result"
}
```

**Note on local:**

```bash
# In bash, combined local+assignment masks exit status:
my_func() {
  local result=$(failing_command)  # Exit status lost!
  echo "Status: $?"                # Always 0 (local succeeded)
}

# Separate them to preserve exit status:
my_func() {
  local result
  result=$(failing_command)
  echo "Status: $?"                # Shows actual exit status
}
```

Reference: [ShellCheck SC2155](https://www.shellcheck.net/wiki/SC2155)
