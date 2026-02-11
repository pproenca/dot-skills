---
title: Use Accessible Selectors over CSS/XPath
impact: MEDIUM-HIGH
impactDescription: tests survive UI redesigns and enforce accessibility
tags: system, accessibility, selectors, capybara, a11y
---

## Use Accessible Selectors over CSS/XPath

Use Capybara's text-based and role-based finders (`click_on`, `fill_in` by label, `find` by role) instead of CSS class or ID selectors. When designers rename CSS classes or restructure the DOM, accessible selectors remain stable because they track the user-visible interface. As a bonus, tests that rely on labels and ARIA roles act as an accessibility audit — if the test can't find a button by its label, neither can a screen reader.

**Incorrect (CSS selectors coupled to DOM structure):**

```ruby
RSpec.describe "Contact form", type: :system do
  it "submits a support request" do
    visit "/contact"

    find("#contact-name-input").set("Jane Doe")
    find(".email-field > input").set("jane@example.com")
    find("textarea.message-box").set("I need help with my account")
    find("#btn-submit").click

    expect(find(".flash-notice")).to have_text("Message sent")
  end
end
```

**Correct (accessible selectors matching labels and roles):**

```ruby
RSpec.describe "Contact form", type: :system do
  it "submits a support request" do
    visit "/contact"

    fill_in "Full name", with: "Jane Doe"
    fill_in "Email address", with: "jane@example.com"
    fill_in "Message", with: "I need help with my account"
    click_on "Send message"

    expect(page).to have_text("Message sent")
  end

  it "displays validation errors for missing required fields" do
    visit "/contact"

    click_on "Send message"

    expect(page).to have_css("[role='alert']", text: "can't be blank")
  end
end
```

**Note:** When accessible selectors are ambiguous (e.g., two "Delete" buttons), scope with `within` instead of falling back to CSS: `within("#order-#{order.id}") { click_on "Delete" }`.

Reference: [Capybara Cheat Sheet — Selectors](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara/Node/Actions) | [Better Specs](https://www.betterspecs.org/)
