---
title: Avoid Play CDN in Production
impact: HIGH
impactDescription: 10-100× larger payload, runtime compilation overhead
tags: bundle, cdn, production, performance, build
---

## Avoid Play CDN in Production

The Play CDN is designed for prototyping and learning. It compiles Tailwind in the browser, resulting in significant performance overhead.

**Incorrect (CDN in production):**

```html
<!DOCTYPE html>
<html>
<head>
  <!-- Runtime compilation in browser -->
  <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body>
  <div class="bg-blue-500 p-4">
    <!-- Every page load recompiles styles -->
  </div>
</body>
</html>
```

**Correct (build-time compilation):**

```html
<!DOCTYPE html>
<html>
<head>
  <!-- Pre-compiled, minified CSS -->
  <link href="/dist/styles.css" rel="stylesheet">
</head>
<body>
  <div class="bg-blue-500 p-4">
    <!-- Zero runtime overhead -->
  </div>
</body>
</html>
```

**Play CDN is appropriate for:**
- Quick prototypes and demos
- CodePen/JSFiddle examples
- Learning and experimentation

**Never use CDN for:**
- Production websites
- Performance-critical applications
- SEO-sensitive pages

Reference: [Tailwind CSS Play CDN](https://tailwindcss.com/docs/installation/play-cdn)
