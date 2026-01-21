---
title: Prevent Argument Injection with Double Dash
impact: CRITICAL
impactDescription: prevents options interpreted as filenames
tags: safety, arguments, injection, double-dash
---

## Prevent Argument Injection with Double Dash

Filenames starting with `-` are interpreted as command options. User-controlled filenames can inject flags that change command behavior, enabling attacks without shell metacharacters.

**Incorrect (filename interpreted as option):**

```bash
#!/bin/bash
filename="$1"
# User passes "-rf" as filename
# rm interprets it as options, not a file
rm $filename

# User passes "--help" → leaks command info
cat $filename

# User passes "-e /etc/shadow" → reads sensitive file
grep "pattern" $filename
```

**Correct (use -- to end option parsing):**

```bash
#!/bin/bash
filename="$1"

# -- signals end of options; everything after is an operand
rm -- "$filename"
cat -- "$filename"
grep -- "pattern" "$filename"

# Or use ./ prefix for current directory files
rm "./$filename"
```

**Correct (for wildcards/globs):**

```bash
#!/bin/bash
# DANGEROUS: * might expand to files starting with -
rm *

# SAFE: Explicit path prefix
rm ./*

# SAFE: Use -- before glob
rm -- *
```

**Commands that need -- protection:**
- `rm`, `cp`, `mv`, `cat`, `grep`, `sed`, `awk`
- `git`, `docker`, `kubectl` (most CLI tools)
- Any command that accepts filenames and options

Reference: [ShellCheck SC2035](https://www.shellcheck.net/wiki/SC2035)
