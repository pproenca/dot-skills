---
title: Replace Complex Method with Method Object
impact: HIGH
impactDescription: enables decomposition of tangled logic
tags: struct, method-object, complexity, extract
---

## Replace Complex Method with Method Object

When a method has many interdependent local variables, extracting pieces into separate methods is painful because each piece needs access to all the locals. Turning the method into its own class converts locals into instance variables, making decomposition straightforward.

**Incorrect (tangled calculation with many interdependent locals):**

```ruby
class InvoiceCalculator
  def calculate_tax(invoice)
    line_totals = invoice.line_items.map { |item| item.quantity * item.unit_price }
    subtotal = line_totals.sum

    exempt_total = invoice.line_items
      .select { |item| item.tax_exempt? }
      .sum { |item| item.quantity * item.unit_price }
    taxable_amount = subtotal - exempt_total

    state_rate = TaxTable.rate_for(invoice.shipping_state)
    state_tax = taxable_amount * state_rate

    county_rate = TaxTable.county_rate_for(invoice.shipping_state, invoice.shipping_county)
    county_tax = taxable_amount * county_rate

    # Threshold discount depends on all prior values
    combined_tax = state_tax + county_tax
    discount = combined_tax > 500 ? combined_tax * 0.02 : 0
    total_tax = combined_tax - discount

    surcharge = invoice.expedited? ? total_tax * 0.015 : 0
    final_tax = (total_tax + surcharge).round(2)

    { subtotal: subtotal, taxable_amount: taxable_amount, state_tax: state_tax,
      county_tax: county_tax, discount: discount, surcharge: surcharge, total_tax: final_tax }
  end
end
```

**Correct (extracted to method object with call()):**

```ruby
class InvoiceCalculator
  def calculate_tax(invoice)
    TaxCalculation.new(invoice).call
  end
end

class TaxCalculation
  def initialize(invoice)
    @invoice = invoice
  end

  def call
    compute_subtotals
    compute_tax_rates
    apply_discount
    apply_surcharge

    build_result
  end

  private

  def compute_subtotals
    @subtotal = @invoice.line_items.sum { |item| item.quantity * item.unit_price }
    exempt_total = @invoice.line_items
      .select { |item| item.tax_exempt? }
      .sum { |item| item.quantity * item.unit_price }
    @taxable_amount = @subtotal - exempt_total
  end

  def compute_tax_rates
    state_rate = TaxTable.rate_for(@invoice.shipping_state)
    @state_tax = @taxable_amount * state_rate

    county_rate = TaxTable.county_rate_for(@invoice.shipping_state, @invoice.shipping_county)
    @county_tax = @taxable_amount * county_rate
  end

  def apply_discount
    combined_tax = @state_tax + @county_tax
    @discount = combined_tax > 500 ? combined_tax * 0.02 : 0
    @total_tax = combined_tax - @discount
  end

  def apply_surcharge
    @surcharge = @invoice.expedited? ? @total_tax * 0.015 : 0
    @total_tax = (@total_tax + @surcharge).round(2)
  end

  def build_result
    { subtotal: @subtotal, taxable_amount: @taxable_amount, state_tax: @state_tax,
      county_tax: @county_tax, discount: @discount, surcharge: @surcharge, total_tax: @total_tax }
  end
end
```

Reference: [Replace Function with Command](https://refactoring.com/catalog/replaceFunctionWithCommand.html)
