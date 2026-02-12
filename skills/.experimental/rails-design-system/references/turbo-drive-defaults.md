---
title: Let Turbo Drive Handle Navigation by Default
impact: HIGH
impactDescription: eliminates custom SPA routing code — 0 lines of JS for page transitions
tags: turbo, drive, navigation, performance
---

## Let Turbo Drive Handle Navigation by Default

Turbo Drive intercepts every link click and form submission in your app, fetching the response and replacing the `<body>` without a full page reload. This gives you SPA-like speed without writing any JavaScript. Do not build custom AJAX navigation, client-side routing, or fetch-based page transitions — Turbo Drive already does this for every page.

**Incorrect (custom AJAX navigation that duplicates Turbo Drive):**

```javascript
// app/javascript/controllers/navigation_controller.js
// Reinventing what Turbo Drive does automatically
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async navigate(event) {
    event.preventDefault()
    const url = event.currentTarget.href
    const response = await fetch(url, {
      headers: { "Accept": "text/html" }
    })
    const html = await response.text()
    const parser = new DOMParser()
    const doc = parser.parseFromString(html, "text/html")
    document.body.innerHTML = doc.body.innerHTML
    history.pushState({}, "", url)
  }
}
```

**Correct (standard links — Turbo Drive handles everything):**

```erb
<%# Just write normal links. Turbo Drive intercepts them automatically. %>
<nav class="flex gap-4">
  <%= link_to "Dashboard", dashboard_path %>
  <%= link_to "Projects", projects_path %>
  <%= link_to "Settings", settings_path %>
</nav>

<%# Forms also work automatically %>
<%= form_with url: search_path, method: :get do |f| %>
  <%= f.text_field :q, placeholder: "Search..." %>
<% end %>
```

### Opting Out When Needed

Disable Turbo Drive for specific links or forms when you need a full page reload (file downloads, OAuth redirects, external links):

```erb
<%# Disable for a single link %>
<%= link_to "Download PDF", report_path(format: :pdf), data: { turbo: false } %>

<%# Disable for an external link (automatic — Turbo ignores cross-origin) %>
<%= link_to "Documentation", "https://docs.example.com" %>

<%# Disable for a form that redirects to a third-party payment page %>
<%= form_with url: checkout_path, data: { turbo: false } do |f| %>
  <%= f.submit "Pay Now" %>
<% end %>
```

### Persistent Elements Across Navigations

Mark elements that should persist across Turbo Drive navigations with `data-turbo-permanent` and a unique `id`:

```erb
<%# app/views/layouts/application.html.erb %>
<audio id="audio-player" data-turbo-permanent
       data-controller="audio-player">
  <%# This audio player survives page navigations %>
</audio>

<div id="notification-bar" data-turbo-permanent
     data-controller="notification">
  <%# Notifications persist across navigations %>
</div>
```

### Performance: Prefetching

Turbo Drive prefetches links on hover, making navigations feel instant:

```erb
<%# Prefetching is automatic for same-origin links %>
<%# Disable for expensive pages %>
<%= link_to "Heavy Report", report_path, data: { turbo_prefetch: false } %>
```

Reference: [Turbo Drive Handbook](https://turbo.hotwired.dev/handbook/drive)
