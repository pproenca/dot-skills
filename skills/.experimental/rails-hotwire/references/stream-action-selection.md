---
title: Choose the Right Stream Action for DOM Mutations
impact: HIGH
impactDescription: "prevents unnecessary DOM thrashing and content duplication"
tags: stream, dom-manipulation, actions, performance
---

## Choose the Right Stream Action for DOM Mutations

Turbo Streams provides nine actions, each suited to a specific DOM mutation pattern. Using `replace` when `update` would suffice destroys the outer element and its event listeners, causing flickering and breaking attached Stimulus controllers. Conversely, using `update` when `replace` is needed leaves stale attributes on the wrapper element. Choosing the correct action minimizes DOM churn and preserves client-side state.

**Incorrect (using replace when update would preserve event listeners):**

```erb
<%# Replaces the entire element, destroying attached Stimulus controllers and event listeners %>
<%= turbo_stream.replace "message_#{@message.id}" do %>
  <div id="<%= dom_id(@message) %>"
       data-controller="clipboard"
       data-clipboard-copied-class="text-green-500">
    <p><%= @message.body %></p>
    <span class="status"><%= @message.edited? ? "edited" : "" %></span>
  </div>
<% end %>
```

**Correct (update for inner HTML changes, replace for full element swap):**

```erb
<%# UPDATE: changes inner HTML only, preserving the outer element and its controllers %>
<%= turbo_stream.update dom_id(@message) do %>
  <p><%= @message.body %></p>
  <span class="status"><%= @message.edited? ? "edited" : "" %></span>
<% end %>

<%# REPLACE: use when the outer element attributes themselves change %>
<%= turbo_stream.replace dom_id(@message) do %>
  <div id="<%= dom_id(@message) %>"
       data-controller="clipboard"
       class="<%= @message.pinned? ? 'bg-yellow-50' : 'bg-white' %>">
    <p><%= @message.body %></p>
  </div>
<% end %>

<%# Quick reference for all 9 actions:
  append   - add to end of container (new items in a list)
  prepend  - add to start of container (newest-first feeds)
  replace  - swap entire element including wrapper (attribute changes)
  update   - swap inner HTML only (content changes, preserves controllers)
  remove   - delete element (after destroy)
  before   - insert before target (insert above a specific item)
  after    - insert after target (insert below a specific item)
  morph    - smart diff/patch of element (minimal DOM changes)
  refresh  - trigger full page morph (broadcast-driven updates)
%>
```
