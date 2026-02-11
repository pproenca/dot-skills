---
title: Test Behavior, Not Implementation
impact: CRITICAL
impactDescription: prevents fragile tests that break on every refactoring
tags: design, behavior, implementation, coupling, refactoring
---

## Test Behavior, Not Implementation

Assert on observable outcomes — return values, state changes, side effects — not on how the code internally achieves them. Tests coupled to implementation details (internal method calls, private state, execution order) break every time you refactor, even when the behavior is unchanged. This creates a test suite that punishes improvement instead of protecting it.

**Incorrect (testing internal method calls and execution order):**

```ruby
RSpec.describe SubscriptionService do
  describe "#activate" do
    it "activates the subscription" do
      user = create(:user)
      service = described_class.new(user)

      expect(service).to receive(:check_eligibility).and_return(true)
      expect(service).to receive(:provision_entitlements).with(user)
      expect(service).to receive(:schedule_renewal).with(kind_of(Date))
      expect(StripeGateway).to receive(:create_subscription)
        .with(customer_id: user.stripe_id, price_id: "price_pro")
        .and_return(double(id: "sub_123"))

      service.activate(plan: :pro)
    end
  end
end
```

**Correct (testing observable outcomes):**

```ruby
RSpec.describe SubscriptionService do
  describe "#activate" do
    it "transitions the user to an active subscription on the requested plan" do
      user = create(:user, :eligible)

      result = described_class.new(user).activate(plan: :pro)

      expect(result).to be_success
      expect(user.reload.subscription).to have_attributes(
        plan: "pro",
        status: "active",
        expires_at: be_within(1.second).of(1.year.from_now)
      )
    end

    it "provisions the correct feature entitlements for the plan" do
      user = create(:user, :eligible)

      described_class.new(user).activate(plan: :pro)

      expect(user.reload.entitlements.map(&:feature)).to include(
        "unlimited_searches",
        "priority_support",
        "api_access"
      )
    end

    it "returns a failure when the user is not eligible" do
      user = create(:user, :ineligible)

      result = described_class.new(user).activate(plan: :pro)

      expect(result).to be_failure
      expect(result.error).to eq("User does not meet eligibility requirements")
    end
  end
end
```

Reference: [Better Specs — Testing Behavior](https://www.betterspecs.org/)
