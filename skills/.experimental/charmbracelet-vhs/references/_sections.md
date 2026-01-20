# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Configuration Structure (config)

**Impact:** CRITICAL
**Description:** Settings order and structure fundamentally determine tape behavior; misplaced settings are silently ignored, causing recordings to fail without warning.

## 2. Dependency Management (deps)

**Impact:** CRITICAL
**Description:** Missing dependencies cause silent failures or incorrect output that wastes entire recording cycles; early validation prevents costly reruns.

## 3. Command Syntax (cmd)

**Impact:** HIGH
**Description:** Correct command usage prevents recording failures and produces intended terminal interactions; syntax errors halt execution entirely.

## 4. Timing & Synchronization (timing)

**Impact:** HIGH
**Description:** Proper timing prevents race conditions, ensures readable output, and creates professional-looking recordings that viewers can follow.

## 5. Output Optimization (output)

**Impact:** MEDIUM-HIGH
**Description:** File size, format selection, and quality settings directly impact deliverable usability; wrong choices result in bloated or unusable files.

## 6. Visual Quality (visual)

**Impact:** MEDIUM
**Description:** Font, theme, and dimension settings affect readability and professional appearance; poor choices reduce demo effectiveness.

## 7. CI/Automation (ci)

**Impact:** MEDIUM
**Description:** Proper CI setup enables automated testing and keeps demos synchronized with code; manual updates become unsustainable at scale.

## 8. Advanced Patterns (advanced)

**Impact:** LOW
**Description:** Source inclusion, clipboard operations, and server mode enable complex workflows for power users with specific requirements.
