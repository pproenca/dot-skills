---
title: Privilege rules that capture the failure gap, not the API surface
tags: source, exemplar-selection, failure-gap
---

## Privilege rules that capture the failure gap, not the API surface

By default the agent writes one rule per public API method. The resulting skill has 60 rules that collectively say "the API does what the API says" — adding no judgment beyond the docs. The move that earns each rule its place is the **failure gap**: a rule is load-bearing only if it captures something the docs omit and production exposed. If you can't name the failure the rule prevents, cut it.

```text
Two rules from shipped skills, same library surface area:

Rule A (cut — pure API restatement):
  "z.object() creates an object schema. Pass a shape object mapping
  keys to schemas. Call .parse() to validate input."
  → This is what zod.dev/api already says. Adds zero judgment.

Rule B (keep — failure gap):
  "Never trust JSON.parse output even after a Zod parse — the JSON
  type system is structural, not nominal. A request body with the
  right keys but wrong meaning (e.g. user_id as a number where you
  meant a UUID string) will parse cleanly and corrupt downstream.
  Use z.string().uuid() at every boundary."
  → This is the production-failure story zod.dev does NOT tell.
  → It earns its place because it prevents a specific real bug.

The discriminator (apply per rule before keeping):
  - Can I cite a GH issue, blog post, or postmortem where someone
    got bitten by the absence of this rule? → keep.
  - Did I just transcribe the API reference? → cut.
  - Is the rule "the framework's headline feature"? → keep ONLY if
    you can name the failure mode of NOT using it.
```

The mechanical filter: after drafting, for each rule ask **"what does this prevent?"** If the answer is "nothing, it just describes how to call X", cut. The shipped library-ref skills that hold up over time are the ones where every rule has a falsification — a concrete bug it stops. Rule count drops to ~30–60, signal density rises.

Reference: [react-hook-form's `formstate-async-submit-lifecycle` rule, which cites GH discussion #10103](../../../../skills/.curated/react-hook-form/SKILL.md)
