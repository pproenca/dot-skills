---
title: Use normalizes Macro for Data Cleaning
impact: HIGH
impactDescription: 3-5x reduction in data-cleaning code via 1-line declarations
tags: model, normalizes, data-cleaning, active-record
---

## Use normalizes Macro for Data Cleaning

Rails 7.1+ provides the `normalizes` macro for declarative, model-level data cleaning. It runs automatically before validation and on finder methods, ensuring consistent data everywhere — not just on save. This replaces scattered `before_validation` callbacks with a single, scannable declaration that makes normalization rules immediately visible at the top of the model.

**Incorrect (manual before_validation callbacks):**

```ruby
# app/models/user.rb
class User < ApplicationRecord
  before_validation :strip_and_downcase_email
  before_validation :normalize_phone_number
  before_validation :strip_name_fields

  private

  def strip_and_downcase_email
    self.email = email&.strip&.downcase
  end

  def normalize_phone_number
    self.phone = phone&.gsub(/[\s\-\(\)]/, "")
  end

  def strip_name_fields
    self.first_name = first_name&.strip
    self.last_name = last_name&.strip
  end
end

# Finders don't normalize — inconsistent lookups
User.find_by(email: " Alice@Example.COM ")  # => nil (missed match)
```

**Correct (normalizes macro):**

```ruby
# app/models/user.rb
class User < ApplicationRecord
  normalizes :email, with: -> { _1.strip.downcase }
  normalizes :phone, with: -> { _1.gsub(/[\s\-\(\)]/, "") }
  normalizes :first_name, :last_name, with: -> { _1.strip }
end

# Finders auto-normalize — consistent lookups
User.find_by(email: " Alice@Example.COM ")  # => #<User email: "alice@example.com">

# Works with where too
User.where(email: "  BOB@test.com  ")  # normalizes before querying
```

**Benefits:**
- Normalization is declarative and scannable at the top of the model
- Finders auto-normalize, preventing lookup mismatches
- No private callback methods cluttering the model
- Composable: chain transformations in a single lambda

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
