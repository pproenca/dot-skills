---
name: radical-simplification
description: Use this skill when stuck on a complex problem, when a proposed design feels overengineered, when reviewing code that has accreted accidental complexity, or when the user wants an elegant solution to a hard engineering or product problem. Distills the documented cognitive moves — reframe, reduce, decompose, invert, constrain, transfer, generalize, audit — used as a working method by mathematicians, physicists, and software engineers known for collapsing hard problems into simple solutions (Pólya, Feynman, Hamming, Brooks, Knuth, Dijkstra, Lamport, Tao, Grothendieck, Munger, Hofstadter). Triggers on phrases like "this feels too complicated", "we are going in circles", "there must be a simpler way", "make it elegant", "find the underlying problem", and on stuck-state moments where forward search has run out and the agent needs a different angle.
---

# Radical Simplification — Cognitive Moves for Collapsing Complex Problems

Distillation of the documented working method of mathematicians, physicists, and engineers who consistently turn complex problems into simple solutions. The skill is not a step list — it is a toolbox of **cognitive moves**, each correcting a specific wrong default a capable model has when faced with complexity. The moves are mostly orthogonal; pick the one that matches the symptom.

This is the **thinking layer** that sits above refactoring (`code-simplifier`), metric design (`deterministic-metric-design`), and reviews (`design-review`). Those skills apply a methodology to a known shape of artifact. This skill is the methodology itself — how to arrive at the simple shape in the first place.

## When to Apply

Use this skill when:

- The user says the problem feels too complicated, that the team is going in circles, or that there must be a simpler way
- A proposed design has accreted parameters, dependencies, or branches and feels overengineered
- A bug investigation has tried several variants of the same approach without progress
- A review surfaces complexity that may be accidental (Brooks) rather than essential
- The agent is asked to find an elegant solution to a hard engineering or product problem
- Forward search has exhausted and the agent needs a different angle (work backwards, invert, transfer from another domain)
- The agent is producing fluent-sounding output but cannot back it up under expansion (Feynman test)

This skill is **not** for cleaning up code that already does the right thing — that is `code-simplifier`. Use this when the *approach itself* is what needs to get simpler.

## How to Use

The eight categories are orthogonal cognitive moves. Match the move to the symptom:

| Symptom | Reach for | First rule to read |
|---------|-----------|--------------------|
| Solving feels off — maybe the wrong problem | **Frame** | [`frame-restate-problem`](references/frame-restate-problem.md) |
| Drowning in cases, parameters, branches | **Reduce** | [`reduce-toy-case-first`](references/reduce-toy-case-first.md) |
| Parts are tangled; changes ripple | **Decompose** | [`decomp-orthogonal-axes`](references/decomp-orthogonal-axes.md) |
| Forward search is exponential or stuck | **Invert** | [`invert-work-backwards`](references/invert-work-backwards.md) |
| Missing the structural truth of the system | **Constrain** | [`constrain-name-the-invariant`](references/constrain-name-the-invariant.md) |
| Stuck inside the current vocabulary | **Transfer** | [`transfer-cross-domain-analogue`](references/transfer-cross-domain-analogue.md) |
| The specific problem keeps resisting | **Generalize** | [`gen-rising-sea`](references/gen-rising-sea.md) |
| Producing fluent output you cannot back up | **Audit** | [`audit-feynman-technique`](references/audit-feynman-technique.md) |

For category overviews and the ordering rationale, see [`references/_sections.md`](references/_sections.md).

## Rule Categories

| # | Category | Prefix | Move | Rules |
|---|----------|--------|------|-------|
| 1 | Reframe the Problem | `frame` | Restate, separate essential from accidental, find the decision | 3 |
| 2 | Reduce to the Smallest Case | `reduce` | Toy case, limit cases, Pareto compression | 3 |
| 3 | Decompose Along Orthogonal Axes | `decomp` | Orthogonal axes, WHAT vs HOW | 2 |
| 4 | Invert the Search | `invert` | Work backwards, assume failure | 2 |
| 5 | Constrain with Invariants and Symmetries | `constrain` | Name the invariant, dimensional check | 2 |
| 6 | Transfer From Another Domain | `transfer` | Cross-domain analogue, vocabulary lock-in | 2 |
| 7 | Generalize Until the Problem Dissolves | `gen` | Rising sea | 1 |
| 8 | Audit Your Own Understanding | `audit` | Feynman, name the confusion, Fermi check | 3 |

