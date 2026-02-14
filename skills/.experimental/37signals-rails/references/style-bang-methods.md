---
title: Bang Methods Only When Non-Bang Exists
impact: MEDIUM
impactDescription: eliminates misleading API signals — every ! has a clear safe counterpart
tags: style, bang-methods, naming, api-design
---

## Bang Methods Only When Non-Bang Exists

Only define a bang (`!`) method when a non-bang counterpart exists in the same class. The `!` suffix means "this is the dangerous version" — which only makes sense relative to a safe alternative. Don't use `!` merely to signal destructive or mutating behavior. Many destructive Ruby and Rails methods (`destroy`, `delete`, `truncate`) intentionally lack the `!` suffix.

**Incorrect (bang without a non-bang counterpart):**

```ruby
class Card < ApplicationRecord
  # No non-bang version exists — the ! is misleading
  def archive!
    update!(archived_at: Time.current)
    archivings.create!(creator: Current.user)
  end

  # ! used to signal "dangerous" — but there's no safe alternative
  def purge_attachments!
    attachments.each(&:purge)
  end

  # ! on a method that always raises — not meaningful
  def validate_permissions!
    raise "Unauthorized" unless editable_by?(Current.user)
  end
end
```

**Correct (bang paired with non-bang, or no bang at all):**

```ruby
class Card < ApplicationRecord
  # Non-bang returns boolean, bang raises on failure
  def archive
    self.archived_at = Time.current
    archivings.build(creator: Current.user)
    save
  end

  def archive!
    archive || raise(ActiveRecord::RecordInvalid, self)
  end

  # No safe version needed — just don't use !
  def purge_attachments
    attachments.each(&:purge)
  end

  # Predicate or guard — no ! needed
  def ensure_editable_by(user)
    raise "Unauthorized" unless editable_by?(user)
  end
end

# Rails follows this pattern:
# save   / save!
# create / create!
# update / update!
# destroy has no destroy! — it's always "destructive"
```

Reference: [Basecamp STYLE.md](https://github.com/basecamp/fizzy/blob/main/STYLE.md)
