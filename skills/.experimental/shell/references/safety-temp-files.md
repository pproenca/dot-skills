---
title: Create Secure Temporary Files
impact: CRITICAL
impactDescription: prevents symlink attacks and race conditions
tags: safety, temporary-files, security, mktemp
---

## Create Secure Temporary Files

Predictable temporary file names enable symlink attacks where attackers create links to sensitive files. Race conditions between checking and creating files can be exploited.

**Incorrect (predictable temp file):**

```bash
#!/bin/bash
# DANGEROUS: Predictable name, race condition
tmpfile="/tmp/myapp.$$"

# Attacker creates: ln -s /etc/passwd /tmp/myapp.1234
# Before this runs, overwriting /etc/passwd
echo "data" > "$tmpfile"
```

**Correct (use mktemp):**

```bash
#!/bin/bash
# mktemp creates file with secure permissions atomically
tmpfile=$(mktemp) || exit 1
tmpdir=$(mktemp -d) || exit 1

# Use trap to clean up on exit
trap 'rm -rf "$tmpfile" "$tmpdir"' EXIT

echo "data" > "$tmpfile"
```

**Alternative (template with mktemp):**

```bash
#!/bin/bash
# Use template for readable names (X's are replaced)
tmpfile=$(mktemp /tmp/myapp.XXXXXX) || exit 1
tmpdir=$(mktemp -d /tmp/myapp.XXXXXX) || exit 1

trap 'rm -rf "$tmpfile" "$tmpdir"' EXIT

# Secure: mktemp uses O_EXCL for atomic creation
# with mode 0600 (owner read/write only)
```

**Never do:**
- Use `$$` (PID) alone for temp names
- Create files in `/tmp` without `mktemp`
- Check existence then create (TOCTOU race)
- Forget cleanup on script exit

Reference: [ShellCheck SC2094](https://www.shellcheck.net/wiki/SC2094)
