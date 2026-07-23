# React Hook Form

**Version 2.1.0**  
Community  
July 2026

> **Note:** This document targets React Hook Form codebases.
> It is mainly for agents and LLMs to follow when maintaining, generating, or refactoring forms.
> Humans may also find it useful, but guidance here is optimized for automation and consistency
> by AI-assisted workflows.

---

## Abstract

Focused guide to the React Hook Form decisions a capable model gets wrong. Contains 35 rules across 7 categories, verified against react-hook-form 7.82.0 by diffing the shipped type definitions and type-checking every code block under tsc --strict against the real package types. Covers where a subscription must live to isolate re-renders, the third useForm generic that transforming resolvers require, the options that silently drop data from the submitted payload (register disabled, shouldUnregister, useFieldArray disabled), the NaN that valueAsNumber produces for an empty input, server error handling via setError('root.*'), resetDefaultValues() for rebasing the dirty baseline after a save, and the Watch / FormStateSubscribe / FieldArray render-prop components. Rules that merely restate what the library already does correctly have been removed.

---

## Table of Contents

1. [Form Configuration](references/_sections.md#1-form-configuration) — **CRITICAL**
   - 1.1 [Always Provide defaultValues for Form Initialization](references/formcfg-default-values.md) — CRITICAL (prevents uncontrolled-to-controlled input warnings and a reset() with nothing to restore)
   - 1.2 [Depend on formState Slices, Not on formState Itself](references/formcfg-useeffect-dependency.md) — HIGH (prevents effects that re-run on every keystroke)
   - 1.3 [Justify Any mode Other Than the Default onSubmit](references/formcfg-validation-mode.md) — CRITICAL (prevents a full validation pass and re-render on every keystroke)
   - 1.4 [Keep Default reValidateMode Unless Validation Is Expensive](references/formcfg-revalidate-mode.md) — MEDIUM (maintains immediate corrective feedback after first submit)
   - 1.5 [Keep shouldUnregister Off Unless Hidden Fields Must Leave the Payload](references/formcfg-should-unregister.md) — HIGH (prevents silently dropping values the user already entered)
   - 1.6 [Pass the Third useForm Generic When the Resolver Transforms Values](references/formcfg-transformed-values-generic.md) — CRITICAL (makes handleSubmit receive the schema's output type instead of its input type)
   - 1.7 [Use Async defaultValues for Server Data](references/formcfg-async-default-values.md) — CRITICAL (eliminates manual useEffect reset patterns)
   - 1.8 [Use the HTML disabled Attribute for Visual Disabling, Not register's disabled Option](references/formcfg-disabled-prop.md) — MEDIUM (prevents fields silently missing from submission and skipped validation)
   - 1.9 [Use the values Prop to Keep a Form in Sync with Server Data](references/formcfg-values-prop.md) — HIGH (replaces a useEffect+reset that overwrites edits whenever the query refetches)
2. [Field Subscription](references/_sections.md#2-field-subscription) — **CRITICAL**
   - 2.1 [Avoid Calling watch() in Render for One-Time Reads](references/sub-avoid-watch-in-render.md) — HIGH (prevents unnecessary subscriptions and re-renders)
   - 2.2 [React.memo Cannot Stop Context-Driven Re-renders Under FormProvider](references/sub-memo-cannot-beat-context.md) — MEDIUM (replaces a memo pass that has no effect with isolation that does)
   - 2.3 [Use subscribe() to React to Form Changes Outside the React Lifecycle](references/sub-subscribe-outside-react.md) — HIGH (eliminates re-renders for non-UI consumers like analytics, autosave, telemetry)
   - 2.4 [Use the Render-Prop Components to Isolate Re-renders Without a Child Component](references/sub-render-prop-components.md) — HIGH (confines a subscription to one subtree without authoring a wrapper component)
   - 2.5 [Use useFormContext Sparingly for Deep Nesting](references/sub-useformcontext-sparingly.md) — MEDIUM (reduces prop drilling but increases implicit dependencies)
   - 2.6 [Use useWatch Instead of watch for Isolated Re-renders](references/sub-usewatch-over-watch.md) — CRITICAL (confines value-change re-renders to the subscribing component)
   - 2.7 [Watch Specific Fields Instead of Entire Form](references/sub-watch-specific-fields.md) — CRITICAL (reduces re-renders from N fields to 1 field change)
3. [Controlled Components](references/_sections.md#3-controlled-components) — **HIGH**
   - 3.1 [Isolate Controlled Inputs in Dedicated Child Components](references/ctrl-usecontroller-isolation.md) — HIGH (re-renders only the changed field instead of the whole form)
   - 3.2 [Wire Controller Field Props Correctly for UI Libraries](references/ctrl-controller-field-props.md) — HIGH (prevents a control that renders correctly but never writes back to the form)
4. [Validation Patterns](references/_sections.md#4-validation-patterns) — **HIGH**
   - 4.1 [Build the Validation Schema Once, Outside the Render Path](references/valid-resolver-caching.md) — HIGH (stops rebuilding the whole schema object on every keystroke)
   - 4.2 [Handle the NaN valueAsNumber Produces for an Empty Input](references/valid-valueasnumber-empty-nan.md) — HIGH (prevents an optional number field that can never be left blank)
   - 4.3 [Surface Server Errors via setError('root.serverError', ...)](references/valid-server-errors.md) — HIGH (prevents lost server-side validation errors and unrecoverable form state)
   - 4.4 [Use delayError to Debounce Rapid Error Display](references/valid-delay-error.md) — MEDIUM (reduces UI flicker during fast typing validation)
5. [State Management](references/_sections.md#5-state-management) — **MEDIUM-HIGH**
   - 5.1 [Avoid isValid with onSubmit Mode for Button State](references/formstate-avoid-isvalid-with-onsubmit.md) — MEDIUM (prevents whole-form validation on every change under a deferred-validation mode)
   - 5.2 [Read Every formState Property You Depend On During Render](references/formstate-destructure-formstate.md) — MEDIUM (prevents a component that never re-renders when the state it shows changes)
   - 5.3 [Rebase Defaults with resetDefaultValues After a Successful Save](references/formstate-reset-default-values.md) — HIGH (clears isDirty without discarding edits made during the in-flight request)
   - 5.4 [Use handleSubmit's Second Argument to Handle a Rejected Submit](references/formstate-handlesubmit-oninvalid.md) — MEDIUM (gives a failed submit somewhere to go instead of silently doing nothing)
   - 5.5 [Use useFormState for Isolated State Subscriptions](references/formstate-useformstate-isolation.md) — MEDIUM (prevents parent re-renders from state access in children)
   - 5.6 [Wrap Async Submit Handlers in try/catch and Reset on isSubmitSuccessful](references/formstate-async-submit-lifecycle.md) — HIGH (prevents stuck isSubmitting state and missing post-success reset)
6. [Field Arrays](references/_sections.md#6-field-arrays) — **MEDIUM-HIGH**
   - 6.1 [Separate Sequential Field Array Operations](references/array-separate-crud-operations.md) — MEDIUM-HIGH (prevents state corruption from batched mutations)
   - 6.2 [Use field.id as Key in useFieldArray Maps](references/array-use-field-id-as-key.md) — MEDIUM-HIGH (prevents state corruption and unnecessary re-renders)
   - 6.3 [Use Single useFieldArray Instance Per Field Name](references/array-unique-fieldarray-per-name.md) — MEDIUM-HIGH (prevents state conflicts from duplicate subscriptions)
   - 6.4 [useFieldArray's disabled Option Makes Every Mutation a Silent No-op](references/array-disabled-silently-noops.md) — MEDIUM-HIGH (prevents append/remove calls that vanish with no error or warning)
7. [Integration Patterns](references/_sections.md#7-integration-patterns) — **MEDIUM**
   - 7.1 [Transform Values at Controller Level for Type Coercion](references/integ-value-transform.md) — MEDIUM (stops string input values reaching a number- or date-typed schema)
   - 7.2 [Verify shadcn Form Component Import Source](references/integ-shadcn-form-import.md) — MEDIUM (prevents silent component mismatch bugs)
   - 7.3 [Wire shadcn Select with onValueChange Instead of Spread](references/integ-shadcn-select-wiring.md) — MEDIUM (prevents a Radix Select that renders but never writes to the form)

---

## References

1. [https://react-hook-form.com/docs](https://react-hook-form.com/docs)
2. [https://react-hook-form.com/advanced-usage](https://react-hook-form.com/advanced-usage)
3. [https://react-hook-form.com/docs/useform](https://react-hook-form.com/docs/useform)
4. [https://react-hook-form.com/docs/useform/subscribe](https://react-hook-form.com/docs/useform/subscribe)
5. [https://react-hook-form.com/docs/useform/seterror](https://react-hook-form.com/docs/useform/seterror)
6. [https://react-hook-form.com/docs/useform/setvalue](https://react-hook-form.com/docs/useform/setvalue)
7. [https://react-hook-form.com/docs/useform/resetdefaultvalues](https://react-hook-form.com/docs/useform/resetdefaultvalues)
8. [https://react-hook-form.com/docs/useform/formstate](https://react-hook-form.com/docs/useform/formstate)
9. [https://react-hook-form.com/docs/usewatch](https://react-hook-form.com/docs/usewatch)
10. [https://react-hook-form.com/docs/usecontroller](https://react-hook-form.com/docs/usecontroller)
11. [https://react-hook-form.com/docs/usefieldarray](https://react-hook-form.com/docs/usefieldarray)
12. [https://react-hook-form.com/docs/useformstate](https://react-hook-form.com/docs/useformstate)
13. [https://github.com/react-hook-form/react-hook-form/releases](https://github.com/react-hook-form/react-hook-form/releases)
14. [https://github.com/react-hook-form/resolvers](https://github.com/react-hook-form/resolvers)
15. [https://ui.shadcn.com/docs/components/form](https://ui.shadcn.com/docs/components/form)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |