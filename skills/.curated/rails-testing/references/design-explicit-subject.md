---
title: Prefer Explicit over Implicit Subject
impact: HIGH
impactDescription: makes the system under test immediately visible without mental indirection
tags: design, subject, explicit, readability, rspec
---

## Prefer Explicit over Implicit Subject

RSpec's implicit `subject` and `is_expected` hide what's actually being tested. When you read `is_expected.to be_valid`, you must mentally resolve `subject` to `described_class.new(...)` then trace the arguments. An explicit, named variable communicates the domain concept at a glance and makes the test self-documenting.

**Incorrect (implicit subject obscures intent):**

```ruby
RSpec.describe Reservation do
  subject {
    described_class.new(
      guest: build(:user),
      listing: build(:listing, :available),
      check_in: Date.tomorrow,
      check_out: Date.tomorrow + 3.days
    )
  }

  it { is_expected.to be_valid }

  context "when check-out is before check-in" do
    subject {
      described_class.new(
        guest: build(:user),
        listing: build(:listing, :available),
        check_in: Date.tomorrow + 3.days,
        check_out: Date.tomorrow
      )
    }

    it { is_expected.not_to be_valid }
  end
end
```

**Correct (named variable communicates domain intent):**

```ruby
RSpec.describe Reservation do
  describe "validations" do
    it "is valid with a check-in date before check-out" do
      reservation = Reservation.new(
        guest: build(:user),
        listing: build(:listing, :available),
        check_in: Date.tomorrow,
        check_out: Date.tomorrow + 3.days
      )

      expect(reservation).to be_valid
    end

    it "is invalid when check-out is before check-in" do
      reservation = Reservation.new(
        guest: build(:user),
        listing: build(:listing, :available),
        check_in: Date.tomorrow + 3.days,
        check_out: Date.tomorrow
      )

      expect(reservation).not_to be_valid
      expect(reservation.errors[:check_out]).to include("must be after check-in date")
    end
  end
end
```

**Exception:** `is_expected` is acceptable for one-liner shoulda-matchers where the subject is `described_class.new` with no arguments: `it { is_expected.to validate_presence_of(:email) }`. Even then, prefer explicit subjects in complex specs.

Reference: [RSpec Best Practices — Named Subjects](https://rspec.info/features/3-12/rspec-core/subject/explicit-subject/)
