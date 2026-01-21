---
title: Use printf Instead of echo for Portability
impact: CRITICAL
impactDescription: ensures consistent output across all systems
tags: port, printf, echo, output, compatibility
---

## Use printf Instead of echo for Portability

`echo` behavior varies across shells and systems. Some interpret `-n`, `-e` flags; others print them literally. `printf` is standardized and behaves consistently everywhere.

**Incorrect (echo with non-portable options):**

```bash
#!/bin/sh
# Behavior varies by system:
echo -n "Enter name: "      # Some shells print "-n "
echo -e "line1\nline2"      # Some shells print "-e line1\nline2"
echo "Path: $PATH"          # Some echo versions expand backslashes

# Even without flags, echo is problematic:
echo "$var"                 # If var="-n", output is blank
```

**Correct (printf is consistent):**

```sh
#!/bin/sh
# printf works the same everywhere:
printf "Enter name: "       # No trailing newline
printf "line1\nline2\n"     # Escapes always interpreted
printf "Path: %s\n" "$PATH" # Safe with any content

# Safe with arbitrary data:
printf "%s\n" "$var"        # Works even if var="-n"
printf "%s" "$var"          # No trailing newline
```

**printf format specifiers:**

```sh
#!/bin/sh
name="Alice"
count=42
price=19.99

# String interpolation
printf "User: %s\n" "$name"

# Integer formatting
printf "Count: %d items\n" "$count"

# Floating point
printf "Price: %.2f\n" "$price"

# Multiple arguments
printf "%s has %d items\n" "$name" "$count"

# Width and padding
printf "%-10s %5d\n" "$name" "$count"
```

**When echo is acceptable:**
- Bash-only scripts (`#!/bin/bash`)
- Simple strings without variables
- No special characters or flags needed
- Performance-critical loops (echo is slightly faster)

Reference: [Rich's POSIX sh tricks](http://www.etalabs.net/sh_tricks.html)
