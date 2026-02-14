---
title: Solid Queue for Background Jobs
impact: HIGH
impactDescription: eliminates Redis dependency for job processing, simplifies deployment
tags: db, solid-queue, jobs, background
---

## Solid Queue for Background Jobs

Use Solid Queue instead of Sidekiq for background jobs. It stores jobs in the database, eliminating Redis as a runtime dependency. Solid Queue supports recurring tasks, concurrency controls, semaphore-based throttling, and continuable long-running jobs — all backed by SQL. Jobs automatically serialize tenant context through Current attributes, and Mission Control provides a built-in web UI for monitoring.

**Incorrect (Sidekiq with Redis dependency and manual tenant propagation):**

```ruby
# Gemfile
gem "sidekiq"
gem "sidekiq-cron"
gem "redis", ">= 4.0"

# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"], size: 25 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"], size: 5 }
end

# app/workers/recording_transcription_worker.rb — manual tenant context
class RecordingTranscriptionWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 3

  def perform(account_id, recording_id)
    # Must manually restore tenant context every time
    account = Account.find(account_id)
    Current.account = account
    recording = account.recordings.find(recording_id)
    TranscriptionService.process(recording)
  ensure
    Current.reset
  end
end

# Caller must remember to pass account_id
RecordingTranscriptionWorker.perform_async(Current.account.id, recording.id)
```

**Correct (Solid Queue with automatic tenant context and built-in scheduling):**

```ruby
# Gemfile
gem "solid_queue"
gem "mission_control-jobs"

# config/solid_queue.yml — declarative queue configuration
production:
  dispatchers:
    - polling_interval: 1
      batch_size: 500
  workers:
    - queues: "*"
      threads: 5
      processes: 2
      polling_interval: 0.1
  schedulers:
    - recurring_tasks:
        daily_digest:
          command: "DigestMailer.daily.deliver_later"
          schedule: "every day at 9am"

# app/jobs/recording_transcription_job.rb — Current attributes propagate automatically
class RecordingTranscriptionJob < ApplicationJob
  queue_as :default
  limits_concurrency to: 2, key: -> (recording) { recording.account_id }, duration: 30.minutes

  def perform(recording)
    TranscriptionService.process(recording)
  end
end

# Current.account is automatically serialized and restored by the framework
RecordingTranscriptionJob.perform_later(recording)

# config/routes.rb — built-in monitoring dashboard
mount MissionControl::Jobs::Engine, at: "/jobs"
```

**Alternative:** For apps already running Sidekiq in production with custom middleware (e.g., Sidekiq Batches, Sidekiq Enterprise rate limiters), migrate incrementally by routing new job classes to Solid Queue while keeping existing ones on Sidekiq.

Reference: [Introducing Solid Queue](https://dev.37signals.com/introducing-solid-queue/)
