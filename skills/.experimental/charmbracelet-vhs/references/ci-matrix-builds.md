---
title: Generate Platform-Specific Demos
impact: LOW-MEDIUM
impactDescription: ensures demos work across different shells
tags: ci, matrix, platforms, cross-platform
---

## Generate Platform-Specific Demos

Use CI matrix builds to generate demos for different shells or platforms when your CLI behaves differently across environments.

**Incorrect (single shell assumption):**

```yaml
- uses: charmbracelet/vhs-action@v2
  with:
    path: demo.tape
# Only generates for default shell
```

**Correct (matrix for multiple shells):**

```yaml
name: Generate Shell-Specific Demos

jobs:
  demo:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        shell: [bash, zsh, fish]
    steps:
      - uses: actions/checkout@v4

      - name: Install shell
        run: sudo apt-get install -y ${{ matrix.shell }}

      - name: Create shell-specific tape
        run: |
          sed "s/Set Shell.*/Set Shell \"${{ matrix.shell }}\"/" \
            demo.tape > demo-${{ matrix.shell }}.tape

      - uses: charmbracelet/vhs-action@v2
        with:
          path: demo-${{ matrix.shell }}.tape

      - name: Rename output
        run: mv demo.gif demo-${{ matrix.shell }}.gif
```

**When to use platform-specific demos:**
- Shell-specific syntax highlighting
- Different command availability
- Platform-specific paths or behaviors

Reference: [VHS GitHub Action](https://github.com/charmbracelet/vhs-action)
