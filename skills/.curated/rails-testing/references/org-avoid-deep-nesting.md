---
title: Limit Context Nesting to 3 Levels
impact: LOW-MEDIUM
impactDescription: deep nesting creates puzzle specs that require scrolling to understand setup
tags: org, nesting, readability, context, describe
---

## Limit Context Nesting to 3 Levels

When describe/context blocks nest beyond 3 levels, the reader must hold multiple conditions in their head simultaneously and scroll up to reconstruct the full setup. Each nesting level also encourages more `let` overrides, which compound into mystery-guest setups where the effective state at any given `it` block is nearly impossible to trace. Flatten deeply nested specs into separate `describe` blocks with inline setup, or extract complex conditions into well-named helper methods.

**Incorrect (5 levels deep — reader must scroll through 40+ lines to understand context):**

```ruby
RSpec.describe OrderFulfillment do
  describe "#fulfill" do
    context "when the order has physical items" do
      let(:order) { create(:order, :with_physical_items) }

      context "when shipping address is domestic" do
        before { order.update!(shipping_country: "US") }

        context "when order qualifies for free shipping" do
          before { order.update!(subtotal_cents: 100_00) }

          context "when warehouse has stock" do
            before { create(:inventory, product: order.items.first.product, quantity: 10) }

            context "when payment is captured" do
              before { order.payment.capture! }

              it "creates a shipment with free shipping" do
                result = described_class.new(order).fulfill

                expect(result.shipment.cost_cents).to eq(0)
              end
            end
          end
        end
      end
    end
  end
end
```

**Correct (max 3 levels with inline setup — each test is self-contained):**

```ruby
RSpec.describe OrderFulfillment do
  describe "#fulfill" do
    context "when a domestic order qualifies for free shipping" do
      it "creates a shipment with zero cost" do
        order = create(:order, :with_physical_items,
          shipping_country: "US",
          subtotal_cents: 100_00
        )
        create(:inventory, product: order.items.first.product, quantity: 10)
        order.payment.capture!

        result = described_class.new(order).fulfill

        expect(result.shipment.cost_cents).to eq(0)
      end
    end

    context "when warehouse is out of stock" do
      it "returns a backorder result" do
        order = create(:order, :with_physical_items, shipping_country: "US")
        order.payment.capture!
        # No inventory created — out of stock

        result = described_class.new(order).fulfill

        expect(result).to be_backordered
      end
    end

    context "when shipping internationally" do
      it "calculates international shipping rate" do
        order = create(:order, :with_physical_items, shipping_country: "DE")
        create(:inventory, product: order.items.first.product, quantity: 5)
        order.payment.capture!

        result = described_class.new(order).fulfill

        expect(result.shipment.cost_cents).to be > 0
      end
    end
  end
end
```

Reference: [Better Specs — Contexts](https://www.betterspecs.org/) | [thoughtbot — Let's Not](https://thoughtbot.com/blog/lets-not)
