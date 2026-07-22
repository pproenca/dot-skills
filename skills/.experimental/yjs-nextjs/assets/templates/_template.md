---
title: Rule Title Here
tags: prefix, concept
# Optional — performance rules only. Omit for correctness and API rules.
# impact: MEDIUM
# impactDescription: prevents stale reads
---

## Rule Title Here

Name the wrong default this rule corrects and its concrete consequence, in 1-3
sentences. Explain the *why* — the model generalizes from the reason, not the
instruction. Don't restate something the model already does correctly.

Where a claim about Yjs behaviour is checkable, check it and state the result:
"Verified with Yjs 13.6.31: ..." beats an assertion, and this skill's existing
rules set that expectation.

**Incorrect (what goes wrong):**

```typescript
const brief = doc.getMap('brief')
brief.set('meta', { title: 'Roadmap', owner: 'ana' })
```

**Correct (what to do instead):**

```typescript
const meta = new Y.Map<string>()
doc.getMap('brief').set('meta', meta)
meta.set('title', 'Roadmap')
```

Reference: [Source title](https://docs.yjs.dev/)

<!-- Keep the incorrect/correct diff minimal — same names, only the key line
     changes — so the contrast is the lesson. A strawman foil nobody would write
     is worse than a single good example.

     OPTIONAL SECTIONS, only when they carry weight:
       **When NOT to use this pattern:** — real exceptions
       **Alternative ({context}):** — a second valid approach

     Prefixes are letters only: host, wire, model, react, hist, pres, ui.
     The first tag must equal the filename prefix. -->
