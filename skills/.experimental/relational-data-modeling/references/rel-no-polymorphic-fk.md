---
title: Avoid polymorphic foreign keys
tags: rel, polymorphic-association, exclusive-arc, referential-integrity
---

## Avoid polymorphic foreign keys

Rails, Django and Laravel all ship a `commentable_type` / `commentable_id` pair,
and it reproduces on request because it looks like the obvious answer to
"comments on articles and videos". It is the one design that makes referential
integrity *undeclarable*: no foreign key can be written against a column whose
target table is decided per row, so deleting an article leaves its comments
pointing at a row that no longer exists, and nothing in the database notices —
not on delete, not on read, not on a consistency check, because there is nothing
to check.

Two shapes keep the reference declarable. For a small, stable set of targets, use
one nullable column per target and a check that exactly one is set:

```sql
CREATE TABLE comments (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id   bigint NOT NULL REFERENCES users,
    body        text   NOT NULL,
    posted_at   timestamptz NOT NULL DEFAULT now(),
    article_id  bigint REFERENCES articles ON DELETE CASCADE,
    video_id    bigint REFERENCES videos   ON DELETE CASCADE,
    CONSTRAINT comment_targets_exactly_one
        CHECK (num_nonnulls(article_id, video_id) = 1)
);
```

Each target is a real foreign key, so cascades work and orphans are impossible.
The cost is a column and a `CHECK` arm per target, which stays readable to about
four or five.

**Alternative (many or open-ended targets):** give the targets a shared supertype
table and point the child at that instead. `commentables(id)` is referenced by
both `articles.id` and `videos.id`, and `comments.commentable_id` references
`commentables`. One join for every target, no columns added per type — at the
cost of an extra table and an id allocation on every insert. See
[`rel-subtypes-through-the-key`](rel-subtypes-through-the-key.md) for making the
variants provably disjoint.

The one case where a type-plus-id pair is acceptable is a genuinely untyped
audit or outbox log, where the reference is a historical record rather than a
live relationship and dangling entries are expected. Say so in a comment on the
column, because the next reader will assume it was an accident.

Reference: [PostgreSQL 18 — Constraints](https://www.postgresql.org/docs/18/ddl-constraints.html), [Karwin, *SQL Antipatterns*: "Polymorphic Associations"](https://pragprog.com/titles/bksap1/sql-antipatterns-volume-1/)
