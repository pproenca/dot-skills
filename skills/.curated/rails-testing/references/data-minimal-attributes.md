---
title: Build Objects with Minimal Attributes
impact: CRITICAL
impactDescription: speeds up test data creation and clarifies which attributes actually matter for the test
tags: data, factory-bot, minimal, build, attributes
---

## Build Objects with Minimal Attributes

Only specify attributes that are relevant to the behavior under test. Let factory defaults handle everything else. Over-specified factories obscure which attributes actually affect the test outcome and create coupling to unrelated fields — if you change the `name` column, tests about email validation shouldn't break.

**Incorrect (over-specified attributes, unclear what matters):**

```ruby
RSpec.describe User do
  describe "#eligible_for_trial?" do
    it "returns false when the user has an active subscription" do
      user = create(:user,
        name: "John Smith",
        email: "john@example.com",
        phone: "+44 20 7946 0958",
        date_of_birth: Date.new(1990, 5, 15),
        address_line_1: "123 Main St",
        city: "London",
        postcode: "SW1A 1AA",
        role: "member",
        subscription_status: "active",  # <-- only this matters
        subscription_started_at: 6.months.ago,
        referral_source: "google",
        marketing_opt_in: true
      )

      expect(user.eligible_for_trial?).to be false
    end
  end
end
```

**Correct (only the relevant attribute, factory handles the rest):**

```ruby
RSpec.describe User do
  describe "#eligible_for_trial?" do
    it "returns false when the user has an active subscription" do
      user = build(:user, subscription_status: "active")

      expect(user.eligible_for_trial?).to be false
    end

    it "returns true when the user has never subscribed" do
      user = build(:user, subscription_status: nil)

      expect(user.eligible_for_trial?).to be true
    end
  end
end
```

**Guideline:** If an attribute is specified in a test, it should be because changing that attribute would change the test outcome. If removing it doesn't break the test, remove it.

Reference: [Thoughtbot — Writing Better Tests with FactoryBot](https://thoughtbot.com/blog/factory-bot)
