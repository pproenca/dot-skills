# React Principles

**Version 1.0.0**  
React Core Team  
2025-01-28

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Master React development by following the official principles taught in React documentation. This skill covers component purity, state management, effects, refs, reducers, context, and event handling - the complete foundation for writing predictable, maintainable React applications.

---

## Table of Contents

1. [Component Purity](references/_sections.md#1-component-purity) — **HIGH | **Rules:** 8**
   - 1.1 [Components render independently](references/pure-render-independence.md) — MEDIUM (Each component should calculate its output independently without relying on or coordinating with other components' render order)
   - 1.2 [Local mutation during render is fine](references/pure-local-mutation-allowed.md) — MEDIUM (Variables created during render can be freely mutated since they don't affect other components)
   - 1.3 [Never mutate external variables during render](references/pure-no-external-mutations.md) — HIGH (Mutations during render cause unpredictable behavior, race conditions, and bugs that are nearly impossible to track down)
   - 1.4 [Same inputs must produce same outputs](references/pure-same-inputs-same-outputs.md) — HIGH (Deterministic rendering enables caching, concurrent features, and predictable debugging)
   - 1.5 [Side effects belong in event handlers, not render](references/pure-side-effects-in-handlers.md) — HIGH (Event handlers run in response to user actions and are the natural place for side effects like API calls and mutations)
   - 1.6 [Treat props as read-only](references/pure-props-as-readonly.md) — HIGH (Mutating props breaks React's data flow and causes bugs that are hard to track across components)
   - 1.7 [Use StrictMode to detect impure components](references/pure-strict-mode-detection.md) — HIGH (StrictMode double-renders to expose hidden bugs before they reach production)
   - 1.8 [useEffect is a last resort for side effects](references/pure-use-effect-last-resort.md) — MEDIUM (Most side effects belong in event handlers; useEffect is specifically for synchronizing with external systems)
   - 1.9 [Why purity unlocks React's power](references/pure-why-purity-matters.md) — MEDIUM (Pure components enable caching, concurrent rendering, server components, and all of React's optimization strategies)
2. [State Structure](references/_sections.md#2-state-structure) — **HIGH | **Rules:** 10**
   - 2.1 [Avoid contradictory state](references/state-avoid-contradictions.md) — HIGH (Mutually exclusive states stored as separate booleans can become impossible combinations, causing bugs)
   - 2.2 [Derive values instead of storing redundant state](references/state-avoid-redundant.md) — HIGH (State that can be calculated from other state creates sync bugs and unnecessary complexity)
   - 2.3 [Don't mirror props in state](references/state-no-mirror-props.md) — HIGH (Initializing state from props creates a copy that won't update when the prop changes)
   - 2.4 [Flatten deeply nested state](references/state-flatten-nested.md) — HIGH (Deep nesting makes updates verbose and error-prone; flat structures with ID references are easier to update)
   - 2.5 [Group related state variables together](references/state-group-related.md) — HIGH (Related state that changes together should be unified to prevent sync bugs and simplify updates)
   - 2.6 [State behaves like a snapshot](references/state-snapshot-behavior.md) — HIGH (State value is fixed for each render; updates schedule new renders rather than changing current values)
   - 2.7 [Store IDs instead of duplicating objects](references/state-avoid-duplication.md) — HIGH (Duplicated objects in state can become out of sync when one copy is updated but others are not)
   - 2.8 [Update state immutably](references/state-immutable-updates.md) — HIGH (Mutating state directly bypasses React's change detection and causes rendering bugs)
   - 2.9 [Use keys to reset component state](references/state-keys-reset.md) — MEDIUM (Changing a component's key tells React to destroy and recreate it, resetting all internal state)
   - 2.10 [Use updater functions for state based on previous state](references/state-updater-functions.md) — HIGH (Updater functions ensure you're working with the latest pending state value, not a stale snapshot)
3. [State Sharing](references/_sections.md#3-state-sharing) — **HIGH | **Rules:** 6**
   - 3.1 [Choose between controlled and uncontrolled components](references/share-controlled-uncontrolled.md) — HIGH (Controlled components are driven by props (maximum flexibility); uncontrolled use internal state (easier setup))
   - 3.2 [Lift state up to the nearest common ancestor](references/share-lift-state-up.md) — HIGH (When multiple components need to reflect the same changing data, move state to their common parent)
   - 3.3 [Maintain a single source of truth](references/share-single-source-truth.md) — HIGH (Each piece of state should have exactly one owner component that controls it)
   - 3.4 [Props flow down, events flow up](references/share-props-down-events-up.md) — HIGH (React's unidirectional data flow - data passes down through props, change requests bubble up through callbacks)
   - 3.5 [Understand when React preserves vs resets state](references/share-preserve-reset-identity.md) — MEDIUM (React preserves state when a component stays at the same position in the tree; changing position or type resets it)
   - 3.6 [Use composition to avoid prop drilling](references/share-composition-over-drilling.md) — MEDIUM (Passing components as children or props can reduce the number of intermediate components that need to forward props)
4. [Effect Patterns](references/_sections.md#4-effect-patterns) — **HIGH | **Rules:** 10**
   - 4.1 [Always provide cleanup functions for effects](references/effect-cleanup.md) — HIGH (Effects that start something must stop it; cleanup runs before re-running and on unmount)
   - 4.2 [Dependencies must match the code](references/effect-dependencies.md) — HIGH (Every reactive value used in an effect must be in the dependency array; don't lie about dependencies)
   - 4.3 [Don't use effects for derived state](references/effect-not-for-derived-state.md) — HIGH (Values that can be calculated from props or state should be computed during render, not in effects)
   - 4.4 [Don't use effects for event-driven logic](references/effect-not-for-events.md) — HIGH (Side effects triggered by user actions should be in event handlers, not effects watching for state changes)
   - 4.5 [Each effect should represent one synchronization concern](references/effect-separate-concerns.md) — HIGH (Don't combine unrelated logic in one effect; split effects by what they synchronize, not by timing)
   - 4.6 [Effects synchronize with external systems](references/effect-synchronization.md) — HIGH (Use effects to keep React components synchronized with things outside React like APIs, DOM, timers)
   - 4.7 [Handle race conditions in effect-based fetching](references/effect-data-fetching.md) — HIGH (Effects can run multiple times; fetch logic must handle races between old and new requests)
   - 4.8 [Never suppress the dependency linter](references/effect-never-suppress-linter.md) — HIGH (Suppressing exhaustive-deps hides bugs; fix the code instead of silencing the warning)
   - 4.9 [Remove unnecessary effects](references/effect-remove-unnecessary.md) — HIGH (Many effects can be eliminated by calculating during render or moving logic to event handlers)
   - 4.10 [Think start/stop synchronization, not component lifecycle](references/effect-think-sync-not-lifecycle.md) — HIGH (Effects have their own lifecycle; don't think in mount/unmount but in how to sync and unsync)
5. [Refs Usage](references/_sections.md#5-refs-usage) — **MEDIUM | **Rules:** 5**
   - 5.1 [Don't read or write refs during render](references/ref-no-render-access.md) — HIGH (Accessing ref.current during render makes component behavior unpredictable and breaks React's model)
   - 5.2 [Follow ref best practices](references/ref-best-practices.md) — MEDIUM (Treat refs as escape hatches - use them sparingly, avoid reading during render, prefer state for UI values)
   - 5.3 [Refs are escape hatches for non-rendering values](references/ref-escape-hatch.md) — MEDIUM (Use refs to store values that shouldn't trigger re-renders, like timer IDs, DOM elements, or external objects)
   - 5.4 [Use refs for imperative DOM operations](references/ref-dom-manipulation.md) — MEDIUM (When you need to call DOM methods like focus(), scrollIntoView(), or measure elements, use refs)
   - 5.5 [Use refs to track mutable values across renders](references/ref-mutable-values.md) — MEDIUM (Refs persist values between renders without causing re-renders, useful for previous values, timers, and callbacks)
6. [Reducer Patterns](references/_sections.md#6-reducer-patterns) — **MEDIUM | **Rules:** 6**
   - 6.1 [Actions describe what happened, not what to do](references/reducer-actions.md) — MEDIUM (Actions represent user intent or events; the reducer decides how to update state)
   - 6.2 [Extract reducers outside components](references/reducer-extract-from-component.md) — LOW (Define reducers outside the component for cleaner code, easier testing, and potential reuse)
   - 6.3 [Reducers must be pure functions](references/reducer-pure-functions.md) — HIGH (Reducers receive state and action, return new state - no mutations, no side effects)
   - 6.4 [Structure reducers with switch and case blocks](references/reducer-structure.md) — LOW (Use switch statements with braced case blocks; always handle unknown actions)
   - 6.5 [Use reducers for complex state logic](references/reducer-when-to-use.md) — MEDIUM (When state updates become complex with many handlers, consolidate them in a reducer for clarity)
7. [Context Patterns](references/_sections.md#7-context-patterns) — **MEDIUM | **Rules:** 5**
   - 7.1 [Combine context with reducers for complex state](references/context-with-reducer.md) — MEDIUM (For state that's both global and has complex updates, provide both state and dispatch through context)
   - 7.2 [Follow the create-use-provide pattern](references/context-create-use-provide.md) — MEDIUM (Context workflow: createContext defines it, useContext reads it, Provider supplies it)
   - 7.3 [Provide meaningful default values](references/context-default-values.md) — LOW (Context default values should be sensible fallbacks, not just placeholders)
   - 7.4 [Use context to avoid prop drilling](references/context-when-to-use.md) — MEDIUM (Context passes data through the component tree without explicit props at each level)
8. [Event Handling](references/_sections.md#8-event-handling) — **MEDIUM | **Rules:** 5**
   - 8.1 [Event handlers are the primary place for side effects](references/event-side-effects.md) — HIGH (User-triggered side effects (API calls, navigation, mutations) belong in event handlers, not render or effects)
   - 8.2 [Follow event handler naming conventions](references/event-naming.md) — LOW (Use "handle" prefix for handlers, "on" prefix for props; be descriptive about what event triggers the handler)
   - 8.3 [Pass handlers, don't call them](references/event-pass-handlers.md) — HIGH (Event handlers should be passed as references, not called inline with parentheses)
   - 8.4 [Understand event propagation and stopping](references/event-propagation.md) — MEDIUM (Events bubble up the tree by default; use stopPropagation to prevent parent handlers from firing)

---

## References

1. [https://react.dev/learn](https://react.dev/learn)
2. [https://react.dev/learn/keeping-components-pure](https://react.dev/learn/keeping-components-pure)
3. [https://react.dev/learn/choosing-the-state-structure](https://react.dev/learn/choosing-the-state-structure)
4. [https://react.dev/learn/lifecycle-of-reactive-effects](https://react.dev/learn/lifecycle-of-reactive-effects)
5. [https://react.dev/learn/extracting-state-logic-into-a-reducer](https://react.dev/learn/extracting-state-logic-into-a-reducer)
6. [https://react.dev/learn/passing-data-deeply-with-context](https://react.dev/learn/passing-data-deeply-with-context)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |