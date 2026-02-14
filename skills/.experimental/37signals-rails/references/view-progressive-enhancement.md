---
title: Progressive Enhancement as Primary Pattern
impact: MEDIUM
impactDescription: ensures functionality without JavaScript, 100% baseline coverage
tags: view, progressive-enhancement, hotwire, accessibility
---

## Progressive Enhancement as Primary Pattern

Build features that work with server-rendered HTML first, then layer on Turbo and Stimulus for a richer experience. Links should navigate, forms should submit, and content should be readable before any JavaScript loads. This ensures the application works on slow connections, when JS fails to load, and for assistive technologies. Hotwire is designed around this principle — Turbo enhances standard links and forms, Stimulus adds behavior to existing markup.

**Incorrect (JavaScript-dependent feature that breaks without JS):**

```ruby
# app/views/cards/index.html.erb — requires JavaScript to function
<div id="card-list"></div>

<script>
  // Nothing renders without JavaScript — blank page on failure
  async function loadCards() {
    const response = await fetch("/cards.json");
    const cards = await response.json();
    const list = document.getElementById("card-list");
    cards.forEach(card => {
      const el = document.createElement("div");
      el.className = "card";
      el.innerHTML = `
        <h3>${card.title}</h3>
        <p>${card.description}</p>
        <button onclick="deleteCard(${card.id})">Delete</button>
      `;
      list.appendChild(el);
    });
  }

  async function deleteCard(id) {
    await fetch(`/cards/${id}`, { method: "DELETE" });
    loadCards();  // Re-render entire list
  }

  loadCards();
</script>
```

**Correct (server-rendered HTML enhanced with Turbo and Stimulus):**

```ruby
# app/views/cards/index.html.erb
<div id="cards">
  <% @cards.each do |card| %>
    <%= render card %>
  <% end %>
</div>

# app/views/cards/_card.html.erb
<%= tag.div id: dom_id(card), class: "card" do %>
  <h3><%= link_to card.title, card %></h3>
  <p><%= card.description %></p>
  <%= button_to "Delete", card, method: :delete,
      form: { data: { turbo_confirm: "Delete this card?" } } %>
<% end %>

# Stimulus adds keyboard navigation (optional enhancement)
# app/javascript/controllers/keyboard_nav_controller.js
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["item"]
  connect() {
    this.index = 0
  }
  next(event) {
    event.preventDefault()
    this.index = Math.min(this.index + 1, this.itemTargets.length - 1)
    this.itemTargets[this.index].focus()
  }
  previous(event) {
    event.preventDefault()
    this.index = Math.max(this.index - 1, 0)
    this.itemTargets[this.index].focus()
  }
}

# app/controllers/cards_controller.rb
class CardsController < ApplicationController
  def destroy
    @card = Card.find(params[:id])
    @card.destroy!
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@card) }
      format.html { redirect_to cards_path, notice: "Card deleted" }
    end
  end
end
```

**Benefits:**
- Page is functional immediately on first paint, before JavaScript loads
- Turbo Stream response removes the card without a full reload when JS is available
- Falls back to a standard redirect with flash notice when JS is not available
- Keyboard navigation is additive — mouse and touch users are unaffected

**When NOT to use:** Highly interactive features like drag-and-drop reordering or real-time collaborative editing inherently require JavaScript. In those cases, still render initial content server-side and use Stimulus to add the interactive layer, providing a sensible read-only fallback.

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
