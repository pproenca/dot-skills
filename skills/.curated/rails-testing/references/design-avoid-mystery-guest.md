---
title: Avoid Mystery Guest Anti-Pattern
impact: CRITICAL
impactDescription: removes hidden dependencies between test and setup defined elsewhere
tags: design, mystery-guest, readability, inline-setup, self-contained
---

## Avoid Mystery Guest Anti-Pattern

All data needed to understand a test must be visible in the test itself. When a test references `user`, `order`, or `product` defined in a `let` block 80 lines up or in a shared context file, readers must scroll or jump to multiple locations to understand what the test actually does. Inline the data that matters and only extract truly shared, well-named helpers.

**Incorrect (mystery guest — test depends on invisible setup):**

```ruby
RSpec.describe RefundPolicy do
  let(:store) { create(:store, :premium) }
  let(:customer) { create(:customer, store: store, tier: :gold) }
  let(:product) { create(:product, store: store, price_cents: 5000, returnable: true) }
  let(:order) { create(:order, customer: customer, product: product, placed_at: 20.days.ago) }

  describe "#eligible?" do
    context "when within return window" do
      # Reader must scroll up to understand: what tier? what product? when was it placed?
      it "returns true" do
        policy = described_class.new(order)

        expect(policy).to be_eligible
      end
    end
  end
end
```

**Correct (self-contained — relevant data is inline):**

```ruby
RSpec.describe RefundPolicy do
  describe "#eligible?" do
    context "when the order is within the 30-day return window" do
      it "returns true for a returnable product" do
        customer = create(:customer, tier: :gold)
        order = create(:order,
          customer: customer,
          product: create(:product, returnable: true),
          placed_at: 20.days.ago
        )

        policy = described_class.new(order)

        expect(policy).to be_eligible
      end
    end

    context "when the order is past the 30-day return window" do
      it "returns false regardless of customer tier" do
        order = create(:order,
          product: create(:product, returnable: true),
          placed_at: 31.days.ago
        )

        policy = described_class.new(order)

        expect(policy).not_to be_eligible
      end
    end
  end
end
```

**Guideline:** If you must use `let`, keep it within 5-10 lines of the test that uses it, and name it to communicate its role in the test — not just its type.

Reference: [Mystery Guest — xUnit Patterns](http://xunitpatterns.com/Mystery%20Guest.html)
