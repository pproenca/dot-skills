---
title: Enable Link Prefetching for Instant Navigation
impact: CRITICAL
impactDescription: up to 500-800ms faster navigation (proportional to server response time)
tags: drive, prefetch, performance, navigation
---

## Enable Link Prefetching for Instant Navigation

Turbo Drive prefetches links on hover (`mouseenter`) by default, making subsequent page loads feel instant. This eliminates the network round-trip delay users would otherwise experience after clicking. Disable prefetching selectively on expensive endpoints (dashboards, reports) to avoid unnecessary server load.

**Incorrect (no prefetch awareness, slow navigation):**

```erb
<%# All links prefetch by default — including expensive ones %>
<nav>
  <%= link_to "Projects", projects_path %>
  <%= link_to "Messages", messages_path %>
  <%= link_to "Analytics Dashboard", analytics_path %>
  <%= link_to "Export Report", reports_export_path %>
</nav>

<%# Or globally disabling prefetch, losing the benefit everywhere %>
<head>
  <meta name="turbo-prefetch" content="false">
</head>
```

See also: [`perf-prefetch-strategic`](perf-prefetch-strategic.md) for granular strategies on which endpoints to exclude.

**Correct (default prefetch with selective opt-out on heavy endpoints):**

```erb
<nav>
  <%# These prefetch on hover by default — instant navigation %>
  <%= link_to "Projects", projects_path %>
  <%= link_to "Messages", messages_path %>

  <%# Opt out on expensive endpoints to avoid unnecessary server load %>
  <%= link_to "Analytics Dashboard", analytics_path,
      data: { turbo_prefetch: false } %>
  <%= link_to "Export Report", reports_export_path,
      data: { turbo_prefetch: false } %>
</nav>

<%# Or disable prefetch for an entire section %>
<div data-turbo-prefetch="false">
  <%= link_to "Heavy Report A", report_path(:a) %>
  <%= link_to "Heavy Report B", report_path(:b) %>
</div>
```
