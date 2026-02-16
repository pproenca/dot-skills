# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Each category is grounded in principles from two foundational design texts:
- **Ken Kocienda** — *Creative Selection: Inside Apple's Design Process During the Golden Age of Steve Jobs*
- **John Edson** — *Design Like Apple: Seven Principles For Creating Insanely Great Products*

---

## 1. Empathy in Every Pixel (empathy)

**Impact:** CRITICAL
**Principle:** Kocienda "Empathy" · Edson "Design Is About People"
**Description:** Kocienda's first lesson from building the iPhone keyboard is that great software starts with empathy — trying to see the world from other people's perspectives and creating work that fits into their lives. Edson's foundational principle demands that design begin with genuine understanding of the person holding the device. In SwiftUI, empathy means semantic colors that never lie about appearance mode, safe areas that protect content on every device, VoiceOver labels that make every interaction accessible, touch targets that respect human fingers, reduce motion alternatives that prevent vestibular harm, readable widths that serve aging eyes, and foreground styles that honestly represent content hierarchy. If your app causes harm or exclusion for even one user, you built it for yourself, not for them.

## 2. The Visual System (system)

**Impact:** CRITICAL
**Principle:** Edson "Design Is Systems Thinking" · Kocienda "Convergence"
**Description:** Edson teaches designers to zoom out and see relationships between objects — understanding how a product's context creates a compelling, coherent system. Kocienda describes "convergence" — the process by which many individual decisions narrow toward one coherent whole, like the keyboard team trying dozens of key sizes before finding the one that worked. In SwiftUI, systems thinking means a unified typography scale that communicates hierarchy without explanation, a spacing grid derived from a base unit so every measurement relates to every other, material backgrounds that create honest depth, SF Symbols that guarantee iconographic consistency, and gradients that add dimension without dishonesty. When every visual element participates in one system, every screen feels like it was designed by one mind.

## 3. Craft: State as Foundation (craft)

**Impact:** CRITICAL
**Principle:** Kocienda "Craft"
**Description:** Kocienda defines craft as applying skill to achieve a high-quality result — the difference between code that works and code that sings. At Apple, the engineers who built the iPhone keyboard didn't just make keys that typed letters; they crafted an autocorrect system that anticipated mistakes before they happened. In SwiftUI, craft means choosing the right state wrapper for each situation — @State for view-local values, @Binding for parent-child communication, @Observable for shared models, @Environment for app-wide concerns. Wrong state management is invisible to the user until it isn't: cascading re-renders that stutter, state that resets when it shouldn't, bindings that silently overwrite on every parent re-render. Craftsmanship in state is the foundation every visible layer stands on.

## 4. Creative Composition (compose)

**Impact:** HIGH
**Principle:** Kocienda "Creative Selection"
**Description:** Kocienda's title concept — creative selection — describes how great software is built through composition and recombination of small, well-crafted pieces. The iPhone keyboard wasn't designed as a monolith; it was composed from individual key views, a suggestion bar, an autocorrect engine, and a touch model, each refined independently and then assembled. In SwiftUI, creative composition means views that return `some View` from a clear body property, configurable through properties rather than subclassing, modifiers applied in the correct order so each layer builds on the last, @ViewBuilder for flexible slot-based APIs, value types that prevent shared-state bugs, and composition over inheritance so pieces can be freely recombined. The best views are small enough to understand in a glance and composable enough to build anything.

## 5. Taste: The Right Choice (taste)

**Impact:** HIGH
**Principle:** Kocienda "Taste" · Edson "Design with Conviction"
**Description:** Kocienda writes that taste is the ability to discern quality — a refined sense of judgment that develops through experience and exposure to excellent work. When the iPhone team had to choose between a hardware keyboard and a software keyboard, taste was what let them see that the software keyboard, despite being harder, was the right answer. Edson's "Design with Conviction" demands committing to one approach and perfecting it rather than hedging with half-measures. In SwiftUI, taste means choosing List when you need swipe actions and selection, LazyVStack when you need custom layouts, sheets for tasks and fullScreenCover for immersive experiences, the right picker style for the data type, button styles that match the action's importance, and alerts only when the situation truly demands interruption. Every component choice is a taste decision — twenty valid options, one right answer.

## 6. Navigation as Conversation (converse)

**Impact:** HIGH
**Principle:** Edson "Design Is a Conversation" · Kocienda "The Demo"
**Description:** Edson's third principle frames design as an ongoing conversation between the product and the person using it. Every navigation action is a sentence in that dialogue: a tap says "tell me more," a swipe-back says "never mind," a sheet says "let me do this one thing." Kocienda's demo culture reinforced this — every Friday demo was a conversation between the engineer and Steve Jobs about whether the interface spoke clearly. In SwiftUI, conversation means NavigationStack for drill-down exploration, TabView for parallel topic switching, sheets for self-contained tasks, environment dismiss for graceful exit, toolbars placed where the hand naturally rests, and search integrated where the user expects to find it. When navigation matches the user's mental model, they never ask "where am I?" — the conversation flows naturally.

## 7. Design Out Loud: Layout (layout)

**Impact:** HIGH
**Principle:** Edson "Design Out Loud" · Kocienda "Intersection of Technology and Liberal Arts"
**Description:** Edson's fifth principle — Design Out Loud — demands the courage to prototype relentlessly, laying out views and rearranging them until the spatial relationships feel inevitable. Kocienda describes the "intersection of technology and liberal arts" that Steve Jobs championed — layout is exactly that intersection, where mathematical constraints meet visual rhythm and human perception. In SwiftUI, designing out loud means building with stacks that flow naturally, spacers that distribute breathing room, frames that set explicit boundaries, ZStacks that layer content with purpose, grids that align data honestly, lazy grids that scale to any collection size, adaptive layouts that reshape for every screen class, and scroll indicators that tell the user there's more to discover. Layout is the grammar of visual communication — get it wrong and nothing else matters.

## 8. The Product Speaks (product)

**Impact:** MEDIUM
**Principle:** Edson "The Product Is the Marketing" · Kocienda "Demo Culture"
**Description:** Edson's final principle states that at Apple, the product itself is the marketing — every pixel, every transition, every empty state communicates the quality of the team that built it. Kocienda's demo culture meant that every animation, every loading state, every list cell was built to survive Steve Jobs' scrutiny in a live demo. In SwiftUI, the product speaks through semantic transitions that give spatial context to appearing views, loading states that show honest progress instead of indefinite spinners, matched geometry effects that maintain object permanence, list cells designed with standard layouts that feel native, empty states that guide rather than abandon, segmented controls that make options scannable, and menus that organize secondary actions without cluttering the primary interface. These are not polish — they are the product.
