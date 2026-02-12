---
title: Use Outlets for Cross-Controller Communication
impact: MEDIUM
impactDescription: eliminates custom event boilerplate for cross-controller communication
tags: stim, stimulus, outlets, communication
---

## Use Outlets for Cross-Controller Communication

When one Stimulus controller needs to talk to another (e.g., a form submits and a counter updates), use Stimulus outlets. Outlets give you a typed, declarative reference from one controller to another. They are cleaner than dispatching custom DOM events and less fragile than querying the DOM for elements managed by other controllers.

**Incorrect (custom DOM events and manual element lookups):**

```javascript
// app/javascript/controllers/cart_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  add(event) {
    const item = event.params.item

    // Fragile: depends on DOM structure and data attribute naming
    const counter = document.querySelector("[data-controller='cart-counter']")
    if (counter) {
      const count = parseInt(counter.dataset.cartCounterCountValue) + 1
      counter.dataset.cartCounterCountValue = count
    }

    // Alternative but still fragile: custom events
    this.element.dispatchEvent(
      new CustomEvent("cart:itemAdded", { bubbles: true, detail: { item } })
    )
  }
}
```

```javascript
// app/javascript/controllers/cart_counter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Have to listen on document — hard to track and clean up
    document.addEventListener("cart:itemAdded", this.increment.bind(this))
  }

  disconnect() {
    document.removeEventListener("cart:itemAdded", this.increment.bind(this))
  }
}
```

**Correct (Stimulus outlets for declarative cross-controller communication):**

```javascript
// app/javascript/controllers/cart_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = ["counter", "notification"]

  add(event) {
    const item = event.params.item

    // Direct, typed reference to the counter controller
    this.counterOutlet.increment()

    // Can reference multiple outlet types
    if (this.hasNotificationOutlet) {
      this.notificationOutlet.show(`Added ${item} to cart`)
    }
  }
}
```

```javascript
// app/javascript/controllers/counter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { count: { type: Number, default: 0 } }
  static targets = ["display"]

  increment() {
    this.countValue++
  }

  countValueChanged() {
    this.displayTarget.textContent = this.countValue
  }
}
```

```javascript
// app/javascript/controllers/notification_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  show(text) {
    this.messageTarget.textContent = text
    this.element.classList.remove("hidden")
    setTimeout(() => this.element.classList.add("hidden"), 3000)
  }
}
```

```erb
<%# HTML wiring — outlets are declared via data attributes %>
<div data-controller="cart"
     data-cart-counter-outlet="#cart-counter"
     data-cart-notification-outlet="#notification-banner">

  <button data-action="cart#add"
          data-cart-item-param="Blue T-Shirt">
    Add to Cart
  </button>
</div>

<%# Counter component — can be anywhere in the DOM %>
<div id="cart-counter" data-controller="counter" data-counter-count-value="0">
  Cart: <span data-counter-target="display">0</span> items
</div>

<%# Notification banner — also anywhere in the DOM %>
<div id="notification-banner" data-controller="notification" class="hidden">
  <p data-notification-target="message"></p>
</div>
```

Outlets also provide lifecycle callbacks:

```javascript
// Called when an outlet element connects/disconnects
counterOutletConnected(outlet, element) {
  console.log("Counter connected:", element.id)
}

counterOutletDisconnected(outlet, element) {
  console.log("Counter disconnected:", element.id)
}
```

Reference: [Stimulus Outlets](https://stimulus.hotwired.dev/reference/outlets)
