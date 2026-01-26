---
title: Use Polling for WSL File Watching
impact: MEDIUM
impactDescription: enables HMR on Windows filesystem in WSL
tags: dev, wsl, polling, hmr
---

## Use Polling for WSL File Watching

WSL (Windows Subsystem for Linux) doesn't properly propagate file system events to Linux processes when files are on the Windows filesystem. Enable polling for HMR to work.

**Incorrect (inotify fails on Windows filesystem):**

```bash
# Project on Windows filesystem
pwd  # /mnt/c/Users/you/project

npm run dev
# Edit file...
# Nothing happens - HMR doesn't detect changes
```

**Correct (enable polling):**

```javascript
// vite.config.js
export default defineConfig({
  server: {
    watch: {
      usePolling: true,
      interval: 100
    }
  }
})
// HMR works on Windows filesystem
```

**Better solution: Use Linux filesystem**

```bash
# Move project to WSL filesystem
mv /mnt/c/Users/you/project ~/project
cd ~/project
npm run dev
# HMR works without polling (faster, less CPU)
```

**Conditional configuration:**

```javascript
// vite.config.js
const isWSL = process.platform === 'linux' &&
  process.env.WSL_DISTRO_NAME !== undefined

export default defineConfig({
  server: {
    watch: isWSL ? { usePolling: true } : undefined
  }
})
```

**Note:** Polling uses more CPU than inotify. Prefer moving project to Linux filesystem when possible.

Reference: [Troubleshooting | Vite](https://vite.dev/guide/troubleshooting)
