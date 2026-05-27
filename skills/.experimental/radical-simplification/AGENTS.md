# Problem-Solving Methodology

**Version 0.2.0**  
dot-skills  
May 2026

---

## Abstract

Methodology distillation of the documented cognitive moves used by mathematicians, physicists, and software engineers known for collapsing complex problems into simple solutions — Pólya, Feynman, Hamming, Brooks, Knuth, Dijkstra, Lamport, Tao, Grothendieck, Munger, and Hofstadter. 20 rules across 9 orthogonal categories — Reframe, Clarify, Reduce, Decompose, Invert, Constrain, Transfer, Generalize, Audit — each naming a specific wrong default a capable model has when facing complexity, the cognitive move that corrects it, and a concrete engineering example showing the move applied. The skill is the thinking layer above refactoring and review — how to arrive at a simple shape, not how to refactor toward one.

---

## Table of Contents

1. [Reframe the Problem](references/_sections.md#1-reframe-the-problem)
   - 1.1 [Find the decision the answer must change](references/frame-find-decision-point.md)
   - 1.2 [Restate the problem in your own words before solving](references/frame-restate-problem.md)
   - 1.3 [Separate essential complexity from accidental complexity](references/frame-essential-vs-accidental.md)
2. [Clarify Through Interview](references/_sections.md#2-clarify-through-interview)
   - 2.1 [Interview one question at a time, each with your recommended answer](references/clarify-interview-one-at-a-time.md)
   - 2.2 [If the codebase can answer it, read the codebase — only ask what the source cannot tell you](references/clarify-prefer-source-over-asking.md)
3. [Reduce to the Smallest Case](references/_sections.md#3-reduce-to-the-smallest-case)
   - 3.1 [Cut to the 20% that produces 80% of the result](references/reduce-pareto-compress.md)
   - 3.2 [Probe limit cases — zero, infinity, empty, identity](references/reduce-limit-cases.md)
   - 3.3 [Solve the smallest non-trivial case fully before generalizing](references/reduce-toy-case-first.md)
4. [Decompose Along Orthogonal Axes](references/_sections.md#4-decompose-along-orthogonal-axes)
   - 4.1 [Decompose along axes that do not entangle](references/decomp-orthogonal-axes.md)
   - 4.2 [Specify WHAT before implementing HOW](references/decomp-what-vs-how.md)
5. [Invert the Search](references/_sections.md#5-invert-the-search)
   - 5.1 [Assume the design failed and find the most likely cause](references/invert-assume-failure.md)
   - 5.2 [Work backwards from the goal when forward search exhausts](references/invert-work-backwards.md)
6. [Constrain with Invariants and Symmetries](references/_sections.md#6-constrain-with-invariants-and-symmetries)
   - 6.1 [Check dimensional, type, or category consistency](references/constrain-dimensional-check.md)
   - 6.2 [Name the invariant — it is usually the answer](references/constrain-name-the-invariant.md)
7. [Transfer From Another Domain](references/_sections.md#7-transfer-from-another-domain)
   - 7.1 [Find a structurally identical solved problem in another domain](references/transfer-cross-domain-analogue.md)
   - 7.2 [Suspect the surrounding vocabulary when stuck](references/transfer-suspect-vocabulary-lock-in.md)
8. [Generalize Until the Problem Dissolves](references/_sections.md#8-generalize-until-the-problem-dissolves)
   - 8.1 [Generalize until the specific problem dissolves](references/gen-rising-sea.md)
9. [Audit Your Own Understanding](references/_sections.md#9-audit-your-own-understanding)
   - 9.1 [Bound the answer with a Fermi estimate before producing it](references/audit-fermi-sanity-check.md)
   - 9.2 [Explain it as if to a beginner — gaps in explanation are gaps in understanding](references/audit-feynman-technique.md)
   - 9.3 [Name what you do not understand instead of retrying variants](references/audit-name-the-confusion.md)

---

## References

1. [https://en.wikipedia.org/wiki/How_to_Solve_It](https://en.wikipedia.org/wiki/How_to_Solve_It)
2. [https://www.cs.virginia.edu/~robins/YouAndYourResearch.html](https://www.cs.virginia.edu/~robins/YouAndYourResearch.html)
3. [https://en.wikipedia.org/wiki/No_Silver_Bullet](https://en.wikipedia.org/wiki/No_Silver_Bullet)
4. [https://dl.acm.org/doi/10.1145/356635.356640](https://dl.acm.org/doi/10.1145/356635.356640)
5. [https://dl.acm.org/doi/10.1145/361598.361623](https://dl.acm.org/doi/10.1145/361598.361623)
6. [https://dl.acm.org/doi/10.1145/363235.363259](https://dl.acm.org/doi/10.1145/363235.363259)
7. [https://www.microsoft.com/en-us/research/publication/state-the-problem-before-presenting-the-solution/](https://www.microsoft.com/en-us/research/publication/state-the-problem-before-presenting-the-solution/)
8. [https://en.wikipedia.org/wiki/Dimensional_analysis](https://en.wikipedia.org/wiki/Dimensional_analysis)
9. [https://en.wikipedia.org/wiki/Feynman%27s_Lost_Lecture](https://en.wikipedia.org/wiki/Feynman%27s_Lost_Lecture)
10. [https://terrytao.wordpress.com/](https://terrytao.wordpress.com/)
11. [https://fs.blog/great-talks/a-lesson-on-elementary-worldly-wisdom/](https://fs.blog/great-talks/a-lesson-on-elementary-worldly-wisdom/)
12. [https://en.wikipedia.org/wiki/Alexander_Grothendieck#The_rising_sea_metaphor](https://en.wikipedia.org/wiki/Alexander_Grothendieck#The_rising_sea_metaphor)
13. [https://en.wikipedia.org/wiki/The_Psychology_of_Invention_in_the_Mathematical_Field](https://en.wikipedia.org/wiki/The_Psychology_of_Invention_in_the_Mathematical_Field)
14. [https://www.basicbooks.com/titles/douglas-hofstadter/surfaces-and-essences/9780465018475/](https://www.basicbooks.com/titles/douglas-hofstadter/surfaces-and-essences/9780465018475/)
15. [https://www.physics.umd.edu/perg/fermi/fermi.htm](https://www.physics.umd.edu/perg/fermi/fermi.htm)
16. [https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/](https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |