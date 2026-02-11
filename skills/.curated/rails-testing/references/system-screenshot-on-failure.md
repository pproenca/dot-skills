---
title: Capture Screenshots on System Test Failure
impact: LOW-MEDIUM
impactDescription: saves debugging time when CI system tests fail without visual context
tags: system, screenshot, debugging, ci, failure
---

## Capture Screenshots on System Test Failure

When a system test fails on CI, the error message alone rarely explains what the user saw — was it a blank page, a 500 error, or an unexpected redirect? Automatic screenshots on failure give immediate visual context. Rails 7+ captures screenshots by default when using `driven_by`, but custom setups or older versions need explicit configuration. Store screenshots as CI artifacts so they persist after the build.

**Incorrect (no screenshot capture, debugging CI failures blind):**

```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  # No failure hooks — when a system test fails on CI,
  # developers must reproduce locally to see what happened
end

# CI output:
# Failure/Error: expect(page).to have_content("Welcome back")
#   expected to find text "Welcome back" in "We're sorry, something went wrong"
# (No screenshot, no way to see the actual page state)
```

**Correct (automatic screenshots on failure with CI artifact storage):**

```ruby
# spec/support/capybara.rb
RSpec.configure do |config|
  config.after(:each, type: :system) do |example|
    if example.exception
      timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
      filename = "#{example.full_description.parameterize}-#{timestamp}.png"
      screenshot_path = Rails.root.join("tmp", "screenshots", filename)

      page.save_screenshot(screenshot_path)
      puts "\n  Screenshot saved: #{screenshot_path}"
    end
  end
end

# spec/system/application_system_test_case.rb (Rails 7+ built-in approach)
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1000]

  # Rails 7+ automatically calls `take_screenshot` on failure
  # Screenshots are saved to tmp/screenshots/
end

# .github/workflows/ci.yml (store screenshots as CI artifacts)
# - name: Upload screenshots
#   if: failure()
#   uses: actions/upload-artifact@v4
#   with:
#     name: system-test-screenshots
#     path: tmp/screenshots/
#     retention-days: 7
```

**Note:** For Capybara-driven tests, ensure the browser window size is consistent across environments (use `screen_size:` in `driven_by`) so that screenshots accurately reflect what the test saw.

Reference: [Rails System Testing Guide](https://guides.rubyonrails.org/testing.html#screenshot-helper) | [Evil Martians — System of a Test](https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-tests)
