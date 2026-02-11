---
title: Use Sequences for Unique Attributes
impact: MEDIUM-HIGH
impactDescription: prevents uniqueness constraint violations in parallel and multi-record tests
tags: data, factory-bot, sequence, uniqueness, parallel-tests
---

## Use Sequences for Unique Attributes

Hardcoded values for unique database columns cause `ActiveRecord::RecordNotUnique` errors the moment a test creates more than one record of that type. Sequences generate unique values deterministically, and they work correctly with parallel test runners like `parallel_tests` where multiple processes create records simultaneously.

**Incorrect (hardcoded values violate uniqueness constraints):**

```ruby
# factories/users.rb
FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { "test@example.com" }  # Fails on second create(:user)
    username { "testuser" }        # Same problem
  end
end

# spec/models/team_spec.rb
RSpec.describe Team do
  describe "#member_emails" do
    it "returns all member email addresses" do
      team = create(:team)
      create(:user, team: team)  # OK
      create(:user, team: team)  # BOOM: ActiveRecord::RecordNotUnique

      expect(team.member_emails.size).to eq(2)
    end
  end
end
```

**Correct (sequences guarantee uniqueness):**

```ruby
# factories/users.rb
FactoryBot.define do
  sequence(:email) { |n| "user#{n}@example.com" }
  sequence(:username) { |n| "user_#{n}" }

  factory :user do
    name { "Test User" }
    email
    username

    trait :with_custom_domain do
      transient do
        domain { "company.com" }
      end
      email { generate(:email).gsub("example.com", domain) }
    end
  end
end

# spec/models/team_spec.rb
RSpec.describe Team do
  describe "#member_emails" do
    it "returns all member email addresses" do
      team = create(:team)
      create_list(:user, 3, team: team)

      expect(team.member_emails.size).to eq(3)
    end
  end
end
```

**Alternative (inline sequence for factory-scoped uniqueness):**

```ruby
FactoryBot.define do
  factory :api_key do
    sequence(:token) { |n| "tok_#{SecureRandom.hex(8)}_#{n}" }
    sequence(:name) { |n| "API Key #{n}" }
  end
end
```

Reference: [FactoryBot — Sequences](https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md#sequences)
