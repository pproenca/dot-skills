---
title: Avoid Bashisms in POSIX Scripts
impact: CRITICAL
impactDescription: prevents failures on dash/ash/busybox systems
tags: port, bashisms, posix, dash, compatibility
---

## Avoid Bashisms in POSIX Scripts

Scripts with `#!/bin/sh` shebang must avoid bash-specific features. On Ubuntu/Debian, `/bin/sh` is dash; on Alpine/BusyBox, it's ash. Bashisms cause silent failures or syntax errors.

**Incorrect (bashisms in /bin/sh script):**

```sh
#!/bin/sh
# These fail on dash/ash:

# Arrays don't exist
files=(one two three)

# [[ ]] is bash-only
[[ -f "$file" ]]

# source is bash-only
source ./lib.sh

# &> redirection is bash-only
command &> /dev/null

# Process substitution is bash-only
diff <(cmd1) <(cmd2)

# echo -e is not portable
echo -e "line1\nline2"
```

**Correct (POSIX-compliant alternatives):**

```sh
#!/bin/sh
# POSIX equivalents:

# Use positional parameters or newline-separated strings
set -- one two three
for file in "$@"; do echo "$file"; done

# Use [ ] single brackets
[ -f "$file" ]

# Use . (dot) instead of source
. ./lib.sh

# Use explicit redirections
command > /dev/null 2>&1

# Use temp files or pipes instead of process substitution
cmd1 > /tmp/out1.$$
cmd2 > /tmp/out2.$$
diff /tmp/out1.$$ /tmp/out2.$$

# Use printf instead of echo -e
printf 'line1\nline2\n'
```

**Common bashisms to avoid:**
| Bashism | POSIX Alternative |
|---------|------------------|
| `[[ ]]` | `[ ]` with proper quoting |
| `source` | `. ` (dot space) |
| `&>` | `> file 2>&1` |
| `$'...'` | `printf` |
| `array=()` | positional parameters |
| `${var,,}` | `tr '[:upper:]' '[:lower:]'` |
| `{1..10}` | `seq 1 10` |

Reference: [ShellCheck SC2039](https://www.shellcheck.net/wiki/SC2039)
