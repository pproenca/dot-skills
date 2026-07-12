---
title: Manage focus in JS-toggled overlays
tags: ui, focus, accessibility, modals
---

## Manage focus in JS-toggled overlays

A hand-rolled modal shown with `JS.show` leaves keyboard focus behind the overlay: Tab cycles through the page underneath, screen readers never enter the dialog, and closing it strands focus at the document root. LiveView ships the exact mechanisms: `<.focus_wrap>` — which the docs call "an essential accessibility feature for interfaces such as modals, dialogs, and menus" — wraps Tab focus inside the container, `JS.focus_first` moves focus in on open, and `JS.push_focus`/`JS.pop_focus` save and restore the trigger's focus around the overlay's lifetime. The generated `core_components.ex` modal wires all three; overlays written from scratch drop them. This rule fires only on enumerated overlay markers — no judgment about what counts as a modal.

**Evidence of violation:** an element bearing `role="dialog"`, `aria-modal="true"`, or an `id` containing `modal`, `drawer`, or `dialog`, shown/hidden via JS commands, whose content is neither wrapped in `<.focus_wrap>` nor focused via `JS.focus_first` on open, or whose close command lacks `JS.pop_focus` (or an equivalent focus restore to the trigger). PASS: cite the `focus_wrap`/`focus_first` on open and the `pop_focus` on close per overlay. N/A: no elements with the enumerated markers in the target. Carve-out (citable): the overlay is non-interactive (no focusable children — a toast or announcement layer); cite the content, otherwise fail closed.

```heex
<div id="confirm-bid-modal" role="dialog" aria-modal="true" class="hidden">
  <.focus_wrap id="confirm-bid-focus">
    <p>Place bid of {@pending_amount} on {@lot.title}?</p>
    <.button phx-click={JS.push("confirm_bid") |> JS.hide(to: "#confirm-bid-modal") |> JS.pop_focus()}>
      Confirm
    </.button>
  </.focus_wrap>
</div>
<.button phx-click={JS.push_focus() |> JS.show(to: "#confirm-bid-modal") |> JS.focus_first(to: "#confirm-bid-focus")}>
  Place bid
</.button>
```

Reference: [Phoenix.Component.focus_wrap/1](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#focus_wrap/1), [Phoenix.LiveView.JS — focus commands](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.JS.html)
