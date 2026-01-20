---
title: Add Natural Pauses Between Actions
impact: MEDIUM
impactDescription: creates human-like interaction flow
tags: timing, sleep, pacing, natural
---

## Add Natural Pauses Between Actions

Add short pauses between actions to simulate natural human interaction. Without pauses, recordings feel robotic and are harder for viewers to follow.

**Incorrect (machine-gun pacing):**

```tape
Type "ls"
Enter
Type "cd src"
Enter
Type "cat main.js"
Enter
# Feels robotic, hard to follow
```

**Correct (natural pauses):**

```tape
Type "ls"
Enter
Sleep 1s  # Let viewer see listing

Type "cd src"
Enter
Sleep 500ms  # Brief pause, directory change is quick

Type "cat main.js"
Enter
Sleep 3s  # Let viewer read file contents
```

**Pause guidelines by action type:**
- After directory listing: 1-2s
- After cd/navigation: 300-500ms
- After typing, before Enter: 200-300ms (thinking pause)
- After command output: 1-5s based on content length
- Between unrelated commands: 500ms-1s

Reference: [VHS README](https://github.com/charmbracelet/vhs)
