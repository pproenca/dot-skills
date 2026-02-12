---
title: Name Partials by What They Render, Not Where They Live
impact: HIGH
impactDescription: prevents partial proliferation and naming confusion
tags: partial, views, naming, conventions, organization
---

## Name Partials by What They Render, Not Where They Live

Name partials after the UI element they render (`_card`, `_row`, `_header`), prefixed with the domain object when disambiguation is needed (`_user_card`). Avoid naming partials after the page they appear on (`_homepage_hero`) unless the content is truly page-specific and will never be reused. Page-named partials lead to duplication when the same UI appears on a second page.

**Incorrect (named by page location):**

```text
app/views/dashboards/_dashboard_user_section.html.erb
app/views/settings/_settings_user_info.html.erb
app/views/admin/_admin_user_details.html.erb
```

All three render nearly identical user information but have different names, making it impossible to know they overlap without reading each file.

**Correct (named by what they render):**

```text
app/views/users/_card.html.erb          # user card used on dashboard, settings, admin
app/views/users/_row.html.erb           # user table row used in lists
app/views/shared/_page_header.html.erb  # page header used across all sections
```

```erb
<%# app/views/dashboards/show.html.erb %>
<%= render "shared/page_header", title: "Dashboard" %>
<%= render partial: "users/card", collection: @recent_users, as: :user %>

<%# app/views/settings/show.html.erb %>
<%= render "shared/page_header", title: "Settings" %>
<%= render "users/card", user: current_user %>
```

### Naming Convention Table

| Partial scope | Directory | Example |
|---|---|---|
| Belongs to a single resource | `app/views/{resource}/` | `app/views/users/_card.html.erb` |
| Shared UI elements | `app/views/shared/` | `app/views/shared/_flash_messages.html.erb` |
| Layout fragments | `app/views/application/` | `app/views/application/_navbar.html.erb` |
| Page-specific (rare) | `app/views/{controller}/` | `app/views/dashboards/_metric_grid.html.erb` |

### Naming Patterns

```text
_card.html.erb        # a self-contained card display
_row.html.erb         # a table or list row
_form.html.erb        # a form for the resource (Rails convention)
_header.html.erb      # a header section
_filters.html.erb     # filter controls
_empty_state.html.erb # what to show when collection is empty
```

Reference: [Rails View Rendering Guide](https://guides.rubyonrails.org/layouts_and_rendering.html#using-partials)
