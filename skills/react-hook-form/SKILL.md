---
name: react-hook-form-best-practices
description: React Hook Form performance optimization guidelines. This skill should be used when writing, reviewing, or refactoring React Hook Form code to ensure optimal performance patterns. Triggers on tasks involving form validation, useForm, useWatch, useController, useFieldArray, FormProvider, Zod resolver, or controlled component integration.
---

# React Hook Form Best Practices

Comprehensive performance optimization guide for React Hook Form applications. Contains 41 rules across 8 categories, prioritized by impact to guide form development, automated refactoring, and code generation.

## When to Apply

Reference these guidelines when:
- Writing new forms with React Hook Form
- Configuring useForm options (mode, defaultValues, validation)
- Subscribing to form values with watch/useWatch
- Integrating controlled UI components (MUI, shadcn, Ant Design)
- Managing dynamic field arrays with useFieldArray
- Reviewing forms for performance issues

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Form Configuration | CRITICAL | `config-` |
| 2 | Field Subscription | CRITICAL | `sub-` |
| 3 | Controlled Components | HIGH | `ctrl-` |
| 4 | Validation Patterns | HIGH | `valid-` |
| 5 | Field Arrays | MEDIUM-HIGH | `array-` |
| 6 | State Management | MEDIUM | `state-` |
| 7 | Integration Patterns | MEDIUM | `integ-` |
| 8 | Advanced Patterns | LOW | `adv-` |

## Quick Reference

### 1. Form Configuration (CRITICAL)

- `config-validation-mode` - Use onSubmit mode for optimal performance
- `config-revalidate-mode` - Set reValidateMode to onBlur for post-submit performance
- `config-default-values` - Always provide defaultValues for form initialization
- `config-async-default-values` - Use async defaultValues for server data
- `config-should-unregister` - Enable shouldUnregister for dynamic form memory efficiency
- `config-useeffect-dependency` - Avoid useForm return object in useEffect dependencies

### 2. Field Subscription (CRITICAL)

- `sub-usewatch-over-watch` - Use useWatch instead of watch for isolated re-renders
- `sub-watch-specific-fields` - Watch specific fields instead of entire form
- `sub-usewatch-with-getvalues` - Combine useWatch with getValues for timing safety
- `sub-deep-subscription` - Subscribe deep in component tree where data is needed
- `sub-avoid-watch-in-render` - Avoid calling watch() in render for one-time reads
- `sub-usewatch-default-value` - Provide defaultValue to useWatch for initial render
- `sub-useformcontext-sparingly` - Use useFormContext sparingly for deep nesting

### 3. Controlled Components (HIGH)

- `ctrl-usecontroller-isolation` - Use useController for re-render isolation
- `ctrl-avoid-double-registration` - Avoid double registration with useController
- `ctrl-controller-field-props` - Wire Controller field props correctly for UI libraries
- `ctrl-single-usecontroller-per-component` - Use single useController per component
- `ctrl-local-state-combination` - Combine local state with useController for UI-only state

### 4. Validation Patterns (HIGH)

- `valid-resolver-caching` - Define schema outside component for resolver caching
- `valid-dynamic-schema-factory` - Use schema factory for dynamic validation
- `valid-error-message-strategy` - Access errors via optional chaining or lodash get
- `valid-inline-vs-resolver` - Prefer resolver over inline validation for complex rules
- `valid-delay-error` - Use delayError to debounce rapid error display
- `valid-native-validation` - Consider native validation for simple forms

### 5. Field Arrays (MEDIUM-HIGH)

- `array-use-field-id-as-key` - Use field.id as key in useFieldArray maps
- `array-complete-default-objects` - Provide complete default objects for field array operations
- `array-separate-crud-operations` - Separate sequential field array operations
- `array-unique-fieldarray-per-name` - Use single useFieldArray instance per field name
- `array-virtualization-formprovider` - Use FormProvider for virtualized field arrays

### 6. State Management (MEDIUM)

- `state-destructure-formstate` - Destructure formState properties before render
- `state-useformstate-isolation` - Use useFormState for isolated state subscriptions
- `state-getfieldstate-for-single-field` - Use getFieldState for single field state access
- `state-subscribe-to-specific-fields` - Subscribe to specific field names in useFormState
- `state-avoid-isvalid-with-onsubmit` - Avoid isValid with onSubmit mode for button state

### 7. Integration Patterns (MEDIUM)

- `integ-shadcn-form-import` - Verify shadcn Form component import source
- `integ-shadcn-select-wiring` - Wire shadcn Select with onValueChange instead of spread
- `integ-mui-controller-pattern` - Use Controller for Material-UI components
- `integ-value-transform` - Transform values at Controller level for type coercion

### 8. Advanced Patterns (LOW)

- `adv-formprovider-memo` - Wrap FormProvider children with React.memo
- `adv-devtools-performance` - Disable DevTools in production and during performance testing
- `adv-testing-wrapper` - Create test wrapper with QueryClient and AuthProvider

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/config-validation-mode.md
rules/sub-usewatch-over-watch.md
rules/_sections.md
```

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
