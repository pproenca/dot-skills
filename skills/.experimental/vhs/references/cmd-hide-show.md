---
title: Use Hide/Show for Sensitive Operations
impact: HIGH
impactDescription: prevents exposing secrets or boring setup in demos
tags: cmd, hide, show, privacy, security
---

## Use Hide/Show for Sensitive Operations

Use `Hide` to stop capturing frames and `Show` to resume. This is essential for hiding sensitive information like passwords, API keys, or lengthy setup commands that would bore viewers.

**Incorrect (sensitive data in recording):**

```tape
Output demo.gif

Type "export API_KEY=sk-1234567890abcdef"
Enter
Type "mycli auth"
Enter
# API key is now visible in your GIF!
```

**Correct (hide sensitive operations):**

```tape
Output demo.gif

Hide
Type "export API_KEY=$REAL_API_KEY"
Enter
Show

Type "mycli auth"
Enter
Sleep 2s
# Key is set but not visible in recording
```

**Hide boring setup:**

```tape
Output demo.gif

Hide
# Setup that viewers don't need to see
Type "cd ~/projects/demo"
Enter
Type "source .env"
Enter
Type "clear"
Enter
Show

# Now show the interesting part
Type "mycli demo"
Enter
```

Reference: [VHS README - Display](https://github.com/charmbracelet/vhs#display)
