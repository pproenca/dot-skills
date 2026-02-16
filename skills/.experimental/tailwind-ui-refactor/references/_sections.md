# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.
Sections are organized into three meta-layers based on Creative Selection (Ken Kocienda)
and Design Like Apple (John Edson): Empathy, Craft, and Taste.

Impact ordering: CRITICAL categories first, then HIGH, MEDIUM, LOW-MEDIUM.
Within each impact level, the workflow order is: Empathy → Craft → Taste.

---

## 1. Design Intent (intent)

**Impact:** CRITICAL
**Meta-layer:** Empathy
**Description:** Styling without understanding the UI's purpose produces polished but bloated interfaces. Auditing user goals, removing unnecessary elements, and reducing cognitive load before touching CSS prevents overengineered markup and creates focused, effective UI. As Creative Selection teaches: start by understanding what the user is trying to accomplish and how they feel while doing it.

## 2. Emotional Context (emotion)

**Impact:** CRITICAL
**Meta-layer:** Empathy
**Description:** Users are not task-completion robots. They bring anxiety to checkout pages, frustration to error screens, excitement to onboarding flows, and confidence to familiar dashboards. Design that ignores emotional state is technically correct but experientially hollow. Design Like Apple's Principle 6: "Design Is For People" — connect with your customer's emotional reality, not just their functional need.

## 3. Visual Hierarchy (hier)

**Impact:** CRITICAL
**Meta-layer:** Craft
**Description:** Wrong hierarchy makes everything compete for attention, creating noisy, chaotic interfaces. Size, weight, and color are the three levers that direct the eye — misusing them is the #1 cause of amateur-looking UI. The goal is not just correct hierarchy but hierarchy that feels effortless to the user.

## 4. Layout & Spacing (space)

**Impact:** CRITICAL
**Meta-layer:** Craft
**Description:** Cramped layouts with inconsistent spacing are the most visible amateur tell. Generous, systematic whitespace creates clarity, groups related elements, and makes interfaces feel professional. Apple's attention to spacing is legendary — every pixel of padding is a deliberate choice.

## 5. Taste & Judgment (taste)

**Impact:** CRITICAL
**Meta-layer:** Taste
**Description:** The most important design skill is knowing when the rules don't apply. Creative Selection's central insight: good design emerges from creating multiple demos and selecting the best one through informed judgment. Generate 2-3 variants with deliberate tradeoffs, demo them at multiple sizes, and trust your felt sense. A component that feels right beats one that follows every rule. Applied after craft rules, but critical in impact.

## 6. Typography (type)

**Impact:** HIGH
**Meta-layer:** Craft
**Description:** Poor font choices, wrong line heights, and excessive line lengths destroy readability across every screen. Typography affects every piece of text in the interface. Good typography is invisible — the user reads content without noticing the type. Bad typography makes every word harder.

## 7. Color Systems (color)

**Impact:** HIGH
**Meta-layer:** Craft
**Description:** Ad-hoc color choices create inconsistent, inaccessible interfaces. A systematic palette with proper shade ranges and accessible contrast ratios builds user trust. Design Like Apple's Principle 4: "Design Is Systems Thinking" — color is not decoration, it's communication infrastructure.

## 8. System Coherence (system)

**Impact:** HIGH
**Meta-layer:** Craft
**Description:** Individual component polish means nothing without system-level consistency. Border radius, spacing scales, color palettes, and shadow levels must all belong to one coherent system. Design Like Apple's Principle 4: "The product and its context are one." A product with consistent visual tokens has more personality than one with individually optimized components.

## 9. Depth & Shadows (depth)

**Impact:** MEDIUM
**Meta-layer:** Craft
**Description:** Flat interfaces lack visual cues for elevation and interactivity. A consistent shadow scale creates dimension and guides user attention to interactive elements. Shadows should communicate — "this is clickable," "this is floating above" — not merely decorate.

## 10. Borders & Separation (sep)

**Impact:** MEDIUM
**Meta-layer:** Craft
**Description:** Over-reliance on borders creates cluttered, busy interfaces. Replacing borders with spacing, shadows, and background color differences produces cleaner separation. The best separation is invisible — the user perceives the grouping without seeing the mechanism.

## 11. Polish & Delight (polish)

**Impact:** MEDIUM
**Meta-layer:** Taste
**Description:** Small finishing touches — accent borders, custom icons, subtle gradients — compound into a polished, professional feel. Design Like Apple's Principle 3: "The Product Is the Marketing." Every pixel communicates quality. Users notice when details are cared for, even if they can't articulate what they notice.

## 12. Images & Content (img)

**Impact:** LOW-MEDIUM
**Meta-layer:** Craft
**Description:** Uncontrolled images, poor text overlays, and neglected empty states break layouts and reduce perceived quality. Every content element is a touchpoint — even an empty state is an opportunity to show the user you care.
