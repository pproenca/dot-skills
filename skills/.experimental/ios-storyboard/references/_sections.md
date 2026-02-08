# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Storyboard Architecture (arch)

**Impact:** CRITICAL
**Description:** Monolithic storyboards are the #1 cause of merge conflicts, slow Xcode loading, and tangled navigation. Splitting into modular storyboards with references yields the largest maintainability and team velocity gains.

## 2. Auto Layout Constraints (layout)

**Impact:** CRITICAL
**Description:** Ambiguous or conflicting constraints cause runtime layout failures, unpredictable UI on different devices, and debugging nightmares. Correct constraint design eliminates entire classes of visual bugs.

## 3. Navigation & Segues (nav)

**Impact:** HIGH
**Description:** Incorrect segue usage, missing unwind segues, and mixed navigation patterns cause crashes, memory leaks, and unmaintainable flow logic.

## 4. Adaptive Layout & Size Classes (adapt)

**Impact:** HIGH
**Description:** Failing to use size classes and trait collections results in UIs that break on different devices and orientations, requiring device-specific workarounds.

## 5. View Hierarchy & Stack Views (view)

**Impact:** MEDIUM-HIGH
**Description:** Deep nesting, missing stack views, and inefficient view hierarchies cause layout performance degradation and unnecessary constraint complexity.

## 6. Accessibility & VoiceOver (ally)

**Impact:** MEDIUM
**Description:** Missing accessibility labels, traits, and identifiers exclude users with disabilities and fail App Store accessibility review requirements.

## 7. Version Control & Collaboration (vcs)

**Impact:** MEDIUM
**Description:** Storyboard XML generates hard-to-merge conflicts. Proper structure and workflow prevent team-blocking merge hell.

## 8. Debugging & Inspection (debug)

**Impact:** LOW-MEDIUM
**Description:** Inefficient debugging wastes hours. Knowing the right tools and techniques for constraint issues and view hierarchy inspection accelerates iteration.
