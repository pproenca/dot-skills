---
title: Preserve Scroll Position During Morphing
impact: HIGH
impactDescription: "prevents jarring scroll-to-top on real-time updates"
tags: morph, scroll, user-experience, meta-tag
---

## Preserve Scroll Position During Morphing

When a broadcast triggers a page refresh (see [`morph-enable-page-refresh`](morph-enable-page-refresh.md) for enabling morphing), Turbo re-renders the page from the server. Without scroll preservation, the browser resets to the top of the page after every morph, which is disorienting for users reading content further down. Setting `scroll: :preserve` in the layout tells Turbo to maintain the current scroll position after morphing. Use `scroll: :reset` only on specific pages where returning to the top is the expected behavior (e.g., after navigating to a new resource).

**Incorrect (page jumping to top after every broadcast morph):**

```erb
<%# app/views/layouts/application.html.erb %>
<html>
<head>
  <%# Morph enabled but scroll preservation missing %>
  <%= turbo_refreshes_with method: :morph %>
  <%# Equivalent to: <meta name="turbo-refresh-scroll" content="reset"> (default) %>
</head>
<body>
  <%= yield %>
</body>
</html>

<%# User scrolls to comment #47 in a long thread.
    Another user posts a comment, triggering broadcasts_refreshes.
    The page morphs and jumps back to the top. User loses their place. %>
```

**Correct (scroll: :preserve in layout, reset on specific pages):**

```erb
<%# app/views/layouts/application.html.erb %>
<html>
<head>
  <%# Preserve scroll globally — most pages should keep position %>
  <%= turbo_refreshes_with method: :morph, scroll: :preserve %>
</head>
<body>
  <%= yield %>
</body>
</html>

<%# For specific pages that SHOULD reset scroll (e.g., navigating to a new record),
    override in the view using content_for or a page-specific meta tag: %>

<%# app/views/projects/show.html.erb %>
<% content_for :head do %>
  <meta name="turbo-refresh-scroll" content="reset">
<% end %>

<%# The layout should yield :head inside <head> for per-page overrides: %>
<%# <head>
      turbo_refreshes_with method: :morph, scroll: :preserve
      yield :head
    </head> %>
```
