---
title: Audit Community Plugins for Performance
impact: HIGH
impactDescription: identifies 50-80% of dev server slowdowns
tags: plugin, audit, inspect, profiling
---

## Audit Community Plugins for Performance

Community plugins may not be optimized. Use `vite-plugin-inspect` and `--debug` flags to identify slow plugins before they impact your development experience.

**Incorrect (blindly trusting plugins):**

```javascript
// vite.config.js
import eslintPlugin from 'vite-plugin-eslint'
import svgIcons from 'vite-plugin-svg-icons'

export default defineConfig({
  plugins: [
    eslintPlugin(),   // Blocks buildStart with full lint
    svgIcons()        // Calls fs.glob on every transform
  ]
})
// Dev server takes 30+ seconds to start
```

**Correct (audit and optimize):**

```bash
# See transform times per plugin
vite --debug plugin-transform

# Generate CPU profile
vite --profile
# Upload to speedscope.app
```

```javascript
// vite.config.js
import Inspect from 'vite-plugin-inspect'

export default defineConfig({
  plugins: [Inspect()]
})
// Visit /__inspect in dev
// See exactly which plugins are slow
```

**Problematic plugins to replace:**

| Slow Plugin | Issue | Alternative |
|-------------|-------|-------------|
| vite-plugin-eslint | Blocks buildStart | vite-plugin-checker |
| vite-plugin-svg-icons | fs.glob every transform | Direct SVG imports |

**What to look for:**
- buildStart taking >100ms
- transform hooks with no early return
- Synchronous filesystem operations

Reference: [Performance | Vite](https://vite.dev/guide/performance)
