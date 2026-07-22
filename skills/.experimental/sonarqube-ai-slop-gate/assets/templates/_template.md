---
title: {Decision-oriented title — {Verb} {object} {context}}
tags: {category-prefix}, {concept}, {concept}
---

## {Same as title}

{WHY — 1-3 sentences. Name the wrong default: what a capable model or engineer
configures here without this rule, and the concrete consequence. For this skill
the consequence is usually silent, so say what the broken setup *looks* like —
"the gate passes", "the metric shows no value", "the analysis lands on main" —
not just that it is wrong.}

{Where a documented sentence settles the point, quote it verbatim in italics
with the source page linked below. SonarQube's behaviour here is frequently
counter-intuitive, and a quote is what makes the claim checkable.}

```{properties|yaml|bash}
{The canonical configuration. Production-realistic names — never foo/bar.
Comment the line that carries the correction.}
```

{Optional: the second-order effect, the verification step that proves the fix
took, or the related rule this interacts with.}

Reference: [{Source page title}]({url}) · [{Second source}]({url})

<!-- ─────────────────────────────────────────────────────────────────────────
NOTES FOR THIS SKILL

- Verify before writing. Property keys, metric keys, API parameters, and edition
  boundaries are all checkable: `api/webservices/list` for endpoint parameters,
  `api/settings/list_definitions` for setting keys, `api/metrics/search` for
  metric keys. A property that does not exist is silently ignored by the
  scanner, which is exactly the failure mode this skill warns about — do not
  reproduce it in the skill itself.
- Pin to the date. This skill is verified against a July 2026 snapshot; if a
  claim depends on a version, say which.
- Use a foil only when the wrong way is a real trap. Most rules here need one
  correct example, because the wrong version is an omission rather than a
  different line.
───────────────────────────────────────────────────────────────────────────── -->
