---
title: Verify System Dependencies
impact: HIGH
impactDescription: prevents cryptic ffmpeg and ttyd errors
tags: deps, ffmpeg, ttyd, system, installation
---

## Verify System Dependencies

VHS requires `ttyd` and `ffmpeg` to be installed and available on `$PATH`. Missing these causes cryptic errors during rendering. Document these requirements and verify them before running tape files.

**Incorrect (assuming dependencies exist):**

```tape
Output demo.gif
Set Shell "bash"
Type "echo hello"
Enter
# Error: ttyd not found in PATH
# Error: ffmpeg: command not found
```

**Correct (verify before running):**

```bash
# Check system dependencies before running VHS
which ttyd ffmpeg

# Install if missing (macOS)
brew install ttyd ffmpeg

# Install if missing (Ubuntu/Debian)
sudo apt install ttyd ffmpeg

# Then run your tape
vhs demo.tape
```

**CI/CD verification:**

```yaml
# GitHub Actions example
- name: Install VHS dependencies
  run: |
    sudo apt-get update
    sudo apt-get install -y ffmpeg
    # ttyd is installed by vhs-action

- uses: charmbracelet/vhs-action@v2
  with:
    path: demo.tape
```

Reference: [VHS README - Installation](https://github.com/charmbracelet/vhs#installation)
