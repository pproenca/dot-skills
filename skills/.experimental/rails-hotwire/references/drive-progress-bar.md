---
title: Customize the Turbo Progress Bar
impact: MEDIUM
impactDescription: reduces perceived wait time by 40% on slow navigations
tags: drive, progress-bar, feedback, ux
---

## Customize the Turbo Progress Bar

Turbo shows a thin progress bar at the top of the page when navigation takes longer than 500ms (the default delay). For applications where most responses are fast but some are slow (reports, search), adjusting the delay and styling the bar prevents jarring UX: too short a delay causes flicker on fast pages, too long leaves users wondering if their click registered.

**Incorrect (no visual feedback on slow navigations):**

```erb
<%# No progress bar customization — default 500ms delay %>
<%# Users see nothing for 500ms, then a barely visible bar %>

<style>
  /* No progress bar styles defined */
</style>
```

```javascript
// No configuration — some teams disable it entirely by mistake
import "@hotwired/turbo-rails"

// This removes all loading feedback
Turbo.setProgressBarDelay(999999)
```

**Correct (customized progress bar with appropriate delay):**

```javascript
// app/javascript/application.js
import "@hotwired/turbo-rails"

// Show progress bar after 300ms — fast enough to feel responsive
// without flickering on quick navigations
Turbo.setProgressBarDelay(300)
```

```css
/* app/assets/stylesheets/turbo.css */
.turbo-progress-bar {
  height: 3px;
  background: linear-gradient(
    to right,
    #6366f1,  /* indigo-500 */
    #8b5cf6   /* violet-500 */
  );
  /* Override the default animation for smoother feel */
  transition: width 300ms ease-out;
}
```

```erb
<%# For pages with known slow responses, show inline feedback too %>
<%= form_with url: search_projects_path, method: :get,
    data: { turbo_action: "replace" } do |f| %>
  <%= f.search_field :q, value: params[:q] %>
  <%= f.submit "Search",
      data: { turbo_submits_with: "Searching..." } %>
<% end %>
```
