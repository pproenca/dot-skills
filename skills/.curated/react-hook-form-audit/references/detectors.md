# Detectors

Per-detector reference: what each rule catches, the pattern it looks for, known false positives, and the companion distillation rule that prescribes the fix.

## Severity Legend

| Severity | Meaning | CI effect |
|----------|---------|-----------|
| CRITICAL | Correctness or major performance bug — likely user-visible | Fails the audit (exit 1) |
| HIGH | Anti-pattern with concrete consequence — should be fixed | Fails the audit (exit 1) |
| MEDIUM | Discouraged pattern; may be deliberate | Reported, doesn't fail |
| LOW | Informational — review and confirm | Reported, doesn't fail |

---

## Rule 01 — `rhf-audit-01-watch-at-form-root`

**Severity:** CRITICAL · **Tool:** ts-morph · **Companion:** `sub-usewatch-over-watch`

**What it catches:** A call to `watch(...)` inside the same function body as `useForm()`. This is the canonical performance footgun — every watched-value change re-renders the entire form component.

**AST shape:**
```
FunctionDeclaration / ArrowFunction
├── CallExpression { useForm }
└── CallExpression { watch }  ← flagged
```

**Fix:** Move the `watch` consumer into a child component that uses `useWatch({ control, name })` instead.

**False positives:** None known — every co-location of `useForm` and `watch` in the same function is suspect.

---

## Rule 02 — `rhf-audit-02-watch-all-fields`

**Severity:** CRITICAL · **Tool:** ts-morph · **Companion:** `sub-watch-specific-fields`

**What it catches:** `watch()` called with zero arguments, which subscribes to every field in the form. Strictly worse than Rule 01.

**AST shape:**
```
CallExpression { watch } with arguments.length === 0
```

**Fix:** Pass specific field names: `watch(['quantity', 'price'])`, or use `useWatch({ control, name: 'quantity' })` in a child component.

**Note:** Rule 02 fires instead of (not in addition to) Rule 01 when args.length is zero, so you won't get duplicate findings.

---

## Rule 03 — `rhf-audit-03-missing-default-values`

**Severity:** CRITICAL · **Tool:** ts-morph · **Companion:** `formcfg-default-values`

**What it catches:** `useForm()` invoked with no options object, or with an options object that lacks a `defaultValues` property.

**Why CRITICAL:** without `defaultValues`, fields are uncontrolled until first interaction, `reset()` has nothing to reset to, and TypeScript can't infer the form's shape correctly.

**AST shape:**
```
CallExpression { useForm }
├── arguments.length === 0  ← flagged
└── arguments[0] is ObjectLiteralExpression without `defaultValues` property  ← flagged
```

**False positives:** Custom hooks that wrap `useForm` and inject `defaultValues` upstream. If you have these, exclude their callers via `exclude_globs` and audit the wrapper itself.

---

## Rule 04 — `rhf-audit-04-useeffect-depends-useform`

**Severity:** CRITICAL · **Tool:** ts-morph · **Companion:** `formcfg-useeffect-dependency`

**What it catches:** `useEffect(fn, [deps])` where `deps` includes the variable bound to `useForm()`'s return (e.g., `const form = useForm(); useEffect(..., [form])`). The return object is a new reference every render, causing infinite effect re-runs.

**Whitelist:** `register`, `control`, `setValue`, `setError`, `clearErrors`, `reset`, `subscribe`, `trigger`, `unregister` — these are stable refs and are intentionally listed as deps.

**Fix:** Destructure the stable callbacks you need and depend on them, not on the form object.

---

## Rule 05 — `rhf-audit-05-non-use-client`

**Severity:** CRITICAL · **Tool:** ripgrep · **Companion:** _(Next.js-specific, no distillation rule)_

**What it catches:** A file imports `react-hook-form` but the first 10 lines do not contain a `"use client"` directive.

**Why CRITICAL:** RHF's hooks (`useForm`, `useWatch`, etc.) only work in client components. In Next.js App Router, a Server Component that imports RHF will throw at request time.

**False positives:** Pages Router projects — every file is implicitly a client component there. `detect-project.sh` reports the router, and the report's introduction notes whether this rule applies. Suppress by excluding the Pages Router paths in `config.json`.

---

## Rule 06 — `rhf-audit-06-controller-inlined`

**Severity:** HIGH · **Tool:** ts-morph · **Companion:** `ctrl-usecontroller-isolation`

**What it catches:** A `<Controller>` JSX element rendered directly inside the function that calls `useForm()`. Every parent re-render flows through every inlined Controller, defeating the isolation Controller is meant to provide.

**Fix:** Move the Controller into a child component (or use `useController` in a child) — both isolate the re-render.

---

## Rule 07 — `rhf-audit-07-async-submit-no-trycatch`

**Severity:** HIGH · **Tool:** ts-morph · **Companion:** `formstate-async-submit-lifecycle`

**What it catches:** The function passed to `handleSubmit(fn)` is async (or contains `await`) but does not contain a `try { ... } catch { ... }`. If the handler throws, `isSubmitting` stays `true` forever and the form is stuck.

**AST shape:**
```
CallExpression { handleSubmit }
└── arguments[0] is async ArrowFunction / FunctionExpression
    └── no TryStatement descendants  ← flagged
```

**Handler resolution:** if `handleSubmit(myFn)` is passed an identifier, the detector resolves `myFn` to a variable or function declaration inside the same component and inspects that.

