---
title: Use Page Objects for System Tests
impact: MEDIUM-HIGH
impactDescription: eliminates Capybara selector duplication across specs
tags: system, page-object, capybara, dry, encapsulation
---

## Use Page Objects for System Tests

Encapsulate page interactions in page objects so that when selectors or UI structure change, you update one class instead of every system test. Page objects also give test authors a domain-specific vocabulary — `checkout_page.complete_purchase` reads better than a sequence of `fill_in` and `click_on` calls, and changes to the checkout flow only require updating the page object.

**Incorrect (raw Capybara selectors duplicated across specs):**

```ruby
# spec/system/sign_in_spec.rb
RSpec.describe "Sign in", type: :system do
  it "allows a user to sign in with valid credentials" do
    user = create(:user, password: "SecurePass123!")

    visit "/login"
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "SecurePass123!"
    click_button "Sign in"

    expect(page).to have_css("[data-testid='dashboard-header']")
  end
end

# spec/system/checkout_spec.rb
RSpec.describe "Checkout", type: :system do
  it "requires authentication before checkout" do
    visit "/checkout"

    # Duplicated sign-in flow — if login form changes, both specs break
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "SecurePass123!"
    click_button "Sign in"

    expect(page).to have_current_path("/checkout")
  end
end
```

**Correct (page object encapsulates interaction):**

```ruby
# spec/support/pages/login_page.rb
class LoginPage
  include Capybara::DSL

  def visit_page
    visit "/login"
    self
  end

  def sign_in(email:, password:)
    visit_page
    fill_in "Email address", with: email
    fill_in "Password", with: password
    click_on "Sign in"
    self
  end

  def signed_in?
    page.has_css?("nav", text: "Dashboard")
  end
end

# spec/system/sign_in_spec.rb
RSpec.describe "Sign in", type: :system do
  let(:login_page) { LoginPage.new }

  it "allows a user to sign in with valid credentials" do
    user = create(:user, password: "SecurePass123!")

    login_page.sign_in(email: user.email, password: "SecurePass123!")

    expect(login_page).to be_signed_in
  end
end

# spec/system/checkout_spec.rb
RSpec.describe "Checkout", type: :system do
  it "requires authentication before checkout" do
    user = create(:user, password: "SecurePass123!")

    LoginPage.new.sign_in(email: user.email, password: "SecurePass123!")
    visit "/checkout"

    expect(page).to have_current_path("/checkout")
  end
end
```

Reference: [Page Objects — Martin Fowler](https://martinfowler.com/bliki/PageObject.html)
