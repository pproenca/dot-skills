# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Rendering & Output (render)

**Impact:** CRITICAL
**Description:** Flicker prevention, batched writes, and synchronized output are the #1 visual quality killers in terminal applications.

## 2. Input & Keyboard (input)

**Impact:** CRITICAL
**Description:** Keyboard event processing, modifier keys, and responsive feedback determine perceived latency and user satisfaction.

## 3. Component Patterns (tuicomp)

**Impact:** HIGH
**Description:** React patterns for terminal including Box/Text usage, Flexbox layouts, and measureElement have multiplicative performance impact.

## 4. State & Lifecycle (tuistate)

**Impact:** HIGH
**Description:** Hooks patterns, useApp/exit handling, cleanup, and avoiding stale closures prevent cascading re-renders and memory leaks.

## 5. Prompt Design (prompt)

**Impact:** MEDIUM-HIGH
**Description:** Clack group flows, validation, spinner/tasks, and cancellation handling affect usability and error recovery.

## 6. UX & Feedback (ux)

**Impact:** MEDIUM
**Description:** Progress indicators, colors, error messages, and next steps guidance are critical for developer experience.

## 7. Configuration & CLI (tuicfg)

**Impact:** MEDIUM
**Description:** Arguments, flags, environment variables, and sensible defaults affect portability and ease of use.

## 8. Robustness & Compatibility (robust)

**Impact:** LOW-MEDIUM
**Description:** TTY detection, graceful degradation, signal handling, and clean exit ensure production reliability.
