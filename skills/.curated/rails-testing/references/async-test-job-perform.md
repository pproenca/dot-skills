---
title: Test Job perform Method Directly
impact: MEDIUM
impactDescription: 10-50× faster than queue round-trip testing
tags: async, job, perform, unit-test, active-job
---

## Test Job perform Method Directly

Call `.perform_now` or `.new.perform` to test the job's logic as a fast unit test. There is no need to push the job through the queue, serialize arguments, and drain — that adds latency and tests framework plumbing rather than your business logic. Reserve queue integration for the specs that verify enqueue behavior.

**Incorrect (enqueuing and draining the queue to test job logic):**

```ruby
RSpec.describe DataExportJob, type: :job do
  describe "#perform" do
    it "generates a CSV export for the user" do
      user = create(:user)
      create_list(:order, 3, user: user)

      # Unnecessary round-trip through the queue
      DataExportJob.perform_later(user.id, "orders", "csv")
      perform_enqueued_jobs

      export = user.exports.last
      expect(export).to be_present
      expect(export.format).to eq("csv")
      expect(export.row_count).to eq(3)
    end
  end
end
```

**Correct (calling perform_now directly):**

```ruby
RSpec.describe DataExportJob, type: :job do
  describe "#perform" do
    it "generates a CSV export with the correct row count" do
      user = create(:user)
      create_list(:order, 3, user: user)

      described_class.perform_now(user.id, "orders", "csv")

      export = user.exports.last
      expect(export).to have_attributes(
        format: "csv",
        row_count: 3,
        status: "completed"
      )
    end

    it "marks the export as failed when the user has no data" do
      user = create(:user)

      described_class.perform_now(user.id, "orders", "csv")

      export = user.exports.last
      expect(export.status).to eq("failed")
      expect(export.error_message).to eq("No orders found for export")
    end

    it "notifies the user when the export is ready" do
      user = create(:user)
      create(:order, user: user)

      expect {
        described_class.perform_now(user.id, "orders", "csv")
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end
end
```

Reference: [Active Job Basics — Rails Guides](https://guides.rubyonrails.org/active_job_basics.html#testing) | [Better Specs](https://www.betterspecs.org/)
