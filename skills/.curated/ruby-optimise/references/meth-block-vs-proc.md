---
title: Pass Blocks Directly Instead of Converting to Proc
impact: MEDIUM
impactDescription: avoids Proc allocation on each call
tags: meth, block, proc, allocation
---

## Pass Blocks Directly Instead of Converting to Proc

Using `&method(:name)` creates a new `Proc` object on every invocation, which adds allocation pressure in tight loops. Passing a block literal avoids the intermediate `Proc` allocation entirely, keeping the call stack simpler for the VM to optimize.

**Incorrect (new Proc allocated per call site):**

```ruby
class ProductCatalog
  def initialize(products)
    @products = products
  end

  def format_name(product)
    product.name.strip.downcase
  end

  def normalized_names
    @products.map(&method(:format_name))  # Allocates a new Proc each time
  end

  def export_names
    @products.select(&method(:active?)).map(&method(:format_name))  # Two Proc allocations
  end
end
```

**Correct (block literals, no intermediate Proc):**

```ruby
class ProductCatalog
  def initialize(products)
    @products = products
  end

  def format_name(product)
    product.name.strip.downcase
  end

  def normalized_names
    @products.map { |product| format_name(product) }
  end

  def export_names
    @products.select { |product| active?(product) }.map { |product| format_name(product) }
  end
end
```

**Exception:** Using `&:symbol` for simple method calls on the receiver (e.g., `names.map(&:downcase)`) is idiomatic and optimized by most Ruby implementations. The overhead concern applies specifically to `&method(:name)`.
