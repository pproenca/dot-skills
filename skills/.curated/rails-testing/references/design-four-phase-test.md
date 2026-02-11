---
title: Use Four-Phase Test Structure
impact: CRITICAL
impactDescription: eliminates mystery guests and obscure tests by making every phase explicit
tags: design, four-phase, setup, exercise, verify, teardown
---

## Use Four-Phase Test Structure

Every test should follow Setup, Exercise, Verify, Teardown (teardown is implicit in RSpec via `after` hooks and database transactions). Separating phases with blank lines makes the test's intent immediately scannable — readers can identify what's being arranged, what action triggers the behavior, and what outcome is expected without parsing interleaved logic.

**Incorrect (phases interleaved, scattered setup across nested contexts):**

```ruby
RSpec.describe OrderService do
  let(:warehouse) { create(:warehouse) }
  let(:product) { create(:product, warehouse: warehouse, stock: 10) }
  let(:customer) { create(:customer, :with_payment_method) }

  describe "#place_order" do
    let(:discount) { create(:discount, percentage: 15) }

    context "when product is in stock" do
      let(:params) { { product_id: product.id, quantity: 2, discount_code: discount.code } }

      it "works" do
        result = described_class.new(customer).place_order(params)
        expect(result).to be_success
        expect(result.order.total).to eq(17.0)
        expect(product.reload.stock).to eq(8)
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
    end
  end
end
```

**Correct (four phases clearly separated, inline setup):**

```ruby
RSpec.describe OrderService do
  describe "#place_order" do
    it "creates an order with discounted total and decrements stock" do
      # Setup
      warehouse = create(:warehouse)
      product = create(:product, warehouse: warehouse, stock: 10, price: 10_00)
      customer = create(:customer, :with_payment_method)
      discount = create(:discount, percentage: 15)

      # Exercise
      result = described_class.new(customer).place_order(
        product_id: product.id,
        quantity: 2,
        discount_code: discount.code
      )

      # Verify
      expect(result).to be_success
      expect(result.order.total_cents).to eq(17_00)
    end

    it "decrements product stock by the ordered quantity" do
      # Setup
      product = create(:product, stock: 10)
      customer = create(:customer, :with_payment_method)

      # Exercise
      described_class.new(customer).place_order(product_id: product.id, quantity: 2)

      # Verify
      expect(product.reload.stock).to eq(8)
    end
  end
end
```

Reference: [Four-Phase Test — xUnit Patterns](http://xunitpatterns.com/Four%20Phase%20Test.html)
