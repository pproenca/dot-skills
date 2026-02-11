---
title: Use flat_map Instead of map.flatten
impact: HIGH
impactDescription: eliminates intermediate nested array allocation
tags: enum, flat-map, flatten, arrays
---

## Use flat_map Instead of map.flatten

Calling `.map { ... }.flatten` first builds a full nested array, then allocates a second flattened copy. `flat_map` yields directly into a single output array, cutting allocations in half and avoiding the extra traversal.

**Incorrect (intermediate nested array):**

```ruby
all_line_items = orders
  .map { |order| order.line_items }   # builds array of arrays
  .flatten                             # traverses again to flatten into new array

tag_names = products
  .map { |product| product.categories.map(&:name) }  # nested array of arrays of strings
  .flatten
```

**Correct (single flattened pass):**

```ruby
all_line_items = orders
  .flat_map { |order| order.line_items }  # yields directly into one array

tag_names = products
  .flat_map { |product| product.categories.map(&:name) }
```
