---
title: Counter Caches to Prevent N+1 Count Queries
impact: HIGH
impactDescription: eliminates COUNT queries, O(1) count access
tags: model, counter-cache, n-plus-one, performance
---

## Counter Caches to Prevent N+1 Count Queries

Use Rails' built-in `counter_cache` to avoid `COUNT(*)` queries when displaying association counts. Every time you call `project.tasks.count` in a list, Rails fires a SQL COUNT query — in a list of 50 projects, that is 50 extra queries. A counter cache stores the count in a dedicated column on the parent, updated automatically on create and destroy. Count access becomes a simple column read: O(1) instead of O(n).

**Incorrect (N+1 COUNT queries in a list view):**

```ruby
# app/models/project.rb
class Project < ApplicationRecord
  has_many :tasks
  has_many :comments
end

# app/views/projects/index.html.erb
<% @projects.each do |project| %>
  <div>
    <%= project.name %>
    <%= project.tasks.count %> tasks       <%# SELECT COUNT(*) FROM tasks WHERE project_id = ? %>
    <%= project.comments.count %> comments <%# SELECT COUNT(*) FROM comments WHERE project_id = ? %>
  </div>
<% end %>
# 50 projects = 100 extra COUNT queries on every page load
```

**Correct (counter cache columns with O(1) access):**

```ruby
# db/migrate/add_counter_caches_to_projects.rb
class AddCounterCachesToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :tasks_count, :integer, default: 0, null: false
    add_column :projects, :comments_count, :integer, default: 0, null: false
  end
end

# app/models/task.rb
class Task < ApplicationRecord
  belongs_to :project, counter_cache: true
end

# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :project, counter_cache: true
end

# app/views/projects/index.html.erb
<% @projects.each do |project| %>
  <div>
    <%= project.name %>
    <%= project.tasks_count %> tasks       <%# column read, no query %>
    <%= project.comments_count %> comments <%# column read, no query %>
  </div>
<% end %>
# 50 projects = 0 extra queries
```

**Alternative:** For existing data, reset counters after adding the migration:

```ruby
# db/migrate/reset_project_counter_caches.rb
Project.find_each do |project|
  Project.reset_counters(project.id, :tasks, :comments)
end
```

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
