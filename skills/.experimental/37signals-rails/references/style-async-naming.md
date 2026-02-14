---
title: Use _later and _now Suffixes for Async Operations
impact: MEDIUM
impactDescription: eliminates sync/async ambiguity across the codebase
tags: style, async, naming, jobs
---

## Use _later and _now Suffixes for Async Operations

Methods that enqueue background jobs use the `_later` suffix. Their synchronous counterparts use the `_now` suffix. The job class itself delegates to the `_now` method, keeping the actual logic in the model rather than the job. This convention from STYLE.md makes the async/sync boundary explicit at every call site — you never have to check whether a method fires inline or enqueues.

**Incorrect (ambiguous async boundary):**

```ruby
# app/models/recording.rb
class Recording < ApplicationRecord
  def transcode
    TranscodeJob.perform_later(id)
  end

  def process_transcode
    update!(transcoded_at: Time.current)
    attachments.each(&:generate_variants)
    notify_creator
  end
end

# app/jobs/transcode_job.rb
class TranscodeJob < ApplicationJob
  def perform(recording_id)
    recording = Recording.find(recording_id)
    recording.process_transcode
  end
end

# Calling code — is this sync or async?
@recording.transcode            # async? sync? have to check
@recording.process_transcode    # "process" doesn't clarify timing
```

**Correct (_later/_now convention):**

```ruby
# app/models/recording.rb
class Recording < ApplicationRecord
  # Enqueues — the _later suffix makes async intent explicit
  def transcode_later
    TranscodeJob.perform_later(id)
  end

  # Executes synchronously — _now suffix signals inline execution
  def transcode_now
    update!(transcoded_at: Time.current)
    attachments.each(&:generate_variants)
    notify_creator
  end
end

# app/jobs/transcode_job.rb
class TranscodeJob < ApplicationJob
  def perform(recording_id)
    recording = Recording.find(recording_id)
    recording.transcode_now
  end
end

# Calling code — intent is unambiguous
@recording.transcode_later   # clearly async, enqueues a job
@recording.transcode_now     # clearly sync, runs inline
```

**Alternative — when only one variant exists:**

```ruby
class Report < ApplicationRecord
  # If there is no synchronous counterpart and the operation is
  # always async, use _later without a _now pair
  def generate_later
    ReportGenerationJob.perform_later(id)
  end
end
```

**When NOT to use:**
- Rails built-in conventions like `deliver_later` and `deliver_now` on mailers already follow this pattern. Don't wrap them in additional `_later`/`_now` methods — call them directly.

Reference: [Basecamp STYLE.md](https://github.com/basecamp/fizzy/blob/main/STYLE.md)
