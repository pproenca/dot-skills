---
title: Extract Critical CSS for Initial Render
impact: MEDIUM-HIGH
impactDescription: 100-300ms faster FCP on slow connections
tags: bundle, critical-css, performance, fcp, rendering
---

## Extract Critical CSS for Initial Render

For large applications, consider extracting critical CSS for above-the-fold content to improve First Contentful Paint (FCP).

**Incorrect (single large CSS file):**

```html
<head>
  <!-- Blocks rendering until fully loaded -->
  <link href="/styles.css" rel="stylesheet">
</head>
```

**Correct (critical CSS inlined):**

```html
<head>
  <!-- Critical styles inline for immediate render -->
  <style>
    /* Above-the-fold critical styles */
    .flex{display:flex}.justify-between{justify-content:space-between}
    .p-4{padding:1rem}.min-h-screen{min-height:100vh}
    .bg-white{background-color:#fff}.text-gray-900{color:#111827}
  </style>

  <!-- Full stylesheet loads async -->
  <link href="/styles.css" rel="stylesheet" media="print" onload="this.media='all'">
  <noscript><link href="/styles.css" rel="stylesheet"></noscript>
</head>
```

**Framework integration:**

```typescript
// Next.js example with critical CSS extraction
import { getCriticalCss } from "your-critical-css-tool";

export default function Document() {
  return (
    <Html>
      <Head>
        <style dangerouslySetInnerHTML={{ __html: getCriticalCss() }} />
      </Head>
      <body>{/* ... */}</body>
    </Html>
  );
}
```

**When to use:**
- Large CSS bundles (>50KB)
- Slow network connections matter (3G users)
- FCP is a critical metric

Reference: [Web.dev Critical CSS](https://web.dev/extract-critical-css/)
