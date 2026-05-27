---
title: Name what you do not understand instead of retrying variants
tags: audit, confusion, debugging
---

## Name what you do not understand instead of retrying variants

When stuck, the default is to retry variants of the same approach — change a parameter, try a different library call, swap a clause. This is the agent equivalent of pattern-matching against fluency. The move that breaks the loop is **naming the confusion**: write down, in a sentence, what you do not understand. The named confusion becomes a falsifiable question; the unnamed one stays a fog.

```text
Bug: this SQL query returns 0 rows, but the row should exist.

Variant-retry loop (the trap):
  Add a WHERE clause. Remove it. Change = to LIKE. Try ILIKE. Try
  LOWER(). Try the row from a different ID. Check casing. Try the
  staging DB. Try a DIFFERENT query that should also hit the row.

  Three hours pass. No progress, because the agent never said what
  it does not know.

Name the confusion (the move):
  "I do not know whether:
    (a) the row does not exist (the data is wrong),
    (b) the WHERE clause excludes it (the filter is wrong),
    (c) the JOIN drops it (a referenced row is missing),
    (d) the user lacks RLS access to it (auth is wrong)."

Now there are four falsifiable hypotheses, each with a one-line test:
  (a) SELECT 1 FROM t WHERE id = X
  (b) SELECT * FROM t WHERE id = X  (no other filters)
  (c) Run the joined tables separately
  (d) SELECT current_user; check RLS policies on t

One of them will be true within five minutes. The variant-retry loop
could have run all day.
```

The mechanical trigger: if the agent has tried more than three variants of the same approach without progress, the next action is **not** another variant. It is "I will write down what I do not understand, then test the cheapest hypothesis."

Reference: [Pólya — How to Solve It, "Looking Back" / understanding failure](https://en.wikipedia.org/wiki/How_to_Solve_It)
