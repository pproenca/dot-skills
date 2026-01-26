---
title: Use CSS Modules for Component Styles
impact: MEDIUM
impactDescription: eliminates style conflicts, enables tree-shaking
tags: css, modules, scoping, components
---

## Use CSS Modules for Component Styles

CSS Modules provide automatic class name scoping and integrate well with Vite's code splitting.

**Incorrect (global styles cause conflicts):**

```css
/* Button.css */
.button {
  background: blue;
}
/* Conflicts with other .button classes */
/* Unused styles still bundled */
```

```typescript
// Button.tsx
import './Button.css'

export function Button() {
  return <button className="button">Click</button>
}
```

**Correct (scoped CSS Modules):**

```css
/* Button.module.css */
.button {
  background: blue;
}

.primary {
  background: green;
}
```

```typescript
// Button.tsx
import styles from './Button.module.css'

export function Button({ variant }) {
  return (
    <button className={`${styles.button} ${styles[variant]}`}>
      Click
    </button>
  )
}
// Classes become: Button_button_x7d3f
// No conflicts, tree-shakeable
```

**Configure CSS Modules:**

```javascript
// vite.config.js
export default defineConfig({
  css: {
    modules: {
      localsConvention: 'camelCase',
      generateScopedName: '[name]__[local]___[hash:base64:5]'
    }
  }
})
```

**Benefits:**
- No class name collisions
- Dead code elimination works
- Co-located with components

Reference: [Features | Vite](https://vite.dev/guide/features)
