---
title: Visibility Modifier Formatting
impact: LOW
impactDescription: 0 formatting deviations — 100% consistency across all class and module definitions
tags: style, visibility, private, formatting
---

## Visibility Modifier Formatting

Follow strict formatting rules for visibility modifiers (`private`, `protected`). Two conventions apply depending on context:

1. **In classes with mixed public/private methods:** No blank line after `private`. The first private method starts on the very next line.
2. **In modules where ALL methods are private:** Place `private` at the top as a section divider, followed by a blank line, with no indentation on the methods below.

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
