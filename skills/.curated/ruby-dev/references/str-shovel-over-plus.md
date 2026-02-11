---
title: Use Shovel Operator for String Building
impact: HIGH
impactDescription: reduces N string allocations to 0 in loops
tags: str, concatenation, shovel, allocation
---

## Use Shovel Operator for String Building

The `+` operator creates a new String object for every concatenation, copying both operands into fresh memory. In a loop that processes thousands of records, this means thousands of throwaway allocations. The shovel operator (`<<`) appends directly to the receiver's buffer, growing it in place with amortized O(1) cost.

**Incorrect (new string allocated on each iteration):**

```ruby
def export_products_csv(products)
  result = "id,name,price,stock\n"

  products.each do |product|
    result = result + product.id.to_s       # allocates new string, copies entire buffer
    result = result + ","                    # another allocation + copy of everything so far
    result = result + product.name
    result = result + ","
    result = result + product.price.to_s
    result = result + ","
    result = result + product.stock.to_s
    result = result + "\n"                   # 8 allocations per product
  end

  result
end
```

**Correct (mutates in place, single buffer grows as needed):**

```ruby
def export_products_csv(products)
  result = String.new("id,name,price,stock\n")

  products.each do |product|
    result << product.id.to_s
    result << ","
    result << product.name
    result << ","
    result << product.price.to_s
    result << ","
    result << product.stock.to_s
    result << "\n"                           # zero intermediate allocations
  end

  result
end
```
