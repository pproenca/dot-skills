---
title: Set Appropriate Wait Timeouts
impact: MEDIUM
impactDescription: prevents infinite hangs and CI failures
tags: timing, wait, timeout, reliability
---

## Set Appropriate Wait Timeouts

Always set explicit timeouts on `Wait` commands to prevent infinite hangs when expected output never appears. The default 15-second timeout may be too short for slow operations or too long for quick checks.

**Incorrect (default timeout may fail):**

```tape
Type "npm run build"
Enter
Wait /Build complete/  # Default 15s timeout—build takes 30s
# VHS times out and fails
```

**Correct (appropriate timeouts):**

```tape
Type "npm run build"
Enter
Wait@60s /Build complete/  # 60-second timeout for slow builds

Type "echo test"
Enter
Wait@2s /test/  # 2-second timeout for instant commands
```

**Timeout guidelines:**
- Instant commands (echo, pwd): 2-5s
- File operations: 5-10s
- Network operations: 10-30s
- Build/compile: 30-120s
- CI operations: 60-300s

**In CI environments:**

```tape
# CI is often slower, use generous timeouts
Wait@120s /Build succeeded/
Wait@60s /Tests passed/
```

Reference: [VHS README - Wait](https://github.com/charmbracelet/vhs#wait)
