# How-to guides — goal-oriented

A how-to guide is a set of **directions** that guide the reader through a problem or towards a result. It is **goal-oriented**. It serves the work of an *already-competent* user who knows what they want to achieve and needs to get it done correctly. A how-to guide is like a recipe in a cookbook: a sequence of steps to a specific end.

> A how-to guide answers: **"How do I achieve this specific goal?"** It assumes competence — the reader is in charge and knows roughly what they're doing. That is exactly what separates it from a tutorial, where *you* take charge of a beginner.

## What makes a how-to guide different

- **vs [tutorial](tutorials.md):** a tutorial is a lesson for a beginner you take responsibility for; a how-to guide assists a competent user pursuing *their own* goal. Same steps, opposite user.
- **vs [reference](reference.md):** a how-to guide is a *sequence of actions*; reference is *description*. Link to reference for the details — don't inline them.
- **vs [explanation](explanation.md):** a how-to guide addresses a real-world problem, not concepts. Keep the *why* out; link to it.

## Principles

- **Address a real problem or goal — not a tool.** Documentation that describes operating machinery ("to shut off the water, turn the tap clockwise") isn't a how-to guide; it doesn't help the user with what they're *trying to do*. Frame around the user's actual task ("how to stop a leak"), the way they would.
- **Provide a logical sequence with flow.** A how-to guide is a series of steps that must be followed in order. Ground the order in the user's natural pattern of activity so it flows; an ill-considered order is the most common how-to failure.
- **Describe actions — including thinking and judgement,** not only commands to type. Real tasks require decisions; say what to weigh, not just what to run.
- **Don't explain.** Concepts and background interrupt the work. If understanding is needed, link to an [explanation](explanation.md).
- **Accommodate the real world with conditional imperatives.** Users arrive in different situations: "If you want x, do y. To achieve w, do z." Cover the practical variations they'll actually hit.
- **Omit the unnecessary; favour usability over completeness.** A how-to guide is *not* exhaustive. Practical usability beats comprehensiveness — leave out anything that doesn't serve the goal. (Completeness is reference's job.)
- **Name it well.** The title must say exactly what the guide shows. "How to integrate application performance monitoring" is good; "Monitoring" or "Performance" is not — the reader searching for a solution must recognise it instantly.

## Keep out of a how-to guide

| Temptation | Where it belongs |
|------------|------------------|
| Teaching the basics / a guided first run | → [tutorial](tutorials.md) |
| Full tables of every option, flag, or field | → [reference](reference.md) |
| Background, rationale, "why this approach" | → [explanation](explanation.md) |

## Language patterns

- Open with the goal: "This guide shows you how to…"
- Conditional imperatives for real-world variation: "If you want x, do y."
- Action-oriented titles naming the outcome: "How to {do the thing}".

## Smell test

If a competent reader who knows their goal can't follow it straight to a result — because it stops to teach, explain, or list every possibility — it has drifted out of how-to.

Reference: https://diataxis.fr/how-to-guides/
