# Gotchas

### Glossary over-promise splits reviewers unless the rule names it (fixed in v0.1.0)
On the first dry run, the "clean" artifact drew a CONTESTED verdict on `gloss-code-conforms`: the
glossary said "Settlement records which payment cleared it" while the `Settlement` type carried no
payment reference. One reviewer called it a conformance FAIL, the other called it "attribute
completeness, not term misuse" and put it out of scope. Root cause: the rule's evidence legs only
covered wrong-term and wrong-concept, not an entry asserting defining content the code lacks.
Fix: leg (c) added to `gloss-code-conforms` — a glossary that over-promises about the model is
drift, FAIL until the model or the entry is amended. The contested reviewer had in fact caught a
real, author-unintended defect in the artifact.
Added: 2026-07-16

### Watch item: gloss-definitions-carry-meaning leg (a)
"The definition adds no word that distinguishes the concept" is the softest boundary in the rule
set (flagged by the skill-reviewer). It has held so far — both dry-run rounds judged it
unanimously — but if it recurs as CONTESTED, tighten leg (a) to a concrete tell, e.g. "the
definition contains only the term's own words plus a generic verb like manages/handles/represents".
Added: 2026-07-16

### Proven both ways (v0.1.0 dry runs, 2026-07-16)
- **Planted-violations artifact** (two-context TS shopfront, no glossary, Order/Purchase synonym
  mapper, `OrderManager`, `setStatus(CANCELLED)`, anemic entity, flag pile, Stripe type as domain
  state, cross-context domain import, two writers on `orders`): both blind reviewers returned
  overall FAIL with rule-for-rule identical verdicts — 11 FAIL / 2 PASS / 7 N/A, 0 contested. The
  absence rule `gloss-language-recorded` fired as FAIL (not N/A) in both, and both fix lists named
  the glossary file and the exact terms to define.
- **Clean artifact** (single-context billing module with glossary, tagged-union lifecycle, named
  transitions, value objects, repository port): round 1 CONTESTED on `gloss-code-conforms` (see
  first gotcha — a real artifact defect plus a rule gap); after sharpening the rule and fixing the
  artifact, round 2 with two fresh blind reviewers returned unanimous overall PASS — 14 PASS /
  6 N/A each, rule-for-rule identical, all carve-outs (persistence hydration, boundary mapper,
  port implementation) claimed with citations, 0 contested.
Added: 2026-07-16
