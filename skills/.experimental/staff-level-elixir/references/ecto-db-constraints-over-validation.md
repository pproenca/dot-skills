---
title: Enforce uniqueness with a DB constraint, not a validation query
tags: ecto, changeset, constraints, race-conditions
---

## Enforce uniqueness with a DB constraint, not a validation query

Checking "is this email taken?" by querying in the changeset (a `validate`-then-insert pattern) is a time-of-check-to-time-of-use race: two concurrent requests both see "available" and both insert. Uniqueness can only be guaranteed by a `UNIQUE` index in the database. Ecto's `unique_constraint/3` doesn't query — it tells the changeset how to catch the database's constraint violation on insert and convert it into a friendly `{:error, changeset}` instead of a raised `Ecto.ConstraintError`. The same applies to `foreign_key_constraint`, `check_constraint`, etc.: the DB enforces the invariant, the changeset helper translates the failure. Requires the matching migration (`create unique_index(...)`).

**Correct (DB enforces it; the changeset translates the violation):**

```elixir
# Migration establishes the real guarantee:
#   create unique_index(:users, [:email])

def changeset(user, attrs) do
  user
  |> cast(attrs, [:email])
  |> validate_required([:email])
  |> unique_constraint(:email)   # translates the DB unique violation, doesn't pre-query
end
```

**Incorrect (racy — two requests can both pass this check):**

```elixir
def changeset(user, attrs) do
  changeset = cast(user, attrs, [:email])
  if Repo.exists?(from u in User, where: u.email == ^get_field(changeset, :email)) do
    add_error(changeset, :email, "already taken")
  else
    changeset
  end
end
```

Reference: [Ecto — `Ecto.Changeset.unique_constraint/3`](https://hexdocs.pm/ecto/Ecto.Changeset.html#unique_constraint/3)
