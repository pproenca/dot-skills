---
title: Encapsulate Collections Behind Domain Methods
impact: MEDIUM-HIGH
impactDescription: prevents external mutation and scatters
tags: data, encapsulate, collection, immutability
---

## Encapsulate Collections Behind Domain Methods

Exposing a raw collection via `attr_accessor` lets any caller add, remove, or replace items without validation. Business rules like quantity limits or duplicate checks get scattered across every call site, and a single `items.clear` can silently violate invariants. Encapsulating the collection behind domain methods keeps mutation controlled and auditable.

**Incorrect (exposed collection allows uncontrolled mutation):**

```ruby
class ShoppingCart
  attr_accessor :items

  def initialize
    @items = []
  end

  def total
    items.sum { |item| item.price * item.quantity }
  end
end

cart = ShoppingCart.new
cart.items << CartItem.new(sku: "SHOE-42", price: 89.99, quantity: 1)
cart.items << CartItem.new(sku: "SHOE-42", price: 89.99, quantity: 1) # duplicate — no guard
cart.items.clear # caller can silently empty the cart
```

**Correct (frozen collection with domain methods enforcing rules):**

```ruby
class ShoppingCart
  def initialize
    @items = []
  end

  def items
    @items.dup.freeze # external callers get a frozen snapshot
  end

  def add_item(item)
    existing = @items.find { |i| i.sku == item.sku }
    if existing
      existing.increment_quantity(item.quantity)
    else
      @items << item
    end
    self
  end

  def remove_item(sku)
    @items.reject! { |item| item.sku == sku }
    self
  end

  def total
    @items.sum { |item| item.price * item.quantity }
  end
end

cart = ShoppingCart.new
cart.add_item(CartItem.new(sku: "SHOE-42", price: 89.99, quantity: 1))
cart.add_item(CartItem.new(sku: "SHOE-42", price: 89.99, quantity: 1)) # merges quantity
cart.items << CartItem.new(sku: "HAT-01", price: 24.99, quantity: 1) # raises FrozenError
```
