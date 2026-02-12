---
title: Disable Prefetch on Expensive Endpoints
impact: MEDIUM
impactDescription: prevents unnecessary server load from hover-triggered requests
tags: perf, turbo-drive, prefetch, server-load
---

## Disable Prefetch on Expensive Endpoints

Turbo Drive 8 prefetches links on hover by default (see [`drive-prefetch-links`](drive-prefetch-links.md) for the general pattern), which improves perceived navigation speed for lightweight pages. However, links to pages that trigger heavy database queries, report generation, or complex rendering will waste server resources when users merely hover without clicking. Selectively disabling prefetch on expensive endpoints prevents unnecessary load while keeping the optimization active where it helps.

**Incorrect (every link prefetched, including admin dashboards and report generators):**

```erb
<%# app/views/layouts/application.html.erb %>
<head>
  <%# Default Turbo Drive prefetch is enabled for all links %>
  <meta name="turbo-prefetch" content="true">
</head>

<%# app/views/projects/show.html.erb %>
<nav>
  <%= link_to "Dashboard", project_path(@project) %>
  <%= link_to "Analytics", project_analytics_path(@project) %>
  <%= link_to "Export CSV", project_export_path(@project, format: :csv) %>
  <%= link_to "Audit Log", project_audit_log_path(@project) %>
  <%# All links prefetch on hover — analytics and export hit the DB for nothing %>
</nav>
```

**Correct (data-turbo-prefetch="false" on heavy endpoints, default prefetch on lightweight pages):**

```erb
<%# app/views/projects/show.html.erb %>
<nav>
  <%= link_to "Dashboard", project_path(@project) %>

  <%= link_to "Analytics", project_analytics_path(@project),
      data: { turbo_prefetch: false } %>

  <%= link_to "Export CSV", project_export_path(@project, format: :csv),
      data: { turbo_prefetch: false } %>

  <%= link_to "Audit Log", project_audit_log_path(@project),
      data: { turbo_prefetch: false } %>
</nav>

<%# Or disable for an entire section with expensive links %>
<div data-turbo-prefetch="false">
  <h3>Admin Tools</h3>
  <%= link_to "User Report", admin_users_report_path %>
  <%= link_to "Revenue Dashboard", admin_revenue_path %>
  <%= link_to "System Health", admin_health_path %>
</div>
```
