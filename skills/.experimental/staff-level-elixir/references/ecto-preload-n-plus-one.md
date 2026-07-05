---
title: Preload associations up front, never inside a loop
tags: ecto, preload, n-plus-one, queries
---

## Preload associations up front, never inside a loop

Ecto does not lazy-load associations — accessing an unloaded one gives `%Ecto.Association.NotLoaded{}`, not a query. The trap is to "fix" that by loading inside an `Enum` iteration (`Enum.map(posts, &Repo.preload(&1, :author))`), which fires one query per row: the classic N+1. Preload the whole set in one shot instead — either with `preload:` in the query (a join or a second batched query) or a single `Repo.preload(posts, :author)` on the full list, which loads all authors in one `WHERE id IN (...)`. Nest preloads for deep associations. The difference is 1–2 queries versus N+1.

**Correct (preload the whole set — 1–2 queries total):**

```elixir
# One query for posts + one batched query for all their authors and comments.
posts =
  from(p in Post, where: p.published)
  |> Repo.all()
  |> Repo.preload([:author, comments: :user])

Enum.each(posts, fn post ->
  IO.puts("#{post.title} by #{post.author.name}")   # already loaded, no query
end)
```

**Incorrect (N+1 — one author query per post):**

```elixir
posts = Repo.all(from p in Post, where: p.published)
Enum.map(posts, fn post -> Repo.preload(post, :author).author.name end)
```

Reference: [Ecto — `Ecto.Repo.preload/3`](https://hexdocs.pm/ecto/Ecto.Repo.html#c:preload/3)
