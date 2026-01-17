# Best Practices

**Version 1.0.0**  
MUI  
2026-01-17

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive style guide for building headless React component libraries following MUI Base UI patterns. Covers component architecture, naming conventions, file organization, error handling, and code style for unstyled UI primitives.

---

## Table of Contents

1. [Component Patterns](#1-component-patterns) — **CRITICAL**
   - 1.1 [Add use client Directive](#11-add-use-client-directive)
   - 1.2 [Context Error Messages with Hierarchy](#12-context-error-messages-with-hierarchy)
   - 1.3 [Create Context with Undefined Default](#13-create-context-with-undefined-default)
   - 1.4 [Hook Namespace Exports](#14-hook-namespace-exports)
   - 1.5 [Memoize Context Provider Values](#15-memoize-context-provider-values)
   - 1.6 [Memoize State Objects](#16-memoize-state-objects)
   - 1.7 [Name Props Parameter componentProps](#17-name-props-parameter-componentprops)
   - 1.8 [Plain Function for Non-DOM Roots](#18-plain-function-for-non-dom-roots)
   - 1.9 [Props Destructuring Order](#19-props-destructuring-order)
   - 1.10 [Use forwardRef with Named Function](#110-use-forwardref-with-named-function)
   - 1.11 [Use useControlled Hook for Dual Modes](#111-use-usecontrolled-hook-for-dual-modes)
   - 1.12 [Use useRenderElement for DOM Rendering](#112-use-userenderelement-for-dom-rendering)
2. [Naming Conventions](#2-naming-conventions) — **HIGH**
   - 2.1 [Component Naming as ParentPart](#21-component-naming-as-parentpart)
   - 2.2 [Constant Naming SCREAMING_SNAKE_CASE](#22-constant-naming-screamingsnakecase)
   - 2.3 [Context Hook as useComponentContext](#23-context-hook-as-usecomponentcontext)
   - 2.4 [Context Naming with Suffix](#24-context-naming-with-suffix)
   - 2.5 [Data Attribute Naming lowercase](#25-data-attribute-naming-lowercase)
   - 2.6 [Directory Naming kebab-case](#26-directory-naming-kebab-case)
   - 2.7 [Event Type Naming Convention](#27-event-type-naming-convention)
   - 2.8 [File Name Matches Primary Export](#28-file-name-matches-primary-export)
   - 2.9 [Handler Naming Convention](#29-handler-naming-convention)
   - 2.10 [Hook Naming with use Prefix](#210-hook-naming-with-use-prefix)
   - 2.11 [Namespace Type Exports](#211-namespace-type-exports)
   - 2.12 [Part Directory Naming lowercase](#212-part-directory-naming-lowercase)
   - 2.13 [Props Interface as ComponentProps](#213-props-interface-as-componentprops)
   - 2.14 [Ref Variable Naming with Suffix](#214-ref-variable-naming-with-suffix)
   - 2.15 [State Interface as ComponentState](#215-state-interface-as-componentstate)
3. [Organization](#3-organization) — **HIGH**
   - 3.1 [Component Directory Structure](#31-component-directory-structure)
   - 3.2 [Context File Placement](#32-context-file-placement)
   - 3.3 [CSS Variables Documentation File](#33-css-variables-documentation-file)
   - 3.4 [Data Attributes Documentation File](#34-data-attributes-documentation-file)
   - 3.5 [Dual Barrel Export Pattern](#35-dual-barrel-export-pattern)
   - 3.6 [Package-Level Wildcard Exports](#36-package-level-wildcard-exports)
   - 3.7 [State Attributes Mapping File](#37-state-attributes-mapping-file)
   - 3.8 [Test File Colocation](#38-test-file-colocation)
4. [Error Handling](#4-error-handling) — **HIGH**
   - 4.1 [Cancelable Event Pattern](#41-cancelable-event-pattern)
   - 4.2 [Context Error Guidance](#42-context-error-guidance)
   - 4.3 [Deduplicated Warning Messages](#43-deduplicated-warning-messages)
   - 4.4 [Development-Only Warnings](#44-development-only-warnings)
   - 4.5 [Event Reason Constants](#45-event-reason-constants)
   - 4.6 [Message Prefix Standard](#46-message-prefix-standard)
   - 4.7 [Prop Validation Timing](#47-prop-validation-timing)
   - 4.8 [Type-Safe Event Reasons](#48-type-safe-event-reasons)
5. [Style](#5-style) — **MEDIUM**
   - 5.1 [Default Values in Destructuring](#51-default-values-in-destructuring)
   - 5.2 [Explicit Undefined in Prop Types](#52-explicit-undefined-in-prop-types)
   - 5.3 [Internal Import Paths](#53-internal-import-paths)
   - 5.4 [JSDoc Documentation](#54-jsdoc-documentation)
   - 5.5 [React Import as Namespace](#55-react-import-as-namespace)

---

## 1. Component Patterns

**Impact: CRITICAL**

Core patterns for building headless React components including forwardRef, render elements, context providers, controlled/uncontrolled state, and memoization strategies.

### 1.1 Add use client Directive

**Impact: HIGH (enables components to work in React Server Components environments like Next.js App Router)**

Add the `'use client'` directive at the top of component files for React Server Components compatibility. This ensures components work correctly in Next.js App Router and other RSC environments.

**Incorrect (no directive):**

```typescript
import * as React from 'react'

export const Button = React.forwardRef(function Button(props, ref) {
  // Uses hooks - requires client environment
  const [pressed, setPressed] = React.useState(false)
  // ...
})
```

**Correct (with directive):**

```typescript
'use client'

import * as React from 'react'

export const Button = React.forwardRef(function Button(
  componentProps: Button.Props,
  forwardedRef: React.ForwardedRef<HTMLButtonElement>
) {
  const [pressed, setPressed] = React.useState(false)
  // ...
})
```

**When to use:**
- All component files that use React hooks
- All component files that use browser APIs
- NOT needed for pure utility functions or type definitions

### 1.2 Context Error Messages with Hierarchy

**Impact: HIGH (helps developers quickly fix component structure issues with clear guidance)**

Context error messages must specify the required component relationship and which component provides the context.

**Incorrect (vague error):**

```typescript
function useAccordionRootContext() {
  const context = React.useContext(AccordionRootContext)
  if (!context) {
    throw new Error('Context is missing')
  }
  return context
}
```

**Correct (descriptive error with hierarchy):**

```typescript
function useAccordionRootContext(): AccordionRootContextType {
  const context = React.useContext(AccordionRootContext)
  if (context === undefined) {
    throw new Error(
      'Base UI: AccordionRootContext is missing. Accordion parts must be placed within <Accordion.Root>.'
    )
  }
  return context
}

function useAccordionItemContext(): AccordionItemContextType {
  const context = React.useContext(AccordionItemContext)
  if (context === undefined) {
    throw new Error(
      'Base UI: AccordionItemContext is missing. AccordionItem parts must be placed within <Accordion.Item>.'
    )
  }
  return context
}
```

**When to use:**
- All context consumer hooks
- Error messages should include: library prefix, context name, and required parent component

### 1.3 Create Context with Undefined Default

**Impact: HIGH (ensures consumers get clear error messages when used outside provider instead of silent failures)**

Create React contexts with `undefined` as the default value instead of an empty object or dummy values. Provide a custom hook that throws a descriptive error when the context is missing.

**Incorrect (empty object default):**

```typescript
interface AccordionContextType {
  value: string[]
  setValue: (value: string[]) => void
}

const AccordionContext = React.createContext<AccordionContextType>({} as AccordionContextType)

// Consumer silently gets undefined behavior
function useAccordion() {
  return React.useContext(AccordionContext)
}
```

**Correct (undefined default with throwing hook):**

```typescript
interface AccordionRootContextType {
  value: string[]
  setValue: (value: string[]) => void
  disabled: boolean
}

const AccordionRootContext = React.createContext<AccordionRootContextType | undefined>(undefined)

export function useAccordionRootContext(): AccordionRootContextType {
  const context = React.useContext(AccordionRootContext)
  if (context === undefined) {
    throw new Error(
      'Base UI: AccordionRootContext is missing. Accordion parts must be placed within <Accordion.Root>.'
    )
  }
  return context
}
```

**When to use:**
- All component contexts in compound component patterns
- Any context that requires a provider to function correctly
- Contexts where missing provider would cause runtime errors

### 1.4 Hook Namespace Exports

**Impact: MEDIUM (provides consistent type access pattern across hooks and components)**

Export hook types using namespace pattern for Parameters and ReturnValue to match component type export patterns.

**Incorrect (separate interface exports):**

```typescript
export interface UseButtonParams {
  disabled?: boolean
  type?: 'button' | 'submit' | 'reset'
}

export interface UseButtonReturn {
  getRootProps: () => React.HTMLAttributes<HTMLButtonElement>
}

export function useButton(params: UseButtonParams): UseButtonReturn {
  // ...
}
```

**Correct (namespace exports):**

```typescript
interface UseButtonParameters {
  disabled?: boolean | undefined
  type?: 'button' | 'submit' | 'reset' | undefined
}

interface UseButtonReturnValue {
  getRootProps: () => React.HTMLAttributes<HTMLButtonElement>
}

export function useButton(params: UseButtonParameters): UseButtonReturnValue {
  // ...
}

export namespace useButton {
  export type Parameters = UseButtonParameters
  export type ReturnValue = UseButtonReturnValue
}

// Usage:
const params: useButton.Parameters = { disabled: true }
const result: useButton.ReturnValue = useButton(params)
```

**When to use:**
- All exported hooks
- Maintains consistency with component namespace patterns (Component.Props, Component.State)

### 1.5 Memoize Context Provider Values

**Impact: HIGH (prevents all context consumers from re-rendering when provider re-renders)**

Always memoize context provider values to prevent unnecessary re-renders of all consumers when the provider component re-renders.

**Incorrect (new value object every render):**

```typescript
function AccordionRoot({ children, value, setValue, disabled }) {
  return (
    <AccordionRootContext.Provider value={{ value, setValue, disabled }}>
      {children}
    </AccordionRootContext.Provider>
  )
}
// All consumers re-render on any AccordionRoot re-render
```

**Correct (memoized context value):**

```typescript
function AccordionRoot(props: AccordionRoot.Props) {
  const { children, value, onValueChange, disabled = false } = props

  const [valueState, setValueState] = useControlled({
    controlled: value,
    default: [],
    name: 'Accordion',
    state: 'value',
  })

  const contextValue = React.useMemo(
    () => ({
      value: valueState,
      setValue: setValueState,
      disabled,
    }),
    [valueState, setValueState, disabled]
  )

  return (
    <AccordionRootContext.Provider value={contextValue}>
      {children}
    </AccordionRootContext.Provider>
  )
}
```

**When to use:**
- All context provider components
- Any object passed to Context.Provider value prop

### 1.6 Memoize State Objects

**Impact: HIGH (prevents unnecessary re-renders when passing state to render props and child components)**

Create a memoized state object for render props and context values. This prevents new object references on every render.

**Incorrect (new object every render):**

```typescript
function AccordionTrigger(props) {
  const { open, disabled } = useAccordionItemContext()

  return useRenderElement('button', props, {
    // New object created every render
    state: { open, disabled },
  })
}
```

**Correct (memoized state object):**

```typescript
function AccordionTrigger(componentProps: AccordionTrigger.Props) {
  const { open, disabled, setOpen } = useAccordionItemContext()

  const state: AccordionTrigger.State = React.useMemo(
    () => ({ open, disabled }),
    [open, disabled]
  )

  return useRenderElement('button', componentProps, {
    state,
    ref: forwardedRef,
    props: [elementProps],
    stateAttributesMapping,
  })
}
```

**When to use:**
- All components exposing state via render props
- State objects passed to useRenderElement
- State values provided through context

### 1.7 Name Props Parameter componentProps

**Impact: HIGH (distinguishes component props from element props after destructuring)**

Name the props parameter `componentProps` and the ref parameter `forwardedRef` in forwardRef callbacks. This distinguishes between the full component props and the element props that remain after destructuring.

**Incorrect (anti-pattern):**

```typescript
export const Button = React.forwardRef(function Button(props, ref) {
  const { disabled, ...rest } = props
  return <button {...rest} ref={ref} />
})
```

**Correct (recommended):**

```typescript
export const Button = React.forwardRef(function Button(
  componentProps: Button.Props,
  forwardedRef: React.ForwardedRef<HTMLButtonElement>
) {
  const { render, className, disabled = false, ...elementProps } = componentProps

  return useRenderElement('button', componentProps, {
    ref: forwardedRef,
    props: [elementProps],
  })
})
```

**When to use:**
- All forwardRef component definitions
- Maintains consistency across the codebase
- Makes code review easier by signaling intent

### 1.8 Plain Function for Non-DOM Roots

**Impact: MEDIUM (avoids unnecessary forwardRef overhead for components that don't render DOM elements)**

Use plain function components (not forwardRef) for Root components that don't render their own DOM element. These components only provide context and orchestration.

**Incorrect (forwardRef for context-only component):**

```typescript
export const DialogRoot = React.forwardRef(function DialogRoot(
  props: DialogRoot.Props,
  ref: React.ForwardedRef<HTMLElement>
) {
  // Component doesn't render a DOM element, ref is unused
  return (
    <DialogRootContext.Provider value={contextValue}>
      {props.children}
    </DialogRootContext.Provider>
  )
})
```

**Correct (plain function):**

```typescript
export function DialogRoot<Payload>(props: DialogRoot.Props<Payload>) {
  const {
    open: openProp,
    defaultOpen = false,
    onOpenChange,
    children,
    ...otherProps
  } = props

  const [open, setOpen] = useControlled({
    controlled: openProp,
    default: defaultOpen,
    name: 'Dialog',
    state: 'open',
  })

  const contextValue = React.useMemo(
    () => ({ open, setOpen }),
    [open, setOpen]
  )

  return (
    <DialogRootContext.Provider value={contextValue}>
      {children}
    </DialogRootContext.Provider>
  )
}
```

**When to use:**
- Root components that only provide context (Dialog.Root, Accordion.Root)
- Components that don't render their own DOM element
- Use forwardRef for components that DO render DOM (Trigger, Panel, etc.)

### 1.9 Props Destructuring Order

**Impact: MEDIUM (maintains consistent code structure across components for easier review)**

Destructure props in a consistent order: render, className, component-specific props with defaults, then rest spread to elementProps.

**Incorrect (inconsistent ordering):**

```typescript
function AccordionTrigger(componentProps) {
  const { disabled, render, className, onClick, ...rest } = componentProps
  // ...
}
```

**Correct (consistent ordering):**

```typescript
function AccordionTrigger(componentProps: AccordionTrigger.Props) {
  const {
    // 1. Render-related props
    render,
    className,
    // 2. Component-specific props with defaults
    disabled = false,
    // 3. Rest spread to elementProps
    ...elementProps
  } = componentProps

  // ...
}
```

**When to use:**
- All component definitions
- Helps maintain consistency during code review
- Makes it clear which props are consumed vs passed through

### 1.10 Use forwardRef with Named Function

**Impact: CRITICAL (improves debugging with meaningful stack traces and component names in React DevTools)**

Use React.forwardRef with a named function callback instead of an arrow function. This provides better debugging experience with meaningful component names in stack traces and React DevTools.

**Incorrect (anonymous function):**

```typescript
export const Button = React.forwardRef((props, ref) => {
  return <button {...props} ref={ref} />
})
// DevTools shows: ForwardRef or Anonymous
```

**Correct (named function):**

```typescript
export const Button = React.forwardRef(function Button(
  componentProps: Button.Props,
  forwardedRef: React.ForwardedRef<HTMLButtonElement>
) {
  const { render, className, disabled = false, ...elementProps } = componentProps

  return useRenderElement('button', componentProps, {
    ref: forwardedRef,
    props: [elementProps],
  })
})
// DevTools shows: Button
```

**When to use:**
- All components that need to expose a ref to parent components
- Components that render DOM elements directly
- Child components in compound component patterns

### 1.11 Use useControlled Hook for Dual Modes

**Impact: CRITICAL (provides consistent controlled/uncontrolled behavior with proper warnings for mode switches)**

Use the `useControlled` hook for components that support both controlled and uncontrolled modes. This hook handles the state management and provides development warnings when switching between modes.

**Incorrect (manual controlled/uncontrolled handling):**

```typescript
function Accordion({ value, defaultValue, onValueChange }) {
  const [internalValue, setInternalValue] = useState(value ?? defaultValue ?? [])

  // No warning when switching from uncontrolled to controlled
  const currentValue = value !== undefined ? value : internalValue

  const setValue = (newValue) => {
    if (value === undefined) {
      setInternalValue(newValue)
    }
    onValueChange?.(newValue)
  }

  return ...
}
```

**Correct (useControlled hook):**

```typescript
import { useControlled } from '@base-ui/utils/useControlled'

function AccordionRoot(props: AccordionRoot.Props) {
  const {
    value: valueProp,
    defaultValue = [],
    onValueChange,
    ...otherProps
  } = props

  const [value, setValueState] = useControlled({
    controlled: valueProp,
    default: defaultValue,
    name: 'Accordion',
    state: 'value',
  })

  const setValue = React.useCallback((newValue: string[]) => {
    setValueState(newValue)
    onValueChange?.(newValue)
  }, [setValueState, onValueChange])

  return ...
}
```

**When to use:**
- Components with `value`/`defaultValue` props
- Components with `open`/`defaultOpen` props
- Any component supporting both controlled and uncontrolled modes

### 1.12 Use useRenderElement for DOM Rendering

**Impact: CRITICAL (provides consistent render prop support, className callbacks, and state attributes across all components)**

Use the `useRenderElement` hook to handle DOM rendering. This hook provides consistent support for render props, className callbacks, and automatic state attribute mapping.

**Incorrect (manual DOM rendering):**

```typescript
export const Button = React.forwardRef(function Button(props, ref) {
  const { disabled, className, ...rest } = props

  return (
    <button
      {...rest}
      ref={ref}
      className={className}
      disabled={disabled}
      data-disabled={disabled || undefined}
    />
  )
})
```

**Correct (useRenderElement):**

```typescript
export const AccordionTrigger = React.forwardRef(function AccordionTrigger(
  componentProps: AccordionTrigger.Props,
  forwardedRef: React.ForwardedRef<HTMLButtonElement>
) {
  const { render, className, ...elementProps } = componentProps
  const { open, disabled, setOpen, triggerId, panelId } = useAccordionItemContext()

  const state: AccordionTrigger.State = React.useMemo(
    () => ({ open, disabled }),
    [open, disabled]
  )

  return useRenderElement('button', componentProps, {
    state,
    ref: forwardedRef,
    props: [{
      ...elementProps,
      id: triggerId,
      'aria-expanded': open,
      'aria-controls': panelId,
      onClick: () => setOpen(!open),
    }],
    stateAttributesMapping: triggerStateAttributesMapping,
  })
})
```

**When to use:**
- All components that render a DOM element
- Components supporting render props for custom element rendering
- Components that expose state via data-* attributes

---

## 2. Naming Conventions

**Impact: HIGH**

Consistent naming patterns for components, files, directories, types, hooks, and data attributes that enable predictable API surfaces and clear code organization.

### 2.1 Component Naming as ParentPart

**Impact: CRITICAL (enables predictable API surface and clear component relationships)**

Name components as [Parent][Part] using PascalCase. This makes the component hierarchy explicit in the name.

**Incorrect (anti-pattern):**

```typescript
// Generic names lose context
export const Root = React.forwardRef(...)
export const Trigger = React.forwardRef(...)
export const Panel = React.forwardRef(...)

// Usage is ambiguous
<Root>
  <Trigger />
  <Panel />
</Root>
```

**Correct (recommended):**

```typescript
// Full names include parent context
export const AccordionRoot = React.forwardRef(...)
export const AccordionItem = React.forwardRef(...)
export const AccordionTrigger = React.forwardRef(...)
export const AccordionPanel = React.forwardRef(...)

// Clear what each component belongs to
<AccordionRoot>
  <AccordionItem>
    <AccordionTrigger />
    <AccordionPanel />
  </AccordionItem>
</AccordionRoot>

// Re-exported with short aliases for namespaced usage
export { AccordionRoot as Root } from './root/AccordionRoot'
// Allows: <Accordion.Root>
```

**When to use:**
- All component definitions
- Short aliases only in barrel exports for namespace patterns

### 2.2 Constant Naming SCREAMING_SNAKE_CASE

**Impact: MEDIUM (clearly distinguishes constants from mutable variables)**

Use SCREAMING_SNAKE_CASE for constants to distinguish them from mutable variables.

**Incorrect (anti-pattern):**

```typescript
const reasons = {
  triggerPress: 'trigger-press',
  escapeKey: 'escape-key',
}

const emptyArray: string[] = []
const defaultValue = 0
```

**Correct (recommended):**

```typescript
const REASONS = {
  triggerPress: 'trigger-press',
  escapeKey: 'escape-key',
  outsidePress: 'outside-press',
  focusOut: 'focus-out',
} as const

const EMPTY_ARRAY: readonly string[] = []
const DEFAULT_DELAY = 300
const ANIMATION_DURATION = 200
```

**When to use:**
- Module-level constants
- Enum-like objects
- Default values that should never change

### 2.3 Context Hook as useComponentContext

**Impact: HIGH (provides consistent API for accessing context across all components)**

Name context consumer hooks as `use[Component]Context` matching the context name.

**Incorrect (anti-pattern):**

```typescript
// Various inconsistent patterns
function useAccordion() {
  return React.useContext(AccordionRootContext)
}

function useAccordionCtx() {
  return React.useContext(AccordionRootContext)
}

function getAccordionContext() {
  return React.useContext(AccordionRootContext)
}
```

**Correct (recommended):**

```typescript
export function useAccordionRootContext(): AccordionRootContextType {
  const context = React.useContext(AccordionRootContext)
  if (context === undefined) {
    throw new Error(
      'Base UI: AccordionRootContext is missing. Accordion parts must be placed within <Accordion.Root>.'
    )
  }
  return context
}

export function useAccordionItemContext(): AccordionItemContextType {
  const context = React.useContext(AccordionItemContext)
  if (context === undefined) {
    throw new Error(
      'Base UI: AccordionItemContext is missing. Accordion parts must be placed within <Accordion.Item>.'
    )
  }
  return context
}
```

**When to use:**
- All context consumer hooks
- Hook name = `use` + context name (without `Type` suffix)

### 2.4 Context Naming with Suffix

**Impact: HIGH (makes context purpose clear and distinguishes from components)**

Name context types and files with `Context` suffix. Include the full component path for clarity.

**Incorrect (anti-pattern):**

```typescript
// AccordionCtx.ts
interface AccordionCtx { ... }
const AccordionCtx = React.createContext<AccordionCtx | undefined>(undefined)

// AccordionState.ts
interface AccordionState { ... }
const AccordionState = React.createContext<AccordionState | undefined>(undefined)
```

**Correct (recommended):**

```typescript
// AccordionRootContext.ts
interface AccordionRootContextType {
  value: string[]
  setValue: (value: string[]) => void
  disabled: boolean
}

const AccordionRootContext = React.createContext<AccordionRootContextType | undefined>(undefined)

// AccordionItemContext.ts
interface AccordionItemContextType {
  open: boolean
  setOpen: (open: boolean) => void
  triggerId: string
  panelId: string
}

const AccordionItemContext = React.createContext<AccordionItemContextType | undefined>(undefined)
```

**When to use:**
- All context definitions
- File name matches context name: `AccordionRootContext.ts`

### 2.5 Data Attribute Naming lowercase

**Impact: HIGH (provides consistent attribute names for CSS selectors and testing)**

Use lowercase data-* attributes derived from state keys. These attributes enable CSS-based styling without JavaScript.

**Incorrect (anti-pattern):**

```typescript
// Inconsistent naming
<button
  data-isOpen={open}
  data-accordion-disabled={disabled}
  data-EXPANDED={expanded}
/>
```

**Correct (recommended):**

```typescript
// Consistent lowercase naming
<button
  data-open={open || undefined}
  data-disabled={disabled || undefined}
  data-expanded={expanded || undefined}
/>

// Document in DataAttributes.ts
export enum AccordionItemDataAttributes {
  index = 'data-index',
  disabled = 'data-disabled',
  open = 'data-open',
}
```

**CSS usage:**

```css
[data-open] {
  /* styles when open */
}

[data-disabled] {
  opacity: 0.5;
  pointer-events: none;
}
```

**When to use:**
- All boolean state exposed to consumers
- Only render attribute when true (use `value || undefined`)

### 2.6 Directory Naming kebab-case

**Impact: HIGH (provides consistent filesystem organization that works across all operating systems)**

Use kebab-case for component directories containing multiple words.

**Incorrect (anti-pattern):**

```text
src/
  checkboxGroup/
  alertDialog/
  NavigationMenu/
  radioGroup/
```

**Correct (recommended):**

```text
src/
  checkbox-group/
  alert-dialog/
  navigation-menu/
  radio-group/
```

**When to use:**
- All multi-word component directories
- Consistent across the entire codebase
- Single-word directories remain lowercase: `accordion/`, `dialog/`, `tabs/`

### 2.7 Event Type Naming Convention

**Impact: MEDIUM (provides predictable event type names for TypeScript consumers)**

Name event types as `[Component]ChangeEventReason` and `[Component]ChangeEventDetails`.

**Incorrect (anti-pattern):**

```typescript
type DialogOpenReason = string
type DialogEvent = { reason: string }
type OpenChangeReason = 'click' | 'escape'
```

**Correct (recommended):**

```typescript
type DialogRootChangeEventReason =
  | typeof REASONS.triggerPress
  | typeof REASONS.escapeKey
  | typeof REASONS.outsidePress
  | typeof REASONS.focusOut

interface DialogRootChangeEventDetails {
  reason: DialogRootChangeEventReason
  cancel: () => void
  isCanceled: boolean
}

// Usage in props
interface DialogRootProps {
  onOpenChange?: (open: boolean, details: DialogRootChangeEventDetails) => void
}
```

**When to use:**
- Components with events that need to communicate why something changed
- Dialogs, popovers, menus that can close for multiple reasons

### 2.8 File Name Matches Primary Export

**Impact: HIGH (enables quick file discovery and consistent import paths)**

File name must exactly match the primary export name using PascalCase.

**Incorrect (anti-pattern):**

```typescript
// accordion-root.tsx
export const AccordionRoot = React.forwardRef(...)

// trigger.tsx
export const AccordionTrigger = React.forwardRef(...)

// index.tsx
export const Panel = React.forwardRef(...)
```

**Correct (recommended):**

```typescript
// AccordionRoot.tsx
export const AccordionRoot = React.forwardRef(...)

// AccordionTrigger.tsx
export const AccordionTrigger = React.forwardRef(...)

// AccordionPanel.tsx
export const AccordionPanel = React.forwardRef(...)
```

**When to use:**
- All component files
- All hook files (useButton.ts exports useButton)
- Makes imports predictable: `import { AccordionRoot } from './AccordionRoot'`

### 2.9 Handler Naming Convention

**Impact: MEDIUM (clearly distinguishes internal handlers from callback props)**

Name event handlers with `handle` prefix for internal handlers and `on` prefix for callback props.

**Incorrect (anti-pattern):**

```typescript
interface Props {
  // Inconsistent naming
  clickHandler?: () => void
  triggerClick?: () => void
  handleValueChange?: (value: string[]) => void
}

function AccordionTrigger(props) {
  // Internal handler without prefix
  const clickTrigger = () => { ... }
  const toggle = () => { ... }
}
```

**Correct (recommended):**

```typescript
interface AccordionRootProps {
  // Callback props use "on" prefix
  onValueChange?: (value: string[], details: ChangeEventDetails) => void
  onOpenChange?: (open: boolean) => void
}

function AccordionTrigger(componentProps: AccordionTrigger.Props) {
  const { setOpen, open } = useAccordionItemContext()

  // Internal handlers use "handle" prefix
  const handleClick = React.useCallback(() => {
    setOpen(!open)
  }, [setOpen, open])

  const handleKeyDown = React.useCallback((event: React.KeyboardEvent) => {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault()
      setOpen(!open)
    }
  }, [setOpen, open])

  return useRenderElement('button', componentProps, {
    props: [{
      onClick: handleClick,
      onKeyDown: handleKeyDown,
    }],
  })
}
```

**When to use:**
- `handle*` for functions defined inside components
- `on*` for props that accept callbacks

### 2.10 Hook Naming with use Prefix

**Impact: HIGH (follows React convention and enables lint rule enforcement)**

Name hooks with `use` prefix in camelCase. This follows React conventions and enables the Rules of Hooks lint plugin.

**Incorrect (anti-pattern):**

```typescript
function UseButton(params) { ... }
function buttonHook(params) { ... }
function getButtonProps(params) { ... }
function createButton(params) { ... }
```

**Correct (recommended):**

```typescript
function useButton(params: useButton.Parameters): useButton.ReturnValue {
  // ...
}

function useAccordionItem(params: useAccordionItem.Parameters): useAccordionItem.ReturnValue {
  // ...
}

function useControlled<T>(params: UseControlledParameters<T>): [T, (value: T) => void] {
  // ...
}

function useRenderElement(
  tag: keyof JSX.IntrinsicElements,
  props: object,
  options: UseRenderElementOptions
): React.ReactElement {
  // ...
}
```

**When to use:**
- All functions that use React hooks internally
- Functions following the composition pattern that return props objects

### 2.11 Namespace Type Exports

**Impact: CRITICAL (provides clean API surface with Component.Props and Component.State patterns)**

Use TypeScript namespaces to export State, Props, and event types from components. This enables the `Component.Props` and `Component.State` access pattern.

**Incorrect (separate exports):**

```typescript
export interface AccordionRootProps { ... }
export interface AccordionRootState { ... }
export type { AccordionRootProps as Props }

// Usage requires knowing internal names
import type { AccordionRootProps } from './AccordionRoot'
```

**Correct (namespace exports):**

```typescript
interface AccordionRootProps { ... }
interface AccordionRootState { ... }

export const AccordionRoot = React.forwardRef(function AccordionRoot(...) { ... })

export namespace AccordionRoot {
  export type Props = AccordionRootProps
  export type State = AccordionRootState
}

// Clean usage pattern
import { AccordionRoot } from './AccordionRoot'

function MyComponent(props: AccordionRoot.Props) {
  const renderTrigger = (state: AccordionTrigger.State) => (
    <button data-open={state.open}>Toggle</button>
  )
}
```

**When to use:**
- All exported components
- Enables IDE autocomplete for `Component.` types

### 2.12 Part Directory Naming lowercase

**Impact: MEDIUM (distinguishes part directories from component directories at a glance)**

Use lowercase single words for component part directories within a compound component.

**Incorrect (anti-pattern):**

```text
accordion/
  Root/
    AccordionRoot.tsx
  trigger-button/
    AccordionTrigger.tsx
  PanelContent/
    AccordionPanel.tsx
```

**Correct (recommended):**

```text
accordion/
  root/
    AccordionRoot.tsx
    AccordionRootContext.ts
  trigger/
    AccordionTrigger.tsx
  panel/
    AccordionPanel.tsx
  item/
    AccordionItem.tsx
```

**When to use:**
- All part directories within a compound component
- Keeps filesystem simple and scannable
- Part names should be single words when possible

### 2.13 Props Interface as ComponentProps

**Impact: HIGH (enables consistent type import patterns across all components)**

Name props interfaces as `[Component]Props` with the full component name.

**Incorrect (anti-pattern):**

```typescript
interface Props {
  disabled?: boolean
}

interface AccordionRootOptions {
  value?: string[]
}

interface RootProps {
  children: React.ReactNode
}
```

**Correct (recommended):**

```typescript
interface AccordionRootProps {
  children?: React.ReactNode
  value?: string[] | undefined
  defaultValue?: string[] | undefined
  onValueChange?: (value: string[]) => void
  disabled?: boolean | undefined
}

interface AccordionTriggerProps extends BaseUIComponentProps<'button', AccordionTrigger.State> {
  // Additional trigger-specific props
}

interface AccordionPanelProps extends BaseUIComponentProps<'div', AccordionPanel.State> {
  // Additional panel-specific props
}
```

**When to use:**
- All component prop type definitions
- Export via namespace: `export namespace AccordionRoot { export type Props = AccordionRootProps }`

### 2.14 Ref Variable Naming with Suffix

**Impact: MEDIUM (makes ref usage clear and distinguishes from regular values)**

Name ref variables with `Ref` suffix to make their purpose clear and distinguish them from regular values.

**Incorrect (anti-pattern):**

```typescript
const accordion = useRef<HTMLDivElement>(null)
const items = useRef(new Map())
const trigger = useRef<HTMLButtonElement>(null)
const previous = useRef(value)
```

**Correct (recommended):**

```typescript
const accordionRef = useRef<HTMLDivElement>(null)
const accordionItemRefs = useRef(new Map<string, HTMLDivElement>())
const triggerRef = useRef<HTMLButtonElement>(null)
const previousValueRef = useRef(value)

// Forwarded refs use forwardedRef
export const Button = React.forwardRef(function Button(
  componentProps: Button.Props,
  forwardedRef: React.ForwardedRef<HTMLButtonElement>
) {
  // ...
})
```

**When to use:**
- All useRef declarations
- Forwarded ref parameters
- Makes code scanning easier for ref-related bugs

### 2.15 State Interface as ComponentState

**Impact: HIGH (enables consistent state type access for render props and styling)**

Name state interfaces as `[Component]State` with the full component name.

**Incorrect (anti-pattern):**

```typescript
interface AccordionRootData {
  expanded: boolean
}

interface RootState {
  value: string[]
}

interface State {
  open: boolean
  disabled: boolean
}
```

**Correct (recommended):**

```typescript
interface AccordionTriggerState {
  open: boolean
  disabled: boolean
}

interface AccordionPanelState {
  open: boolean
  hidden: boolean
}

// Usage in component
const state: AccordionTrigger.State = React.useMemo(
  () => ({ open, disabled }),
  [open, disabled]
)
```

**When to use:**
- All component state type definitions
- State is exposed via render props and data-* attributes
- Export via namespace: `export namespace AccordionTrigger { export type State = AccordionTriggerState }`

---

## 3. Organization

**Impact: HIGH**

File and folder structure patterns for compound components, barrel exports, test placement, and documentation files that scale with library complexity.

### 3.1 Component Directory Structure

**Impact: CRITICAL (enables scalable compound component organization with clear part boundaries)**

Organize compound components with a top-level directory containing sub-directories for each part (root, trigger, panel, etc.).

**Incorrect (flat structure):**

```text
accordion/
  AccordionRoot.tsx
  AccordionTrigger.tsx
  AccordionPanel.tsx
  AccordionItem.tsx
  AccordionRootContext.ts
  AccordionItemContext.ts
  index.ts
```

**Correct (nested structure):**

```text
accordion/
  root/
    AccordionRoot.tsx
    AccordionRootContext.ts
  item/
    AccordionItem.tsx
    AccordionItemContext.ts
  trigger/
    AccordionTrigger.tsx
    stateAttributesMapping.ts
  panel/
    AccordionPanel.tsx
    AccordionPanelCssVars.ts
  header/
    AccordionHeader.tsx
  index.ts
  index.parts.ts
  DataAttributes.ts
```

**When to use:**
- All compound components with multiple parts
- Each part with its own logic, context, or styling concerns
- Keeps related files co-located

### 3.2 Context File Placement

**Impact: MEDIUM (keeps context definitions close to providing components)**

Place context files in the same directory as the component that provides them.

**Incorrect (centralized contexts):**

```text
contexts/
  AccordionRootContext.ts
  AccordionItemContext.ts
  DialogContext.ts
accordion/
  AccordionRoot.tsx
  AccordionItem.tsx
```

**Correct (co-located contexts):**

```text
accordion/
  root/
    AccordionRoot.tsx
    AccordionRootContext.ts
  item/
    AccordionItem.tsx
    AccordionItemContext.ts
```

**When to use:**
- All component contexts
- Context and provider are tightly coupled, should live together
- Makes it clear which component owns the context

### 3.3 CSS Variables Documentation File

**Impact: LOW (documents CSS custom properties for consumer styling)**

Create dedicated `CssVars.ts` files to document CSS custom properties exposed by components.

**Incorrect (undocumented CSS vars):**

```typescript
// CSS vars set in component with no documentation
element.style.setProperty('--collapsible-panel-height', `${height}px`)
```

**Correct (dedicated documentation):**

```typescript
// collapsible/panel/CollapsiblePanelCssVars.ts
export enum CollapsiblePanelCssVars {
  /**
   * The height of the panel's content.
   * Useful for CSS transitions on height.
   * @type {string}
   */
  height = '--collapsible-panel-height',

  /**
   * The width of the panel's content.
   * @type {string}
   */
  width = '--collapsible-panel-width',
}

// Usage in CSS:
// .panel {
//   height: var(--collapsible-panel-height);
//   transition: height 200ms ease;
// }
```

**When to use:**
- Components that expose CSS custom properties for animation/styling
- Collapsible panels, progress bars, sliders

### 3.4 Data Attributes Documentation File

**Impact: MEDIUM (provides single source of truth for data attribute names)**

Create dedicated `DataAttributes.ts` files with enums documenting each `data-*` attribute a component exposes.

**Incorrect (inline documentation):**

```typescript
// Scattered across component files
// AccordionTrigger.tsx
<button data-open={open} data-disabled={disabled} />

// No central documentation of what attributes exist
```

**Correct (dedicated file):**

```typescript
// accordion/DataAttributes.ts
export enum AccordionRootDataAttributes {
  /**
   * Present when the accordion is disabled.
   */
  disabled = 'data-disabled',
}

export enum AccordionItemDataAttributes {
  /**
   * The index of the item in the accordion.
   */
  index = 'data-index',
  /**
   * Present when the item is disabled.
   */
  disabled = 'data-disabled',
  /**
   * Present when the item is expanded/open.
   */
  open = 'data-open',
}

export enum AccordionTriggerDataAttributes {
  /**
   * Present when the panel controlled by this trigger is open.
   */
  open = 'data-open',
  /**
   * Present when the trigger is disabled.
   */
  disabled = 'data-disabled',
}
```

**When to use:**
- All compound components with data attributes
- Serves as documentation for consumers
- Enables type-safe attribute references

### 3.5 Dual Barrel Export Pattern

**Impact: HIGH (enables both namespaced and direct import patterns for flexibility)**

Create `index.ts` for type exports and `index.parts.ts` for component exports with short aliases. This enables both `Accordion.Root` and direct `AccordionRoot` imports.

**Incorrect (single index file):**

```typescript
// index.ts - mixed exports
export { AccordionRoot } from './root/AccordionRoot'
export { AccordionTrigger } from './trigger/AccordionTrigger'
export type { AccordionRootProps } from './root/AccordionRoot'
```

**Correct (dual export files):**

```typescript
// index.ts - full component exports and types
export { AccordionRoot } from './root/AccordionRoot'
export { AccordionItem } from './item/AccordionItem'
export { AccordionTrigger } from './trigger/AccordionTrigger'
export { AccordionPanel } from './panel/AccordionPanel'
export { AccordionHeader } from './header/AccordionHeader'

// index.parts.ts - short aliases for namespaced usage
export { AccordionRoot as Root } from './root/AccordionRoot'
export { AccordionItem as Item } from './item/AccordionItem'
export { AccordionTrigger as Trigger } from './trigger/AccordionTrigger'
export { AccordionPanel as Panel } from './panel/AccordionPanel'
export { AccordionHeader as Header } from './header/AccordionHeader'
```

**Usage:**

```typescript
// Direct imports
import { AccordionRoot, AccordionTrigger } from '@base-ui/accordion'

// Namespaced imports
import * as Accordion from '@base-ui/accordion/index.parts'
<Accordion.Root>
  <Accordion.Trigger />
</Accordion.Root>
```

**When to use:**
- All compound components
- Allows consumers to choose their preferred import style

### 3.6 Package-Level Wildcard Exports

**Impact: HIGH (simplifies main entry point and ensures all components are exported)**

Main package `index.ts` should use wildcard exports for each component module rather than explicit named exports.

**Incorrect (explicit exports):**

```typescript
// src/index.ts
export { Accordion } from './accordion'
export { AccordionRoot, AccordionTrigger } from './accordion'
export { Dialog } from './dialog'
export { DialogRoot, DialogTrigger } from './dialog'
// Easy to forget exports when adding new components
```

**Correct (wildcard exports):**

```typescript
// src/index.ts
export * from './accordion'
export * from './alert-dialog'
export * from './checkbox'
export * from './collapsible'
export * from './dialog'
export * from './menu'
export * from './popover'
export * from './progress'
export * from './radio'
export * from './select'
export * from './separator'
export * from './slider'
export * from './switch'
export * from './tabs'
export * from './toast'
export * from './toggle'
export * from './toggle-group'
export * from './tooltip'
```

**When to use:**
- Main package entry point (src/index.ts)
- Ensures new exports from component modules are automatically available
- Reduces maintenance burden

### 3.7 State Attributes Mapping File

**Impact: MEDIUM (centralizes logic for converting state to data attributes)**

Create `stateAttributesMapping.ts` files to map component state to data attributes. These are used by `useRenderElement`.

**Incorrect (inline mapping):**

```typescript
function AccordionTrigger(props) {
  const { open, disabled } = useAccordionItemContext()

  return (
    <button
      data-open={open || undefined}
      data-disabled={disabled || undefined}
    />
  )
}
```

**Correct (mapping file):**

```typescript
// accordion/trigger/stateAttributesMapping.ts
import type { StateAttributesMapping } from '../../utils/types'
import type { AccordionTrigger } from './AccordionTrigger'

export const accordionTriggerStateAttributesMapping: StateAttributesMapping<AccordionTrigger.State> = {
  open: (state) => state.open || undefined,
  disabled: (state) => state.disabled || undefined,
}

// accordion/trigger/AccordionTrigger.tsx
import { accordionTriggerStateAttributesMapping } from './stateAttributesMapping'

function AccordionTrigger(componentProps: AccordionTrigger.Props) {
  const state = React.useMemo(() => ({ open, disabled }), [open, disabled])

  return useRenderElement('button', componentProps, {
    state,
    stateAttributesMapping: accordionTriggerStateAttributesMapping,
  })
}
```

**When to use:**
- Components using useRenderElement with state attributes
- Keeps mapping logic testable and reusable

### 3.8 Test File Colocation

**Impact: HIGH (makes tests easy to find and update alongside implementation changes)**

Place test files alongside source files with `.test.tsx` suffix for unit tests and `.spec.tsx` for type/integration tests.

**Incorrect (separate test directory):**

```text
src/
  accordion/
    AccordionRoot.tsx
    AccordionTrigger.tsx
__tests__/
  accordion/
    AccordionRoot.test.tsx
    AccordionTrigger.test.tsx
```

**Correct (co-located tests):**

```text
accordion/
  root/
    AccordionRoot.tsx
    AccordionRoot.test.tsx      # Unit tests
    AccordionRoot.spec.ts       # Type tests
    AccordionRootContext.ts
  trigger/
    AccordionTrigger.tsx
    AccordionTrigger.test.tsx
  Accordion.test.tsx            # Integration tests for full component
```

**When to use:**
- `.test.tsx` for component behavior tests
- `.spec.ts` for type definition tests
- Integration tests at component root level

---

## 4. Error Handling

**Impact: HIGH**

Development-only warnings, error message standards, cancelable events, and validation patterns that improve developer experience without impacting production bundles.

### 4.1 Cancelable Event Pattern

**Impact: CRITICAL (allows consumers to prevent default behavior based on custom logic)**

Event handlers should receive a details object with a `cancel()` method that prevents the default behavior. This allows consumers to conditionally prevent state changes.

**Incorrect (no cancellation):**

```typescript
interface DialogProps {
  onOpenChange?: (open: boolean) => void
}

function DialogRoot(props: DialogProps) {
  const handleClose = () => {
    // No way for consumer to prevent close
    setOpen(false)
    props.onOpenChange?.(false)
  }
}
```

**Correct (with cancelable details):**

```typescript
interface ChangeEventDetails {
  reason: string
  cancel: () => void
  isCanceled: boolean
}

function createChangeEventDetails(reason: string): ChangeEventDetails {
  let canceled = false
  return {
    reason,
    cancel: () => { canceled = true },
    get isCanceled() { return canceled },
  }
}

interface DialogRootProps {
  onOpenChange?: (open: boolean, details: ChangeEventDetails) => void
}

function DialogRoot(props: DialogRootProps) {
  const handleClose = (reason: string) => {
    const details = createChangeEventDetails(reason)
    props.onOpenChange?.(false, details)

    // Consumer can prevent close
    if (details.isCanceled) {
      return
    }

    setOpen(false)
  }
}

// Consumer usage
<Dialog.Root
  onOpenChange={(open, details) => {
    if (!open && hasUnsavedChanges) {
      details.cancel() // Prevent close
      showConfirmation()
    }
  }}
/>
```

**When to use:**
- All state change callbacks
- Especially for close/dismiss events in dialogs, modals, popovers

### 4.2 Context Error Guidance

**Impact: HIGH (helps developers fix component hierarchy issues quickly)**

Context errors must explain the required component hierarchy, not just state that the context is missing.

**Incorrect (anti-pattern):**

```typescript
function useAccordionRootContext() {
  const context = React.useContext(AccordionRootContext)
  if (!context) {
    throw new Error('Base UI: useAccordionRootContext must be used within a provider')
  }
  return context
}
```

**Correct (recommended):**

```typescript
function useAccordionRootContext(): AccordionRootContextType {
  const context = React.useContext(AccordionRootContext)
  if (context === undefined) {
    throw new Error(
      'Base UI: AccordionRootContext is missing. Accordion parts must be placed within <Accordion.Root>.'
    )
  }
  return context
}

function useDialogPopupContext(): DialogPopupContextType {
  const context = React.useContext(DialogPopupContext)
  if (context === undefined) {
    throw new Error(
      'Base UI: DialogPopupContext is missing. Dialog.Popup must be placed within <Dialog.Root>.'
    )
  }
  return context
}
```

**When to use:**
- All context consumer hooks
- Include: library prefix, which context is missing, which component to wrap with

### 4.3 Deduplicated Warning Messages

**Impact: HIGH (prevents console spam when the same warning triggers repeatedly)**

Use Set-based deduplication to prevent warning spam. The same warning should only appear once per session.

**Incorrect (repeated warnings):**

```typescript
function warn(message: string) {
  console.warn('Base UI: ' + message)
}

// Renders 100 items, logs 100 identical warnings
items.forEach(item => {
  if (item.invalid) {
    warn('Item is invalid')
  }
})
```

**Correct (deduplicated):**

```typescript
// utils/warn.ts
const printedWarnings = new Set<string>()

export function warn(...messages: string[]) {
  if (process.env.NODE_ENV === 'production') {
    return
  }

  const key = messages.join(' ')

  if (!printedWarnings.has(key)) {
    printedWarnings.add(key)
    console.warn('Base UI: ' + key)
  }
}

// Usage - only logs once regardless of how many invalid items
items.forEach(item => {
  if (item.invalid) {
    warn('Item is invalid. Ensure all items have valid IDs.')
  }
})
```

**When to use:**
- All warning utilities
- Warnings that could trigger in loops or rapid re-renders

### 4.4 Development-Only Warnings

**Impact: CRITICAL (ensures warnings don't affect production bundle size or performance)**

Wrap all console warnings and errors in `process.env.NODE_ENV !== 'production'` checks. This ensures warnings are tree-shaken in production builds.

**Incorrect (always runs):**

```typescript
function useControlled({ controlled, default: defaultValue, name, state }) {
  const isControlled = controlled !== undefined

  if (isControlledRef.current !== isControlled) {
    console.warn(
      `A component is changing from ${isControlled ? 'controlled' : 'uncontrolled'} to ${isControlled ? 'uncontrolled' : 'controlled'}.`
    )
  }
}
```

**Correct (development only):**

```typescript
import { warn } from '../utils/warn'

function useControlled({ controlled, default: defaultValue, name, state }) {
  const isControlled = controlled !== undefined

  if (process.env.NODE_ENV !== 'production') {
    if (isControlledRef.current !== isControlled) {
      warn(
        `A component is changing from ${isControlled ? 'controlled' : 'uncontrolled'} to ${isControlled ? 'uncontrolled' : 'controlled'}.`,
        `This is likely caused by the value changing from undefined to a defined value, which should not happen.`,
        `Decide between using a controlled or uncontrolled ${name} element for the lifetime of the component.`
      )
    }
  }
}
```

**When to use:**
- All console.warn and console.error calls
- Validation messages
- Development-only debugging

### 4.5 Event Reason Constants

**Impact: HIGH (provides type-safe event reasons for analytics and conditional handling)**

Use typed `REASONS` constants for event reasons, not string literals. This enables type-safe reason checking and autocomplete.

**Incorrect (string literals):**

```typescript
function handleClose() {
  onOpenChange?.(false, { reason: 'escape-key' })
}

// Consumer has to guess valid strings
onOpenChange={(open, details) => {
  if (details.reason === 'escapeKey') { // typo, wrong format
    // ...
  }
}}
```

**Correct (typed constants):**

```typescript
// dialog/root/constants.ts
export const REASONS = {
  triggerPress: 'trigger-press',
  escapeKey: 'escape-key',
  outsidePress: 'outside-press',
  focusOut: 'focus-out',
} as const

export type DialogCloseReason = typeof REASONS[keyof typeof REASONS]

// In component
import { REASONS } from './constants'

function handleEscapeKey() {
  const details = createChangeEventDetails(REASONS.escapeKey)
  onOpenChange?.(false, details)
}

// Consumer with type safety
onOpenChange={(open, details) => {
  if (details.reason === REASONS.escapeKey) {
    // TypeScript ensures this is valid
  }
}}
```

**When to use:**
- All event callbacks with reason parameters
- Enables consistent tracking and conditional logic

### 4.6 Message Prefix Standard

**Impact: HIGH (makes it easy to identify which library produced an error)**

All user-facing error messages and warnings must be prefixed with the library name (e.g., "Base UI:").

**Incorrect (anti-pattern):**

```typescript
throw new Error('Context missing')

console.warn('Invalid prop combination')

throw new Error('useAccordionContext must be used within AccordionRoot')
```

**Correct (recommended):**

```typescript
throw new Error('Base UI: AccordionRootContext is missing. Accordion parts must be placed within <Accordion.Root>.')

warn('Base UI: Invalid prop combination - disabled and loading cannot both be true.')

throw new Error('Base UI: useTooltip must be used within <Tooltip.Provider>.')
```

**When to use:**
- All thrown errors
- All console warnings
- Any user-facing messages
- Helps developers quickly identify the source of issues

### 4.7 Prop Validation Timing

**Impact: MEDIUM (catches issues early without blocking initial render)**

Run prop validation in `useIsoLayoutEffect` to catch issues early without blocking the initial render.

**Incorrect (in render body):**

```typescript
function Accordion(props) {
  const { value, defaultValue, disabled } = props

  // Blocks render
  if (value !== undefined && defaultValue !== undefined) {
    warn('Accordion: Providing both value and defaultValue is not supported.')
  }

  return ...
}
```

**Correct (in effect):**

```typescript
import { useIsoLayoutEffect } from '../utils/useIsoLayoutEffect'

function Accordion(props: Accordion.Props) {
  const { value, defaultValue, disabled } = props

  useIsoLayoutEffect(() => {
    if (process.env.NODE_ENV !== 'production') {
      if (value !== undefined && defaultValue !== undefined) {
        warn(
          'Accordion: Providing both value and defaultValue is not supported.',
          'Use value for controlled or defaultValue for uncontrolled, but not both.'
        )
      }
    }
  }, [value, defaultValue])

  return ...
}
```

**useIsoLayoutEffect:**

```typescript
// Works in both SSR and browser environments
export const useIsoLayoutEffect =
  typeof window !== 'undefined' ? React.useLayoutEffect : React.useEffect
```

**When to use:**
- Prop combination validation
- Runtime checks that don't affect render output
- Keeps React strict mode happy

### 4.8 Type-Safe Event Reasons

**Impact: MEDIUM (enables TypeScript to catch invalid reason checks at compile time)**

Define typed union of possible reasons for each component's events. This allows TypeScript to catch invalid reason checks.

**Incorrect (loose string type):**

```typescript
interface DialogChangeEventDetails {
  reason: string // Any string allowed
  cancel: () => void
}

// TypeScript can't catch typos
if (details.reason === 'esacpe-key') { // typo not caught
  // ...
}
```

**Correct (typed union):**

```typescript
const REASONS = {
  triggerPress: 'trigger-press',
  escapeKey: 'escape-key',
  outsidePress: 'outside-press',
  focusOut: 'focus-out',
} as const

type DialogRootChangeEventReason =
  | typeof REASONS.triggerPress
  | typeof REASONS.escapeKey
  | typeof REASONS.outsidePress
  | typeof REASONS.focusOut

interface DialogRootChangeEventDetails {
  reason: DialogRootChangeEventReason
  cancel: () => void
  isCanceled: boolean
}

// TypeScript catches invalid comparisons
if (details.reason === 'esacpe-key') {
  // Error: This comparison appears to be unintentional because...
}

// Exhaustive switch pattern
switch (details.reason) {
  case REASONS.escapeKey:
    // handle escape
    break
  case REASONS.outsidePress:
    // handle outside click
    break
  // TypeScript ensures all cases handled
}
```

**When to use:**
- All event detail interfaces
- Export reason types for consumer use

---

## 5. Style

**Impact: MEDIUM**

Code style conventions for imports, prop type definitions, default values, and documentation that maintain consistency across the codebase.

### 5.1 Default Values in Destructuring

**Impact: MEDIUM (keeps default values close to usage and visible in one place)**

Provide default values in destructuring, not in prop types or separate statements.

**Incorrect (defaults elsewhere):**

```typescript
interface ButtonProps {
  disabled: boolean  // default in component
  type: 'button' | 'submit' | 'reset'  // default in component
}

function Button(componentProps: ButtonProps) {
  const { disabled, type, ...rest } = componentProps
  const actualDisabled = disabled ?? false
  const actualType = type ?? 'button'
}
```

**Correct (defaults in destructuring):**

```typescript
interface ButtonProps {
  disabled?: boolean | undefined
  type?: 'button' | 'submit' | 'reset' | undefined
}

function Button(componentProps: ButtonProps) {
  const {
    render,
    className,
    disabled = false,
    type = 'button',
    ...elementProps
  } = componentProps

  // disabled and type are guaranteed to have values
}
```

**When to use:**
- All optional props with sensible defaults
- Keeps default values visible at the component's entry point
- Makes prop documentation accurate (optional means truly optional)

### 5.2 Explicit Undefined in Prop Types

**Impact: MEDIUM (makes optional prop handling explicit and improves type inference)**

Include `| undefined` in optional prop types for clarity. This makes it explicit that the prop can be omitted.

**Incorrect (anti-pattern):**

```typescript
interface ButtonProps {
  disabled?: boolean
  type?: 'button' | 'submit' | 'reset'
  onClick?: () => void
}
```

**Correct (recommended):**

```typescript
interface ButtonProps {
  disabled?: boolean | undefined
  type?: 'button' | 'submit' | 'reset' | undefined
  onClick?: (() => void) | undefined
}

interface AccordionRootProps {
  value?: string[] | undefined
  defaultValue?: string[] | undefined
  onValueChange?: ((value: string[]) => void) | undefined
  disabled?: boolean | undefined
  children?: React.ReactNode
}
```

**When to use:**
- All optional props in interface definitions
- Makes `exactOptionalPropertyTypes` TypeScript config work correctly

### 5.3 Internal Import Paths

**Impact: MEDIUM (creates clear dependency boundaries between packages)**

Use package imports (e.g., `@base-ui/utils`) for shared utilities. Use relative paths only for files within the same component.

**Incorrect (anti-pattern):**

```typescript
// Deep relative imports crossing package boundaries
import { useControlled } from '../../../../utils/useControlled'
import { warn } from '../../../../../../packages/utils/src/warn'
import { mergeProps } from '../../../shared/mergeProps'
```

**Correct (recommended):**

```typescript
// Package imports for cross-package dependencies
import { useControlled } from '@base-ui/utils/useControlled'
import { warn } from '@base-ui/utils/warn'
import { mergeProps } from '@base-ui/utils/mergeProps'

// Relative imports for same-component files
import { useAccordionRootContext } from '../root/AccordionRootContext'
import { accordionTriggerStateAttributesMapping } from './stateAttributesMapping'
```

**When to use:**
- Always use package imports for utilities and shared code
- Relative imports only within the same component directory tree
- Makes refactoring easier by keeping imports stable

### 5.4 JSDoc Documentation

**Impact: LOW (improves IDE experience and documentation generation)**

Add JSDoc comments for component descriptions linking to documentation. Keep comments focused and avoid redundant information.

**Incorrect (verbose or missing):**

```typescript
// Button component
export const Button = React.forwardRef(...)

/**
 * This is a button that can be clicked.
 * It renders a button element.
 * You can pass disabled prop.
 * It supports className.
 */
export const Button = React.forwardRef(...)
```

**Correct (recommended):**

```typescript
/**
 * A button component that can be used to trigger actions.
 * Renders a `<button>` element.
 *
 * Documentation: [Base UI Button](https://base-ui.com/react/components/button)
 */
export const Button = React.forwardRef(function Button(
  componentProps: Button.Props,
  forwardedRef: React.ForwardedRef<HTMLButtonElement>
) {
  // ...
})

/**
 * The root component for an accordion.
 * Manages expansion state for accordion items.
 * Does not render a DOM element.
 *
 * Documentation: [Base UI Accordion](https://base-ui.com/react/components/accordion)
 */
export function AccordionRoot(props: AccordionRoot.Props) {
  // ...
}
```

**When to use:**
- All exported components
- State what element it renders (or if it doesn't render one)
- Link to documentation when available

### 5.5 React Import as Namespace

**Impact: HIGH (enables consistent React.* usage and better tree-shaking)**

Import React as namespace (`import * as React from 'react'`) rather than default import with destructuring.

**Incorrect (anti-pattern):**

```typescript
import React, { useState, useEffect, useCallback, forwardRef } from 'react'

const Button = forwardRef((props, ref) => {
  const [pressed, setPressed] = useState(false)
  useEffect(() => { ... }, [])
  const handleClick = useCallback(() => { ... }, [])
})
```

**Correct (recommended):**

```typescript
import * as React from 'react'

const Button = React.forwardRef(function Button(
  componentProps: Button.Props,
  forwardedRef: React.ForwardedRef<HTMLButtonElement>
) {
  const [pressed, setPressed] = React.useState(false)
  React.useEffect(() => { ... }, [])
  const handleClick = React.useCallback(() => { ... }, [])
})
```

**When to use:**
- All React component and hook files
- Provides consistent `React.` prefix throughout codebase
- Makes it clear which APIs are from React vs local

---

## References

1. [[object Object]]([object Object])
2. [[object Object]]([object Object])

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |