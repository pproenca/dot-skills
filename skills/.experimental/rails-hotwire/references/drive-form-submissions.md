---
title: Use Turbo Drive for Form Submissions
impact: CRITICAL
impactDescription: eliminates full page reload on every form submit
tags: drive, forms, submissions, redirect
---

## Use Turbo Drive for Form Submissions

Turbo Drive intercepts standard form submissions automatically, sending them as fetch requests and processing the response without a full page reload. Rails controllers must respond with `303 See Other` status on redirects after non-GET requests (Rails does this by default with `redirect_to`). Avoid bypassing Turbo with manual `fetch()` calls for standard CRUD operations.

**Incorrect (bypassing Turbo with manual JavaScript):**

```erb
<%# Using JavaScript fetch instead of letting Turbo handle the form %>
<%= form_with model: @message, id: "message-form", data: { turbo: false } do |f| %>
  <%= f.text_area :body %>
  <%= f.submit "Send" %>
<% end %>

<script>
  document.getElementById("message-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const form = e.target;
    const response = await fetch(form.action, {
      method: "POST",
      body: new FormData(form),
      headers: { "Accept": "application/json" }
    });
    const data = await response.json();
    // Manually update DOM...
    document.getElementById("messages").insertAdjacentHTML("beforeend", data.html);
    form.reset();
  });
</script>
```

**Correct (standard form_with that Turbo intercepts automatically):**

```erb
<%= form_with model: @message do |f| %>
  <%= f.text_area :body %>
  <%= f.submit "Send", data: { turbo_submits_with: "Sending..." } %>
<% end %>
```

```ruby
# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  def create
    @message = current_user.messages.build(message_params)

    if @message.save
      # Rails automatically uses 303 See Other for redirect after POST
      redirect_to project_messages_path(@message.project),
                  notice: "Message sent"
    else
      # 422 tells Turbo to render the form with validation errors
      render :new, status: :unprocessable_entity
    end
  end
end
```
