---
title: Use Turbo Streams for Multi-Element Page Updates
impact: HIGH
impactDescription: eliminates custom AJAX for real-time CRUD updates
tags: turbo, streams, real-time, crud
---

## Use Turbo Streams for Multi-Element Page Updates

Turbo Frames replace one element. Turbo Streams update multiple elements simultaneously — append to a list, update a counter, remove a deleted item, and show a flash message, all from a single response. Use Turbo Streams when a user action needs to change more than one part of the page.

**Incorrect (custom JavaScript to update multiple DOM elements after AJAX):**

```javascript
// app/javascript/controllers/comment_controller.js
// Hand-rolled AJAX + DOM manipulation
export default class extends Controller {
  async submit(event) {
    event.preventDefault()
    const form = event.target
    const response = await fetch(form.action, {
      method: "POST",
      body: new FormData(form),
      headers: { "X-CSRF-Token": document.querySelector("[name='csrf-token']").content }
    })
    const html = await response.text()

    // Manually update 3 different page sections
    document.querySelector("#comments-list").insertAdjacentHTML("beforeend", html)
    const counter = document.querySelector("#comment-count")
    counter.textContent = parseInt(counter.textContent) + 1
    form.reset()
  }
}
```

**Correct (Turbo Stream response updates multiple elements declaratively):**

```ruby
# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  def create
    @comment = @post.comments.build(comment_params)

    if @comment.save
      respond_to do |format|
        format.turbo_stream  # renders create.turbo_stream.erb
        format.html { redirect_to @post }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

```erb
<%# app/views/comments/create.turbo_stream.erb %>
<%# Append the new comment to the list %>
<%= turbo_stream.append dom_id(@comment.post, :comments) do %>
  <%= render @comment %>
<% end %>

<%# Update the comment counter %>
<%= turbo_stream.update "comment-count" do %>
  <%= @comment.post.comments.count %>
<% end %>

<%# Clear the form %>
<%= turbo_stream.replace "new-comment-form" do %>
  <%= render "comments/form", comment: Comment.new, post: @comment.post %>
<% end %>
```

```erb
<%# app/views/posts/show.html.erb %>
<article>
  <h1><%= @post.title %></h1>
  <p><%= @post.body %></p>
</article>

<h2>Comments (<span id="comment-count"><%= @post.comments.count %></span>)</h2>

<div id="<%= dom_id(@post, :comments) %>">
  <%= render @post.comments %>
</div>

<%= turbo_frame_tag "new-comment-form" do %>
  <%= render "comments/form", comment: Comment.new, post: @post %>
<% end %>
```

### Turbo Stream Actions

| Action | What it does |
|---|---|
| `turbo_stream.append` | Add to end of target container |
| `turbo_stream.prepend` | Add to beginning of target container |
| `turbo_stream.replace` | Replace the target element entirely |
| `turbo_stream.update` | Replace the target's inner HTML |
| `turbo_stream.remove` | Remove the target element |
| `turbo_stream.before` | Insert before the target |
| `turbo_stream.after` | Insert after the target |

### Broadcasting with ActionCable

For real-time updates pushed to other users (live chat, notifications):

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  after_create_commit -> {
    broadcast_append_to(
      post,
      target: dom_id(post, :comments),
      partial: "comments/comment"
    )
  }

  after_destroy_commit -> {
    broadcast_remove_to(post)
  }
end
```

Reference: [Turbo Streams Handbook](https://turbo.hotwired.dev/handbook/streams)
