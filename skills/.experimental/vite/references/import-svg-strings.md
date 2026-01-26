---
title: Import SVGs as Strings Instead of Components
impact: MEDIUM-HIGH
impactDescription: reduces transform overhead
tags: import, svg, strings, performance
---

## Import SVGs as Strings Instead of Components

Transforming SVGs into React/Vue components adds transform overhead. Import as strings or URLs for simple display.

**Incorrect (component transform):**

```typescript
// Each SVG becomes a full React component
import Logo from './logo.svg?react'
import Icon from './icon.svg?react'
// Plugin transforms SVG → JSX → JavaScript
```

**Correct (string or URL import):**

```typescript
// Import as URL (fastest)
import logoUrl from './logo.svg'
// <img src={logoUrl} alt="Logo" />

// Import as raw string
import logoSvg from './logo.svg?raw'
// <div dangerouslySetInnerHTML={{ __html: logoSvg }} />

// Or use inline for simple cases
// <img src="/logo.svg" alt="Logo" />
```

**When to use component transform:**
- SVG needs dynamic props (color, size)
- SVG needs event handlers
- SVG needs to be part of the DOM for accessibility

**When to use strings/URLs:**
- Static images
- Background images
- Decorative icons
- Logos

```javascript
// vite.config.js - avoid default component transform
export default defineConfig({
  // Don't add vite-plugin-svgr unless needed
})
```

Reference: [Performance | Vite](https://vite.dev/guide/performance)
