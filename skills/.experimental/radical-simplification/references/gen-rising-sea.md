---
title: Generalize until the specific problem dissolves
tags: gen, grothendieck, abstraction, rising-sea
---

## Generalize until the specific problem dissolves

Grothendieck's image: instead of breaking a nut by force, submerge it — raise the surrounding water until the shell softens and the nut opens almost without pressure. When a specific problem resists, the harder, more abstract version is often easier, because the abstraction strips away the incidental features that made the specific case confusing. By default the agent attacks the specific problem harder. Sometimes the move is the other direction: solve a more general problem and the specific one is a corollary.

```text
Problem (specific, resisting):
  "Detect this one type of N+1 query in this one ORM, where a hasMany
   relation is accessed inside a forEach over the parent collection."

A direct detector for this case requires pattern-matching the ORM's
specific call syntax, its lazy-loading hooks, its association config.
Brittle, and breaks the moment someone uses .map instead of .forEach.

Generalize (rising sea):
  "Detect any database query whose call site is inside a loop, where
   the query's filter depends on the loop variable."

Generalizing further:
  "Detect any sub-linear aggregate operation (a query, an RPC, a file
   read) executed inside a linear traversal of a collection whose
   element identifier the operation parameterizes."

The most general version drops every reference to "ORM", "hasMany",
and "forEach". The detector becomes: "static-analyze for I/O calls
inside loops where the loop binding flows into the call's arguments".
That detector also catches the original case — and N+1 over plain SQL,
N+1 in an RPC fan-out, and N+1 in file reads. One detector, three bugs.
```

The rising sea is a *simplification* move, not a complication move. The test for correct generalization: the abstract version has *fewer* concepts than the specific one, not more. If your generalization needed extra parameters, type variables, and "configuration", you are not generalizing — you are accreting. Stop and go back to the specific.

Reference: [Grothendieck — Récoltes et Semailles ("la mer qui monte")](https://en.wikipedia.org/wiki/Alexander_Grothendieck#The_rising_sea_metaphor)
