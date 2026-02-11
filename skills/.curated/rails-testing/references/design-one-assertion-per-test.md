---
title: One Expectation per Test
impact: CRITICAL
impactDescription: reduces failure diagnosis from N assertions to exactly 1 cause
tags: design, single-assertion, expectation, focused-test, aggregate-failures
---

## One Expectation per Test

Each `it` block should verify one logical behavior. When a test contains multiple unrelated assertions, the first failure masks all subsequent checks — you fix one problem, re-run, and discover the next. Separate `it` blocks produce failure output that reads like a specification checklist of exactly what broke.

**Incorrect (multiple unrelated assertions in one test):**

```ruby
RSpec.describe RegistrationService do
  describe "#register" do
    it "registers a new user" do
      params = { email: "new@example.com", name: "Jane", plan: "starter" }

      result = described_class.new.register(params)

      expect(result).to be_success
      expect(User.find_by(email: "new@example.com")).to be_present
      expect(User.last.plan).to eq("starter")
      expect(ActionMailer::Base.deliveries.last.to).to include("new@example.com")
    end
  end
end
```

**Correct (one logical behavior per test, explicit inline setup):**

```ruby
RSpec.describe RegistrationService do
  describe "#register" do
    it "returns a success result" do
      params = { email: "new@example.com", name: "Jane", plan: "starter" }

      result = described_class.new.register(params)

      expect(result).to be_success
    end

    it "persists the user with the correct plan" do
      params = { email: "new@example.com", name: "Jane", plan: "starter" }

      described_class.new.register(params)

      expect(User.find_by(email: "new@example.com")).to have_attributes(plan: "starter")
    end

    it "sends a welcome email to the registered address" do
      params = { email: "new@example.com", name: "Jane", plan: "starter" }

      described_class.new.register(params)

      expect(ActionMailer::Base.deliveries.last.to).to include("new@example.com")
    end
  end
end
```

**Alternative (aggregate_failures for related assertions on the same object):**

```ruby
it "persists the user with complete registration data", :aggregate_failures do
  params = { email: "new@example.com", name: "Jane", plan: "starter" }

  described_class.new.register(params)

  user = User.find_by(email: "new@example.com")
  expect(user.name).to eq("Jane")
  expect(user.plan).to eq("starter")
  expect(user.confirmed_at).to be_nil
end
```

**Note:** Multiple assertions about the same object are fine when they describe a single logical behavior. Use `:aggregate_failures` to report all failures without masking. The rule targets assertions about unrelated behaviors in the same test.

Reference: [Better Specs — Single Expectation](https://www.betterspecs.org/#single)
