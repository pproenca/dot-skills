---
title: Compute at Write Time Not Read Time
impact: HIGH
impactDescription: enables pagination, caching, and simpler views by precomputing data
tags: state, write-time, precompute, performance
---

## Compute at Write Time Not Read Time

Store computed values in the database when data changes rather than computing them at read time. DHH: "Compute at write time, not presentation time." This trades slightly more expensive writes for dramatically cheaper reads — enabling database sorting, pagination, indexing, and caching on values that would otherwise require N+1 queries or in-memory computation on every page load.

**Incorrect (computing at read time in views and controllers):**

```ruby
# app/models/project.rb
class Project < ApplicationRecord
  has_many :todos

  # Computed on every read — no way to sort or paginate by this
  def completion_percentage
    return 0 if todos.count.zero?
    (todos.where.not(completed_at: nil).count.to_f / todos.count * 100).round
  end

  def last_activity_at
    # N+1 risk when called across a collection
    [todos.maximum(:updated_at), comments.maximum(:created_at), updated_at].compact.max
  end
end

# app/views/projects/index.html.erb
<% @projects.each do |project| %>
  <!-- Two queries per project in the loop -->
  <span><%= project.completion_percentage %>% complete</span>
  <span>Last active: <%= time_ago_in_words(project.last_activity_at) %></span>
<% end %>

# Cannot do: Project.order(:completion_percentage) — it's not a column
# Cannot do: Project.where("completion_percentage > 80") — it's Ruby, not SQL
```

**Correct (precomputing at write time with callbacks):**

```ruby
# db/migrate/20240115_add_computed_columns_to_projects.rb
class AddComputedColumnsToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :completion_percentage, :integer, default: 0, null: false
    add_column :projects, :last_activity_at, :datetime
    add_column :projects, :todos_count, :integer, default: 0, null: false

    add_index :projects, :completion_percentage
    add_index :projects, :last_activity_at
  end
end

# app/models/todo.rb
class Todo < ApplicationRecord
  belongs_to :project, counter_cache: :todos_count

  after_save :update_project_completion
  after_destroy :update_project_completion

  private

  def update_project_completion
    total = project.todos.count
    completed = project.todos.where.not(completed_at: nil).count
    percentage = total.zero? ? 0 : (completed.to_f / total * 100).round

    project.update_columns(
      completion_percentage: percentage,
      last_activity_at: Time.current
    )
  end
end

# app/models/project.rb
class Project < ApplicationRecord
  has_many :todos

  # Now these are just column reads — no computation
  scope :most_active, -> { order(last_activity_at: :desc) }
  scope :nearly_done, -> { where(completion_percentage: 80..100) }
end

# Views are trivial — no queries, no computation
# Project.most_active.nearly_done.page(params[:page])
```

**Alternative — use `after_touch` for cascading updates:**

```ruby
class Comment < ApplicationRecord
  belongs_to :project, touch: true

  after_create_commit { project.update_column(:last_activity_at, Time.current) }
end
```

**When NOT to use:**
- When the computed value changes so frequently that write amplification outweighs read savings (e.g., a real-time view counter with thousands of writes per second) — use a cache or materialized view instead.
- When the computation is only needed in a single, rarely-visited view — inline computation is simpler and the cost is negligible.

Reference: DHH's code review patterns
