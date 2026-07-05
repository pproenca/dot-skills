---
title: Model expected outcomes as tagged tuples, not raise/rescue control flow
tags: flow, error-handling, control-flow, tagged-tuples
---

## Model expected outcomes as tagged tuples, not raise/rescue control flow

A `raise`/`rescue` pair used to branch on an *expected* outcome — record not found, validation failed, insufficient funds — is control flow smuggled in from languages where exceptions are the branching tool (Python's `try`, Ruby's `rescue`). Rip it out: exceptions-as-an-`if` hide the branch (control jumps invisibly across the stack), are slower than a return, and conflate an *expected alternative* with a *bug*. Expected alternatives are data — return `{:ok, value}` / `{:error, reason}` and branch with `case`/`with`. Reserve `raise` for violated invariants, the "this should never happen" cases the supervisor should catch. Refactoring this often deletes a whole `try/rescue` scaffold and the custom exception modules it depended on.

**Incorrect (exception as a branch):**

```elixir
def charge(account, amount) do
  if account.balance < amount, do: raise "insufficient funds"
  debit(account, amount)
end

# caller:
try do
  charge(account, amount)
rescue
  _ -> show_declined()
end
```

**Correct (the alternative is a value):**

```elixir
# Bind the field in the head and guard on the variable — dot-access is not
# allowed inside a guard.
def charge(%{balance: balance} = account, amount) when balance >= amount,
  do: {:ok, debit(account, amount)}
def charge(_account, _amount), do: {:error, :insufficient_funds}

case charge(account, amount) do
  {:ok, account} -> show_receipt(account)
  {:error, :insufficient_funds} -> show_declined()
end
```

This is the same distinction the standard library draws with `Repo.get` (returns `nil`) versus `Repo.get!` (raises): the `!` variant is for when absence truly is a bug.

Reference: [Elixir — Design anti-patterns: "Exceptions for control-flow"](https://hexdocs.pm/elixir/design-anti-patterns.html)
