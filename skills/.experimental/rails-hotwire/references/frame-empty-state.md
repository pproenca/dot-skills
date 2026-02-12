---
title: Provide Meaningful Frame Loading States
impact: MEDIUM
impactDescription: reduces perceived latency and layout shift
tags: frame, loading-state, skeleton, ux
---

## Provide Meaningful Frame Loading States

Content placed inside a `turbo_frame_tag` with a `src` attribute displays as a placeholder until the frame's content loads from the server. An empty frame shows a blank gap that causes layout shift when content arrives. Providing skeleton placeholders or spinners inside the frame tag gives users immediate visual feedback and reserves the correct amount of vertical space.

**Incorrect (empty frame that shows nothing during load):**

```erb
<%# app/views/projects/show.html.erb %>
<%# Users see a blank gap until the frame loads — feels broken %>
<h1><%= @project.name %></h1>

<%= turbo_frame_tag "project_comments",
    src: project_comments_path(@project),
    loading: :lazy %>

<%# Or with a generic "Loading..." that provides no spatial context %>
<%= turbo_frame_tag "project_activity",
    src: project_activity_path(@project),
    loading: :lazy do %>
  Loading...
<% end %>
```

**Correct (skeleton placeholders that match loaded content dimensions):**

```erb
<%# app/views/projects/show.html.erb %>
<h1><%= @project.name %></h1>

<%# Skeleton placeholder matches the shape of loaded comments %>
<%= turbo_frame_tag "project_comments",
    src: project_comments_path(@project),
    loading: :lazy do %>
  <div class="comments-skeleton" aria-busy="true" aria-label="Loading comments">
    <% 3.times do %>
      <div class="skeleton-comment">
        <div class="skeleton-avatar"></div>
        <div class="skeleton-lines">
          <div class="skeleton-line skeleton-line--wide"></div>
          <div class="skeleton-line skeleton-line--medium"></div>
        </div>
      </div>
    <% end %>
  </div>
<% end %>

<%# For simpler sections, a contextual spinner works %>
<%= turbo_frame_tag "project_activity",
    src: project_activity_path(@project),
    loading: :lazy do %>
  <div class="loading-placeholder" aria-busy="true">
    <svg class="spinner" role="img" aria-label="Loading activity feed">
      <!-- spinner SVG -->
    </svg>
    <span>Loading activity feed...</span>
  </div>
<% end %>
```

```css
/* app/assets/stylesheets/skeletons.css */
.skeleton-comment {
  display: flex;
  gap: 12px;
  padding: 16px 0;
}

.skeleton-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--skeleton-bg, #e5e7eb);
  animation: pulse 1.5s ease-in-out infinite;
}

.skeleton-line {
  height: 12px;
  border-radius: 4px;
  background: var(--skeleton-bg, #e5e7eb);
  animation: pulse 1.5s ease-in-out infinite;
}

.skeleton-line--wide { width: 80%; }
.skeleton-line--medium { width: 60%; margin-top: 8px; }

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
```
