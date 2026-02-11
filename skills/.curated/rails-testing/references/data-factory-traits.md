---
title: Use Factory Traits for Variations
impact: CRITICAL
impactDescription: eliminates factory explosion and keeps factories maintainable through composition
tags: data, factory-bot, traits, composition, factories
---

## Use Factory Traits for Variations

Traits compose into any combination without creating separate factory definitions for each permutation. Without traits, N variations require N factories; with traits, you compose from a small set. Traits also communicate intent — `create(:user, :admin, :confirmed)` reads like a specification of what kind of user the test needs.

**Incorrect (separate factories for each variation):**

```ruby
# factories/users.rb
FactoryBot.define do
  factory :user do
    name { "Jane Doe" }
    email { generate(:email) }
  end

  factory :admin_user, class: "User" do
    name { "Admin User" }
    email { generate(:email) }
    role { :admin }
  end

  factory :confirmed_user, class: "User" do
    name { "Confirmed User" }
    email { generate(:email) }
    confirmed_at { Time.current }
  end

  factory :admin_confirmed_user, class: "User" do
    name { "Admin Confirmed" }
    email { generate(:email) }
    role { :admin }
    confirmed_at { Time.current }
  end

  # Combinatorial explosion: every new dimension doubles factory count
end
```

**Correct (composable traits on a single factory):**

```ruby
# factories/users.rb
FactoryBot.define do
  factory :user do
    name { "Jane Doe" }
    email { generate(:email) }
    role { :member }
    confirmed_at { nil }

    trait :admin do
      role { :admin }
    end

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :with_avatar do
      after(:build) do |user|
        user.avatar.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/avatar.png")),
          filename: "avatar.png",
          content_type: "image/png"
        )
      end
    end

    trait :deactivated do
      deactivated_at { 1.week.ago }
    end
  end
end

# Usage — any combination, always readable:
create(:user, :admin, :confirmed)
create(:user, :confirmed, :with_avatar)
create(:user, :admin, :deactivated)
```

Reference: [FactoryBot — Traits](https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md#traits)
