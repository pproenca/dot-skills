---
title: Never Mutate State in before(:all)
impact: MEDIUM-HIGH
impactDescription: prevents 100% of ordering-dependent failures from shared before(:all) state
tags: perf, before-all, shared-state, test-isolation, let
---

## Never Mutate State in before(:all)

`before(:all)` (aliased as `before(:context)`) runs once before all examples in a group, and its side effects persist across every example — including database records, instance variables, and in-memory state. Unlike `before(:each)`, there is no automatic transaction rollback between examples. If one test modifies a record created in `before(:all)`, every subsequent test sees that mutation. This creates ordering-dependent failures that only appear when tests run in a different order or in parallel.

**Incorrect (before(:all) creates shared records that leak mutations between tests):**

```ruby
RSpec.describe Subscription do
  before(:all) do
    @plan = create(:plan, price_cents: 999, trial_days: 14)
    @user = create(:user)
    @subscription = create(:subscription, user: @user, plan: @plan)
  end

  it "starts with a trial period" do
    expect(@subscription.trial?).to be true
  end

  it "can be cancelled" do
    @subscription.cancel!  # Mutation persists — @subscription is now cancelled for all later tests

    expect(@subscription).to be_cancelled
  end

  it "renews after trial ends" do
    # FAILS: @subscription was cancelled by the previous test
    travel_to 15.days.from_now do
      expect(@subscription.renewable?).to be true
    end
  end

  after(:all) do
    # Manual cleanup required — easy to forget, doesn't rollback mid-test mutations
    Subscription.delete_all
    User.delete_all
    Plan.delete_all
  end
end
```

**Correct (let and before(:each) provide isolated state per example):**

```ruby
RSpec.describe Subscription do
  let(:plan) { create(:plan, price_cents: 999, trial_days: 14) }
  let(:user) { create(:user) }
  let(:subscription) { create(:subscription, user: user, plan: plan) }

  it "starts with a trial period" do
    expect(subscription.trial?).to be true
  end

  it "can be cancelled" do
    subscription.cancel!

    expect(subscription).to be_cancelled
  end

  it "renews after trial ends" do
    # Each test gets a fresh subscription — this works regardless of test order
    travel_to 15.days.from_now do
      expect(subscription.renewable?).to be true
    end
  end
end

# If you need expensive one-time setup (e.g., seed reference data), use before(:all)
# ONLY for read-only data that no test will ever modify:
RSpec.describe TaxCalculator do
  before(:all) do
    @tax_rates = YAML.load_file(Rails.root.join("config/tax_rates.yml")).freeze
  end

  it "calculates UK VAT" do
    calculator = described_class.new(rates: @tax_rates)

    expect(calculator.compute(country: "GB", amount: 100_00)).to eq(120_00)
  end
end
```

Reference: [RSpec before and after hooks](https://rspec.info/features/3-12/rspec-core/hooks/before-and-after-hooks/) | [Better Specs — Let and Before](https://www.betterspecs.org/)
