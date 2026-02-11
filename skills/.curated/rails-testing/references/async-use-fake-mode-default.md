---
title: Use Sidekiq Fake Mode as Default
impact: MEDIUM
impactDescription: prevents jobs from executing during unrelated tests
tags: async, sidekiq, fake-mode, inline, test-isolation
---

## Use Sidekiq Fake Mode as Default

Configure `Sidekiq::Testing.fake!` globally so that jobs pushed during tests are stored in a per-worker array without executing. Only switch to `inline!` when you specifically want to test job execution end-to-end. Running jobs inline by default means every test that touches code which enqueues a job — even indirectly — will execute that job, causing unexpected side effects, slower tests, and hard-to-trace failures.

**Incorrect (inline mode globally, jobs execute everywhere):**

```ruby
# spec/rails_helper.rb
require "sidekiq/testing"
Sidekiq::Testing.inline!  # Every enqueued job runs immediately in all specs

# spec/requests/users_spec.rb
RSpec.describe "POST /users", type: :request do
  it "creates a user" do
    # This test only cares about user creation, but inline! also executes:
    # - WelcomeEmailJob (sends email, hits mailer)
    # - SyncToCrmJob (makes HTTP call to external CRM, fails or times out)
    # - AnalyticsTrackingJob (writes to analytics service)
    post users_path, params: { user: { email: "new@example.com", name: "Jane" } }

    expect(response).to have_http_status(:created)
  end
end
```

**Correct (fake mode by default, inline only when testing job execution):**

```ruby
# spec/rails_helper.rb
require "sidekiq/testing"
Sidekiq::Testing.fake!  # Jobs are pushed but never executed

# spec/requests/users_spec.rb
RSpec.describe "POST /users", type: :request do
  it "creates a user and enqueues the welcome email job" do
    post users_path, params: { user: { email: "new@example.com", name: "Jane" } }

    expect(response).to have_http_status(:created)
    expect(WelcomeEmailJob.jobs.size).to eq(1)
    expect(WelcomeEmailJob.jobs.first["args"]).to eq([User.last.id])
  end
end

# spec/jobs/welcome_email_job_spec.rb
RSpec.describe WelcomeEmailJob, type: :job do
  describe "#perform" do
    it "sends a welcome email to the user" do
      user = create(:user)

      Sidekiq::Testing.inline! do
        WelcomeEmailJob.perform_async(user.id)
      end

      expect(ActionMailer::Base.deliveries.last.to).to include(user.email)
    end
  end
end
```

**Note:** If you use Active Job instead of the Sidekiq client API, use `ActiveJob::Base.queue_adapter = :test` and the `have_enqueued_job` matcher instead of inspecting `SomeJob.jobs`.

Reference: [Sidekiq Testing — GitHub](https://github.com/sidekiq/sidekiq/wiki/Testing) | [Active Job Testing — Rails Guides](https://guides.rubyonrails.org/testing.html#testing-jobs)
