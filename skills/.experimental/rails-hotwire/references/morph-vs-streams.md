---
title: Choose Morphing Over Complex Stream Orchestration
impact: MEDIUM
impactDescription: "reduces real-time code complexity by 80%"
tags: morph, streams, architecture, simplicity
---

## Choose Morphing Over Complex Stream Orchestration

When a single user action affects multiple page sections (sidebar counts, main content, header badges, activity feeds), orchestrating individual Turbo Stream tags for each target becomes brittle and hard to maintain. See also [`bcast-refresh-over-replace`](bcast-refresh-over-replace.md) for the model declaration side. Each stream tag requires a matching DOM ID, the correct action, and the right partial with the right locals. A broadcast refresh with morphing re-renders the entire page server-side and patches only the differences, achieving the same result with zero stream orchestration.

**Incorrect (5+ turbo_stream tags targeting different page sections):**

```erb
<%# app/views/tasks/update.turbo_stream.erb %>

<%# Update the task in the list %>
<%= turbo_stream.replace dom_id(@task), partial: "tasks/task", locals: { task: @task } %>

<%# Update the project progress bar %>
<%= turbo_stream.replace "project_progress" do %>
  <div id="project_progress">
    <%= render "projects/progress_bar", project: @task.project %>
  </div>
<% end %>

<%# Update the sidebar task counts %>
<%= turbo_stream.update "open_tasks_count", @task.project.tasks.open.count %>
<%= turbo_stream.update "completed_tasks_count", @task.project.tasks.completed.count %>

<%# Update the activity feed %>
<%= turbo_stream.prepend "activity_feed" do %>
  <%= render "activities/activity", activity: @task.activities.last %>
<% end %>

<%# Update the assignee's workload badge %>
<%= turbo_stream.replace "assignee_workload_#{@task.assignee_id}" do %>
  <%= render "users/workload_badge", user: @task.assignee %>
<% end %>

<%# If any DOM ID is wrong, that section silently fails to update. %>
```

**Correct (broadcasts_refreshes with morphing updates everything at once):**

```ruby
# app/models/task.rb
class Task < ApplicationRecord
  belongs_to :project
  belongs_to :assignee, class_name: "User"

  broadcasts_refreshes_to :project
end
```

```ruby
# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  def update
    @task = @project.tasks.find(params[:id])

    if @task.update(task_params)
      # The acting user gets a standard redirect (Turbo Drive navigates).
      # Other viewers get the update via broadcasts_refreshes on the model.
      redirect_to @project
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
```

```erb
<%# app/views/projects/show.html.erb %>
<%# No stream templates needed — the normal view IS the template.
    All sections (progress bar, counts, feed, badges) render from
    the same server response and morph into place automatically. %>
<%= turbo_stream_from @project %>

<%= render "projects/progress_bar", project: @project %>
<%= render "sidebar/task_counts", project: @project %>
<%= render @project.tasks %>
<%= render "activities/feed", activities: @project.activities.recent %>
```
