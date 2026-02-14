---
title: Turbo Frames for Scoped Page Fragments
impact: MEDIUM
impactDescription: eliminates custom AJAX code, zero JavaScript required
tags: view, turbo-frames, hotwire, partial-updates
---

## Turbo Frames for Scoped Page Fragments

Use Turbo Frames to update specific page sections without full page reloads. Each frame scopes navigation so that links and forms within a frame only replace that frame's content. This eliminates the need for custom JavaScript fetch calls, manual DOM manipulation, and hand-rolled AJAX handlers — the server renders HTML and Turbo handles the swap.

**Incorrect (custom JavaScript for partial page updates):**

```ruby
# app/views/cards/show.html.erb — manual AJAX approach
<div id="card-comments">
  <%= render @card.comments %>
</div>

<%= form_with model: [@card, Comment.new], id: "new-comment-form" do |f| %>
  <%= f.text_area :body %>
  <%= f.submit "Post Comment" %>
<% end %>

<script>
  // Custom JavaScript to handle form submission and partial update
  document.getElementById("new-comment-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const form = e.target;
    const response = await fetch(form.action, {
      method: "POST",
      body: new FormData(form),
      headers: { "X-CSRF-Token": document.querySelector("[name='csrf-token']").content }
    });
    const html = await response.text();
    document.getElementById("card-comments").innerHTML = html;
    form.reset();
  });
</script>
```

**Correct (Turbo Frame scoping navigation):**

```ruby
# app/views/cards/show.html.erb — Turbo Frame scopes updates automatically
<%= turbo_frame_tag "card_comments" do %>
  <%= render @card.comments %>

  <%= form_with model: [@card, Comment.new] do |f| %>
    <%= f.text_area :body %>
    <%= f.submit "Post Comment" %>
  <% end %>
<% end %>

# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  def create
    @card = Card.find(params[:card_id])
    @card.comments.create!(comment_params)
    redirect_to @card
  end

  private

  def comment_params
    params.expect(comment: [:body])
  end
end

# app/views/cards/show.html.erb — lazy-loaded frame for expensive sections
<%= turbo_frame_tag "activity_feed", src: card_activities_path(@card), loading: :lazy do %>
  <p>Loading activity...</p>
<% end %>
```

**Alternative:** For updates that target multiple page sections at once, use Turbo Streams instead — frames can only replace their own content.

**When NOT to use:** If the entire page layout changes on navigation (e.g., going from a list view to a detail view with a different layout), use standard full-page navigation. Turbo Frames are best for scoped, in-place updates within a stable page layout.

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
