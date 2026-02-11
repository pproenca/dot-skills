---
title: One Expectation per Test
impact: CRITICAL
impactDescription: pinpoints failures to exact behavior instead of hiding breakages behind earlier assertions
tags: design, single-assertion, expectation, focused-test
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
      expect(Analytics).to have_received(:track).with("user.registered", anything)
    end
  end
end
```

**Correct (one logical assertion per test):**

```ruby
RSpec.describe RegistrationService do
  describe "#register" do
    let(:params) { { email: "new@example.com", name: "Jane", plan: "starter" } }
    let(:result) { described_class.new.register(params) }

    it "returns a success result" do
      expect(result).to be_success
    end

    it "persists the user with the correct plan" do
      result

      expect(User.find_by(email: "new@example.com")).to have_attributes(plan: "starter")
    end

    it "sends a welcome email to the registered address" do
      result

      expect(ActionMailer::Base.deliveries.last.to).to include("new@example.com")
    end

    it "tracks the registration event in analytics" do
      result

      expect(Analytics).to have_received(:track).with("user.registered", anything)
    end
  end
end
```

**Note:** Multiple assertions about the same object are fine when they describe a single logical behavior — e.g., using `have_attributes` to check several fields on one domain object. The rule targets assertions about unrelated behaviors in the same test.

Reference: [Better Specs — Single Expectation](https://www.betterspecs.org/#single)
