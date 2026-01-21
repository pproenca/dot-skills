---
title: Use ShellCheck for Static Analysis
impact: LOW
impactDescription: catches bugs before runtime
tags: style, shellcheck, linting, static-analysis
---

## Use ShellCheck for Static Analysis

ShellCheck detects common bugs, style issues, and portability problems that are easy to miss in review. Integrate it into CI and use it during development.

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
shellcheck script.sh

# Check multiple files
shellcheck scripts/*.sh

# Specify shell dialect
shellcheck --shell=bash script.sh
shellcheck --shell=sh script.sh

# Output formats
shellcheck --format=gcc script.sh     # GCC-style for editors
shellcheck --format=json script.sh    # Machine-readable
shellcheck --format=checkstyle script.sh  # CI integration

# Severity filter
shellcheck --severity=warning script.sh  # Skip style/info
```

**Directive comments:**

```bash
#!/bin/bash
# Disable specific check for next line
# shellcheck disable=SC2086
echo $unquoted_var  # Intentionally unquoted

# Disable for entire file (at top)
# shellcheck disable=SC2034,SC2154

# Enable optional checks
# shellcheck enable=require-variable-braces

# Explain why check is disabled
# shellcheck disable=SC2029
# Intentional remote expansion: $REMOTE_VAR is expanded on server
ssh server "echo $REMOTE_VAR"
```

**Common ShellCheck warnings:**

```bash
#!/bin/bash
# SC2086: Double quote to prevent globbing and word splitting
echo $var      # Warning
echo "$var"    # OK

# SC2046: Quote to prevent word splitting
files=$(find .)  # Warning
# shellcheck disable=SC2046 (if intentional)

# SC2034: Variable appears unused
unused_var=1   # Warning (typo? dead code?)

# SC2155: Declare and assign separately
local var=$(cmd)  # Warning: exit status lost
local var         # OK
var=$(cmd)        # OK

# SC2164: Use cd ... || exit
cd /dir          # Warning
cd /dir || exit  # OK

# SC2006: Use $() instead of backticks
var=`cmd`        # Warning
var=$(cmd)       # OK
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

```bash
# Pre-commit hook
#!/bin/bash
# .git/hooks/pre-commit
files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$')
if [[ -n "$files" ]]; then
  shellcheck $files || exit 1
fi
```

**Editor integration:**

```bash
# VS Code: Install "ShellCheck" extension
# Vim: Use ALE or Syntastic
# Neovim: Use null-ls or nvim-lint
# Emacs: Use flycheck-mode
```

**ShellCheck in Makefiles:**

```makefile
SHELL_FILES := $(shell find . -name '*.sh')

.PHONY: lint
lint:
	shellcheck $(SHELL_FILES)

.PHONY: lint-fix
lint-fix:
	shellcheck --format=diff $(SHELL_FILES) | patch -p1
```

Reference: [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki)
