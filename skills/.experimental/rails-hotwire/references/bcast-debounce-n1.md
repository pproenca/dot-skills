---
title: Debounce Broadcasts to Prevent N+1 Broadcast Storms
impact: HIGH
impactDescription: "reduces server load by 91% (100 broadcasts/sec to 1)"
tags: bcast, debounce, performance, n-plus-one
---

## Debounce Broadcasts to Prevent N+1 Broadcast Storms

When a bulk operation updates many records (importing tasks, reordering a list, batch status changes), each `after_commit` callback fires its own broadcast. A 100-row import produces 100 WebSocket messages in rapid succession, overwhelming the Action Cable server and triggering 100 page morphs on every connected client. Suppress broadcasts during bulk operations and fire a single manual broadcast after the batch completes.

**Incorrect (after_commit broadcasting directly, causing 100 broadcasts per bulk operation):**

```ruby
# app/models/task.rb
class Task < ApplicationRecord
  belongs_to :project

  # Each save fires a separate broadcast
  broadcasts_refreshes_to :project

  # Bulk import triggers N broadcasts
  def self.import_from_csv(project, csv_data)
    csv_data.each do |row|
      project.tasks.create!(
        title: row["title"],
        status: row["status"]
      )
      # => 100 rows = 100 broadcasts = 100 morphs for every viewer
    end
  end
end
```

**Correct (suppress broadcasts during bulk operations, fire one at the end):**

```ruby
# app/models/task.rb
class Task < ApplicationRecord
  belongs_to :project
  broadcasts_refreshes_to :project

  def self.import_from_csv(project, csv_data)
    # Suppress all Turbo broadcasts inside the block
    Task.suppressing_turbo_broadcasts do
      transaction do
        csv_data.each do |row|
          project.tasks.create!(
            title: row["title"],
            status: row["status"]
          )
        end
      end
    end

    # Single broadcast after the entire import completes
    Turbo::StreamsChannel.broadcast_refresh_to(project)
  end
end
```

**Alternative (controller-level suppression for batch endpoints):**

```ruby
# app/controllers/tasks/imports_controller.rb
class Tasks::ImportsController < ApplicationController
  def create
    Task.suppressing_turbo_broadcasts do
      @results = Task.import_from_csv(@project, parsed_csv)
    end

    # One broadcast for all connected viewers
    Turbo::StreamsChannel.broadcast_refresh_to(@project)

    redirect_to @project, notice: "Imported #{@results.count} tasks"
  end
end
```

**When NOT to use this pattern:**
- Single-record creates/updates — `broadcasts_refreshes_to` is fine as-is
- Real-time collaborative editing where each keystroke should broadcast

Reference: [Turbo Broadcastable — turbo-rails](https://github.com/hotwired/turbo-rails)
