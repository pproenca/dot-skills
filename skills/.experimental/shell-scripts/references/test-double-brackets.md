---
title: Use [[ ]] for Tests in Bash
impact: MEDIUM
impactDescription: prevents word splitting and enables regex
tags: test, conditionals, double-brackets, bash
---

## Use [[ ]] for Tests in Bash

In bash scripts, `[[ ]]` is safer than `[ ]`: no word splitting on variables, supports `&&`/`||` inside, regex matching, and better error messages.

**Incorrect (single brackets with issues):**

```bash
#!/bin/bash
file="my file.txt"

# Word splitting breaks this
if [ -f $file ]; then     # Error: too many arguments
  echo "exists"
fi

# Empty variable causes error
if [ $unset == "value" ]; then  # Error: unary operator expected
  echo "match"
fi

# Can't use && inside [ ]
if [ -f "$file" && -r "$file" ]; then  # Syntax error
  echo "readable"
fi
```

**Correct (double brackets):**

```bash
#!/bin/bash
file="my file.txt"

# No word splitting inside [[ ]]
if [[ -f $file ]]; then   # Works! (but still quote for clarity)
  echo "exists"
fi

# Empty/unset variables are safe
if [[ $unset == "value" ]]; then  # Works, evaluates to false
  echo "match"
fi

# Logical operators inside [[ ]]
if [[ -f "$file" && -r "$file" ]]; then  # Works!
  echo "readable"
fi

# Regex matching
if [[ "$email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
  echo "Valid email format"
fi

# Pattern matching (without quotes on right side)
if [[ "$file" == *.txt ]]; then
  echo "Text file"
fi
```

**Single bracket use cases:**

```bash
#!/bin/bash
# Use [ ] only when:

# 1. POSIX compliance required (#!/bin/sh)
#!/bin/sh
if [ -f "$file" ]; then
  echo "exists"
fi

# 2. Combining with -a and -o (though avoid these)
# Prefer: [ cond1 ] && [ cond2 ]
# Over:   [ cond1 -a cond2 ]
```

**Pattern vs literal matching:**

```bash
#!/bin/bash
var="hello.txt"

# Pattern matching (unquoted right side)
[[ "$var" == *.txt ]]   # True - pattern match
[[ "$var" == "*.txt" ]] # False - literal match

# Regex matching
[[ "$var" =~ \.txt$ ]]  # True - regex match

# Common patterns
[[ "$str" == *substring* ]]  # Contains
[[ "$str" == prefix* ]]      # Starts with
[[ "$str" == *suffix ]]      # Ends with
```

**Test operators reference:**

```bash
#!/bin/bash
# String tests
[[ -z "$var" ]]           # Empty string
[[ -n "$var" ]]           # Non-empty string
[[ "$a" == "$b" ]]        # String equality
[[ "$a" != "$b" ]]        # String inequality
[[ "$a" < "$b" ]]         # String comparison (alphabetical)

# File tests
[[ -f "$file" ]]          # Regular file exists
[[ -d "$dir" ]]           # Directory exists
[[ -e "$path" ]]          # Exists (any type)
[[ -r "$file" ]]          # Readable
[[ -w "$file" ]]          # Writable
[[ -x "$file" ]]          # Executable
[[ -s "$file" ]]          # Non-empty file
[[ "$f1" -nt "$f2" ]]     # f1 newer than f2

# Numeric comparison (use (( )) instead for clarity)
[[ "$a" -eq "$b" ]]       # Equal
[[ "$a" -lt "$b" ]]       # Less than
```

Reference: [Google Shell Style Guide - Test](https://google.github.io/styleguide/shellguide.html)
