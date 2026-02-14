---
title: Methods Ordered by Call Sequence
impact: MEDIUM
impactDescription: reduces time to find method definitions by 2-3x
tags: style, method-ordering, readability, organization
---

## Methods Ordered by Call Sequence

Order methods vertically so the code reads top-to-bottom like a narrative. When method A calls method B, place B immediately after A. This eliminates the mental overhead of jumping around a file to trace execution flow. Within a class, class methods come first, then public instance methods (with `initialize` at the top), then private methods — each group following the same call-sequence rule.

**Incorrect (methods in random order, hard to trace):**

```ruby
# app/models/inbox.rb
class Inbox < ApplicationRecord
  def summarize
    "#{title}: #{entry_count} entries"
  end

  def archive
    entries.each(&:archive)
    update!(archived_at: Time.current)
    notify_owner
  end

  private

  def notify_owner
    InboxMailer.archived(self).deliver_later
  end

  public

  def entry_count
    entries.visible.count
  end

  def title
    name.presence || "Untitled Inbox"
  end
end
```

**Correct (methods follow call sequence, top to bottom):**

```ruby
# app/models/inbox.rb
class Inbox < ApplicationRecord
  def archive
    entries.each(&:archive)
    update!(archived_at: Time.current)
    notify_owner
  end

  def summarize
    "#{title}: #{entry_count} entries"
  end

  def title
    name.presence || "Untitled Inbox"
  end

  def entry_count
    entries.visible.count
  end

  private

  # Called by #archive — positioned directly after public methods,
  # mirroring the call order within the private section
  def notify_owner
    InboxMailer.archived(self).deliver_later
  end
end
```

**Benefits:**
- New contributors read the file once, top to bottom, and understand the full flow.
- Code reviews are faster because reviewers don't need to scroll back and forth.
- Related methods cluster naturally, making future extraction into concerns obvious.

Reference: [Basecamp STYLE.md](https://github.com/basecamp/fizzy/blob/main/STYLE.md)
