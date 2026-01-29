---
title: Use Bun Runtime for Faster Analysis
impact: LOW-MEDIUM
impactDescription: 2-3× faster startup and execution
tags: perf, bun, runtime, speed
---

## Use Bun Runtime for Faster Analysis

Run Knip with Bun instead of Node.js for significantly faster startup and execution, especially on large codebases.

**Incorrect (Node.js runtime, slower startup):**

```bash
npx knip  # Uses Node.js
```

**Correct (Bun runtime for speed):**

```bash
bunx knip
# or if installed globally
knip-bun
```

**Install Bun:**

```bash
# macOS/Linux
curl -fsSL https://bun.sh/install | bash

# Windows
powershell -c "irm bun.sh/install.ps1 | iex"
```

**Performance comparison (typical large project):**
- Node.js: ~30 seconds
- Bun: ~12 seconds

**CI configuration:**

```yaml
- uses: oven-sh/setup-bun@v1
- run: bunx knip
```

**Note:** Bun compatibility is generally excellent, but test in your project before switching CI.

Reference: [Knip CLI](https://knip.dev/reference/cli)
