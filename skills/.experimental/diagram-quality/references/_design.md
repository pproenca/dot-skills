---
title: Design Effectiveness
impact: MEDIUM
impactDescription: Improves convergence speed and ensures exported specs are implementable
tags: design, heuristics, decomposition, traceability, export
---

# Design Effectiveness

Once diagrams render correctly (Section 1) and the conversation loop works (Section 2), design quality determines whether the exported specification is something a developer can implement. These heuristics set concrete thresholds — not "keep it simple" but "split when a component diagram exceeds 12 elements."

---

## Heuristic 1: Feedback Interpretation

The canvas provides three feedback channels. Each has different semantics and demands a different response posture.

| Signal | What It Means | Response Posture | Common Mistake |
|---|---|---|---|
| **Element annotation** | "Change THIS specific thing." The human clicked an element and typed. | Fix the annotated element in the next version. Mention the fix in the message. | Treating an annotation as a suggestion to "consider" — it's a directive. |
| **Chat message** | Broader concern or direction. Not tied to a single element. | May require structural rethinking. Ask a clarifying question if the scope is unclear before pushing a new version. | Immediately redrawing without understanding scope — you might change the wrong thing. |
| **Silence (120s timeout)** | Either carefully reviewing, satisfied, or stepped away. | Post a message via `design_feedback` with `reply` asking a specific question or announcing you're advancing. Never proceed silently. | Assuming silence means approval and pushing three more versions without checking. |
| **"Looks good" / "continue"** | Current diagram is approved. Ready for the next level of detail. | Advance to the next diagram type or deeper view. State what you're doing next in the message. | Staying on the same diagram and adding more detail to something already approved. |
| **Multiple annotations on the same area** | That area is wrong or confusing. Individual fixes won't resolve it. | Redesign that subsystem. Explain the new approach in the message before pushing the version. | Fixing annotations one by one without stepping back to see the pattern. |
| **Contradictory feedback (annotation says X, chat says not-X)** | The human is exploring the design space, not giving final direction. | Call out the contradiction explicitly via `design_feedback` reply. Ask which direction to take. | Picking one and ignoring the other. |

---

## Heuristic 2: Progressive Detail Layers

Each layer of detail uses specific diagram types and references the previous layer. The element counts are upper bounds — exceeding them is a signal to split, not a hard failure.

| Layer | Diagram Type(s) | What This Layer Adds | Max Elements | References |
|---|---|---|---|---|
| **L1: System Context** | `component` | Actors, external systems, main system boundary | 7±2 boxes | Starting point — no prior layer |
| **L2: Container** | `component` (detailed) | Internal services, data stores, communication protocols | 10±3 boxes | Every box in L2 must appear inside the L1 system boundary |
| **L3: Internal Structure** | `class` | Domain model, interfaces, relationships for ONE container | 12±3 classes | Each class diagram covers exactly one L2 container |
| **L4: Behavior** | `sequence`, `activity` | Interaction flows, business processes | 8±2 participants, 15 messages | Every participant must map to an L2 container or L3 class |
| **L5: State** | `state` | Entity lifecycle, transitions, guards | 6±2 states | Each state diagram covers exactly one L3 entity |

### Cross-Reference Traceability Rules

Element counts prevent visual overload, but traceability is what makes the exported spec implementable. These rules are mandatory:

| Rule | What It Means | Violation Signal |
|---|---|---|
| **Every L4 sequence participant maps to an L2 component or L3 class** | If a participant appears in a sequence diagram, it must exist as a named element (same alias) in a component or class diagram. | A participant alias that doesn't match any component/class alias = orphan. Either add the missing component/class or remove the participant. |
| **Every L3 interface belongs to exactly one L2 component boundary** | An interface in a class diagram must be inside a package/boundary that maps to a single L2 container. | An interface floating outside any boundary, or inside multiple boundaries = ambiguous ownership. |
| **Every L2 communication arrow has a corresponding L4 sequence** | If two containers communicate (arrow in component diagram), at least one sequence diagram must show the interaction. | A component-to-component arrow with no sequence = underspecified behavior. Either add the sequence or remove the arrow if it's aspirational. |
| **L5 state transitions reference L4 triggers** | A state transition guard or trigger should reference a message from a sequence diagram. | A transition with no identifiable trigger = magic state change. Name the triggering interaction. |

**How to check:** Before calling `design_export`, review each diagram layer and verify aliases match across layers. Flag any orphan aliases in the export message.

---

## Heuristic 3: Decomposition — When to Split a Diagram

When a diagram exceeds these thresholds, split it. Don't add a note saying "simplified" — create a second diagram that covers the overflow.

| Diagram Type | Split Threshold | Split Strategy | New Diagram Scope |
|---|---|---|---|
| `component` | >12 components | Split by bounded context or deployment boundary | Each new diagram covers one context with its external dependencies shown as simplified boxes |
| `class` | >15 classes | Split by package or aggregate root | Each new diagram covers one package with external dependencies shown as interfaces only |
| `sequence` | >10 participants OR >20 messages | Split by scenario or phase | Each new diagram covers one scenario; shared participants keep the same aliases |
| `activity` | >15 activities | Split by subprocess or phase boundary | Each new diagram covers one phase; handoff points shown as start/end events |
| `state` | >8 states | Split by state group (e.g., happy path vs. error states) | Each new diagram covers one group; transitions between groups shown as notes |

**After splitting:** Post a message explaining the split and how the diagrams relate: "Split the checkout sequence into two: happy path (this one) and error handling (next). Both share the same participant aliases."

---

## Heuristic 4: Export-Readiness Checklist

Before calling `design_export`, verify every item. A failed item should be fixed in a final `diagram_upsert` pass, not left as a note.

| # | Check | How to Verify | Fix |
|---|---|---|---|
| 1 | **All aliases are meaningful** | No single-letter aliases (`A`, `B`) or generic names (`Service1`) | Rename to domain terms: `PaymentService`, `OrderDB` |
| 2 | **Skinparams consistent across diagrams** | Every diagram uses the same preset from [_presets.md](_presets.md) | Re-apply the correct preset block |
| 3 | **No TODO/placeholder notes** | Search for `TODO`, `TBD`, `placeholder`, `???` in puml_source | Either resolve the TODO or remove the element |
| 4 | **Every diagram has a title** | Each `puml_source` contains a `title` line | Add `title [System] - [View Type]` |
| 5 | **Cross-diagram aliases match** | Same concept uses identical alias string everywhere (see Heuristic 2 traceability rules) | Standardize on one alias per concept |
| 6 | **No orphan elements** | Every element has at least one relationship (arrow, containment, or note) | Remove or connect the orphan |
| 7 | **Notes explain WHY, not WHAT** | Notes describe design rationale, constraints, or tradeoffs — not restating what the diagram already shows visually | Rewrite: "Uses async because order processing takes 2-5s" not "This is the order service" |
