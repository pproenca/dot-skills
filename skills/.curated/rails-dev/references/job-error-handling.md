---
title: Configure Retry and Error Handling for Jobs
impact: LOW-MEDIUM
impactDescription: prevents infinite retries and silent failures
tags: job, error-handling, retries, dead-letter, discard
---

## Configure Retry and Error Handling for Jobs

Default retry behavior retries indefinitely on all errors. Configure explicit retry limits, backoff, and discard rules for known error types.

**Incorrect (default unlimited retries):**

```ruby
class ImportOrdersJob < ApplicationJob
  def perform(csv_url)
    data = HTTP.get(csv_url)  # Retries forever if URL is permanently broken
    OrderImporter.import(data.body)
  end
end
```

**Correct (explicit retry configuration):**

```ruby
class ImportOrdersJob < ApplicationJob
  retry_on Net::OpenTimeout, wait: :polynomially_longer, attempts: 5
  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(csv_url)
    data = HTTP.get(csv_url)
    OrderImporter.import(data.body)
  end
end
```

**Benefits:**
- `retry_on` with `attempts` prevents infinite loops
- `discard_on` skips permanently unprocessable jobs
- Polynomial backoff prevents thundering herd on recovery

Reference: [Active Job Basics — Rails Guides](https://guides.rubyonrails.org/active_job_basics.html#retrying-or-discarding-failed-jobs)
