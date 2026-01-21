---
title: Use Portable Test Constructs
impact: CRITICAL
impactDescription: prevents silent logic failures across shells
tags: port, test, conditionals, posix, brackets
---

## Use Portable Test Constructs

`[[ ]]` is bash/ksh/zsh-only. POSIX shells only support `[ ]` (test). Using `[[ ]]` in `/bin/sh` scripts causes syntax errors or silent failures.

**Incorrect (bash-only tests in sh script):**

```sh
#!/bin/sh
# [[ ]] is not POSIX - fails on dash/ash
if [[ -f "$file" ]]; then
  echo "exists"
fi

# Regex matching is bash-only
if [[ "$input" =~ ^[0-9]+$ ]]; then
  echo "numeric"
fi

# Pattern matching without quotes is bash-only
if [[ $var == *.txt ]]; then
  echo "text file"
fi
```

**Correct (POSIX-compliant tests):**

```sh
#!/bin/sh
# Use [ ] with proper quoting
if [ -f "$file" ]; then
  echo "exists"
fi

# Use case for pattern matching (POSIX)
case "$input" in
  *[!0-9]*|"")
    echo "not numeric"
    ;;
  *)
    echo "numeric"
    ;;
esac

# Use case for glob patterns
case "$var" in
  *.txt)
    echo "text file"
    ;;
esac
```

**Test operator portability:**

```sh
#!/bin/sh
# These work in POSIX [ ]:
[ -f "$file" ]          # File exists and is regular
[ -d "$dir" ]           # Directory exists
[ -n "$var" ]           # String is non-empty
[ -z "$var" ]           # String is empty
[ "$a" = "$b" ]         # String equality (single =)
[ "$a" != "$b" ]        # String inequality
[ "$a" -eq "$b" ]       # Numeric equality
[ "$a" -lt "$b" ]       # Numeric less than
[ -r "$file" ]          # File is readable

# Combine with -a (and) and -o (or), or use separate [ ]:
[ -f "$file" ] && [ -r "$file" ]  # Preferred
```

Reference: [ShellCheck SC3010](https://www.shellcheck.net/wiki/SC3010)
