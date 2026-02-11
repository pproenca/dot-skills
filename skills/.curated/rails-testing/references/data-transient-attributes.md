---
title: Use Transient Attributes for Complex Setup
impact: MEDIUM-HIGH
impactDescription: keeps factory interface clean while supporting complex multi-step scenarios
tags: data, factory-bot, transient, callbacks, complex-setup
---

## Use Transient Attributes for Complex Setup

Transient attributes are factory parameters that don't map to model columns. They control `after(:build)` or `after(:create)` callbacks to set up associated records, conditional logic, or multi-step state. Without them, tests end up with repetitive manual setup that obscures the scenario being tested.

**Incorrect (manual multi-step setup repeated across tests):**

```ruby
RSpec.describe Dashboard::SummaryQuery do
  describe "#call" do
    it "returns the correct published article count for the author" do
      author = create(:user)
      create(:article, author: author, status: :published, published_at: 1.day.ago)
      create(:article, author: author, status: :published, published_at: 2.days.ago)
      create(:article, author: author, status: :published, published_at: 3.days.ago)
      create(:article, author: author, status: :draft)
      create(:article, author: author, status: :draft)

      summary = described_class.new(author).call

      expect(summary.published_count).to eq(3)
    end
  end
end
```

**Correct (transient attributes encapsulate complex setup):**

```ruby
# factories/users.rb
FactoryBot.define do
  factory :user do
    name { "Jane Doe" }
    email { generate(:email) }

    trait :with_articles do
      transient do
        published_count { 0 }
        draft_count { 0 }
      end

      after(:create) do |user, evaluator|
        create_list(:article, evaluator.published_count, :published, author: user)
        create_list(:article, evaluator.draft_count, author: user)
      end
    end
  end
end

# spec/queries/dashboard/summary_query_spec.rb
RSpec.describe Dashboard::SummaryQuery do
  describe "#call" do
    it "returns the correct published article count for the author" do
      author = create(:user, :with_articles, published_count: 3, draft_count: 2)

      summary = described_class.new(author).call

      expect(summary.published_count).to eq(3)
    end

    it "returns zero when the author has no published articles" do
      author = create(:user, :with_articles, published_count: 0, draft_count: 4)

      summary = described_class.new(author).call

      expect(summary.published_count).to eq(0)
    end
  end
end
```

**Note:** Keep transient attributes in traits rather than the base factory — not every test needs the overhead of associated records, and traits make the factory composable.

Reference: [FactoryBot — Transient Attributes](https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md#transient-attributes)
