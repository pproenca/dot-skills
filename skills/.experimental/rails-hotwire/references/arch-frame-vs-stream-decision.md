---
title: Use Frames for Scoped Navigation, Streams for Multi-Target Updates
impact: MEDIUM
impactDescription: prevents architectural mismatch and maintenance burden
tags: arch, turbo-frames, turbo-streams, decision
---

## Use Frames for Scoped Navigation, Streams for Multi-Target Updates

Turbo Frames and Turbo Streams solve different problems. Frames scope navigation to a single region of the page in response to user-initiated actions like clicking a link or submitting a form. Streams update one or more targets from server-initiated events or multi-target responses. Using the wrong primitive leads to convoluted workarounds, such as forcing Streams to handle simple inline editing or shoehorning Frames into multi-region update scenarios.

**Incorrect (using Turbo Streams for simple inline edit that Frames handle perfectly):**

```ruby
# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  def edit
    @comment = Comment.find(params[:id])
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "comment_#{@comment.id}",
          partial: "comments/form",
          locals: { comment: @comment }
        )
      }
    end
  end
end
```

```erb
<%# Unnecessarily complex: needs explicit turbo_stream response for a simple edit %>
<%= link_to "Edit", edit_comment_path(comment),
    data: { turbo_stream: true } %>
```

**Correct (Frame for inline edit, Stream for updating notification count + last-activity timestamp simultaneously):**

```erb
<%# Turbo Frame: perfect for scoped inline edit %>
<turbo-frame id="<%= dom_id(comment) %>">
  <p><%= comment.body %></p>
  <%= link_to "Edit", edit_comment_path(comment) %>
</turbo-frame>

<%# The edit form automatically scopes within the same frame %>
<%# app/views/comments/edit.html.erb %>
<turbo-frame id="<%= dom_id(@comment) %>">
  <%= form_with model: @comment do |f| %>
    <%= f.text_area :body %>
    <%= f.submit "Save" %>
    <%= link_to "Cancel", comment_path(@comment) %>
  <% end %>
</turbo-frame>
```

```erb
<%# Turbo Streams: correct for multi-target server-initiated updates %>
<%# app/views/comments/create.turbo_stream.erb %>
<%= turbo_stream.append "comments", @comment %>
<%= turbo_stream.update "comments_count", Comment.count %>
<%= turbo_stream.replace "last_activity" do %>
  <%= render "shared/last_activity", time: @comment.created_at %>
<% end %>
```
