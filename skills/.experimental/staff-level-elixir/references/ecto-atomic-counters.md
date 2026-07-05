---
title: Update counters with SQL arithmetic, not read-modify-write
tags: ecto, update-all, concurrency, lost-update
---

## Update counters with SQL arithmetic, not read-modify-write

The natural way to bump a counter — load the row, add one in Elixir, save — is a lost-update race: two concurrent requests both read `views: 10`, both write `views: 11`, and one increment vanishes. A transaction alone doesn't fix it without an explicit row lock, because both reads can still happen before either write. Do the arithmetic in the database instead, where it's atomic: `Repo.update_all` with `inc:` (or `update: [inc: ...]` inside an `Ecto.Multi`) issues a single `UPDATE ... SET views = views + 1` that the DB serializes correctly under concurrency. Reserve read-modify-write for fields only one process ever touches.

**Correct (atomic — the DB serializes the increment):**

```elixir
# Atomic in the database — no read, no lost update under concurrency.
def increment_views(post_id) do
  {1, _} =
    from(p in Post, where: p.id == ^post_id)
    |> Repo.update_all(inc: [views: 1])

  :ok
end
```

**Incorrect (lost update — concurrent callers overwrite each other):**

```elixir
def increment_views(post_id) do
  post = Repo.get!(Post, post_id)
  post |> Post.changeset(%{views: post.views + 1}) |> Repo.update()
end
```

Reference: [Ecto — `Ecto.Repo.update_all/3`](https://hexdocs.pm/ecto/Ecto.Repo.html#c:update_all/3)
