---
title: Auto-Commit Generated Assets
impact: MEDIUM
impactDescription: keeps documentation synchronized automatically
tags: ci, github, auto-commit, automation
---

## Auto-Commit Generated Assets

Configure your workflow to automatically commit generated GIFs back to the repository. This keeps demos synchronized with code changes without manual intervention.

**Incorrect (manual GIF updates):**

```yaml
# Generate but don't commit—requires manual download and commit
- uses: charmbracelet/vhs-action@v2
  with:
    path: demo.tape
```

**Correct (auto-commit generated files):**

```yaml
name: Generate Demo GIF

on:
  push:
    paths:
      - 'src/**'
      - 'demo.tape'

jobs:
  demo:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: charmbracelet/vhs-action@v2
        with:
          path: demo.tape

      - name: Commit generated GIF
        uses: stefanzweifel/git-auto-commit-action@v5
        with:
          commit_message: "chore: update demo GIF"
          file_pattern: "*.gif *.mp4 *.webm"
```

**Trigger on relevant changes only:**

```yaml
on:
  push:
    paths:
      - 'src/**'         # Source code changes
      - 'demo.tape'      # Tape file changes
      - '.github/workflows/demo.yml'
```

Reference: [VHS GitHub Action](https://github.com/charmbracelet/vhs-action)
