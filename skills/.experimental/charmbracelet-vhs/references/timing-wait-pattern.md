---
title: Use Wait for Dynamic Command Completion
impact: HIGH
impactDescription: eliminates guesswork for variable-duration commands
tags: timing, wait, regex, synchronization, dynamic
---

## Use Wait for Dynamic Command Completion

Use `Wait` with a regex pattern to wait for specific output instead of guessing sleep durations. This creates reliable recordings regardless of system speed or network latency.

**Incorrect (guessing sleep duration):**

```tape
Type "npm install"
Enter
Sleep 30s  # Might be too long or too short

Type "npm run build"
Enter
Sleep 60s  # Build time varies wildly
```

**Correct (wait for completion patterns):**

```tape
Type "npm install"
Enter
Wait /added .* packages/  # Wait for npm completion message

Type "npm run build"
Enter
Wait /Build complete/  # Wait for build success message
```

**Wait scopes:**

```tape
# Wait for pattern anywhere on screen
Wait+Screen /ready/

# Wait for pattern on current line only (default)
Wait+Line /\$/  # Wait for prompt

# Wait with timeout
Wait+Screen@30s /Server started/
```

**Common patterns:**
- Shell prompt: `/\$\s*$/` or `/>\s*$/`
- npm completion: `/added .* packages/`
- Build success: `/Build complete|Successfully compiled/`
- Error detection: `/error:|Error:/`

Reference: [VHS README - Wait](https://github.com/charmbracelet/vhs#wait)
