# Calibration Result — What SQS Reliably Measures (and What It Doesn't)

This is the credibility statement for the whole quality system. It reports how the cheap
deterministic **SQS** compares to two independent ground-truth signals, and states plainly
where SQS can and cannot be trusted. Sample: the 12 stratified skills in `README.md`; the
functional anchor is 3 of them.

## Signal 1 — SQS vs. rubric verdict (intrinsic correctness), n=12

The dev-skill discipline rubric was applied by an independent reviewer agent. After the
`guidance`-discipline re-tune (below), verdict-band agreement:

| Agreement | Count | Skills |
|-----------|------:|--------|
| SQS verdict == rubric verdict | 3/12 | harness-engineering, zod, tdd (all SHIP/SHIP) |
| SQS more lenient than rubric | 9/12 | react, effect-ts, bug-review, dx-harness, nuqs-codemod-runner, react-19-scaffolder, humanize, think, rust-refactor |
| SQS harsher than rubric | 0/12 | — |

**Verdict-band agreement is low (3/12) — but the disagreement is systematic, not random.**
In every one of the 9 mismatches the rubric found a concrete **content** defect that a static
score structurally cannot see:

- `effect-ts` — heading misnames `acquireRelease` vs `acquireUseRelease` (factual API error)
- `dx-harness` — `&&/||` precedence bug mis-detects `Justfile`, corrupting the happy path
- `nuqs-codemod-runner` — `scan.sh` feeds plain text to `jq --slurpfile` → hard crash
- `react` — `useDeferredValue` example contradicts the skill's own pairing table
- `react-19-component-scaffolder` — a promised template file is missing

**Conclusion:** SQS and the rubric measure *different things*. SQS measures **structure**; the
rubric measures **content correctness**. They are complementary, not redundant. A corpus-level
finding falls out of this for free: **content bugs are common even in high-SQS skills** — so a
high SQS must never be read as "this skill is correct."

## Signal 2 — SQS vs. Functional Quality Delta (does it actually help), n=3 anchor

FQD = pass-rate(with-skill) − pass-rate(no-skill baseline), same model (Sonnet) both sides.

| Skill | SQS | Baseline | With-skill | **FQD** |
|-------|----:|---------:|-----------:|--------:|
| react | 95.7 | 4/4 | 4/4 | **+0%** |
| harness-engineering | 80.1 | 2/4 | 4/4 | **+50%** |
| think | 83.1 | 1/4 | 4/4 | **+75%** |

**Spearman rank correlation SQS↔FQD ≈ −0.5 (negative).** The highest-SQS skill produced the
*smallest* functional lift; the skills that were hardest to fit the rule-pack mould produced
the *largest*. The mechanism is not noise, it is structural:

> A skill about something the model already does well (idiomatic React 19) is both **easy to
> author to a high structural standard** *and* **low in marginal value**. A skill encoding
> genuinely non-obvious judgement (strategic thinking, agent-harness design) is **harder to
> express as a tidy rule pack** *and* **high in marginal value**.

**Conclusion:** SQS does **not** predict marginal usefulness. On this anchor it is mildly
*inversely* related to it. No re-weighting can fix this — usefulness depends on the consuming
model's baseline knowledge, which is external to any static analysis of the skill text.

## The re-tune we did make

Calibration exposed exactly one clear, fixable SQS bias: prose/guidance skills (no rule pack,
no scripts, no templates) were graded as *broken distillation* rule-packs and unfairly
crater-scored. We added a **`guidance` discipline** scored on prose-appropriate metrics
(structure, actionability, rationale, depth). Effect on the sample:

| Skill | SQS before | SQS after | Rubric | FQD |
|-------|-----------:|----------:|--------|----:|
| harness-engineering | 48.3 (REJECT) | 80.1 (SHIP) | SHIP | +50% |
| think | 58.4 (NEEDS-WORK) | 83.1 (SHIP) | NEEDS-WORK¹ | +75% |
| humanize | 54.9 | 83.0 | NEEDS-WORK¹ | — |

¹ rubric NEEDS-WORK is for *content* issues SQS cannot see; structurally these are sound.

This change improved both SQS↔rubric and SQS↔FQD agreement for the prose cases. One caveat
it introduces: `rust-refactor` (a refactoring skill that *should* be a rule pack) is now
scored leniently as guidance — the rubric correctly flags it should be restructured. SQS
cannot make that "should-be-structured" judgement; the rubric layer must.

## Bottom line — how to reliably know if quality improved

No single number is sufficient. Use the right instrument for each question:

| Question | Instrument | Cost | Coverage |
|----------|-----------|------|----------|
| Does it follow authoring best practices? Did structure regress? | **SQS** (this scorer) | $0, instant | every skill, every commit |
| Is the content correct / current / non-contradictory? | **Rubric review** (skill-reviewer) | moderate | periodic / on-change sample |
| Does it actually beat a no-skill baseline? | **FQD** (baseline-differential eval) | high | the few skills that matter most |

SQS is a reliable, reproducible **structural-quality and regression** signal — and it is
honestly *only* that. Trusting it as a usefulness score would be the exact mistake this
calibration was built to catch.
