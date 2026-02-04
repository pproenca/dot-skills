---
title: Place CSS Entry File in App Root Directory
impact: CRITICAL
impactDescription: wrong placement causes className scanning to miss files
tags: build, css, entry-file, tailwind
---

## Place CSS Entry File in App Root Directory

Tailwind scans for classNames starting from the CSS entry file's directory. Wrong placement causes missing styles.

**Incorrect (CSS file isolated from components):**

```text
project/
├── config/
│   └── global.css      # Tailwind won't scan src/
├── src/
│   └── components/
│       └── Button.tsx  # classNames not detected
```

**Correct (CSS file in app root):**

```text
project/
├── src/
│   ├── global.css      # Tailwind scans entire src/ tree
│   └── components/
│       └── Button.tsx  # classNames detected
```

```css
/* src/global.css */
@import 'tailwindcss';
@import 'uniwind';

/* Your theme and custom styles */
```

**For monorepos with components outside the CSS directory:**

```css
/* src/global.css */
@import 'tailwindcss';
@import 'uniwind';

@source '../../packages/ui/src';  /* Include external packages */
```

Reference: [Uniwind Metro Config](https://docs.uniwind.dev/api/metro-config)
