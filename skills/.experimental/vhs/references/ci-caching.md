---
title: Cache VHS Dependencies in CI
impact: LOW-MEDIUM
impactDescription: reduces CI run time by 30-60 seconds
tags: ci, caching, performance, optimization
---

## Cache VHS Dependencies in CI

When not using the official action, cache VHS and its dependencies to speed up CI runs. The official action handles this automatically.

**Incorrect (downloading every run):**

```yaml
steps:
  - name: Install VHS
    run: |
      go install github.com/charmbracelet/vhs@latest
  # Downloads Go and VHS every run
```

**Correct (with caching):**

```yaml
steps:
  - uses: actions/setup-go@v5
    with:
      go-version: '1.21'
      cache: true

  - name: Cache VHS binary
    uses: actions/cache@v4
    with:
      path: ~/go/bin/vhs
      key: vhs-${{ runner.os }}-${{ hashFiles('.vhs-version') }}

  - name: Install VHS
    run: |
      if [ ! -f ~/go/bin/vhs ]; then
        go install github.com/charmbracelet/vhs@latest
      fi
```

**Better approach—use official action:**

```yaml
# The official action handles caching automatically
- uses: charmbracelet/vhs-action@v2
  with:
    path: demo.tape
```

Reference: [VHS GitHub Action](https://github.com/charmbracelet/vhs-action)
