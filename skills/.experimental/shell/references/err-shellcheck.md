---
title: Use ShellCheck for Static Analysis
impact: HIGH
impactDescription: catches 80%+ of quoting, error handling, and portability bugs before runtime
tags: err, shellcheck, linting, static-analysis, quality
---

## Use ShellCheck for Static Analysis

ShellCheck catches security vulnerabilities (unquoted variables), error handling bugs (masked exit status), and portability issues (bashisms in POSIX scripts). It enforces rules from nearly every category in this guide. Run it in CI and during development.

**Incorrect (no static analysis):**

```bash
#!/bin/bash
# Script ships with common bugs undetected
echo $unquoted_var    # Word splitting bug
local result=$(cmd)   # Exit status masked
cd /some/dir          # May fail silently
files=`find .`        # Deprecated syntax
```

**Correct (ShellCheck-validated code):**

```bash
#!/bin/bash
# ShellCheck catches these before they cause problems
echo "$unquoted_var"       # SC2086 fixed
local result
result=$(cmd)              # SC2155 fixed
cd /some/dir || exit 1     # SC2164 fixed
files=$(find .)            # SC2006 fixed
```

**Run ShellCheck:**

```bash
# Basic usage
shellcheck deploy.sh

# Check multiple files
shellcheck scripts/*.sh

# Specify shell dialect
shellcheck --shell=bash deploy.sh
shellcheck --shell=sh install.sh

# Output formats for CI
shellcheck --format=gcc deploy.sh        # GCC-style for editors
shellcheck --format=json deploy.sh       # Machine-readable
shellcheck --format=checkstyle deploy.sh # CI integration

# Severity filter
shellcheck --severity=warning deploy.sh  # Skip style/info
```

**Directive comments:**

```bash
#!/bin/bash
# Disable specific check for next line
# shellcheck disable=SC2086
echo $intentionally_unquoted  # Documented exception

# Disable for entire file (at top)
# shellcheck disable=SC2034,SC2154

# Enable optional checks
# shellcheck enable=require-variable-braces

# Always explain why a check is disabled
# shellcheck disable=SC2029
# Intentional remote expansion: DEPLOY_ENV is expanded on server
ssh "$deploy_host" "echo $DEPLOY_ENV"
```

**Common ShellCheck warnings:**

```bash
#!/bin/bash
# SC2086: Double quote to prevent globbing and word splitting
echo $var      # Warning
echo "$var"    # OK

# SC2155: Declare and assign separately
local config=$(cmd)  # Warning: exit status lost
local config         # OK
config=$(cmd)        # OK

# SC2164: Use cd ... || exit
cd /deploy/dir          # Warning
cd /deploy/dir || exit  # OK

# SC2006: Use $() instead of backticks
tag=`git describe`   # Warning
tag=$(git describe)  # OK
```

**CI integration:**

```yaml
# GitHub Actions
name: Lint
on: [push, pull_request]
jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run ShellCheck
        uses: ludeeus/action-shellcheck@master
        with:
          severity: warning
```

**Pre-commit hook:**

```bash
#!/bin/bash
# .git/hooks/pre-commit
changed_scripts=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$')
if [[ -n "$changed_scripts" ]]; then
  shellcheck $changed_scripts || exit 1
fi
```

Reference: [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki)
