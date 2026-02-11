---
title: Quarantine Flaky Tests Instead of Retrying
impact: MEDIUM
impactDescription: reduces CI waste by 30-50% vs auto-retry approach
tags: perf, flaky-tests, quarantine, ci, reliability
---

## Quarantine Flaky Tests Instead of Retrying

Auto-retrying failed tests is a tax on every CI run — it doubles the time for flaky specs and trains the team to ignore failures. Instead, tag flaky tests with a quarantine label, exclude them from the main suite, and run them in a separate non-blocking CI job. This keeps the main build fast and green while giving you a visible backlog of tests that need root-cause analysis (usually timing issues, order-dependent state, or external service dependencies).

**Incorrect (auto-retry hides flaky tests and wastes CI time):**

```ruby
# spec/support/retry.rb — blanket retry for all failures
RSpec.configure do |config|
  config.around(:each) do |example|
    attempts = 0
    begin
      attempts += 1
      example.run
      raise example.exception if example.exception
    rescue StandardError
      retry if attempts < 3
    end
  end
end

# CI output shows "passed" but the test failed twice before passing.
# Nobody investigates, the flaky test stays forever.
# CI time increases by retry overhead on every run.
```

**Correct (quarantine tag isolates flaky tests for focused investigation):**

```ruby
# spec/support/quarantine.rb
RSpec.configure do |config|
  # Exclude quarantined tests from the default suite
  config.filter_run_excluding quarantine: true

  # When specifically running quarantined tests, only run those
  config.filter_run_including quarantine: true if ENV["RUN_QUARANTINE"]
end

# spec/system/payment_checkout_spec.rb — tagged as quarantined with a reason
RSpec.describe "Payment checkout", type: :system do
  it "processes a Stripe payment end-to-end", :quarantine, quarantine_reason: "Stripe webhook timing" do
    customer = create(:customer, :with_card)

    visit new_checkout_path
    CheckoutPage.new.complete_purchase(customer: customer)

    expect(page).to have_text("Payment confirmed")
  end
end

# .github/workflows/ci.yml
# Main suite (blocking): excludes quarantined tests
# jobs:
#   test:
#     steps:
#       - run: bundle exec rspec
#
# Quarantine suite (non-blocking, runs separately):
#   quarantine:
#     continue-on-error: true
#     steps:
#       - run: RUN_QUARANTINE=1 bundle exec rspec

# Track quarantined tests count as a metric — it should trend toward zero.
```

Reference: [Quarantine — Test Flakiness at Scale](https://engineering.atspotify.com/2019/11/test-flakiness-methods-for-identifying-and-dealing-with-flaky-tests/) | [rspec-retry gem (use sparingly)](https://github.com/NoRedInk/rspec-retry)
