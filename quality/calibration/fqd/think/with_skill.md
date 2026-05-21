# Think: CLI Tool at 200 Stars, Growth Stalled

## The Reframe

The question asks "what's the highest-leverage thing to grow this tool?" But growth stalling at 200 stars isn't a distribution problem. It's a comprehension problem. 200 stars means people found it, understood it enough to star it, then told nobody. The star count is a leading indicator of word-of-mouth potential that never converted. The real question is: **why did 200 people think "neat" instead of "I need to tell someone about this"?**

## The Landscape

**Immediate domain — open-source CLIs:**
The standard playbook is: write a blog post, submit to Hacker News, post on Reddit, add to awesome lists, improve README, add a demo GIF. These tactics are well-worn. Everyone knows them. They produce a spike followed by the same plateau.

**Adjacent domain — developer tools / PLG:**
Developer tools with breakout growth (ripgrep, fd, bat, zoxide, exa) didn't grow because of marketing. They grew because someone wrote "I switched from X to Y and here's why" and the post spread because the *before/after delta was viscerally obvious*. The tool solved something people felt daily friction on, and the solution was fast enough and clean enough that the demo was self-explanatory.

**Distant domain — epidemiology (viral spread):**
A key concept from epidemiology is the reproduction number R0: how many people does one infected person infect? For an idea to spread, R0 must exceed 1. Most open-source tools have R0 < 1: users find the tool but the barrier to recommending it (explaining what it does, why it matters, when to use it) is high enough that most don't bother. The tool spreads only when that activation energy is near zero.

**Distant domain — product positioning (April Dunford):**
Positioning theory says that the problem isn't the product — it's the frame. A product without a clear competitive alternative and a clear "better for whom in what situation" statement can't be recommended, because the recommender can't construct the sentence. "You should use X" requires the speaker to know: instead of what, for what use case, giving what advantage.

**Distant domain — memetics / information diffusion:**
Richard Dawkins' original framing: a meme spreads when it's easy to copy and retransmit with low fidelity loss. The CLI tools that spread are the ones where the pitch compresses into one line: "it's like grep but faster," "it's like cd but smart." If your tool's pitch requires a paragraph, R0 stays below 1.

## The Insight (Where Two Domains Collide)

Here's the collision: **positioning theory + epidemiology**.

A CLI tool spreads not when it's shared, but when it's shareable — when a user can transmit the essential value with zero friction. That transmission moment almost always happens in one of three places:
1. A dotfiles repo or config file someone shares
2. A tweet/post saying "I replaced X with Y"
3. A comment in a Slack/Discord/team channel

For all three, the tool needs to be instantly intelligible as "better than X for Y." Not good. Better than something specific for someone specific.

Most stalled CLIs haven't done this. They've described what the tool *does* (its features), not what it *replaces* (its competitive position). The README says "A fast, flexible tool for Z" — which tells you nothing about what to stop using, and therefore gives you nothing to say to a colleague.

The 4D chess move: **positioning the tool as a sharp replacement for exactly one thing in exactly one workflow makes it instantly recommendable, which converts passive stars into active evangelists, which is the only growth channel that compounds.**

## The Proposal

**Reposition the tool as the explicit, opinionated replacement for one specific thing that developers already use and already dislike.**

Concretely:
1. Identify the one command, tool, or workflow your users most commonly had before adopting yours. (If you don't know, look at your issues, your README's "why I built this" section, or just ask one of your 200 stars.)
2. Rewrite the first 5 lines of the README as a direct comparison: "You know how `[existing tool]` does [thing] and it always [pain]? This does [thing] without [pain]. Here's the diff:" — followed by a side-by-side terminal screenshot.
3. Name it in the project description / GitHub About field with the positioning line ("the X you actually want").

That's the complete change. No new features. No blog post. No HN submission. Just making the value transmittable.

## Why This Beats the Obvious

The obvious move is to post to Hacker News or submit to an awesome list. This is fine. It produces a traffic spike. But your 200 stars came from *somewhere* — the discovery channel isn't broken. What's broken is that the 200 people who found you didn't tell anyone. A spike to 400 stars from HN just gives you 400 people who also won't tell anyone.

The obvious second move is to improve docs or add features. Both address the wrong bottleneck. You don't have a retention or capability problem — you have a transmission problem.

## What It Unlocks

Sharp positioning has compounding effects that the star count hides:
- It makes the tool show up in "alternatives to X" searches, which is a constant long-tail traffic source.
- It makes every existing user into a potential advocate because they can now form the sentence "instead of X, use this."
- It invites GitHub issues that say "does this replace Y too?" — which is qualitative signal about adjacent positioning opportunities.
- It attracts contributors who came from the same friction. Aligned contributors build more coherent tools.

The compound effect: one repositioning change raises R0 above 1, and organic growth begins — slowly at first, then in a way that doesn't require you to keep doing marketing.

## The Risk

The honest counterargument: positioning against a specific tool can feel reductive or alienating to people who found the tool on a different path. You might lose breadth of appeal.

This is real but it's the wrong frame for where you are. Breadth of appeal is a luxury for tools with strong word-of-mouth. At 200 stars with stalled growth, you need depth of transmission more than breadth of appeal. You can always widen the positioning later once growth restarts. Narrowing first to restart the engine is the right sequence.

The irreversibility check: this is highly reversible. A README change takes 20 minutes and costs nothing. If it doesn't work, you've learned something real about whether positioning is actually the bottleneck — and that learning is worth the 20 minutes regardless.

## What I'd Do

Tomorrow: look at your 200 stars' profiles and your closed issues. Find the one tool/workflow that appears most often. Write the comparison lede. Ship it. Measure stars-per-week over the next 30 days against the previous 30. You'll know within a month whether this was the bottleneck — and if it was, you'll see it.
