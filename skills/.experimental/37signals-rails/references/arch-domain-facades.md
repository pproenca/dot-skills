---
title: Domain Models as Facades Over Internal Complexity
impact: HIGH
impactDescription: reduces public API surface by 60-80%
tags: arch, facades, domain-models, encapsulation
---

## Domain Models as Facades Over Internal Complexity

Models should expose high-level methods that read like English while hiding internal systems behind them. `recording.incinerate` is better than `Recording::IncinerationService.execute(recording)`. The caller doesn't need to know about storage cleanup, webhook notifications, or audit logging — the model is the facade.

**Incorrect (service-based approach exposing internals):**

```ruby
# Caller must orchestrate multiple services
class RecordingsController < ApplicationController
  def destroy
    @recording = Recording.find(params[:id])

    Recording::StorageCleanupService.new(@recording).call
    Recording::WebhookNotifier.new(@recording, event: :deleted).call
    Recording::AuditLogger.new(@recording, actor: Current.user).log_deletion
    Recording::SearchIndexRemover.new(@recording).call
    @recording.destroy!

    redirect_to recordings_path, notice: "Recording deleted"
  end
end
```

**Correct (model as facade hiding complexity):**

```ruby
# app/models/recording.rb
class Recording < ApplicationRecord
  include Incineratable
  include Searchable

  def incinerate
    transaction do
      cleanup_storage
      notify_webhooks(:incinerated)
      audit_log(:incinerated, actor: Current.user)
      remove_from_search_index
      destroy!
    end
  end

  private

  def cleanup_storage
    attachments.each(&:purge_later)
  end

  def notify_webhooks(event)
    WebhookDeliveryJob.perform_later(self, event)
  end

  def audit_log(action, actor:)
    audits.create!(action: action, actor: actor)
  end
end

# Controller is clean — one method call
class RecordingsController < ApplicationController
  def destroy
    @recording = Recording.find(params[:id])
    @recording.incinerate

    redirect_to recordings_path, notice: "Recording deleted"
  end
end
```

**Benefits:**
- Controllers stay thin — one line per action
- Public API reads like natural language (`recording.incinerate`, `message.publish`)
- Implementation can change without touching callers
- Concerns can break up internal complexity without leaking it outward

Reference: [Vanilla Rails is Plenty](https://dev.37signals.com/vanilla-rails-is-plenty/)
