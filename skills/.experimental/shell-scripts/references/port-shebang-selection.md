---
title: Choose Shebang Based on Portability Needs
impact: CRITICAL
impactDescription: determines script compatibility across systems
tags: port, shebang, posix, bash, compatibility
---

## Choose Shebang Based on Portability Needs

The shebang line determines which interpreter runs your script. Using `#!/bin/sh` implies POSIX compliance, while `#!/bin/bash` enables bash-specific features but reduces portability.

**Incorrect (mismatched shebang and features):**

```bash
#!/bin/sh
# Uses bash-specific features with sh shebang
# Fails on systems where /bin/sh is dash, ash, or busybox

declare -a array=(one two three)  # bash-only
[[ $var == pattern ]]             # bash-only
echo "value is $((x + 1))"        # mostly portable
source ./config.sh                # bash-only (use . instead)
```

**Correct (match shebang to features used):**

```bash
#!/bin/bash
# Bash script - use bash-specific features freely
set -euo pipefail

declare -a files=()
while IFS= read -r -d '' file; do
  files+=("$file")
done < <(find . -type f -print0)

if [[ "${#files[@]}" -gt 0 ]]; then
  process_files "${files[@]}"
fi
```

**Correct (POSIX-compliant script):**

```sh
#!/bin/sh
# POSIX script - avoid bashisms for maximum portability
set -eu

# Use . instead of source
. ./config.sh

# Use [ ] instead of [[ ]]
if [ -n "$var" ]; then
  echo "var is set"
fi

# No arrays - use positional parameters or files
set -- one two three
for item in "$@"; do
  echo "$item"
done
```

**Decision guide:**
- `#!/bin/bash` - Complex scripts, arrays, `[[ ]]`, process substitution
- `#!/bin/sh` - Simple scripts, containers, embedded systems, CI pipelines
- `#!/usr/bin/env bash` - When bash location varies (macOS vs Linux)

Reference: [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