## Quick Reference

### 1. Reframe the Problem

- [`frame-restate-problem`](references/frame-restate-problem.md) — Restate in your own words before solving; surfaces the wrong-problem case while it is still cheap
- [`frame-essential-vs-accidental`](references/frame-essential-vs-accidental.md) — Brooks's distinction: name each piece of complexity as inherent or layered-on
- [`frame-find-decision-point`](references/frame-find-decision-point.md) — Find the decision the answer must change; answer that, not the literal question

### 2. Reduce to the Smallest Case

- [`reduce-toy-case-first`](references/reduce-toy-case-first.md) — Solve n=1 fully before generalizing; the structure of the big problem becomes visible
- [`reduce-limit-cases`](references/reduce-limit-cases.md) — Probe zero, infinity, empty, identity to expose where the design degrades
- [`reduce-pareto-compress`](references/reduce-pareto-compress.md) — Design for the 20% of inputs that produce 80% of the result

### 3. Decompose Along Orthogonal Axes

- [`decomp-orthogonal-axes`](references/decomp-orthogonal-axes.md) — Axes are correct when changing one does not force changing another; verbs over today's nouns
- [`decomp-what-vs-how`](references/decomp-what-vs-how.md) — Write the WHAT before debating the HOW; the spec is the referee

### 4. Invert the Search

- [`invert-work-backwards`](references/invert-work-backwards.md) — When forward search is exponential, ask what must be true one step before the goal
- [`invert-assume-failure`](references/invert-assume-failure.md) — Write the postmortem before writing the design (Munger's inversion)

### 5. Constrain with Invariants and Symmetries

- [`constrain-name-the-invariant`](references/constrain-name-the-invariant.md) — The property that does not change is often the answer in disguise
- [`constrain-dimensional-check`](references/constrain-dimensional-check.md) — Mismatched units, types, or categories are bugs before they are runtime failures

### 6. Transfer From Another Domain

- [`transfer-cross-domain-analogue`](references/transfer-cross-domain-analogue.md) — Search for the structural twin in another domain; the twin's solution often transplants
- [`transfer-suspect-vocabulary-lock-in`](references/transfer-suspect-vocabulary-lock-in.md) — Suffix accretion (`Manager`, `Helper`, `Coordinator`) signals the original noun is wrong

### 7. Generalize Until the Problem Dissolves

- [`gen-rising-sea`](references/gen-rising-sea.md) — Grothendieck's rising sea; the more abstract version is sometimes the easier one — but only if it has *fewer* concepts, not more

### 8. Audit Your Own Understanding

- [`audit-feynman-technique`](references/audit-feynman-technique.md) — Unfold technical shorthand into beginner-vocabulary sentences; the hand-waves are the gaps
- [`audit-name-the-confusion`](references/audit-name-the-confusion.md) — When stuck, name what you do not know — do not retry variants of the same approach
- [`audit-fermi-sanity-check`](references/audit-fermi-sanity-check.md) — Bound the answer order-of-magnitude before producing it; 10× disagreements are the signal

## Related Skills

- [`code-simplifier`](../code-simplifier/SKILL.md) — Refactoring patterns once the right approach is known (this skill ends, that one begins)
- [`deterministic-metric-design`](../deterministic-metric-design/SKILL.md) — Applies this methodology to the specific problem of inventing metrics
- [`design-review`](../design-review/SKILL.md) — Applies this methodology to the specific problem of reviewing UI

## Authoring Note

These moves are **load-bearing**, not decorative. The wrong default each rule corrects is named in the rule itself — if a rule restates something a capable model already does correctly, cut it. The coverage of the skill is proven by `/dev-skill:eval` on real complex-problem prompts, not by hitting a rule count.
