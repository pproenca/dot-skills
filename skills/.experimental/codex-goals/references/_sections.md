# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Goal Fit Decisions (fit)

**Impact:** CRITICAL  
**Description:** Choosing whether a task needs a Goal at all — Goals are for outcomes that require iteration against evidence, not for one-shot edits or vague aspirations. A misfit Goal either spins without a stop condition or wastes the persistence machinery on work a single prompt would have closed.

## 2. Outcome Definition (outcome)

**Impact:** CRITICAL  
**Description:** Pinning the end state precisely enough to audit yet broadly enough to allow Codex to discover the path. Vague outcomes ("improve performance", "make this better") give Codex no completion condition; over-narrow outcomes ("fix this exact line") block discovery of the real root cause.

## 3. Verification Surface (verify)

**Impact:** CRITICAL  
**Description:** Naming the concrete evidence that proves the Goal is done — a test, benchmark, artifact, command output, or source material. Without a verification surface, Codex falls back to model belief, and "probably done" replaces "evidence says done".

## 4. Boundaries & Iteration (bound)

**Impact:** HIGH  
**Description:** Constraining what Codex may touch, how it should choose the next experiment between iterations, and what to report when no defensible path remains. Boundaries prevent scope creep; an iteration policy prevents wandering; a blocked stop condition prevents fake completion.

## 5. Lifecycle Commands (life)

**Impact:** HIGH  
**Description:** Managing the Goal's state through `/goal`, `/goal pause`, `/goal resume`, and `/goal clear`. Goals are thread-scoped persistent state — failing to pause during detours or clear on resumed threads causes Codex to continue against a stale objective.

## 6. Evidence-Based Completion (evidence)

**Impact:** HIGH  
**Description:** Completion is decided by evidence, not by the model's confidence. Budget limits halt work and require summary, not a "done" claim. Blockers must be surfaced explicitly — substituting proxies for the asked claim is how plausible artifacts become overclaimed conclusions.

## 7. Crafting Strong Goals (craft)

**Impact:** MEDIUM  
**Description:** Patterns for turning a weak Goal into a strong one — the six-component contract (outcome, verification, constraints, boundaries, iteration policy, blocked stop), the canonical template, and the two-step "draft with Codex, then tighten" workflow.

## 8. Research Goals & Anti-Patterns (research)

**Impact:** MEDIUM  
**Description:** Investigation Goals where exact proof may not be available — define the evidence standard before work begins, build a claim inventory, and preserve epistemic levels in the final report. Anti-patterns: using Goals as "keep going" without a stop condition, hiding uncertainty in the Goal text, or overclaiming on proxy evidence.
