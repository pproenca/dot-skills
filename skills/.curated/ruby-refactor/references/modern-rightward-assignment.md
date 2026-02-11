---
title: Use Rightward Assignment for Pipeline Expressions
impact: LOW-MEDIUM
impactDescription: reads naturally for method chain results
tags: modern, rightward-assignment, pipeline, syntax
---

## Use Rightward Assignment for Pipeline Expressions

When a multi-step method chain produces a result that needs a name, traditional leftward assignment forces readers to see the variable name before understanding the transformation. Ruby 3.0+ rightward assignment (`=> variable`) lets the code read top-to-bottom like a pipeline, matching the natural data flow from input to named output.

**Incorrect (leftward assignment breaks reading flow):**

```ruby
class SalesReport
  def quarterly_summary(orders)
    regional_totals = orders
      .select { |o| o.status == :completed }
      .group_by(&:region)
      .transform_values { |group| group.sum(&:total) }  # reader must scroll up to find what this becomes

    top_regions = regional_totals
      .sort_by { |_region, total| -total }
      .first(5)
      .to_h

    { totals: regional_totals, top_regions: top_regions }
  end
end
```

**Correct (rightward assignment follows data flow):**

```ruby
class SalesReport
  def quarterly_summary(orders)
    orders
      .select { |o| o.status == :completed }
      .group_by(&:region)
      .transform_values { |group| group.sum(&:total) } => regional_totals  # name appears at the end of the pipeline

    regional_totals
      .sort_by { |_region, total| -total }
      .first(5)
      .to_h => top_regions

    { totals: regional_totals, top_regions: top_regions }
  end
end
```

**When NOT to use:** Avoid rightward assignment for simple, single-step expressions where leftward assignment is already clear. It adds unnecessary novelty without improving readability.

```ruby
# Do NOT use rightward assignment here
"hello world" => greeting         # confusing for a trivial assignment
user.name => name                 # no pipeline, leftward is clearer

# Traditional assignment is better for simple cases
greeting = "hello world"
name = user.name
```
