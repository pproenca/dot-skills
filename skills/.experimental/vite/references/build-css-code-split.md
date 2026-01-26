---
title: Enable CSS Code Splitting
impact: MEDIUM-HIGH
impactDescription: 30-50% smaller initial CSS payload
tags: build, css, code-splitting, lazy-loading
---

## Enable CSS Code Splitting

CSS code splitting keeps styles with their JavaScript chunks. Users only download CSS for components they use.

**Incorrect (single CSS file):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    cssCodeSplit: false
  }
})
// All 500KB of CSS loaded on first page
// Dashboard styles loaded even on landing page
```

**Correct (CSS code splitting enabled):**

```javascript
// vite.config.js
export default defineConfig({
  build: {
    cssCodeSplit: true  // Default
  }
})
```

```typescript
// Routes lazy load their CSS automatically
const Dashboard = lazy(() => import('./Dashboard'))
// Dashboard.css loads only when user visits /dashboard
```

**How it works:**

```typescript
// Home.tsx
import './Home.css'  // Bundled with Home chunk (50KB)

// Dashboard.tsx (lazy loaded)
import './Dashboard.css'  // Bundled with Dashboard chunk (200KB)

// Initial load: only Home.css
// Dashboard visit: loads Dashboard.css on demand
```

**Benefits:**
- Smaller initial CSS payload
- Better caching (page-specific CSS)
- Reduced unused CSS per page

Reference: [Build Options](https://vite.dev/config/build-options)
