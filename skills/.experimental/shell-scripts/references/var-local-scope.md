---
title: Use local for Function Variables
impact: HIGH
impactDescription: prevents namespace pollution and hidden bugs
tags: var, local, scope, functions, namespace
---

## Use local for Function Variables

Variables in functions are global by default. Without `local`, functions can accidentally overwrite caller variables, creating mysterious bugs that are hard to trace.

**Incorrect (global variables leak):**

```bash
#!/bin/bash
result=""

process() {
  result="processing"  # Overwrites global!
  for i in 1 2 3; do   # Global 'i'
    echo "$i"
  done
}

main() {
  result="initial"
  for i in a b c; do
    process
    echo "i is now: $i"  # Prints "3", not "a", "b", "c"!
  done
  echo "Result: $result"  # "processing", not "initial"
}
```

**Correct (use local):**

```bash
#!/bin/bash
process() {
  local result="processing"  # Scoped to function
  local i
  for i in 1 2 3; do
    echo "$i"
  done
  echo "$result"
}

main() {
  local result="initial"
  local i
  for i in a b c; do
    process
    echo "i is: $i"  # Correctly prints "a", "b", "c"
  done
  echo "Result: $result"  # "initial"
}
```

**Declare local variables at function start:**

```bash
#!/bin/bash
process_file() {
  # Declare all local variables at top
  local file="$1"
  local line_count
  local word_count
  local result

  # Now use them
  line_count=$(wc -l < "$file")
  word_count=$(wc -w < "$file")

  # Separate declaration from command substitution
  # to preserve exit status
  result=$(process "$file") || return 1

  echo "Lines: $line_count, Words: $word_count"
}
```

**Note: local masks exit status:**

```bash
#!/bin/bash
# WRONG: Exit status lost
bad_function() {
  local result=$(failing_command)  # Status masked!
  echo $?  # Always 0
}

# CORRECT: Separate declaration
good_function() {
  local result
  result=$(failing_command)
  echo $?  # Actual exit status
}
```

**Use declare -g for intentional globals:**

```bash
#!/bin/bash
# When you need a function to set a global
setup_config() {
  declare -g CONFIG_PATH="/etc/myapp"
  declare -g CONFIG_FILE="$CONFIG_PATH/config.ini"
}

setup_config
echo "$CONFIG_PATH"  # Accessible
```

Reference: [Google Shell Style Guide - Local Variables](https://google.github.io/styleguide/shellguide.html)
