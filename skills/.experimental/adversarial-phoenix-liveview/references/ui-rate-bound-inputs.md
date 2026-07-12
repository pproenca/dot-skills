---
title: Debounce and key-scope keystroke-driven events
tags: ui, debounce, throttle, key-bindings
---

## Debounce and key-scope keystroke-driven events

An unbounded `phx-change` on a text input pushes one server event per keystroke — a user typing a bid-history search fires a dozen round-trips, each re-running validation or a query, saturating the socket and the LiveView's single mailbox. `phx-debounce` (a millisecond value, `"blur"`, or bare for the 300ms default) collapses the firehose to the rhythm that matters. The same applies to key bindings: `phx-window-keydown` without `phx-key` fires for *every* key press even when the handler matches only one, and for held-key scenarios the docs are explicit that throttle "should always be used". The debounce *value* is not gated — only that a bound exists.

**Evidence of violation:** a text-entry input under a form with `phx-change` (validation, search, autocomplete) carrying no `phx-debounce` attribute; or a `phx-keydown`/`phx-window-keydown` binding without `phx-key` while its `handle_event` matches specific keys only; or a held-key binding (arrow/navigation handling) without `phx-throttle`. PASS: cite the `phx-debounce`/`phx-key`/`phx-throttle` attribute per binding. N/A: no `phx-change` text inputs and no key bindings in the target. Carve-out (citable): an input whose per-keystroke events are the product itself — a collaborative editor or live character counter — where the handler is a pure assign with no query; cite the handler body, otherwise fail closed. Also note `phx-keydown`/`phx-keyup` are documented as not supported on inputs — form bindings own those elements.

```heex
<.input
  field={@search_form[:query]}
  type="text"
  placeholder="Search bid history"
  phx-debounce="300"
/>
<div id="lot-viewer" phx-window-keydown="cycle_lot" phx-key="ArrowRight" phx-throttle="200">
  <!-- next-lot navigation; fires only for ArrowRight, at most 5/s -->
</div>
```

Reference: [Bindings — key events](https://hexdocs.pm/phoenix_live_view/bindings.html), [Form bindings — debounce and throttle](https://hexdocs.pm/phoenix_live_view/form-bindings.html)
