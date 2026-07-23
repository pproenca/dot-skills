---
name: react-hook-form
description: React Hook Form performance optimization for client-side form validation using useForm, useWatch, useController, useFieldArray, the subscribe() API, and the Watch / FormStateSubscribe / FieldArray render-prop components. Covers RHF 7.82 additions including resetDefaultValues() and the disabled field-array option. This skill should be used when building client-side controlled forms with React Hook Form library. This skill does NOT cover React 19 Server Actions, useActionState, or server-side form handling (use react-19 skill for those).
---

# React Hook Form Best Practices by Community

Comprehensive performance optimization guide for React Hook Form applications. Contains 35 rules across 7 categories, each naming a decision that goes wrong by default. Verified against react-hook-form **7.82.0**.

## When to Apply

Reference these guidelines when:
- Writing new forms with React Hook Form
- Configuring useForm options (mode, defaultValues, validation)
- Subscribing to form values with watch / useWatch / subscribe
- Integrating controlled UI components (MUI, shadcn, Ant Design)
- Managing dynamic field arrays with useFieldArray
- Handling async submit, server errors, and submit lifecycle state
- Reviewing forms for performance issues

## When NOT to Use This Skill

- **React 19 Server Actions / `useActionState`** — use the `react-19` skill instead
- **Deeply nested, fully type-safe forms** — TanStack Form may be a better fit for forms with complex nested schemas; this skill assumes you've already chosen RHF
- **Single-input or trivial forms** — uncontrolled `<form>` + `FormData` is often simpler than pulling in any library

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Form Configuration | CRITICAL | `formcfg-` |
| 2 | Field Subscription | CRITICAL | `sub-` |
| 3 | Controlled Components | HIGH | `ctrl-` |
| 4 | Validation Patterns | HIGH | `valid-` |
| 5 | State Management | MEDIUM-HIGH | `formstate-` |
| 6 | Field Arrays | MEDIUM-HIGH | `array-` |
| 7 | Integration Patterns | MEDIUM | `integ-` |

## Quick Reference

### 1. Form Configuration (CRITICAL)

- `formcfg-default-values` - Always Provide defaultValues for Form Initialization
- `formcfg-useeffect-dependency` - Depend on formState Slices, Not on formState Itself
- `formcfg-validation-mode` - Justify Any mode Other Than the Default onSubmit
- `formcfg-revalidate-mode` - Keep Default reValidateMode Unless Validation Is Expensive
- `formcfg-should-unregister` - Keep shouldUnregister Off Unless Hidden Fields Must Leave the Payload
- `formcfg-transformed-values-generic` - Pass the Third useForm Generic When the Resolver Transforms Values
- `formcfg-async-default-values` - Use Async defaultValues for Server Data
- `formcfg-disabled-prop` - Use the HTML disabled Attribute for Visual Disabling, Not register's disabled Option
- `formcfg-values-prop` - Use the values Prop to Keep a Form in Sync with Server Data

### 2. Field Subscription (CRITICAL)

- `sub-avoid-watch-in-render` - Avoid Calling watch() in Render for One-Time Reads
- `sub-memo-cannot-beat-context` - React.memo Cannot Stop Context-Driven Re-renders Under FormProvider
- `sub-subscribe-outside-react` - Use subscribe() to React to Form Changes Outside the React Lifecycle
- `sub-render-prop-components` - Use the Render-Prop Components to Isolate Re-renders Without a Child Component
- `sub-useformcontext-sparingly` - Use useFormContext Sparingly for Deep Nesting
- `sub-usewatch-over-watch` - Use useWatch Instead of watch for Isolated Re-renders
- `sub-watch-specific-fields` - Watch Specific Fields Instead of Entire Form

### 3. Controlled Components (HIGH)

- `ctrl-usecontroller-isolation` - Isolate Controlled Inputs in Dedicated Child Components
- `ctrl-controller-field-props` - Wire Controller Field Props Correctly for UI Libraries

### 4. Validation Patterns (HIGH)

- `valid-resolver-caching` - Build the Validation Schema Once, Outside the Render Path
- `valid-valueasnumber-empty-nan` - Handle the NaN valueAsNumber Produces for an Empty Input
- `valid-server-errors` - Surface Server Errors via setError('root.serverError', ...)
- `valid-delay-error` - Use delayError to Debounce Rapid Error Display

### 5. State Management (MEDIUM-HIGH)

- `formstate-avoid-isvalid-with-onsubmit` - Avoid isValid with onSubmit Mode for Button State
- `formstate-destructure-formstate` - Read Every formState Property You Depend On During Render
- `formstate-reset-default-values` - Rebase Defaults with resetDefaultValues After a Successful Save
- `formstate-handlesubmit-oninvalid` - Use handleSubmit's Second Argument to Handle a Rejected Submit
- `formstate-useformstate-isolation` - Use useFormState for Isolated State Subscriptions
- `formstate-async-submit-lifecycle` - Wrap Async Submit Handlers in try/catch and Reset on isSubmitSuccessful

### 6. Field Arrays (MEDIUM-HIGH)

- `array-separate-crud-operations` - Separate Sequential Field Array Operations
- `array-use-field-id-as-key` - Use field.id as Key in useFieldArray Maps
- `array-unique-fieldarray-per-name` - Use Single useFieldArray Instance Per Field Name
- `array-disabled-silently-noops` - useFieldArray's disabled Option Makes Every Mutation a Silent No-op

### 7. Integration Patterns (MEDIUM)

- `integ-value-transform` - Transform Values at Controller Level for Type Coercion
- `integ-shadcn-form-import` - Verify shadcn Form Component Import Source
- `integ-shadcn-select-wiring` - Wire shadcn Select with onValueChange Instead of Spread

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules
- Reference files: `references/{prefix}-{slug}.md`

## Related Skills

- For schema validation with Zod resolver, see `zod` skill
- For React 19 server actions, see `react-19` skill
- For UI/UX form design, see `frontend-design` skill

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
