---
title: Define a deletion rule for every relationship
tags: rel, deletion-rule, referential-integrity
---

## Define a deletion rule for every relationship

The wrong default is to leave deletion behavior unspecified and discover at runtime that deleting a parent record has orphaned its children (child records that reference a parent that no longer exists). Every relationship needs an explicit deletion rule, decided from the parent's side, that says what happens to the child records when a parent is deleted. This is core to relationship-level integrity.

```text
The five deletion rules (what the database does when a parent record is deleted):
  Deny        — refuse the delete; keep the parent, mark it inactive (a soft delete).
  Restrict    — refuse the delete while related child records exist; delete children first.
  Cascade     — delete the parent AND automatically delete its child records.
  Nullify     — delete the parent and set the child foreign keys to null
                (requires the foreign key to allow nulls).
  Set Default — delete the parent and set the child foreign keys to their default value
                (requires a default on the foreign key).
```

Use **Restrict** as the default and the others as the business dictates. Choose by asking: "when a parent record is deleted, what should happen to the related child records?" — the answer names the rule. Set the rule from the parent perspective, since deleting a child normally has no effect on the parent.
