---
title: Use Golden Files for Integration Testing
impact: MEDIUM
impactDescription: detects unintended output changes
tags: ci, testing, golden-files, regression
---

## Use Golden Files for Integration Testing

Use VHS's `.txt` or `.ascii` output format to generate golden files for integration testing. Store these in version control to detect unintended changes in CLI output.

**Incorrect (only generating GIFs):**

```tape
Output demo.gif
# No way to detect if output content changed
```

**Correct (golden file for testing):**

```tape
Output demo.gif
Output demo.txt  # Text output for comparison

Type "mycli --version"
Enter
Sleep 1s
Type "mycli help"
Enter
Sleep 2s
```

**CI workflow with golden file comparison:**

```yaml
name: Test CLI Output

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: charmbracelet/vhs-action@v2
        with:
          path: test.tape

      - name: Compare golden file
        run: |
          diff -u expected/demo.txt demo.txt
          # Fails if output differs from expected
```

**Update golden files intentionally:**

```bash
# After intentional changes, update golden files
vhs test.tape
cp demo.txt expected/demo.txt
git add expected/demo.txt
git commit -m "update: golden file for new output format"
```

Reference: [VHS README](https://github.com/charmbracelet/vhs)
