---
title: Never Use sleep in System Tests
impact: MEDIUM-HIGH
impactDescription: sleep causes flaky slow tests — Capybara has built-in waiting
tags: system, sleep, flaky, waiting, capybara
---

## Never Use sleep in System Tests

Capybara automatically retries assertions and finders up to `Capybara.default_max_wait_time` seconds. Using `sleep` is either too short (causing intermittent failures on slower CI runners) or too long (wasting minutes across a test suite). Replace `sleep` with Capybara's built-in waiting matchers — they poll the DOM and return as soon as the condition is met, giving you both speed and reliability.

**Incorrect (hardcoded sleep introduces flakiness and waste):**

```ruby
RSpec.describe "Project creation", type: :system do
  it "creates a project and displays a success message" do
    user = create(:user)
    sign_in user

    visit new_project_path
    fill_in "Project name", with: "New Dashboard"
    click_on "Create project"

    sleep 3  # Waiting for Turbo to render the response
    expect(page).to have_content("Project created successfully")

    sleep 2  # Waiting for the project to appear in the sidebar
    expect(page).to have_css("nav", text: "New Dashboard")
  end

  it "shows a loading indicator while processing" do
    visit projects_path
    click_on "Generate report"

    sleep 1
    expect(page).to have_css(".spinner")

    sleep 5  # Wait for report to finish
    expect(page).not_to have_css(".spinner")
  end
end
```

**Correct (Capybara waits automatically, returns as soon as condition is met):**

```ruby
RSpec.describe "Project creation", type: :system do
  it "creates a project and displays a success message" do
    user = create(:user)
    sign_in user

    visit new_project_path
    fill_in "Project name", with: "New Dashboard"
    click_on "Create project"

    expect(page).to have_content("Project created successfully")
    expect(page).to have_css("nav", text: "New Dashboard")
  end

  it "shows a loading indicator while processing" do
    visit projects_path
    click_on "Generate report"

    expect(page).to have_css(".spinner")
    expect(page).to have_no_css(".spinner", wait: 10)  # Override wait for slow operations
  end
end
```

**Note:** If the default wait time is too short for a specific operation (e.g., file uploads, long-running jobs), pass `wait:` to the individual matcher instead of bumping the global `default_max_wait_time`.

Reference: [Capybara — Asynchronous JavaScript](https://github.com/teamcapybara/capybara#asynchronous-javascript-ajax-and-friends) | [Evil Martians — System of a Test](https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-tests)
