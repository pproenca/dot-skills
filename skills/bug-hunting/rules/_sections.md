# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Systematic Reproduction (repro)

**Impact:** CRITICAL
**Description:** Reproducibility is the foundation of debugging—without reliable reproduction, fixes are guesswork. Establishing consistent reproduction steps enables targeted investigation and verifiable fixes.

## 2. Hypothesis-Driven Investigation (hypo)

**Impact:** CRITICAL
**Description:** Applying the scientific method to debugging eliminates random trial-and-error, reducing debug time by 40-60%. Form hypotheses, design experiments, and systematically narrow down the cause.

## 3. Root Cause Analysis (rca)

**Impact:** HIGH
**Description:** Finding the true cause prevents recurring bugs and symptom-only fixes. Use structured techniques like Five Whys and Fishbone diagrams to trace effects back to their origin.

## 4. Strategic Logging (log)

**Impact:** HIGH
**Description:** Effective logging provides crucial debugging context without overwhelming noise. Use structured logging, appropriate log levels, and correlation IDs to make logs queryable and actionable.

## 5. Debugger Mastery (debug)

**Impact:** MEDIUM-HIGH
**Description:** Efficient debugger use enables precise state inspection, execution control, and faster bug localization. Master breakpoints, watch expressions, and stepping to maximize debugging efficiency.

## 6. Bug Triage and Classification (triage)

**Impact:** MEDIUM
**Description:** Proper severity and priority classification ensures development resources focus on highest-impact issues. Distinguish technical severity from business priority to make informed decisions.

## 7. Common Bug Patterns (pattern)

**Impact:** MEDIUM
**Description:** Recognizing classic bug patterns—null pointers, race conditions, off-by-one errors, memory leaks—enables faster diagnosis by matching symptoms to known causes.

## 8. Prevention and Verification (prevent)

**Impact:** LOW
**Description:** Preventing bug recurrence through regression tests, code review, and defensive coding ensures long-term code quality. Verify fixes completely before closing issues.
