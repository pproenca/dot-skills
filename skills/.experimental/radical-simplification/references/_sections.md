# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Categories are ordered by **leverage** —
the cognitive moves most often missing when a competent agent is stuck on a
complex problem go first. This is a methodology skill, not a performance one,
so categories carry **no fixed impact tier**: the right move depends on the
problem in front of you, not on a hard-coded priority.

The moves are mostly orthogonal — you do not walk them in order. Pick the one
that fits the symptom: stuck → `audit`; over-elaborated → `frame` or `reduce`;
forward search exhausted → `invert`; entangled → `decomp`; outside your
vocabulary → `transfer`; specific problem resists → `gen`; missing structural
truth → `constrain`.

---

## 1. Reframe the Problem (frame)

**Description:** Whether the problem the agent is solving is the problem actually being asked. The most expensive failure mode is solving the wrong problem perfectly. Covers restating before solving, distinguishing essential from accidental complexity, and finding the decision underneath the surface request.

## 2. Reduce to the Smallest Case (reduce)

**Description:** Shrinking the problem until its structure is visible, then scaling back up. The core "simple solution" move: an answer that works on n=1, at limit cases, and across the highest-leverage 20% generalizes; one built on the full noisy general case usually does not. Covers toy models, limit-case probes, and Pareto compression.

## 3. Decompose Along Orthogonal Axes (decomp)

**Description:** Splitting the problem so the parts do not entangle. Wrong decompositions hide complexity inside the seams between parts. Covers finding axes where changing one thing does not break another, and separating WHAT (the specification) from HOW (the implementation) so each can be argued about on its own.

## 4. Invert the Search (invert)

**Description:** Looking from the other end of the problem. Forward search from the current state can be exponentially harder than backward search from the goal, and considering only success paths blinds the agent to the failure modes that determine the design. Covers working backwards from the desired outcome and Munger-style inversion (assume the solution failed — what is the most likely cause?).

## 5. Constrain with Invariants and Symmetries (constrain)

**Description:** Finding what does not change to pin down what does. The invariant is often the answer in disguise; equal inputs producing unequal outputs reveals a hidden coupling; mismatched units or types signals a category error before any code runs. Covers naming the invariant and dimensional/type consistency checks.

## 6. Transfer From Another Domain (transfer)

**Description:** Searching outside the current vocabulary for a structurally identical solved problem. Staying inside a domain's terminology silently constrains the solution space to whatever that domain has already considered. Covers cross-domain analogues and noticing when the surrounding vocabulary is the cage.

## 7. Generalize Until the Problem Dissolves (gen)

**Description:** When the specific problem resists, Grothendieck's rising sea — raise the surrounding water until what looked like a cliff is submerged. A more abstract version of the problem can be the easier one, because it exposes the structure the specific case obscures. Covers when and how to generalize as a simplification, not a complication.

## 8. Audit Your Own Understanding (audit)

**Description:** Catching the moments when the agent has stopped thinking and started pattern-matching. Stuck-and-retrying, fluent-sounding shorthand, and unbounded answers all signal an unaudited reasoning step. Covers explain-to-a-beginner (Feynman technique), naming the confusion explicitly when stuck, and Fermi-style sanity bounds before producing an answer.
