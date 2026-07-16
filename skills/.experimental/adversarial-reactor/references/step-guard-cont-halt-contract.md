---
title: Guards speak :cont / {:halt, result} — where speaks booleans
tags: step, guard, where, conditionals
---

## Guards speak :cont / {:halt, result} — where speaks booleans

The two conditional entities have different contracts and different powers, and
the wrong default is to treat both as predicates. `where` takes a function
returning a **boolean**: false skips the step. `guard` takes a function
returning **`:cont`** (proceed) or **`{:halt, result}`** (skip the step and use
`result` in its place — how a cache hit substitutes a real result). A guard
returning `true`/`false` violates the contract and does not conditionally skip
anything; a `where` returning `:cont`/`{:halt, _}` hands the step a truthy
value that never skips. The tell is a boolean expression inside `guard` or
guard-vocabulary inside `where`.

**Evidence of violation:** a `guard` block whose function returns a boolean
expression (no `:cont`/`{:halt, _}` in any path), or a `where` block whose
function returns `:cont`/`{:halt, _}`. PASS: every `where` returns a boolean;
every `guard` returns `:cont` or `{:halt, result}` on all paths. N/A: the
target uses neither entity.

```elixir
step :fetch_profile, Profiles.Fetch do
  argument :user_id, input(:user_id)

  # Boolean skip: where.
  where fn %{user_id: id}, _ctx -> not is_nil(id) end

  # Skip-with-substitute: guard.
  guard fn %{user_id: id}, context ->
    case Map.fetch(context, :profile_cache) do
      {:ok, cached} -> {:halt, {:ok, cached}}
      :error -> :cont
    end
  end
end
```

Reference: [Reactor DSL — guard and where entities](https://reactor.hexdocs.pm/dsl-reactor.html)
