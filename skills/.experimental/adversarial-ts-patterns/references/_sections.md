# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
decisions that come up most often and cost most when wrong go first.

---

## 1. State Modeling & Machines (state)

**Description:** Implicit state machines that let impossible states compile — mutually exclusive lifecycles encoded as independent booleans, effect chains standing in for transitions, derived values stored and synced by hand, and union matches that silently swallow new members. The costliest category because these are not style problems; they are the source of "can't happen" production bugs.

## 2. Creational Ports (create)

**Description:** Gang of Four creational machinery ported from Java/C# where TypeScript already has the primitive — `getInstance()` singletons in a module system whose modules are singletons, factory-class hierarchies whose subclasses only override one create method, and mutable builder classes assembling an all-optional bag a literal with `Partial<T>` describes better.

## 3. Behavioral Ports (behave)

**Description:** Behavioral patterns whose class form exists only because the source language lacked first-class functions or tagged unions — single-method Strategy/Command interfaces implemented by stateless classes, class-per-state State machines and accept/visit Visitor pairs over closed sets, and event buses wired between components that share a React ancestor.

## 4. Enterprise Layers (layer)

**Description:** Enterprise-architecture layers ported without their original justification — repositories that delegate 1-to-1 to an already-abstract data client, dependency-injection containers where every token has one production implementation, and interfaces with a single implementation and no test double. Each adds a file, an import hop, and a naming scheme while changing no behavior.

## 5. React Composition (react)

**Description:** OO reuse mechanisms applied to React components — inheritance hierarchies (including `Base*` components and new class components), higher-order components that only inject logic a hook could return, and `useImperativeHandle` used to push data flows through refs instead of props.

## 6. OO Ceremony (oo)

**Description:** Class syntax carrying no class semantics — static-only container classes standing in for modules, and trivial get/set pairs that mirror a private field. Pure ceremony; the lowest-cost category, but the highest-frequency one in code ported from Java/C# conventions.
