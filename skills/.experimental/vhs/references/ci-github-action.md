---
title: Use Official VHS GitHub Action
impact: MEDIUM
impactDescription: simplifies CI setup and ensures compatibility
tags: ci, github, actions, automation
---

## Use Official VHS GitHub Action

Use the official `charmbracelet/vhs-action` for GitHub Actions instead of manually installing VHS. The action handles dependencies, caching, and updates automatically.

**Incorrect (manual installation):**

```yaml
# .github/workflows/demo.yml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y ffmpeg
          go install github.com/charmbracelet/vhs@latest
      - name: Generate demo
        run: vhs demo.tape
# Complex, error-prone, slow
```

**Correct (using official action):**

```yaml
# .github/workflows/demo.yml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: charmbracelet/vhs-action@v2
        with:
          path: demo.tape
```

**With additional options:**

```yaml
- uses: charmbracelet/vhs-action@v2
  with:
    path: demo.tape
    version: latest
    install-fonts: true  # Adds extra font support
```

Reference: [VHS GitHub Action](https://github.com/charmbracelet/vhs-action)
