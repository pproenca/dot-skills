# Gotchas

The recurring traps of applying Diátaxis. The first ones are the classic mistakes the framework exists to prevent. Append new ones (with dates) as real use surfaces them.

### Building empty structure first
The most common failure: creating the four containers (`tutorials/`, `how-to/`, `reference/`, `explanation/`) with a skeleton of headings and no content, then trying to file everything in. Empty structure advertises content that isn't there and the migration stalls half-built — "it's horrible." Let structure emerge from improving real content instead. See `restructure-tree.md`.
Added: 2026-05-22

### "Balancing" the four modes inside one page
Diátaxis is about *separation*, not balance. Trying to give every page a little tutorial, a little how-to, a little reference, and a little explanation reproduces exactly the type-mixing it's meant to cure. One page → one user need. When a page wants to do two things, split it (`wrong-type-tree.md`), don't balance it.
Added: 2026-05-22

### Explaining inside a tutorial (the #1 drift)
The strongest pull in all of documentation is to stop and explain *why* mid-tutorial. It overwhelms the beginner and breaks the rhythm of doing. A tutorial is not the place for explanation — link out to an explanation page and keep the learner moving. (The mirror traps: how-to guides that lecture, reference that editorialises.) See `tutorials.md`.
Added: 2026-05-22

### Writing how-to guides about the tool, not the goal
"To shut off the water, turn the tap clockwise" describes operating machinery — it isn't a how-to guide, because it doesn't help with what the user is *trying to do*. Name the real-world goal ("how to stop a leak") and title it so a searching user recognises it instantly. Tool-described steps belong in reference. See `how-to-guides.md`.
Added: 2026-05-22

### Confusing the two same-axis pairs
The hard classifications are the within-axis ones. **Tutorial vs how-to** (both inform action): is the reader a beginner you're teaching, or a competent user pursuing their own goal? **Reference vs explanation** (both inform cognition): is it a neutral fact to look up, or discussion to build understanding? Decide by the *reader's situation*, not the topic. See `compass-tree.md`.
Added: 2026-05-22

### Treating Diátaxis as a rigid plan or a big migration
Diátaxis is a guide, not a project plan. Top-down "let's reorganise all the docs" projects stall and ship nothing for months. Work one small thing at a time and publish each change — structure emerges organically. See `workflow.md`.
Added: 2026-05-22

### Refusing to ship until it's "finished"
Documentation is never finished — but it should always be *complete* (every part useful at its current stage). Withholding improvements until the whole set is perfect is how the empty-scaffold trap and the big-migration trap both start. Publish the small improvement now. See `workflow.md`.
Added: 2026-05-22

### Misreading the compass because the reader wasn't named
The same sentence can be tutorial, how-to, reference, or explanation depending on *who* reads it and *why*. Running the compass on content without first fixing the unit and the reader's situation produces a confident wrong answer. Name the reader and their situation first. See `compass-tree.md`.
Added: 2026-05-22
