---
title: Treat metadata.references[] as a cite-set checksum — exact match with rule cites
tags: meta, metadata, references, checksum
---

## Treat metadata.references[] as a cite-set checksum — exact match with rule cites

By default `metadata.references[]` accretes as an aspirational reading list — URLs the author scanned, intended to use, or thought looked relevant. Over time it diverges from the URLs rules actually cite. When the skill is audited or migrated, this divergence is the first signal that either the rules or the metadata is lying. The convention is to treat `metadata.references[]` as **the exact set of URLs cited in rules** — no superset, no subset, no aspirational entries.

```text
The invariant (must hold at every commit):

  set( URLs cited in references/*.md "Reference:" lines )
    ==
  set( metadata.json "references": [ ... ] )

Diff procedure (run before /dev-skill:validate):

  1. grep -h "^Reference:" skills/<skill>/references/*.md \
       | extract URLs → set A
  2. jq -r ".references[]" skills/<skill>/metadata.json → set B
  3. set A XOR set B should be empty.
     - In A but not B: a rule cites a source the metadata hides.
     - In B but not A: metadata lists a source no rule uses.

Both directions are bugs:

  In-A-not-in-B (under-listed):
    The metadata under-credits the skill's actual provenance. An
    auditor reading metadata.json alone cannot reconstruct what
    the skill is built from. Add the missing URL.

  In-B-not-in-A (over-listed / aspirational):
    The metadata claims influence the rules do not show. Either
    the rule that should have cited it is missing — write it — or
    the URL was never load-bearing — remove it.

Anti-pattern: "I read this and it shaped my thinking, so it goes
in references." If it shaped your thinking, it should have shaped
at least one rule. If no rule cites it, it did not actually shape
anything — it was background reading.
```

The mechanical trigger: add the diff procedure as a one-line check in your skill's CI or pre-commit. The shipped library-ref skills that age well have this invariant hold; the ones that decay have `references[]` drift into a graveyard of links nobody reads. Make the cite-set a checksum, not a reading list.

Reference: [zod skill's metadata.references[] matches the exact URLs cited in references/*.md rule bodies](../../../../skills/.curated/zod/metadata.json)
