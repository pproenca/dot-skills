---
title: Use Colors Semantically and Consistently
impact: MEDIUM
impactDescription: reduces time-to-comprehension by 2-3×
tags: ux, color, semantics, accessibility, styling
---

## Use Colors Semantically and Consistently

Use colors to convey meaning, not decoration. Reserve red for errors, yellow for warnings, green for success, and cyan/blue for emphasis.

**Incorrect (inconsistent/decorative colors):**

```typescript
// Colors chosen for aesthetics, not meaning
console.log(color.magenta('Error: File not found'))  // Error in magenta?
console.log(color.blue('Warning: Low disk space'))   // Warning in blue?
console.log(color.red('Success!'))                   // Success in red??
```

**Correct (semantic colors):**

```typescript
import color from 'picocolors'

// Consistent semantic color scheme
const log = {
  error: (msg: string) => console.log(color.red(`✖ ${msg}`)),
  warn: (msg: string) => console.log(color.yellow(`⚠ ${msg}`)),
  success: (msg: string) => console.log(color.green(`✔ ${msg}`)),
  info: (msg: string) => console.log(color.cyan(`ℹ ${msg}`)),
  dim: (msg: string) => console.log(color.dim(msg))
}

log.success('Build complete')
log.warn('Deprecated API usage detected')
log.error('Connection failed')
log.info('Server running on port 3000')
log.dim('Press Ctrl+C to stop')
```

**With Clack logging:**

```typescript
import * as p from '@clack/prompts'

p.log.success('Dependencies installed')
p.log.warn('Using deprecated config format')
p.log.error('Build failed')
p.log.info('Starting server...')
p.log.message('Custom message')  // Neutral
```

**Color scheme reference:**
- **Red**: Errors, failures, destructive actions
- **Yellow**: Warnings, caution, deprecation
- **Green**: Success, completion, safe actions
- **Cyan/Blue**: Information, emphasis, prompts
- **Magenta**: Highlights, special items
- **Dim/Gray**: Secondary info, hints, help text

**Note:** Always support `NO_COLOR` environment variable and provide non-color fallbacks for accessibility.

Reference: [clig.dev - Output](https://clig.dev/#output)
