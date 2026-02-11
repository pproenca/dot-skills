---
title: Use Transaction Strategy for Non-System Tests
impact: MEDIUM
impactDescription: transactions are 10-50× faster than truncation for database cleanup
tags: perf, transaction, truncation, speed, database-cleanup
---

## Use Transaction Strategy for Non-System Tests

Transactional cleanup wraps each test in a database transaction and rolls it back at the end — this is essentially free because no rows are ever committed. Truncation physically deletes all rows from every table after each test, which is orders of magnitude slower. Since Rails 5.1+, the shared database connection means transactional fixtures work for system tests too. Only use truncation if your setup requires it (multiple databases, custom drivers).

**Incorrect (truncation strategy for all specs — 10-50× slower cleanup):**

```ruby
# spec/support/database_cleaner.rb
RSpec.configure do |config|
  config.use_transactional_fixtures = false  # Disabled globally

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
```

**Correct (transactional fixtures for all spec types in Rails 7+):**

```ruby
# spec/rails_helper.rb — simplest and fastest approach
RSpec.configure do |config|
  config.use_transactional_fixtures = true  # Instant rollback, zero cost
end

# No database_cleaner gem needed for standard Rails 7+ setups.
# The shared database connection handles system test visibility.
```

**When database_cleaner is still needed:**

```ruby
# Only for multi-database setups or non-standard threading
RSpec.configure do |config|
  config.use_transactional_fixtures = true  # Default for model/request specs

  # Override only for specs that need truncation
  config.before(:each, :truncation) do
    DatabaseCleaner.strategy = :truncation
  end

  config.around(:each, :truncation) do |example|
    DatabaseCleaner.cleaning { example.run }
  end
end
```

Reference: [Rails Testing Guide](https://guides.rubyonrails.org/testing.html) | [Better Specs — Database Cleaning](https://www.betterspecs.org/)
