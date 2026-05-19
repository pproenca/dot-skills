---
title: Use `NoInfer<T>` to Disambiguate Overloaded Function Signatures
impact: HIGH
impactDescription: prevents 100% of "argument leaked into inferred default" bugs in multi-parameter generics
tags: mod, noinfer, overloads, inference, typescript-5
---

## Use `NoInfer<T>` to Disambiguate Overloaded Function Signatures

`NoInfer<T>` (TypeScript 5.4) marks a generic parameter position as **non-inferring** — the type-checker reads the type but does not let arguments at that position influence the generic's inference. The standard advice is to use it to make defaults work correctly. The advanced application is in overload-heavy APIs where one argument should *anchor* the generic and the others should *follow*. Without `NoInfer`, the compiler picks up clues from every parameter and resolves the generic to the union of all of them — usually wider than intended, sometimes selecting the wrong overload entirely.

**Incorrect (every parameter contributes to inference — generic widens):**

```typescript
function pick<T extends string>(options: T[], fallback: T): T {
  return options[0] ?? fallback
}

const choice = pick(['red', 'green'], 'blue')
//    ^? 'red' | 'green' | 'blue'  — fallback widened the result.
// Caller wanted: "choose from options, with fallback for the empty case."
// They got: "result might be the fallback value too."
```

**Correct (anchor inference on `options`; do not infer from `fallback`):**

```typescript
function pick<T extends string>(options: T[], fallback: NoInfer<T>): T {
  return options[0] ?? fallback
}

const choice = pick(['red', 'green'], 'blue')
//                                    ~~~~~~ Error: 'blue' is not assignable to 'red' | 'green'.

const valid = pick(['red', 'green'], 'red')
//    ^? 'red' | 'green'  — exactly the options union.
```

The pattern generalises to any signature with one *driving* parameter and several *constrained* parameters:

```typescript
// Reducer: state shape anchored to the initial value.
function createStore<S>(initial: S, reducer: (state: NoInfer<S>, action: unknown) => NoInfer<S>) {
  /* … */
}

// Subscription: event shape anchored to the schema, not the handler's parameter inference.
function subscribe<E>(schema: Schema<E>, handler: (event: NoInfer<E>) => void) {
  /* … */
}

// Type-safe routing: param shape anchored to the path, not the handler's destructure.
function route<P extends string>(path: P, handler: (params: NoInfer<ExtractParams<P>>) => Response) {
  /* … */
}
```

The diagnostic when `NoInfer` triggers is far more actionable than the alternative — the error points at the *specific* argument that violated the anchor, instead of producing an inscrutable widened union at the call site.

**When NOT to apply:**
- Single-parameter generics — there's nothing to disambiguate; the constraint already determines inference.
- When you *want* the union — sometimes "any of these strings" is the desired return type. Don't reach for `NoInfer` reflexively.
- TypeScript versions before 5.4. Polyfills (`type NoInfer<T> = [T][T extends any ? 0 : never]`) exist but produce worse errors than the built-in.

**Scope delta:**
- `typescript-refactor`'s `modern-noinfer-utility` introduces `NoInfer<T>`. This rule covers the overload-disambiguation and anchor-vs-constrained-parameter framing — the *design pattern* for picking which positions infer and which constrain, not just the syntax.

Reference: [TypeScript 5.4 Release Notes — `NoInfer` Utility Type](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-4.html#the-noinfer-utility-type)
