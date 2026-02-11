---
title: Run Tests in Parallel
impact: MEDIUM
impactDescription: 60-90% reduction in CI time by distributing specs across CPU cores
tags: perf, parallel, ci, speed, parallel-tests
---

## Run Tests in Parallel

A sequential test suite that grows beyond 10 minutes destroys developer feedback loops and discourages running the full suite locally. Use the `parallel_tests` gem to split specs across CPU cores. Each worker gets its own numbered database (e.g., `myapp_test2`, `myapp_test3`) to avoid transaction conflicts.

**Incorrect (entire suite runs sequentially on a single process):**

```ruby
# Gemfile — no parallelization configured
group :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
end

# .github/workflows/ci.yml
# Single-process run: 35 minutes on a 4-core runner
jobs:
  test:
    steps:
      - run: bundle exec rspec

# spec/rails_helper.rb — no parallel configuration
RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
```

**Correct (parallel_tests gem splits across all available cores):**

```ruby
# Gemfile
group :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "parallel_tests"
end

# .github/workflows/ci.yml — parallel execution: ~8 minutes on same runner
jobs:
  test:
    steps:
      - run: bundle exec rake parallel:setup
      - run: bundle exec rake parallel:spec

# config/database.yml — each worker gets its own database
test:
  database: myapp_test<%= ENV["TEST_ENV_NUMBER"] %>

# spec/rails_helper.rb
RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
```

**CI optimization — split across matrix workers:**

```yaml
# .github/workflows/ci.yml — distribute across CI nodes for even faster runs
jobs:
  test:
    strategy:
      matrix:
        ci_node_total: [4]
        ci_node_index: [0, 1, 2, 3]
    steps:
      - run: bundle exec rake parallel:setup
      - run: |
          bundle exec parallel_test spec/ \
            --type rspec \
            -n ${{ matrix.ci_node_total }} \
            --only-group ${{ matrix.ci_node_index }}
```

Reference: [parallel_tests gem](https://github.com/grosser/parallel_tests)
