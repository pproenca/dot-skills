# Explanation — understanding-oriented

Explanation is a **discursive treatment of a subject that permits reflection**. It is **understanding-oriented**. Unlike the other three modes, explanation is read *away* from the product, at leisure — it deepens and broadens the reader's understanding. It is documentation *about* a topic: the article about cooking, not the recipe.

> Explanation depends on, and illuminates, prior experience. It is **reflection**, and reflection happens after engagement — which is why explanation is the mode most easily skipped, and most easily bloated.

## What makes explanation different

- **Not tied to action** (unlike [tutorials](tutorials.md) and [how-to guides](how-to-guides.md)) and **not tied to the machinery** (unlike [reference](reference.md)). It takes a **higher, wider view**, treating the topic as a bounded area of knowledge.
- **It's "about" the subject.** The natural title is *"About X"* — about authentication, about the data model — which is a good test of whether you're really writing explanation.
- **It's the least bounded mode,** so it's the hardest to write well and the easiest to let absorb material that belongs in the other three.

## Principles

- **Make connections.** Relate the topic to other things — even things outside the immediate subject, if it helps the reader build a mental model. Connections are what turn facts into understanding.
- **Provide context and background.** Explain *why* things are the way they are: design decisions, historical reasons, technical constraints, alternatives that were rejected. This is the home for every "why" you kept out of the other modes.
- **Talk about the subject — frame around the topic, not the task.** Discuss; don't instruct. "About user authentication", not "How to authenticate a user".
- **Admit opinion and perspective.** Explanation **can and must** weigh alternatives, counter-examples, and different approaches to the same question. A considered point of view is appropriate here (and nowhere else).
- **Keep it bounded.** Deliberately fence the scope of an explanation, or it will sprawl and start swallowing instruction and description that belong elsewhere. Decide what the piece is about — and what it is *not* about.

## Keep out of explanation

| Temptation | Where it belongs |
|------------|------------------|
| Steps to accomplish a task | → [how-to guide](how-to-guides.md) |
| Exact specs, parameters, signatures | → [reference](reference.md) |
| A first-run, hand-held lesson | → [tutorial](tutorials.md) |

## Language patterns

- Historical/causal: "The reason for x is that, historically, y…"
- Comparative judgement: "w is better than z, because…"
- Analogy: "An x in system y is analogous to a w in system z…"
- Weighing alternatives: "Some users prefer w. This can be a good approach, but…"

## Smell test

If it reads like a lecture you'd give to help someone *understand* the topic — connecting, contextualising, weighing options — it's explanation. If it has started telling the reader to *do* something or listing exact specs, those parts belong in another mode.

Reference: https://diataxis.fr/explanation/
