---
title: Cache Turbo Frame Responses with Fragment Caching
impact: MEDIUM-HIGH
impactDescription: 90% cache hit rate, 80% reduction in database load
tags: perf, turbo-frames, caching, fragment
---

## Cache Turbo Frame Responses with Fragment Caching

Turbo Frames trigger separate HTTP requests for lazy-loaded or navigated content, which can multiply database queries across a page. Wrapping frame partials in Rails fragment caching with proper cache keys prevents redundant database hits and template rendering on subsequent requests. This is especially impactful for frames that display data shared across users or change infrequently.

**Incorrect (frame endpoint hitting database on every request):**

```ruby
# app/controllers/projects_controller.rb
class ProjectsController < ApplicationController
  def team_members
    @project = Project.find(params[:id])
    @members = @project.members.includes(:avatar_attachment).order(:name)
    render partial: "projects/team_members", locals: { members: @members }
  end
end
```

```erb
<%# app/views/projects/_team_members.html.erb %>
<turbo-frame id="team_members">
  <% members.each do |member| %>
    <div class="member-card">
      <%= image_tag member.avatar, class: "avatar" %>
      <span><%= member.name %></span>
      <span class="role"><%= member.role %></span>
    </div>
  <% end %>
</turbo-frame>
```

**Correct (cache block wrapping frame content with proper cache keys):**

```ruby
# app/controllers/projects_controller.rb
class ProjectsController < ApplicationController
  def team_members
    @project = Project.find(params[:id])
    @members = @project.members.includes(:avatar_attachment).order(:name)

    if stale?(etag: @project.members_cache_key)
      render partial: "projects/team_members", locals: { project: @project, members: @members }
    end
  end
end
```

```erb
<%# app/views/projects/_team_members.html.erb %>
<turbo-frame id="team_members">
  <% cache [project, "team_members", project.members.maximum(:updated_at)] do %>
    <% members.each do |member| %>
      <div class="member-card">
        <%= image_tag member.avatar, class: "avatar" %>
        <span><%= member.name %></span>
        <span class="role"><%= member.role %></span>
      </div>
    <% end %>
  <% end %>
</turbo-frame>
```
