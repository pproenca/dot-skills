---
title: Turbo Streams for Real-Time Updates
impact: MEDIUM
impactDescription: eliminates custom WebSocket JavaScript, server-driven DOM updates
tags: view, turbo-streams, hotwire, real-time, action-cable
---

## Turbo Streams for Real-Time Updates

Use Turbo Streams to broadcast real-time changes from the server to all connected clients. Turbo Streams support seven actions — append, prepend, replace, update, remove, before, after — that declaratively mutate the DOM without any custom JavaScript. Combined with Solid Cable for database-backed pub/sub, this gives you real-time features using the same infrastructure as the rest of your app.

**Incorrect (manual WebSocket JavaScript for real-time updates):**

```ruby
# app/javascript/channels/cards_channel.js — hand-rolled WebSocket consumer
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "CardsChannel", board_id: boardId }, {
  received(data) {
    if (data.action === "created") {
      const list = document.getElementById(`list_${data.list_id}`);
      list.insertAdjacentHTML("beforeend", data.html);
    } else if (data.action === "updated") {
      const card = document.getElementById(`card_${data.id}`);
      card.outerHTML = data.html;
    } else if (data.action === "deleted") {
      const card = document.getElementById(`card_${data.id}`);
      card.remove();
    }
  }
});

# app/channels/cards_channel.rb
class CardsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "board_#{params[:board_id]}_cards"
  end
end

# app/models/card.rb — manual broadcast with rendered HTML
after_create_commit do
  ActionCable.server.broadcast("board_#{board_id}_cards", {
    action: "created",
    list_id: list_id,
    html: ApplicationController.render(partial: "cards/card", locals: { card: self })
  })
end
```

**Correct (Turbo Stream broadcasts with account-scoped streams):**

```ruby
# app/models/card.rb — declarative broadcasting, zero JavaScript
class Card < ApplicationRecord
  belongs_to :list
  belongs_to :board

  broadcasts_to ->(card) { [card.board.account, :cards] },
    inserts_by: :prepend,
    target: ->(card) { "list_#{card.list_id}_cards" }
end

# app/views/cards/_card.html.erb — standard partial, used for both initial render and broadcasts
<%= tag.div id: dom_id(card), class: "card" do %>
  <h3><%= card.title %></h3>
  <p><%= card.description %></p>
  <span class="badge"><%= card.assignees.count %> assigned</span>
<% end %>

# app/views/boards/show.html.erb — subscribe to account-scoped stream
<%= turbo_stream_from Current.account, :cards %>

<% @board.lists.each do |list| %>
  <div class="list">
    <h2><%= list.name %></h2>
    <div id="<%= "list_#{list.id}_cards" %>">
      <%= render list.cards %>
    </div>
  </div>
<% end %>

# config/cable.yml — Solid Cable for database-backed pub/sub
production:
  adapter: solid_cable
  polling_interval: 0.1.seconds
  silence_polling: true

# For inline stream responses from controller actions:
# app/controllers/cards_controller.rb
class CardsController < ApplicationController
  def create
    @card = Current.board.cards.create!(card_params)
    respond_to do |format|
      format.turbo_stream  # renders create.turbo_stream.erb
      format.html { redirect_to @card.board }
    end
  end
end

# app/views/cards/create.turbo_stream.erb
<%= turbo_stream.prepend "list_#{@card.list_id}_cards", @card %>
<%= turbo_stream.update "card_count", html: Current.board.cards.count %>
```

**When NOT to use:** For updates that only affect the current user's session (e.g., form validation errors, local UI state changes), use Turbo Frame responses or standard redirects. Broadcasts are for multi-user, real-time scenarios where all viewers of a resource need to see changes.

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
