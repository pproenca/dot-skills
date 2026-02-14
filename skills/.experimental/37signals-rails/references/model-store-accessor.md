---
title: Use store_accessor for JSON Column Access
impact: HIGH
impactDescription: eliminates manual JSON parsing, adds dirty tracking
tags: model, store-accessor, json, schema-less
---

## Use store_accessor for JSON Column Access

Rails' `store_accessor` gives typed, attribute-like access to JSON columns without schema migrations. It generates getter/setter methods, supports dirty tracking, and works with validations and form helpers. Use it for flexible settings, metadata, and configuration that would otherwise require frequent column additions or a separate key-value table.

**Incorrect (raw JSON access scattered through the codebase):**

```ruby
# app/models/account.rb
class Account < ApplicationRecord
  # settings is a JSON column, but access is manual everywhere
end

# Controller — raw hash access, no type safety
def update_settings
  settings = @account.settings || {}
  settings["timezone"] = params[:timezone]
  settings["email_notifications"] = params[:email_notifications] == "1"
  settings["weekly_digest_day"] = params[:weekly_digest_day]
  @account.update!(settings: settings)
end

# View — defensive hash access
<%= @account.settings&.dig("timezone") || "UTC" %>

# Querying requires remembering exact key names
Account.where("settings->>'timezone' = ?", "America/New_York")
```

**Correct (store_accessor with attribute-like interface):**

```ruby
# app/models/account.rb
class Account < ApplicationRecord
  store_accessor :settings, :timezone, :email_notifications, :weekly_digest_day

  # Works with validations
  validates :timezone, inclusion: { in: ActiveSupport::TimeZone::MAPPING.keys }, allow_nil: true

  # Works with defaults via attribute API
  attribute :timezone, default: "UTC"
end

# Controller — standard attribute assignment
def update_settings
  @account.update!(account_params)
end

private

def account_params
  params.expect(account: [:timezone, :email_notifications, :weekly_digest_day])
end

# View — clean attribute access
<%= @account.timezone %>

# Dirty tracking works
@account.timezone_changed?          # => true
@account.timezone_was               # => "UTC"
```

**When NOT to use:**
- If you need to query, index, or join on the data frequently, promote it to a proper column. `store_accessor` values live inside JSON and are expensive to query at scale.

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
