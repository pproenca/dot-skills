# Rule Categories

This skill teaches React principles from the official React documentation. Categories are ordered by impact and development lifecycle.

## 1. Component Purity (pure)
**Impact:** HIGH | **Rules:** 8

Components as pure functions - predictable, testable, and cacheable. The foundation of React's rendering model.

- No external mutations during render
- Same inputs produce same outputs
- Local mutation is acceptable
- StrictMode detection
- Side effects belong elsewhere

## 2. State Structure (state)
**Impact:** HIGH | **Rules:** 10

Designing state that's easy to update without introducing bugs. Like database normalization for UI state.

- Group related state variables
- Avoid contradictory state
- Derive values instead of storing
- Store IDs not objects
- Flatten nested structures
- Don't mirror props in state

## 3. State Sharing (share)
**Impact:** HIGH | **Rules:** 6

Coordinating state between components through lifting and data flow patterns.

- Lift state to common ancestor
- Single source of truth
- Controlled vs uncontrolled patterns
- Props down, events up

## 4. Effect Patterns (effect)
**Impact:** HIGH | **Rules:** 10

Synchronizing with external systems correctly. Effects have their own lifecycle separate from components.

- Cleanup functions required
- Dependencies must match code
- Separate synchronization concerns
- Never suppress the linter
- Think start/stop, not mount/unmount

## 5. Refs Usage (ref)
**Impact:** MEDIUM | **Rules:** 5

Escape hatches for values outside React's render cycle. Use sparingly.

- Refs for non-rendering values
- Don't read/write during render
- DOM access and external APIs
- Timeout/interval IDs

## 6. Reducer Patterns (reducer)
**Impact:** MEDIUM | **Rules:** 6

Consolidating complex state logic into predictable, testable functions.

- Actions describe what happened
- Reducers are pure functions
- Extract from component
- Switch statements with cases
- Handle unknown actions

## 7. Context Patterns (context)
**Impact:** MEDIUM | **Rules:** 5

Passing data deeply without prop drilling. Use for truly global concerns.

- Create, Use, Provide pattern
- Avoid overuse
- Combine with reducers for complex state
- Default values matter

## 8. Event Handling (event)
**Impact:** MEDIUM | **Rules:** 5

Responding to user interactions and where side effects belong.

- Pass handlers, don't call
- Side effects in handlers
- Event handler naming conventions
- Propagation and prevention
