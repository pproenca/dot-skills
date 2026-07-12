---
title: Target component-owned events with phx-target={@myself}
tags: bound, live-component, phx-target, event-routing
---

## Target component-owned events with phx-target={@myself}

Event bindings route to the parent LiveView by default — a LiveComponent's template does not change that. When a component defines `handle_event("toggle_watch", ...)` but its `phx-click="toggle_watch"` carries no `phx-target={@myself}`, the event arrives at the parent instead: a crash if the parent has no matching clause, or — worse — silent mis-handling if the parent happens to define an event of the same name for another element. The component's handler is dead code either way, and the bug only surfaces at click time, never at compile time. The docs state it directly: "For a client event to reach a component, the tag must be annotated with a phx-target. If you want to send the event to yourself, you can simply use the `@myself` assign."

**Evidence of violation:** an event binding (`phx-click`, `phx-change`, `phx-submit`, `phx-keydown`, or any `phx-*` event attribute) in a LiveComponent's template whose event name matches a `handle_event/3` clause defined in that same component, with no `phx-target={@myself}` (or an explicit target) on the required element: for form-lifecycle events (`phx-change`/`phx-submit`) the target may sit on the `<form>`/`<.form>` element itself; for every other binding (`phx-click`, key and focus bindings) the target must be on the bound element — an enclosing form's `phx-target` does not cover non-form events. PASS: every binding whose handler lives in the component carries its own `phx-target={@myself}` (or sits on a form that carries it, for form events only); cite the template lines checked. Also PASS (citable): the binding intentionally targets the parent — cite the parent's `handle_event` clause for that event name; if neither module defines a matching clause, the binding fails this rule as dead wiring.

```heex
<%!-- lib/paddle_web/live/auction_live/watch_button_component.ex --%>
<button phx-click="toggle_watch" phx-target={@myself} class="watch-btn">
  {if @watching?, do: "Unwatch", else: "Watch"}
</button>
```

Reference: [Phoenix.LiveComponent — targeting component events](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html)
