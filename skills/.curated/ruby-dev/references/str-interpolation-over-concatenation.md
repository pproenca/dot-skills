---
title: Use String Interpolation Over Concatenation
impact: MEDIUM-HIGH
impactDescription: single allocation vs N intermediate strings
tags: str, interpolation, concatenation, allocation
---

## Use String Interpolation Over Concatenation

Each `+` between strings allocates and copies an intermediate result. With four fragments you get three throwaway strings before the final one. Interpolation compiles to a single `String#new` that sizes the buffer once and fills it in order, producing exactly one object regardless of how many expressions are embedded.

**Incorrect (intermediate string per concatenation):**

```ruby
def order_summary(user, order)
  greeting = "Hello, " + user.name + "! "                   # 2 intermediate strings
  details = "Your order #" + order.reference + " for " +
            order.total.to_s + " was placed on " +
            order.placed_at.strftime("%B %d, %Y") + "."     # 4 intermediate strings
  greeting + details                                         # 1 more to join them
end

def product_url(product)
  "/products/" + product.category.slug + "/" + product.slug  # 2 throwaway strings
end
```

**Correct (single allocation per string):**

```ruby
def order_summary(user, order)
  greeting = "Hello, #{user.name}! "
  details = "Your order ##{order.reference} for #{order.total}" \
            " was placed on #{order.placed_at.strftime("%B %d, %Y")}."
  "#{greeting}#{details}"
end

def product_url(product)
  "/products/#{product.category.slug}/#{product.slug}"
end
```
