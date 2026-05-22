# Reference — information-oriented

Reference guides are **technical descriptions** of the machinery and how to operate it. They are **information-oriented**: propositional, theoretical knowledge the user *consults* during work rather than reads through. Reference is like an encyclopaedia entry, or a map — it states the facts of the territory so the user can trust them without verifying for themselves.

> Users come to reference for **truth and certainty** — a firm platform to stand on while they work. Reference is the one mode **led by the structure of the product**, not by the user's needs.

## What makes reference different

- **vs [how-to guide](how-to-guides.md):** reference *describes*; a how-to *instructs*. Don't put step-by-step procedures in reference.
- **vs [explanation](explanation.md):** reference is neutral description; explanation is discursive, with context and opinion. No discussion, no argument, no "why" in reference — link out for that.
- **It is consulted, not read.** Optimise for *finding* the one fact, not for a narrative read-through.

## The four principles

1. **Describe, and only describe.** Neutral description is the sole job. The style is **austere and uncompromising**; its virtues are *accuracy, precision, completeness, and clarity*. Resist every urge to instruct, explain, speculate, or offer opinion — link to the how-to or explanation that belongs to it instead.
2. **Adopt standard patterns.** Reference is useful when it is **consistent**. Put information where the user expects to find it; use the same structure for every like thing; prefer a familiar, repeated format over stylistic variety. Predictability *is* the feature.
3. **Respect the structure of the machinery.** The documentation's structure should **mirror the structure of the product** — the logical arrangement of the code, the API, the CLI. The map matches the territory, so users navigate it the way they navigate the thing itself.
4. **Provide examples.** Illustrate with examples — but examples that *show*, without explaining or instructing. A short, in-context snippet conveys usage faster than prose.

## Keep out of reference

| Temptation | Where it belongs |
|------------|------------------|
| "First do this, then that" procedures | → [how-to guide](how-to-guides.md) |
| Rationale, history, trade-offs, opinions | → [explanation](explanation.md) |
| A gentle guided walkthrough for beginners | → [tutorial](tutorials.md) |

## Language patterns

- Declarative statements of fact, not narrative: state what *is*.
- Lists of commands, options, fields, parameters, return values, limits, and errors.
- Warnings and caveats where the machinery can bite — stated plainly, not argued.

## Smell test

If a reader can't open it, jump straight to the exact fact they need, and trust it without reading around it — or if it starts narrating, instructing, or editorialising — it has stopped being reference.

Reference: https://diataxis.fr/reference/
