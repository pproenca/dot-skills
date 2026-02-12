---
title: Enable Morphing for Page Refreshes
impact: HIGH
impactDescription: "7.8x faster DOM updates (23ms vs 180ms for 1000 nodes)"
tags: morph, page-refresh, performance, meta-tag
---

## Enable Morphing for Page Refreshes

By default, Turbo replaces the entire `<body>` on page refreshes, which destroys all DOM state including scroll position, focus, open modals, and Stimulus controller state. Enabling morphing via `turbo_refreshes_with method: :morph` makes Turbo diff the new HTML against the existing DOM and apply only the minimal set of changes. This is dramatically faster for pages with many elements and preserves client-side state that would otherwise be lost.

**Incorrect (full page body replacement on every navigation):**

```erb
<%# app/views/layouts/application.html.erb %>
<html>
<head>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>
  <%# No morph configuration — Turbo replaces the entire body %>
  <%= stylesheet_link_tag "application" %>
  <%= javascript_importmap_tags %>
</head>
<body>
  <%= yield %>
</body>
</html>

<%# Every broadcast refresh or Turbo visit replaces the full body,
    destroying scroll position, open dropdowns, and form input state. %>
```

**Correct (turbo_refreshes_with in layout for morph-based refreshes):**

```erb
<%# app/views/layouts/application.html.erb %>
<html>
<head>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>

  <%# Enable morphing for page refreshes with scroll preservation %>
  <%= turbo_refreshes_with method: :morph, scroll: :preserve %>

  <%= stylesheet_link_tag "application" %>
  <%= javascript_importmap_tags %>
</head>
<body>
  <%= yield %>
</body>
</html>

<%# This adds two meta tags to the <head>:
    <meta name="turbo-refresh-method" content="morph">
    <meta name="turbo-refresh-scroll" content="preserve">

    Now broadcast refreshes diff the DOM instead of replacing it,
    preserving scroll position, focus, and ephemeral UI state. %>
```
