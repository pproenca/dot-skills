---
title: Quote Command Substitutions
impact: MEDIUM-HIGH
impactDescription: prevents word splitting of command output
tags: quote, command-substitution, word-splitting, output
---

## Quote Command Substitutions

Command substitution output undergoes word splitting and glob expansion like variables. A command returning "my file.txt" becomes two words when unquoted.

**Incorrect (unquoted command substitution):**

```bash
#!/bin/bash
# Output with spaces is split
file=$(find_first_file)   # Returns "my file.txt"
rm $file                  # Tries to rm "my" and "file.txt"

# Glob patterns in output expand
pattern_cmd=$(get_pattern)  # Returns "*.log"
echo $pattern_cmd           # Expands to all .log files!

# Nested substitution issues
result=$(process $(get_input))  # Inner output may split
```

**Correct (quoted command substitution):**

```bash
#!/bin/bash
# Quote the result
file=$(find_first_file)
rm "$file"                # Correctly handles "my file.txt"

# Preserves literal patterns
pattern_cmd=$(get_pattern)
echo "$pattern_cmd"       # Prints "*.log" literally

# Nested - quote inner too
result=$(process "$(get_input)")
```

**$() vs backticks:**

```bash
#!/bin/bash
# Prefer $() over backticks for readability and nesting
# INCORRECT (hard to read and nest)
result=`command \`nested\``

# CORRECT (clear nesting)
result=$(command "$(nested)")

# Complex nesting is clear with $()
value=$(echo "$(cat "$(find_config)")")
```

**Common patterns:**

```bash
#!/bin/bash
# Assign to variable (quotes on use, not assignment)
output=$(my_command)
echo "$output"

# Direct use in arguments
grep "pattern" "$(get_filename)"

# In conditionals
if [[ "$(get_status)" == "ready" ]]; then
  proceed
fi

# Capturing exit status
output=$(my_command)
status=$?  # Get status IMMEDIATELY after

# When you want splitting (rare, document it)
# shellcheck disable=SC2046
set -- $(get_list)  # Intentionally split into positional args
```

**Handle empty output:**

```bash
#!/bin/bash
# Check for empty result
result=$(find_something)
if [[ -z "$result" ]]; then
  echo "Nothing found" >&2
  exit 1
fi

# Or use default
result=$(find_something)
: "${result:=default_value}"
```

Reference: [ShellCheck SC2046](https://www.shellcheck.net/wiki/SC2046)
