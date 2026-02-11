---
title: Test Public Methods with Input/Output Pairs
impact: MEDIUM-HIGH
impactDescription: model methods are the core of domain logic
tags: model, methods, domain-logic, edge-cases, context-blocks
---

## Test Public Methods with Input/Output Pairs

Model methods contain your domain logic — the business rules that define what your application actually does. A single happy-path test misses the edge cases where bugs hide: nil inputs, empty strings, boundary values, and unicode characters. Use `context` blocks to organize scenarios by input condition, making it immediately clear which cases are covered and which are missing.

**Incorrect (single happy-path test with no edge case coverage):**

```ruby
RSpec.describe User, type: :model do
  describe "#full_name" do
    it "returns the full name" do
      user = build(:user, first_name: "Jane", last_name: "Doe")

      expect(user.full_name).to eq("Jane Doe")
    end
  end

  describe "#trial_days_remaining" do
    it "returns the remaining days" do
      user = build(:user, trial_ends_at: 5.days.from_now)

      expect(user.trial_days_remaining).to eq(5)
    end
  end
end
```

**Correct (comprehensive input/output coverage with context blocks):**

```ruby
RSpec.describe User, type: :model do
  describe "#full_name" do
    context "when both names are present" do
      it "joins first and last name with a space" do
        user = build(:user, first_name: "Jane", last_name: "Doe")

        expect(user.full_name).to eq("Jane Doe")
      end
    end

    context "when first_name is nil" do
      it "returns only the last name without leading space" do
        user = build(:user, first_name: nil, last_name: "Doe")

        expect(user.full_name).to eq("Doe")
      end
    end

    context "when last_name is nil" do
      it "returns only the first name without trailing space" do
        user = build(:user, first_name: "Jane", last_name: nil)

        expect(user.full_name).to eq("Jane")
      end
    end

    context "when names contain unicode characters" do
      it "handles diacritics and CJK characters" do
        user = build(:user, first_name: "Jose", last_name: "Garcia")

        expect(user.full_name).to eq("Jose Garcia")
      end
    end

    context "when names have leading or trailing whitespace" do
      it "strips extra whitespace" do
        user = build(:user, first_name: "  Jane  ", last_name: "  Doe  ")

        expect(user.full_name).to eq("Jane Doe")
      end
    end
  end

  describe "#trial_days_remaining" do
    context "when trial is active" do
      it "returns the number of days until trial expires" do
        user = build(:user, trial_ends_at: 5.days.from_now)

        expect(user.trial_days_remaining).to eq(5)
      end
    end

    context "when trial expires today" do
      it "returns zero" do
        user = build(:user, trial_ends_at: Time.current.end_of_day)

        expect(user.trial_days_remaining).to eq(0)
      end
    end

    context "when trial has expired" do
      it "returns a negative number" do
        user = build(:user, trial_ends_at: 3.days.ago)

        expect(user.trial_days_remaining).to eq(-3)
      end
    end

    context "when trial_ends_at is nil" do
      it "returns nil for users without a trial" do
        user = build(:user, trial_ends_at: nil)

        expect(user.trial_days_remaining).to be_nil
      end
    end
  end
end
```

Reference: [Better Specs — Describe Your Methods](https://www.betterspecs.org/#describe)
