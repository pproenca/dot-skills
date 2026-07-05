---
title: Assert the expected shape; don't defensively nil-guard everything
tags: flow, pattern-matching, assertive, let-it-crash
---

## Assert the expected shape; don't defensively nil-guard everything

Reaching for `Map.get(params, :email)` and then threading `if email do ... else ... end` guards through the code assumes the contract might be violated and buries the happy path under defensive checks. Worse, non-assertive access turns a missing key into a silent `nil` that propagates far from the real bug. On the BEAM you assert the shape you expect — `params.email` or a `%{email: email} = params` match — and let genuinely malformed input crash, so the supervisor restarts from clean state and the stack trace points at the boundary that received bad data.

**Incorrect (defensive, hides the contract, nil leaks downstream):**

```elixir
def notify(params) do
  email = Map.get(params, :email)
  if email, do: Mailer.send(email), else: :ok
end
```

**Correct (assertive — a missing email is a bug and crashes here):**

```elixir
def notify(%{email: email}), do: Mailer.send(email)
```

When a value is *legitimately* optional, write both clauses explicitly — `def notify(%{email: nil})` and `def notify(%{email: email})`. That is a real branch on a real state, not a defensive guard against a broken caller.

Reference: [Elixir — Code anti-patterns: "Non-assertive map access"](https://hexdocs.pm/elixir/code-anti-patterns.html)
