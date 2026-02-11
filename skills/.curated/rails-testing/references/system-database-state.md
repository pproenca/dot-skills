---
title: Ensure Clean Database State Between System Tests
impact: MEDIUM
impactDescription: prevents 100% of cross-test data leakage in multi-threaded system specs
tags: system, database, transactions, test-isolation, shared-connection
---

## Ensure Clean Database State Between System Tests

Since Rails 5.1, the test and server threads share a database connection by default, meaning `use_transactional_fixtures = true` works for system tests out of the box. This is the recommended approach for Rails 7+ — no extra gems needed. Only reach for `database_cleaner` with truncation if you use multiple databases, a custom Capybara driver that doesn't share connections, or a non-standard threading setup.

**Incorrect (adding database_cleaner when Rails handles it natively):**

```ruby
# Gemfile — unnecessary dependency for Rails 7+
gem "database_cleaner-active_record"

# spec/rails_helper.rb
RSpec.configure do |config|
  config.use_transactional_fixtures = false  # Disabled to use DatabaseCleaner

  config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }
  config.before(:each) { DatabaseCleaner.strategy = :transaction }
  config.before(:each, type: :system) { DatabaseCleaner.strategy = :truncation }
  config.before(:each) { DatabaseCleaner.start }
  config.after(:each) { DatabaseCleaner.clean }
end
# Truncation is 10-50× slower than transactions and adds gem maintenance overhead
```

**Correct (Rails 7+ shared connection — transactional fixtures work for system tests):**

```ruby
# spec/rails_helper.rb — no extra gems needed
RSpec.configure do |config|
  config.use_transactional_fixtures = true  # Works for ALL spec types in Rails 7+

  config.before(:each, type: :system) do
    driven_by :selenium_chrome_headless
  end
end

# spec/system/dashboard_spec.rb
RSpec.describe "Dashboard", type: :system do
  it "displays the user's recent orders" do
    user = create(:user)
    create(:order, user: user, total_cents: 5_000, placed_at: 1.hour.ago)

    sign_in user
    visit dashboard_path

    # Server thread shares the DB connection — sees test data without commit
    expect(page).to have_content("$50.00")
  end
end
```

**When to use database_cleaner with truncation:**
- Multiple databases where connections aren't shared
- Custom Capybara drivers that spawn separate processes
- Pre-Rails 5.1 applications

Reference: [Rails System Testing Guide](https://guides.rubyonrails.org/testing.html#system-testing) | [Rails 5.1 Release Notes](https://guides.rubyonrails.org/5_1_release_notes.html)
