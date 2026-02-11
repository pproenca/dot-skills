---
title: Use Transaction Strategy for Non-System Tests
impact: MEDIUM
impactDescription: transactions are 10-50x faster than truncation for database cleanup
tags: perf, database-cleaner, transaction, truncation, speed
---

## Use Transaction Strategy for Non-System Tests

Transactional cleanup wraps each test in a database transaction and rolls it back at the end — this is essentially free because no rows are ever committed. Truncation physically deletes all rows from every table after each test, which is orders of magnitude slower. Only system tests (Capybara with a real browser) need truncation because the test server runs in a separate thread that cannot see the test's uncommitted transaction. Using truncation everywhere is the single most common cause of unnecessarily slow test suites.

**Incorrect (truncation strategy for all specs — 10-50x slower cleanup):**

```ruby
# spec/support/database_cleaner.rb
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

# spec/rails_helper.rb
config.use_transactional_fixtures = false  # Disabled globally to use DatabaseCleaner
```

**Correct (transactions by default, truncation only for system specs):**

```ruby
# spec/rails_helper.rb — Rails' built-in transactional fixtures handle most specs
RSpec.configure do |config|
  config.use_transactional_fixtures = true
end

# spec/support/database_cleaner.rb — only override for system tests
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_chrome_headless
  end

  # Only use DatabaseCleaner for system specs where threads don't share connections
  config.before(:each, type: :system) do
    DatabaseCleaner.strategy = :truncation
  end

  config.around(:each, type: :system) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

# Model and request specs use transactional fixtures — instant rollback, zero cost.
# System specs use truncation — slower but necessary for cross-thread visibility.
```

Reference: [DatabaseCleaner — Recommended Strategy](https://github.com/DatabaseCleaner/database_cleaner#how-to-use) | [Better Specs — Database Cleaning](https://www.betterspecs.org/)
