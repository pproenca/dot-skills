---
title: Earn Abstractions Through Rule of Three
impact: CRITICAL
impactDescription: prevents premature design that creates unnecessary indirection
tags: arch, abstractions, rule-of-three, dhh
---

## Earn Abstractions Through Rule of Three

Don't extract abstractions until you have three or more concrete cases that genuinely share the same pattern. Premature abstraction creates indirection, increases cognitive load, and often doesn't even fit when the second or third case arrives. As DHH puts it: "If you can't point to three or more variations that need it, inline it."

**Incorrect (premature extraction after first use):**

```ruby
# Extracted after just ONE notification type exists
# app/services/notification_dispatcher.rb
class NotificationDispatcher
  def initialize(strategy:, recipient:, payload:)
    @strategy = strategy
    @recipient = recipient
    @payload = payload
  end

  def dispatch
    adapter = NotificationAdapterFactory.for(@strategy)
    message = MessageBuilder.new(@payload).build
    adapter.deliver(message, to: @recipient)
  end
end

# Only one adapter actually exists
# app/services/notification_adapters/email_adapter.rb
class NotificationAdapters::EmailAdapter
  def deliver(message, to:)
    UserMailer.notification(to, message).deliver_later
  end
end
```

**Correct (inline until three cases prove the pattern):**

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :recording
  belongs_to :creator, class_name: "User"

  after_create_commit :notify_participants

  private

  def notify_participants
    recipients = recording.participants.where.not(id: creator_id)
    recipients.each do |recipient|
      CommentMailer.new_comment(self, recipient).deliver_later
    end
    # TODO: When we add Slack/push notifications (3rd channel),
    # extract a Notifier concern. Until then, inline is clearer.
  end
end
```

**When NOT to use:**
- Well-known patterns with established Rails conventions (concerns, callbacks, validators) are fine to use immediately — they're not speculative abstractions, they're framework idioms.

Reference: [On Writing Software Well](https://signalvnoise.com/svn3/on-writing-software-well/)
