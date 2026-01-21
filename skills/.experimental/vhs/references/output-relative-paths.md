---
title: Use Relative Paths for Portability
impact: MEDIUM
impactDescription: ensures tape files work across machines and CI
tags: output, paths, portability, ci
---

## Use Relative Paths for Portability

Use relative paths in `Output` commands to ensure tape files work on any machine. Output paths are relative to the current working directory when VHS runs, not the tape file location.

**Incorrect (absolute paths):**

```tape
Output /Users/developer/projects/myapp/docs/demo.gif
# Fails on other machines or CI
```

**Incorrect (assuming tape file directory):**

```tape
# In ./docs/demo.tape
Output demo.gif
# Outputs to CWD, not ./docs/
```

**Correct (relative paths from CWD):**

```tape
Output docs/demo.gif
Output assets/demo.mp4
```

**Run from project root:**

```bash
# From project root
vhs docs/demo.tape
# Output: ./docs/demo.gif (relative to CWD)
```

**For CI consistency:**

```yaml
# GitHub Actions
- name: Generate demo
  working-directory: ${{ github.workspace }}
  run: vhs docs/demo.tape
  # Outputs relative to workspace root
```

Reference: [VHS Issues - Output Paths](https://github.com/charmbracelet/vhs/issues/121)
