---
title: Use Server Mode for Remote Access
impact: LOW
impactDescription: eliminates per-machine VHS installation
tags: advanced, server, ssh, remote, collaboration
---

## Use Server Mode for Remote Access

VHS has a built-in SSH server that allows remote tape execution. This is useful for teams where not everyone has VHS installed locally, or for running VHS on a dedicated build server.

**Incorrect (local installation required):**

```bash
# Every team member must install VHS
brew install vhs
brew install ffmpeg ttyd

# Each machine may have different versions
vhs --version  # v0.7.0 on one machine
vhs --version  # v0.6.0 on another

# Inconsistent output between machines
vhs demo.tape
```

**Correct (centralized server):**

```bash
# Server setup (once)
vhs serve

# Any team member can generate demos
ssh -p 1976 vhs.internal.example.com < demo.tape

# Consistent environment and versions
# No local installation needed
```

**Server configuration:**

```bash
# Environment variables
VHS_PORT=1976              # SSH port (default: 1976)
VHS_HOST=0.0.0.0           # Bind address
VHS_KEY_PATH=~/.ssh/key    # Host key path
VHS_AUTHORIZED_KEYS_PATH=~/.ssh/authorized_keys
```

**When to use server mode:**
- Centralized demo generation for teams
- Team members without VHS installed
- Consistent rendering environment
- Dedicated build servers with dependencies

Reference: [VHS README - SSH Server](https://github.com/charmbracelet/vhs#vhs-server)
