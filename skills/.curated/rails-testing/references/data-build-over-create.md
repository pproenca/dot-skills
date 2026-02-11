---
title: Prefer build over create
impact: HIGH
impactDescription: avoids unnecessary database writes, 10-50x faster per object
tags: data, factory-bot, build, create, performance
---

## Prefer build over create

`build` instantiates an in-memory object without hitting the database. `build_stubbed` goes further by faking persistence (assigns an `id`, stubs `persisted?`). Only use `create` when the test genuinely requires a persisted record — for example, when testing queries, scopes, or uniqueness constraints that need database state.

**Incorrect (create when the test never queries the database):**

```ruby
RSpec.describe ShippingCalculator do
  describe "#estimate" do
    it "returns free shipping for orders over 50 GBP" do
      order = create(:order, subtotal_cents: 6000, shipping_country: "GB")
      calculator = described_class.new(order)

      estimate = calculator.estimate

      expect(estimate.cost_cents).to eq(0)
      expect(estimate.label).to eq("Free shipping")
    end

    it "returns standard rate for orders under 50 GBP" do
      order = create(:order, subtotal_cents: 3000, shipping_country: "GB")
      calculator = described_class.new(order)

      estimate = calculator.estimate

      expect(estimate.cost_cents).to eq(499)
    end
  end
end
# Two INSERTs + associated records for a pure calculation test
```

**Correct (build for in-memory objects, create only when needed):**

```ruby
RSpec.describe ShippingCalculator do
  describe "#estimate" do
    it "returns free shipping for orders over 50 GBP" do
      order = build(:order, subtotal_cents: 6000, shipping_country: "GB")
      calculator = described_class.new(order)

      estimate = calculator.estimate

      expect(estimate.cost_cents).to eq(0)
      expect(estimate.label).to eq("Free shipping")
    end

    it "returns standard rate for orders under 50 GBP" do
      order = build(:order, subtotal_cents: 3000, shipping_country: "GB")
      calculator = described_class.new(order)

      estimate = calculator.estimate

      expect(estimate.cost_cents).to eq(499)
    end
  end
end

# Use build_stubbed when you need an id without persistence:
RSpec.describe OrderPresenter do
  it "formats the order reference with the id" do
    order = build_stubbed(:order, id: 42)

    expect(described_class.new(order).reference).to eq("ORD-000042")
  end
end

# Use create only when querying the database:
RSpec.describe Order, ".recent" do
  it "returns orders placed within the last 7 days" do
    recent_order = create(:order, placed_at: 3.days.ago)
    _old_order = create(:order, placed_at: 10.days.ago)

    expect(Order.recent).to eq([recent_order])
  end
end
```

Reference: [FactoryBot — Build Strategies](https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md#build-strategies)
