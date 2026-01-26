---
title: Increase File Descriptor Limits on Linux
impact: MEDIUM-HIGH
impactDescription: prevents EMFILE errors, enables large projects
tags: dev, linux, filesystem, limits
---

## Increase File Descriptor Limits on Linux

Vite serves files unbundled in development. Large projects can hit OS file descriptor limits, causing errors and slowdowns.

**Incorrect (hitting system limits):**

```bash
# Error messages:
Error: EMFILE: too many open files
Error: ENOSPC: System limit for number of file watchers reached

# Default limits often too low:
ulimit -n  # 1024 (not enough for large projects)
```

**Correct (increased limits):**

```bash
# Check current limits
ulimit -n
cat /proc/sys/fs/inotify/max_user_watches

# Increase file descriptor limit
ulimit -n 65536

# Increase inotify watches (Linux)
sudo sysctl fs.inotify.max_user_watches=524288
```

**Permanent configuration:**

```bash
# ~/.bashrc or ~/.zshrc
ulimit -n 65536

# /etc/sysctl.conf (Linux)
fs.inotify.max_user_watches=524288
```

**Alternative: Reduce watched files**

```javascript
// vite.config.js
export default defineConfig({
  server: {
    watch: {
      ignored: ['**/node_modules/**', '**/dist/**', '**/.git/**']
    }
  }
})
```

**macOS equivalent:**

```bash
sudo launchctl limit maxfiles 65536 200000
```

Reference: [Troubleshooting | Vite](https://vite.dev/guide/troubleshooting)
