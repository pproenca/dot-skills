---
title: Fragment Caching for View Performance
impact: MEDIUM
impactDescription: reduces rendering time by caching expensive view fragments
tags: view, fragment-caching, cache, performance
---

## Fragment Caching for View Performance

Use Rails fragment caching with `cache` helpers to avoid re-rendering expensive view sections on every request. Combined with `touch` chains on associations, cached fragments automatically invalidate when underlying data changes. The 37signals multi-layer strategy stacks HTTP caching (`fresh_when`), fragment caching, and query caching — each layer reduces work for the layer below it.

**Incorrect (uncached views re-rendering expensive computations every request):**

```ruby
# app/views/boards/show.html.erb — renders everything on every request
<h1><%= @board.name %></h1>

<% @board.lists.includes(cards: [:assignees, :tags]).each do |list| %>
  <div class="list">
    <h2><%= list.name %> (<%= list.cards.count %>)</h2>
    <% list.cards.each do |card| %>
      <div class="card">
        <h3><%= card.title %></h3>
        <p><%= truncate(card.description, length: 200) %></p>
        <div class="assignees">
          <% card.assignees.each do |person| %>
            <%= image_tag person.avatar_url, class: "avatar", alt: person.name %>
          <% end %>
        </div>
        <div class="tags">
          <% card.tags.each do |tag| %>
            <span class="tag" style="background: <%= tag.color %>"><%= tag.name %></span>
          <% end %>
        </div>
        <time><%= time_ago_in_words(card.updated_at) %> ago</time>
      </div>
    <% end %>
  </div>
<% end %>
```

**Correct (multi-layer caching with touch invalidation):**

```ruby
# app/models/card.rb
class Card < ApplicationRecord
  belongs_to :list, touch: true
  has_many :tags, through: :taggings
end

# app/models/list.rb
class List < ApplicationRecord
  belongs_to :board, touch: true
  has_many :cards
end

# app/models/tagging.rb
class Tagging < ApplicationRecord
  belongs_to :card, touch: true
  belongs_to :tag
end

# app/controllers/boards_controller.rb
class BoardsController < ApplicationController
  def show
    @board = Current.account.boards.find(params[:id])
    fresh_when @board
  end
end

# app/views/boards/show.html.erb
<h1><%= @board.name %></h1>
<% @board.lists.includes(cards: :tags).each do |list| %>
  <%= cache list do %>
    <div class="list">
      <h2><%= list.name %> (<%= list.cards.size %>)</h2>
      <% list.cards.each do |card| %>
        <%= render card %>
      <% end %>
    </div>
  <% end %>
<% end %>

# app/views/cards/_card.html.erb
<%= cache card do %>
  <div class="card">
    <h3><%= card.title %></h3>
    <p><%= truncate(card.description, length: 200) %></p>
    <% card.tags.each do |tag| %>
      <span class="tag"><%= tag.name %></span>
    <% end %>
  </div>
<% end %>
```

**Benefits:**
- `fresh_when` prevents rendering entirely when the client has a current copy (304 response)
- Nested fragment caches mean updating one card only re-renders that card's fragment, not the entire board
- `touch: true` chains ensure that creating a tagging invalidates the card, which invalidates the list, which invalidates the board's `updated_at` for HTTP caching
- Collection caching with `render @cards` uses multi-read cache fetches for batch efficiency

**When NOT to use:** Do not cache fragments that contain user-specific content (e.g., "Welcome, Pedro") unless you scope the cache key to the user. For highly dynamic content that changes on every request (live counters, real-time presence), caching adds overhead without benefit.

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
