---
title: Handle Stimulus Controller Reconnection After Morph
impact: MEDIUM-HIGH
impactDescription: "prevents broken interactivity after morphing updates"
tags: morph, stimulus, controllers, lifecycle
---

## Handle Stimulus Controller Reconnection After Morph

When Turbo morphs the DOM, it patches elements in place rather than removing and re-inserting them. This means Stimulus controllers attached to morphed elements may not receive `disconnect`/`connect` lifecycle callbacks, leaving stale state (expired timers, orphaned event listeners, outdated data). Listening to `turbo:morph-element` or `turbo:morph` events allows controllers to detect when their element has been morphed and re-initialize any state that depends on current DOM content.

**Incorrect (Stimulus controller state lost after morph):**

```javascript
// app/javascript/controllers/countdown_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { deadline: String };

  connect() {
    this.startCountdown();
  }

  disconnect() {
    clearInterval(this.timer);
  }

  startCountdown() {
    this.timer = setInterval(() => {
      const remaining = new Date(this.deadlineValue) - new Date();
      this.element.textContent = this.formatTime(remaining);
    }, 1000);
  }

  // BUG: when morph updates the deadline value attribute,
  // the controller keeps counting down to the OLD deadline
  // because connect/disconnect are never called.

  formatTime(ms) {
    const seconds = Math.floor(ms / 1000) % 60;
    const minutes = Math.floor(ms / 60000);
    return `${minutes}:${seconds.toString().padStart(2, "0")}`;
  }
}
```

**Correct (listening to turbo:morph-element to re-establish state):**

```javascript
// app/javascript/controllers/countdown_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { deadline: String };

  connect() {
    this.startCountdown();
    // Listen for morphs on this element
    this.element.addEventListener("turbo:morph-element", this.handleMorph);
  }

  disconnect() {
    clearInterval(this.timer);
    this.element.removeEventListener("turbo:morph-element", this.handleMorph);
  }

  handleMorph = () => {
    // Re-read values and restart after morph patches the element
    clearInterval(this.timer);
    this.startCountdown();
  };

  // Stimulus value changed callback — also works for morphed attribute updates
  deadlineValueChanged() {
    clearInterval(this.timer);
    this.startCountdown();
  }

  startCountdown() {
    this.timer = setInterval(() => {
      const remaining = new Date(this.deadlineValue) - new Date();
      this.element.textContent = this.formatTime(remaining);
    }, 1000);
  }

  formatTime(ms) {
    const seconds = Math.floor(ms / 1000) % 60;
    const minutes = Math.floor(ms / 60000);
    return `${minutes}:${seconds.toString().padStart(2, "0")}`;
  }
}
```
