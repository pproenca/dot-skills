---
title: Use Endless Method Definition for Simple Methods
impact: MEDIUM
impactDescription: reduces noise for one-liner methods
tags: modern, endless-method, syntax, readability
---

## Use Endless Method Definition for Simple Methods

Three-line method definitions that simply return a single expression add visual noise without adding clarity. Ruby 3.0+ endless methods (`def name = expr`) eliminate the `end` keyword and make the intent immediately scannable, similar to how `attr_reader` signals simple accessors. Reserve this for truly simple expressions -- anything requiring multiple statements or complex logic should keep the traditional form.

**Incorrect (verbose definitions for single-expression methods):**

```ruby
class Invoice
  attr_reader :line_items, :tax_rate, :customer

  def subtotal
    line_items.sum(&:total)  # 3 lines for a one-expression method
  end

  def tax_amount
    subtotal * tax_rate
  end

  def total
    subtotal + tax_amount
  end

  def display_name
    "#{customer.company} - Invoice ##{id}"
  end

  def overdue?
    due_date < Date.today
  end
end
```

**Correct (endless methods for single expressions):**

```ruby
class Invoice
  attr_reader :line_items, :tax_rate, :customer

  def subtotal = line_items.sum(&:total)  # reads like a declaration, not a procedure
  def tax_amount = subtotal * tax_rate
  def total = subtotal + tax_amount
  def display_name = "#{customer.company} - Invoice ##{id}"
  def overdue? = due_date < Date.today

  # Keep traditional form for methods with side effects or multiple statements
  def finalize!
    validate_line_items!
    self.status = :finalized
    save!
  end
end
```