**False positives:** Handlers that delegate to a wrapper utility which already handles errors. The detector can't see across function boundaries — if you have such a wrapper, document it via a comment so reviewers can dismiss the finding.

---

## Rule 08 — `rhf-audit-08-schema-inside-component`

**Severity:** HIGH · **Tool:** ts-morph · **Companion:** `valid-resolver-caching`

**What it catches:** A call to `z.object`, `yup.object`, `Joi.object`, `valibot.object`, or bare `object(...)` inside a component body. The schema is recreated on every render, and the resolver re-validates against a fresh schema reference each time.

**Fix:** Hoist the schema to module scope: define it outside the component, then reference it inside.

---

## Rule 09 — `rhf-audit-09-no-server-error-setError`

**Severity:** HIGH · **Tool:** ts-morph · **Companion:** `valid-server-errors`

**What it catches:** A submit handler calls `fetch`, `axios`, or anything matching `api.X` / `http.X`, but never calls `setError('root.serverError', ...)` (or any `setError('root.*', ...)`).

**Why HIGH:** server failures will be silently swallowed by `handleSubmit`. The user gets no feedback that "saving" actually failed.

**Fix:** `try { await api(...) } catch { setError('root.serverError', { message: '...' }) }` — combined with rendering `errors.root?.serverError` in the JSX.

---

## Rule 10 — `rhf-audit-10-rhf-with-useactionstate`

**Severity:** HIGH · **Tool:** ts-morph · **Companion:** _(Next.js-specific)_

**What it catches:** Both `useForm()` and `useActionState()` are called inside the same component. Mixing client-side RHF validation with React 19's Server Action state machine produces duplicated state, race conditions on submit, and unclear ownership.

**Recommendation:** Pick one. For pure client-side validation, use RHF and submit via your own handler. For Server Actions with simple validation, use `useActionState` alone. If you genuinely need both — RHF for input UX + Server Action for submission — document it explicitly because the failure modes are subtle.

---

## Rule 11 — `rhf-audit-11-onchange-mode`

**Severity:** MEDIUM · **Tool:** ripgrep · **Companion:** `formcfg-validation-mode`

**What it catches:** `mode: 'onChange'` in any options object.

**Why MEDIUM:** sometimes deliberate (real-time password strength, "available username" checks). But it's the worst default for performance — every keystroke validates and re-renders.

**Fix:** If real-time feedback is essential for the use case, keep it and add a comment explaining why. Otherwise switch to `mode: 'onSubmit'` (the default).

---

## Rule 12 — `rhf-audit-12-disabled-visual`

**Severity:** MEDIUM · **Tool:** ts-morph · **Companion:** `formcfg-disabled-prop`

**What it catches:** `register('name', { disabled: <expression> })` where the expression is an Identifier (state variable), PropertyAccess, PrefixUnary (e.g. `!x`), or BinaryExpression — i.e., a reactive value rather than a literal `true`.

**Why this matters:** `register`'s `disabled` option clears the field's value to `undefined` and skips validation. If you only want the input greyed out, use the HTML `disabled` attribute directly on the input.

**Fix:** `<input {...register('name')} disabled={condition} />` for visual disable; `{...register('name', { disabled: condition })}` only when you truly want the field excluded from submission and validation.

---

## Rule 13 — `rhf-audit-13-fieldarray-no-field-id`

**Severity:** MEDIUM · **Tool:** ts-morph · **Companion:** `array-use-field-id-as-key`

**What it catches:** A `.map()` over `fields` from `useFieldArray`'s destructured return, where the inner JSX either has no `key` attribute or uses something other than `field.id` (e.g., the array index).

**Why MEDIUM:** index keys cause state corruption when items are added, removed, or reordered. `field.id` is stable and unique.

---

## Rule 14 — `rhf-audit-14-revalidate-onblur`

**Severity:** LOW · **Tool:** ripgrep · **Companion:** `formcfg-revalidate-mode`

**What it catches:** `reValidateMode: 'onBlur'` in any options object.

**Why LOW (not higher):** the demoted advice. The default `onChange` gives users immediate positive feedback when they fix an error. Overriding to `onBlur` is a UX trade-off, justified only when validation is genuinely expensive. The detector flags it for review, not as a definite bug.

---

## Rule 15 — `rhf-audit-15-useformcontext`

**Severity:** LOW · **Tool:** ts-morph · **Companion:** `sub-useformcontext-sparingly`

**What it catches:** Any `useFormContext()` call site.

**Why informational:** FormContext is occasionally the right tool (e.g., a generic reusable Field component). It's just worth a manual check — shallow uses add implicit coupling without payoff. Confirm the consuming component is deep enough that prop drilling would be worse.

---

## Adding New Detectors

To extend the catalog:

1. Pick a rule ID slot: `rhf-audit-NN-<short-name>` where NN is the next available number
2. Decide tool: ripgrep (regex-detectable, line-level) or ts-morph (structural)
3. Add to the appropriate script (`detect-fast.sh` or `detect-ast.mjs`)
4. Add a row to the catalog table in `SKILL.md`
5. Add an entry in `RULE_TO_FILE` in `render-report.mjs` mapping to the companion distillation rule (or `null` if Next.js-specific)
6. Document it in this file with severity, tool, companion, AST shape, and false positives
