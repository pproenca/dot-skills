---
title: Use Screenshot for Static Captures
impact: MEDIUM
impactDescription: creates PNG snapshots for documentation
tags: cmd, screenshot, capture, png, documentation
---

## Use Screenshot for Static Captures

Use `Screenshot` to capture the current terminal state as a PNG image. This is useful for documentation, README files, or when a static image is more appropriate than an animated GIF.

**Incorrect (using GIF for static content):**

```tape
Output static-example.gif

Type "mycli --help"
Enter
Sleep 5s
# Creates a 5-second GIF of static content
```

**Correct (screenshot for static content):**

```tape
Output demo.gif

Type "mycli --help"
Enter
Sleep 1s
Screenshot help-output.png

Type "mycli version"
Enter
Sleep 1s
Screenshot version-output.png
```

**Screenshot for key moments:**

```tape
Output tutorial.gif

Type "npm run build"
Enter
Sleep 5s
Screenshot build-success.png  # Capture successful build

Type "npm test"
Enter
Sleep 3s
Screenshot test-results.png  # Capture test output
```

Reference: [VHS README - Screenshot](https://github.com/charmbracelet/vhs#screenshot)
