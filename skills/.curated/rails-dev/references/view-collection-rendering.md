---
title: Use Collection Rendering Instead of Loop Partials
impact: MEDIUM-HIGH
impactDescription: 5-20× faster rendering with single partial instantiation
tags: view, collection-rendering, partials, performance
---

## Use Collection Rendering Instead of Loop Partials

Rendering partials inside a loop instantiates ActionView once per iteration. Collection rendering instantiates it once for all items.

**Incorrect (partial instantiated per iteration):**

```erb
<% @orders.each do |order| %>
  <%= render partial: "order", locals: { order: order } %>
<% end %>
```

**Correct (single instantiation for collection):**

```erb
<%= render partial: "order", collection: @orders, as: :order %>
```

**Alternative (shorthand):**

```erb
<%= render @orders %>
```

Reference: [Layouts and Rendering — Rails Guides](https://guides.rubyonrails.org/layouts_and_rendering.html#rendering-collections)
