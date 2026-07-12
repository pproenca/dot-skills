---
title: Give visible in-flight feedback on server actions
tags: ui, loading-states, disable-with, feedback
---

## Give visible in-flight feedback on server actions

Between a click and the server's ack, the UI is the only evidence the action registered — on localhost that window is invisible; on a real connection it is hundreds of milliseconds of apparent deadness that trains users to click again. LiveView already provides the mechanisms for free: `phx-disable-with` swaps the button text during submission, every push applies loading classes (`phx-submit-loading`, `phx-click-loading`, `phx-change-loading`) to the pushing element until ack, and `JS.push(..., loading: selector)` directs those classes at the element the user perceives as busy. Note the built-in double-submit protection (inputs set readonly, submit button disabled during `phx-submit`) is automatic — this rule gates *visible* feedback, not a re-implementation of that guard.

**Evidence of violation:** a form submit button with neither `phx-disable-with` nor any `phx-submit-loading` styling anywhere in the project's classes/CSS; or a mutating `phx-click` (an event whose handler writes data) with none of `phx-disable-with`, a `phx-click-loading` style reference, a `JS.push(..., loading: ...)` target, or a piped client-side JS mutation acknowledging the click. PASS: cite the mechanism per action — the `phx-disable-with` attribute, the `phx-*-loading:` class variant in the template or CSS, or the piped `JS.push`. N/A: the target contains no submit buttons and no mutating click bindings. No carve-outs — one of the named mechanisms exists per action or the rule fails.

```heex
<.form for={@bid_form} phx-submit="place_bid">
  <.input field={@bid_form[:amount]} type="number" />
  <.button phx-disable-with="Placing bid..." class="phx-submit-loading:opacity-75">
    Place bid
  </.button>
</.form>
```

Reference: [Form bindings — hexdocs](https://hexdocs.pm/phoenix_live_view/form-bindings.html), [Syncing changes — loading classes](https://hexdocs.pm/phoenix_live_view/syncing-changes.html)
