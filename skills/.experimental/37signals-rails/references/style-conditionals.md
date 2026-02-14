---
title: Expanded Conditionals Over Guard Clauses
impact: MEDIUM
impactDescription: reduces cognitive load by showing both branches explicitly
tags: style, conditionals, guard-clauses, readability
---

## Expanded Conditionals Over Guard Clauses

37signals prefers explicit if/else blocks over guard clauses because they show both branches clearly, making the full control flow visible at a glance. Guard clauses hide the "else" path by returning early, which can obscure intent when scanning a method. The only acceptable use of a guard clause is when the return appears at the very beginning of the method and the main body spans multiple lines.

**Incorrect (guard clause obscuring both branches):**

```ruby
# app/models/recording.rb
class Recording < ApplicationRecord
  def publishable?
    return false if draft?

    return false unless bucket.publishable?

    attachments.any?
  end

  def publish
    return unless publishable?

    update!(published_at: Time.current)
    notify_subscribers
  end

  private

  def notify_subscribers
    return if subscribers.none?

    subscribers.each { |sub| RecordingMailer.published(self, sub).deliver_later }
  end
end
```

**Correct (expanded conditionals showing both paths):**

```ruby
# app/models/recording.rb
class Recording < ApplicationRecord
  def publishable?
    if draft?
      false
    elsif !bucket.publishable?
      false
    else
      attachments.any?
    end
  end

  def publish
    if publishable?
      update!(published_at: Time.current)
      notify_subscribers
    end
  end

  private

  def notify_subscribers
    if subscribers.any?
      subscribers.each { |sub| RecordingMailer.published(self, sub).deliver_later }
    end
  end
end
```

**When NOT to use:**
- A guard clause at the very top of a long method is acceptable when the main body is 5+ lines and the early return handles a trivial precondition (e.g., `return if param.blank?` before a multi-step process). The key is that the guard must be the first statement.

Reference: [Basecamp STYLE.md](https://github.com/basecamp/fizzy/blob/main/STYLE.md)
