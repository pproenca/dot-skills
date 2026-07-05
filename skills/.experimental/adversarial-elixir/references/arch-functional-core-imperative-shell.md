---
title: Extract decisions into a pure core; keep processes and web a thin shell
tags: arch, functional-core, testability, refactor
---

## Extract decisions into a pure core; keep processes and web a thin shell

When business decisions are computed *inside* a `handle_call`, a controller action, or an Oban worker, the logic can only be exercised by starting a process or building a `conn` — it is trapped in the effectful shell. The idiomatic shape is a functional core / imperative shell: pure functions decide *what* should happen from plain data, and the process/controller is a thin adapter that feeds data in and performs the effects out. This is a deep, wide refactor — it moves logic across module boundaries — but it makes the core trivially testable and the shell almost logic-free.

```elixir
# Pure core: a plain function computes the decision from data.
defmodule MyApp.Checkout do
  def review(cart, coupons) do
    # returns %{total: _, applied: _, rejected: _} — no IO, no process
  end
end

# Imperative shell: LiveView just calls the core and renders/persists.
def handle_event("apply", %{"code" => code}, socket) do
  review = MyApp.Checkout.review(socket.assigns.cart, [code | socket.assigns.coupons])
  {:noreply, assign(socket, review: review)}
end
```

Reference: [Designing Elixir Systems with OTP — functional core, then wrap it in processes](https://pragprog.com/titles/jgotp/designing-elixir-systems-with-otp/)
