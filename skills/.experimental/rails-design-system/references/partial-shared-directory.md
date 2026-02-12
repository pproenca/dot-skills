---
title: Put Cross-Cutting Partials in app/views/shared
impact: MEDIUM
impactDescription: eliminates cross-directory render calls for shared UI elements
tags: partial, views, organization, shared, directory-structure
---

## Put Cross-Cutting Partials in app/views/shared

Partials used across multiple resource views belong in `app/views/shared/` or `app/views/application/`. Resource-specific partials stay in their resource directory. This convention prevents the "where does this partial live?" hunt that slows down teams working across features. When a partial lives in `users/` but is rendered from `orders/`, `products/`, and `admin/`, its location is misleading.

**Incorrect (cross-cutting partial in resource directory):**

```text
app/views/users/_flash_messages.html.erb   # used by orders, products, admin
app/views/orders/_pagination.html.erb      # used by users, products, reports
app/views/products/_empty_state.html.erb   # used everywhere
```

```erb
<%# Confusing cross-directory render calls %>
<%= render "users/flash_messages" %>  <%# Why users? This is the orders page %>
<%= render "orders/pagination" %>     <%# Why orders? This is the products page %>
```

**Correct (shared partials in shared directory):**

```text
app/views/shared/_flash_messages.html.erb
app/views/shared/_pagination.html.erb
app/views/shared/_empty_state.html.erb
```

```erb
<%# Clear and predictable render calls %>
<%= render "shared/flash_messages" %>
<%= render "shared/pagination", pagy: @pagy %>
<%= render "shared/empty_state",
           icon: "inbox",
           message: "No orders yet",
           action_path: new_order_path,
           action_label: "Create your first order" %>
```

### Convention Table

| Directory | Purpose | Examples |
|---|---|---|
| `app/views/{resource}/` | Partials specific to one resource | `users/_card.html.erb`, `users/_form.html.erb` |
| `app/views/shared/` | UI elements used across resources | `shared/_flash_messages.html.erb`, `shared/_empty_state.html.erb` |
| `app/views/application/` | Layout-level fragments | `application/_navbar.html.erb`, `application/_footer.html.erb` |
| `app/views/layouts/` | Full layout templates | `layouts/application.html.erb`, `layouts/admin.html.erb` |

### Migration Heuristic

Move a partial to `shared/` when it is rendered from 2+ different resource directories. A quick check:

```bash
# Find partials rendered from outside their own directory
grep -r "render.*users/" app/views --include="*.erb" | grep -v "app/views/users/"
```

If the output shows other views rendering `users/` partials, those partials are candidates for `shared/`.

Reference: [Rails View Rendering Guide](https://guides.rubyonrails.org/layouts_and_rendering.html#using-partials)
