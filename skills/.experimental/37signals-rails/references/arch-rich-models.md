---
title: Rich Domain Models Over Service Objects
impact: CRITICAL
impactDescription: eliminates indirection layers, keeps domain logic discoverable
tags: arch, domain-models, service-objects, active-record
---

## Rich Domain Models Over Service Objects

Business logic belongs in ActiveRecord models augmented by concerns. Service objects create anemic models where domain knowledge scatters across the codebase, making behavior hard to find and reason about. When a model owns its logic, you can ask "what can a Recording do?" and the model itself answers. As DHH puts it: "These explicit classes for the notifier are anemic. Inline them."

**Incorrect (service objects wrapping domain logic):**

```ruby
# app/services/recording_archiver.rb
class RecordingArchiver
  def initialize(recording)
    @recording = recording
  end

  def call
    @recording.update!(archived_at: Time.current)
    @recording.attachments.each { |a| a.update!(storage_tier: "glacier") }
    RecordingMailer.archived(@recording).deliver_later
  end
end

# Controller must know which service to use
RecordingArchiver.new(@recording).call
```

**Correct (rich model with domain methods):**

```ruby
# app/models/recording.rb
class Recording < ApplicationRecord
  has_many :attachments

  def archive
    update!(archived_at: Time.current)
    attachments.each(&:move_to_cold_storage)
    RecordingMailer.archived(self).deliver_later
  end

  def archived?
    archived_at.present?
  end
end

# Controller calls the model directly
@recording.archive
```

**When NOT to use:**
- Form objects coordinating multiple unrelated models (e.g., `RegistrationForm` creating a User, Account, and Subscription) are acceptable — they represent input coordination, not domain logic.
- Job orchestrators that sequence multiple async steps are not domain logic either.

Reference: [Vanilla Rails is Plenty](https://dev.37signals.com/vanilla-rails-is-plenty/)
