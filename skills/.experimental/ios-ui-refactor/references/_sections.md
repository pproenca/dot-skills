# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Each category is grounded in principles from three foundational design texts:
- **Dieter Rams** — *Ten Principles for Good Design* (Cees W. de Jong)
- **Ken Segall** — *Insanely Simple: The Obsession That Drives Apple's Success*
- **John Edson** — *Design Like Apple: Seven Principles For Creating Insanely Great Products*

---

## 1. Less, But Better (less)

**Impact:** CRITICAL
**Principle:** Rams #10 "Good design is as little design as possible" · Segall "Think Minimal"
**Description:** Every element on screen must earn its place. Rams taught that concentration on essential aspects means the product is not burdened with non-essentials. Segall showed that Apple succeeded by saying no to a thousand things — distilling a lineup of twenty models into four. In SwiftUI, this means one focal point per screen, one typeface, fewer type treatments, restrained color, and zero purposeless animation. If removing an element doesn't degrade the experience, it should never have been there.

## 2. Self-Evident Design (evident)

**Impact:** CRITICAL
**Principle:** Rams #4 "Good design makes a product understandable" · Segall "Think Human"
**Description:** Rams believed the best design clarifies a product's structure and makes it self-explanatory — no manual required. Segall's Think Human principle demands that interfaces speak in terms people understand, not technical abstractions. In SwiftUI, this means clear visual hierarchy through size and weight contrast, whitespace that groups related content, progressive disclosure that surfaces the essential and hides the rest, and navigation paradigms that match the user's mental model — all without a single explanatory tooltip.

## 3. Honest Interfaces (honest)

**Impact:** CRITICAL
**Principle:** Rams #6 "Good design is honest" · Segall "Think Brutal"
**Description:** Rams insisted design must not attempt to make a product more innovative, powerful, or valuable than it really is — it does not manipulate the consumer with promises that cannot be kept. Segall's Think Brutal demands clarity without sugar-coating. In SwiftUI, honesty means semantic colors that never lie about dark mode, contrast ratios that genuinely serve readability, loading states that reflect real progress, and foreground styles that accurately represent content hierarchy. Every visual decision tells the truth about what the interface is and what it does.

## 4. Invisible Design (invisible)

**Impact:** HIGH
**Principle:** Rams #5 "Good design is unobtrusive" · Edson "The Product Is the Marketing"
**Description:** Rams compared well-designed products to neutral tools — they should not be decorative objects or works of art, but leave room for the user's self-expression. Edson showed that at Apple, the product itself is the marketing — the interface quality speaks for itself without calling attention to the mechanism. In SwiftUI, this means system materials instead of hand-tuned opacity, spring physics instead of artificial easing curves, built-in symbol effects instead of manual animation. The best interaction design is the one the user never notices — they notice only the content.

## 5. Systems, Not Pieces (system)

**Impact:** HIGH
**Principle:** Edson "Design Is Systems Thinking" · Rams #8 "Good design is thorough down to the last detail"
**Description:** Edson's fourth principle teaches designers to zoom out and see relationships between objects, understanding how the product's context creates a compelling, coherent system. Rams insisted nothing must be arbitrary or left to chance. In SwiftUI, this means a unified spacing grid derived from a base unit, color roles named by purpose not hue, consistent corner radii per component type, and brand identity mapped onto iOS semantic roles — so every screen feels like part of one deliberate system rather than a collection of individually designed views.

## 6. Thorough to the Last Detail (thorough)

**Impact:** HIGH
**Principle:** Rams #8 "Good design is thorough down to the last detail" · Rams #2 "Good design makes a product useful"
**Description:** Rams was uncompromising: care and accuracy in the design process show respect for the user. Nothing must be arbitrary or left to chance. A product that ignores edge cases — reduce motion preferences, minimum touch targets, safe area insets, unreadable font weights — fails at being useful regardless of how beautiful the happy path looks. In SwiftUI, thoroughness means every interaction works for every user in every context, without exception.

## 7. Enduring Over Trendy (enduring)

**Impact:** MEDIUM-HIGH
**Principle:** Rams #7 "Good design is long-lasting" · Edson "Design With Conviction"
**Description:** Rams warned that fashionable design becomes antiquated — unlike good design, which is never outdated. Edson's seventh principle demands commitment to a unique voice that persists across product generations. In SwiftUI, enduring design means system text styles that scale with platform evolution, weight-based emphasis over stylistic gimmicks, platform navigation gestures preserved, and modular card patterns that compose into any future layout. These choices outlast trends because they align with the platform's own trajectory.

## 8. Refined Through Iteration (refined)

**Impact:** MEDIUM
**Principle:** Edson "Design Out Loud" · Rams #1 "Good design is innovative" · Rams #3 "Good design is aesthetic"
**Description:** Edson's fifth principle teaches the courage to relentlessly prototype — to design out loud until every interaction feels inevitable. Rams saw innovation not as an end in itself but as a means of serving genuine purposes, and aesthetic quality as integral to usefulness. In SwiftUI, this means adopting modern APIs like scroll transitions, phase animators, and matched geometry — not for novelty, but because they enable refinements that were previously impossible. Each iteration removes friction and adds polish until the interface feels effortless.
