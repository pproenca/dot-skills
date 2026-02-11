---
title: Ensure Clean Database State Between System Tests
impact: MEDIUM
impactDescription: shared state between system tests causes ordering-dependent failures
tags: system, database-cleaner, truncation, transactions, test-isolation
---

## Ensure Clean Database State Between System Tests

System tests run the application server in a separate thread from the test process. Transactional fixtures wrap each test in a database transaction that is invisible to the server thread — records created in the test are never committed, so the app sees an empty database. Use `database_cleaner` with truncation strategy for system specs while keeping the faster transaction strategy for unit and request specs.

**Incorrect (relying on transactional fixtures in system tests):**

```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.use_transactional_fixtures = true  # Works for model/request specs
end

# spec/system/dashboard_spec.rb
RSpec.describe "Dashboard", type: :system do
  it "displays the user's recent orders" do
    user = create(:user)
    create(:order, user: user, total_cents: 5_000, placed_at: 1.hour.ago)

    sign_in user
    visit dashboard_path

    # FAILS — the Puma server thread cannot see records inside
    # the test's uncommitted transaction
    expect(page).to have_content("$50.00")
  end
end
```

**Correct (truncation for system specs, transactions for everything else):**

```ruby
# Gemfile
gem "database_cleaner-active_record"

# spec/rails_helper.rb
RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :system) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

# spec/system/dashboard_spec.rb
RSpec.describe "Dashboard", type: :system do
  it "displays the user's recent orders" do
    user = create(:user)
    create(:order, user: user, total_cents: 5_000, placed_at: 1.hour.ago)

    sign_in user
    visit dashboard_path

    # Truncation strategy commits records, so the server thread sees them
    expect(page).to have_content("$50.00")
  end
end
```

**Note:** Rails 5.1+ introduced shared database connections for the test server thread, which can eliminate the need for `database_cleaner` in many setups. If you use `driven_by :selenium` with the default configuration, verify whether your Rails version shares the connection before adding the gem.

Reference: [DatabaseCleaner — GitHub](https://github.com/DatabaseCleaner/database_cleaner) | [Rails Testing Guide](https://guides.rubyonrails.org/testing.html#system-testing)
