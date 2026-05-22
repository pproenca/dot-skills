# The Diátaxis Workflow — a guide to work

Diátaxis is a way to *understand* documentation, applied as a way to *work* on it. The whole method of improvement fits in one loop, run over and over at small scale.

## Use Diátaxis as a guide, not a plan

Diátaxis describes what good documentation looks like; it does not hand you a project plan. It actively **discourages top-down planning** in favour of small, responsive iterations from which the overall pattern emerges. Don't wait to understand the whole framework before you start — apply each idea as you meet it, alternating between doing the work and reflecting on it.

## Don't worry about structure first

The most tempting wrong move is to create the four empty containers — `tutorials/`, `how-to/`, `reference/`, `explanation/` — with a skeleton of headings and no content. **Empty structure is horrible:** it advertises content that isn't there, and the migration stalls half-built. Structure should *emerge* from healthy parts, never be imposed ahead of them.

## Work one step at a time

Improve wherever the opportunity is, at the smallest scale that's still useful — a section, a paragraph, a sentence. Then **publish the change immediately**, even if everything around it is still imperfect.

## Just do something — the loop

```
   ┌─────────────────────────────────────────────┐
   ▼                                              │
1. CHOOSE something   ── any piece, preferably small
   │
   ▼
2. ASSESS it          ── "What user need does this represent?
   │                      How well does it serve that need?"
   ▼
3. DECIDE what to do  ── a single next action that produces
   │                      an immediate improvement
   ▼
4. DO it              ── complete the change, and PUBLISH it
   │
   └──────────────────── repeat
```

That's the entire workflow. Its power is that every pass leaves the docs better and shipped — there is never a long broken interlude.

## Allow your work to develop organically

Good documentation grows like a **well-formed organism that adapts to external conditions**, not like a building erected to a fixed blueprint. When the internal parts are healthy — each serving one need well — the overall structure that emerges is sound. Trust that.

### Complete, not finished

Documentation is **never finished** — but it should always be **complete**: at any given moment, everything that exists is useful to users and structurally sound *for its current stage of growth*. Holding to "complete, not finished" is exactly what lets you ship continuously and never need a big-bang reorganisation.

## How this connects to the rest of the skill

- The **assess** step uses [compass-tree.md](compass-tree.md) (which mode is this?) and [quality.md](quality.md) (how well does it serve the need?).
- The **decide / do** step routes through [wrong-type-tree.md](wrong-type-tree.md) (content is mixed), [gaps-tree.md](gaps-tree.md) (a need has no content), or the four type guides ([tutorials](tutorials.md), [how-to-guides](how-to-guides.md), [reference](reference.md), [explanation](explanation.md)) for *how* to write the chosen mode well.
- For a whole messy corpus, [restructure-tree.md](restructure-tree.md) is this same loop applied at scale.

Reference: https://diataxis.fr/how-to-use-diataxis/
