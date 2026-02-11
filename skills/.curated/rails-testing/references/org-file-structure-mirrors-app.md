---
title: Mirror App Directory Structure in Specs
impact: LOW-MEDIUM
impactDescription: reduces spec-hunting time to 0 — mental s/app/spec/ finds every file
tags: org, file-structure, conventions, directory-layout, spec-helpers
---

## Mirror App Directory Structure in Specs

When `spec/` mirrors `app/`, every developer can find the spec for any file by mentally replacing `app/` with `spec/` and appending `_spec.rb`. No searching, no guessing. This convention also lets RSpec automatically infer spec types from file paths (`spec/models/` sets `type: :model`), reducing boilerplate. Break the convention and developers waste time hunting for specs — or worse, write duplicate specs because they couldn't find the existing ones.

**Incorrect (flat structure with inconsistent naming — specs are unfindable):**

```text
spec/
  user_tests.rb                    # _tests instead of _spec
  order_spec.rb                    # model spec in root
  payment_controller_spec.rb       # controller spec in root
  sign_in_spec.rb                  # system spec in root
  helpers.rb                       # shared helpers loose in root
  user_factory.rb                  # factory in root
  mailer_tests.rb                  # wrong suffix, in root
  some_shared_context.rb           # shared context in root
```

```ruby
# spec/user_tests.rb — wrong naming convention, wrong location
require "rails_helper"

RSpec.describe User do  # No type: :model — RSpec can't infer from path
  it "validates email" do
    # ...
  end
end
```

**Correct (spec/ mirrors app/ — RSpec infers types, specs are instantly locatable):**

```text
spec/
  factories/
    users.rb                       # FactoryBot definitions
    orders.rb
    payments.rb
  models/
    user_spec.rb                   # mirrors app/models/user.rb
    order_spec.rb                  # mirrors app/models/order.rb
  requests/
    orders_spec.rb                 # mirrors app/controllers/orders_controller.rb
    api/
      v1/
        payments_spec.rb           # mirrors app/controllers/api/v1/payments_controller.rb
  system/
    sign_in_spec.rb                # user-facing journey
    checkout_spec.rb
  jobs/
    payment_capture_job_spec.rb    # mirrors app/jobs/payment_capture_job.rb
  mailers/
    order_confirmation_mailer_spec.rb  # mirrors app/mailers/order_confirmation_mailer.rb
  services/
    order_fulfillment_spec.rb      # mirrors app/services/order_fulfillment.rb
  support/
    pages/                         # page objects for system specs
      login_page.rb
      checkout_page.rb
    matchers/                      # custom RSpec matchers
      be_ready_for_review.rb
    shared_contexts/               # shared RSpec contexts
      authenticated_user.rb
  rails_helper.rb
  spec_helper.rb
```

```ruby
# spec/models/user_spec.rb — RSpec infers type: :model from the path
require "rails_helper"

RSpec.describe User do
  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
  end
end

# spec/rails_helper.rb — enable automatic type inference
RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end
```

Reference: [RSpec Directory Structure](https://rspec.info/features/7-0/rspec-rails/directory-structure/) | [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
