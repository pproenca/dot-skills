---
title: Test Validations with Boundary Cases
impact: HIGH
impactDescription: catches data integrity bugs at the cheapest test level
tags: model, validations, shoulda-matchers, boundary-cases, data-integrity
---

## Test Validations with Boundary Cases

Testing that a valid factory builds a valid record tells you nothing — it only proves your factory matches your validations, not that your validations catch bad data. Test each validation by exercising specific invalid states: nil values, boundary lengths, duplicate entries, and malformed formats. Use shoulda-matchers for declarative one-liners and manual specs for nuanced edge cases that one-liners cannot express.

**Incorrect (tautological test that only proves the factory works):**

```ruby
RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      user = build(:user)

      expect(user).to be_valid
    end

    it "is invalid without a name" do
      user = build(:user, name: nil)

      expect(user).not_to be_valid
    end
  end
end
```

**Correct (boundary cases with shoulda-matchers and manual edge cases):**

```ruby
RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    # Declarative one-liners for standard validations
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }

    # Edge cases that one-liners cannot express
    context "when email has valid format edge cases" do
      it "rejects emails without a TLD" do
        user = build(:user, email: "user@localhost")

        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("is invalid")
      end

      it "accepts plus-addressed emails" do
        user = build(:user, email: "user+tag@example.com")

        expect(user).to be_valid
      end
    end

    context "when name is at the boundary length" do
      it "accepts a name of exactly 100 characters" do
        user = build(:user, name: "a" * 100)

        expect(user).to be_valid
      end

      it "rejects a name of 101 characters" do
        user = build(:user, name: "a" * 101)

        expect(user).not_to be_valid
      end
    end

    context "when email uniqueness is tested with different casing" do
      it "rejects a duplicate email with different casing" do
        create(:user, email: "Admin@Example.com")
        user = build(:user, email: "admin@example.com")

        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("has already been taken")
      end
    end
  end
end
```

Reference: [shoulda-matchers — thoughtbot](https://github.com/thoughtbot/shoulda-matchers)
