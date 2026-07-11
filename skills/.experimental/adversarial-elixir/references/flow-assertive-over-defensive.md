---
title: Assert the expected shape; don't defensively nil-guard everything
tags: flow, pattern-matching, assertive, let-it-crash
---

## Assert the expected shape; don't defensively nil-guard everything

Reaching for `Map.get(params, :email)` and then threading `if email do ... else ... end` guards through the code assumes the contract might be violated and buries the happy path under defensive checks. Worse, non-assertive access turns a missing key into a silent `nil` that propagates far from the real bug. On the BEAM you assert the shape you expect — `params.email` or a `%{email: email} = params` match — and let genuinely malformed input crash, so the supervisor restarts from clean state and the stack trace points at the boundary that received bad data.

**Evidence of violation:** non-assertive access (`Map.get/2`, `map[:key]`, or a bare truthiness check) on a value the function's contract requires — the tell is what the nil branch does: it silently swallows (`:ok`, `nil`, skipping the work) instead of representing a real domain state. Cite the access and the swallowing branch together. PASS: required values are bound by pattern matching in the head or body (`%{email: email} = params`, `params.email`), and genuinely broken input crashes. N/A: no map/keyword access in the target. Carve-out (in the rule): a legitimately optional value handled with explicit clauses for both states (`def notify(%{email: nil})` / `def notify(%{email: email})`) or a `case` naming both outcomes — the optionality must be real (a nullable column, an optional param), not a guard against a hypothetical broken caller. Boundary code validating raw external input is `flow-normalize-at-boundary`'s subject, not this rule's.

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
