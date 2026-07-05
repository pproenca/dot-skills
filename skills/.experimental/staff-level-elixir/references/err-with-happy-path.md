---
title: Chain fallible steps with `with`, and keep the error term intact
tags: err, with, pattern-matching, control-flow
---

## Chain fallible steps with `with`, and keep the error term intact

A sequence of operations that each return `{:ok, _}`/`{:error, _}` gets ugly fast as nested `case` (the "pyramid of doom") or, worse, gets flattened by rescuing exceptions. `with` expresses the happy path linearly and short-circuits to the first non-matching clause. The common mistake in the `else` block is collapsing every failure into one generic term (`else _ -> {:error, :failed}`), which throws away *which* step failed and why. Either omit `else` entirely — an unmatched `{:error, reason}` is returned as-is, preserving context — or match the specific shapes you need to transform. Adding a catch-all `else` is what turns a precise error into a useless one.

**Correct (no catch-all `else` — each error keeps its identity):**

```elixir
def publish_post(user, attrs) do
  with {:ok, post}   <- Posts.create(user, attrs),
       {:ok, _}      <- Search.index(post),
       {:ok, post}   <- Posts.mark_published(post) do
    {:ok, post}
  end
  # No `else`: a {:error, %Ecto.Changeset{}} from create/1 flows straight out,
  # distinct from {:error, :index_unavailable} from Search.index/1.
end
```

**Incorrect (loses which step failed):**

```elixir
with {:ok, post} <- Posts.create(user, attrs),
     {:ok, _}    <- Search.index(post) do
  {:ok, post}
else
  _ -> {:error, :publish_failed}   # changeset errors and index errors now indistinguishable
end
```

Reference: [Elixir — `with`](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#with/1)
