# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Problem Definition (prob)

**Impact:** CRITICAL
**Description:** Unclear problem statements waste 50%+ of debugging time; precise reproduction and symptom documentation prevent chasing wrong issues entirely.

## 2. Hypothesis-Driven Search (hypo)

**Impact:** CRITICAL
**Description:** Scientific method approach with systematic hypothesis testing eliminates 80%+ of guesswork; binary search techniques halve the search space per iteration.

## 3. Observation Techniques (obs)

**Impact:** HIGH
**Description:** Proper logging, strategic breakpoints, and execution tracing reveal actual vs expected behavior without relying on assumptions or mental simulation.

## 4. Root Cause Analysis (rca)

**Impact:** HIGH
**Description:** Finding true causes vs symptoms prevents recurring bugs; structured techniques like 5 Whys and cause-effect chains reach core issues systematically.

## 5. Tool Mastery (tool)

**Impact:** MEDIUM-HIGH
**Description:** Advanced debugger features like conditional breakpoints, watchpoints, and memory inspection provide 10× faster insight than print statement debugging.

## 6. Fix Verification (verify)

**Impact:** MEDIUM
**Description:** Confirming fixes actually resolve the root cause and don't introduce regressions prevents bug ping-pong and ensures permanent resolution.

## 7. Anti-Patterns (anti)

**Impact:** MEDIUM
**Description:** Recognizing and avoiding shotgun debugging, quick patches, assumption traps, and other counterproductive habits saves hours of wasted effort.

## 8. Prevention & Learning (prev)

**Impact:** LOW-MEDIUM
**Description:** Post-mortems, defensive coding, and knowledge sharing reduce future debugging time by 40-60% through systematic learning from past issues.
