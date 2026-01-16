---
title: Configure Viewport Meta Tag Correctly
impact: HIGH
impactDescription: enables proper mobile rendering, prevents zoom issues
tags: resp, viewport, mobile, meta, html
---

## Configure Viewport Meta Tag Correctly

Without a viewport meta tag, mobile browsers render pages at desktop width (typically 980px) then scale down. This breaks responsive layouts and makes text unreadable.

**Incorrect (missing or misconfigured viewport):**

```html
<!-- Missing viewport tag -->
<head>
  <title>My Website</title>
</head>
<!-- Mobile browser renders at 980px width, then shrinks -->
<!-- Text is tiny, user must pinch-zoom to read -->

<!-- Disabled zoom (accessibility violation) -->
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<!-- Users with low vision cannot zoom to read -->
```

**Correct (proper viewport configuration):**

```html
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>My Website</title>
</head>
<!-- Viewport matches device width -->
<!-- Initial zoom is 100%, user can still zoom if needed -->
```

**Viewport settings explained:**
- `width=device-width`: Match viewport to device screen width
- `initial-scale=1`: Start at 100% zoom
- Never use `maximum-scale=1` or `user-scalable=no` (blocks accessibility zoom)

**Additional responsive meta tags:**

```html
<!-- Proper color scheme support -->
<meta name="color-scheme" content="light dark">

<!-- iOS web app settings -->
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">

<!-- Theme color for browser chrome -->
<meta name="theme-color" content="#1a1a2e">
```

Reference: [MDN Viewport Meta](https://developer.mozilla.org/en-US/docs/Web/HTML/Viewport_meta_tag)
