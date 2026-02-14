---
title: Visibility Modifier Formatting
impact: LOW
impactDescription: 0 formatting inconsistencies across all class definitions
tags: style, visibility, private, formatting
---

## Visibility Modifier Formatting

Follow strict formatting rules for visibility modifiers (`private`, `protected`). No blank line immediately after the modifier keyword. Indent method definitions beneath them. For modules that contain only private methods, place `private` at the top of the module with a blank line after it and no indentation on the methods. Never define bang (`!`) methods unless a non-bang counterpart exists — the bang signals "this is the dangerous version," which only makes sense relative to a safe alternative.

**Incorrect (inconsistent visibility formatting):**

```ruby
# app/models/account.rb
class Account < ApplicationRecord
  def display_name
    name.presence || email
  end

  private

  # Blank line after `private` — not allowed
  def normalize_email
    self.email = email.strip.downcase
  end

  def generate_token
    self.token = SecureRandom.hex(20)
  end

  # Bang method without a non-bang counterpart
  def reset_token!
    update!(token: SecureRandom.hex(20))
  end
end

# app/models/concerns/trackable.rb
module Trackable
  extend ActiveSupport::Concern

  private

    # Over-indented under private in a module with only private methods
    def track_event(name)
      Event.create!(name: name, trackable: self)
    end

    def tracking_enabled?
      self.class.tracking_enabled
    end
end
```

**Correct (STYLE.md-compliant formatting):**

```ruby
# app/models/account.rb
class Account < ApplicationRecord
  def display_name
    name.presence || email
  end

  private
  def normalize_email
    self.email = email.strip.downcase
  end

  def generate_token
    self.token = SecureRandom.hex(20)
  end

  # Non-bang version exists, so bang is justified
  def reset_token
    self.token = SecureRandom.hex(20)
  end

  def reset_token!
    reset_token
    save!
  end
end

# app/models/concerns/trackable.rb
module Trackable
  extend ActiveSupport::Concern

  private

  def track_event(name)
    Event.create!(name: name, trackable: self)
  end

  def tracking_enabled?
    self.class.tracking_enabled
  end
end
```

**When NOT to use:**
- If you are contributing to an existing codebase with a different established style for visibility modifiers, follow that project's convention instead. Consistency within a project trumps this rule.

Reference: [Basecamp STYLE.md](https://github.com/basecamp/fizzy/blob/main/STYLE.md)
