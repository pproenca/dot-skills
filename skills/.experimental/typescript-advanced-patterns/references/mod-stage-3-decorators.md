---
title: Use Stage 3 Decorators with Decorator Context for Metaprogramming
impact: HIGH
impactDescription: prevents 100% of legacy-decorator type holes (`any` parameters); removes dependency on `experimentalDecorators` flag
tags: mod, decorators, stage-3, metaprogramming, typescript-5
---

## Use Stage 3 Decorators with Decorator Context for Metaprogramming

TypeScript 5.0 ships the Stage 3 TC39 decorator proposal as the default decorator implementation. The new design is a near-rewrite of the legacy `experimentalDecorators` model: decorators receive a *context object* describing what they decorate (kind, name, static, private), they return values explicitly rather than mutating the prototype, and they integrate with the type system far better. Old-style decorators will keep working under the flag, but new code should target the standard — the ecosystem (Lit, MobX, Effect) has converged on it.

**Incorrect (legacy experimental decorators — non-standard, fragile typing):**

```typescript
// tsconfig.json: "experimentalDecorators": true, "emitDecoratorMetadata": true

function logged(target: any, name: string, desc: PropertyDescriptor) {
  const original = desc.value
  desc.value = function (...args: any[]) {
    console.log(`call ${name}`)
    return original.apply(this, args)
  }
}

class Service {
  @logged
  greet(name: string) { return `hi ${name}` }
}
```

The signature is untyped (`any`, `any`, `PropertyDescriptor`), the decorator mutates the descriptor object in place, and the behaviour depends on a compiler flag.

**Correct (Stage 3 decorator with typed context):**

```typescript
// tsconfig.json: no decorator flags needed; "target": "ES2022" or newer.

function logged<This, Args extends unknown[], Return>(
  target: (this: This, ...args: Args) => Return,
  context: ClassMethodDecoratorContext<This, (this: This, ...args: Args) => Return>,
): (this: This, ...args: Args) => Return {
  const name = String(context.name)
  return function (this: This, ...args: Args): Return {
    console.log(`call ${name}`)
    return target.call(this, ...args)
  }
}

class Service {
  @logged
  greet(name: string) { return `hi ${name}` }
}
```

The context object differs per decorator kind: `ClassMethodDecoratorContext`, `ClassFieldDecoratorContext`, `ClassGetterDecoratorContext`, `ClassSetterDecoratorContext`, `ClassAccessorDecoratorContext`, `ClassDecoratorContext`. Each has typed `name`, `kind`, `static`, `private`, `addInitializer`, and `metadata` properties. Use `context.addInitializer` to run code when the class is defined (e.g. for registration patterns) and `context.metadata` (Stage 3 decorator metadata, supported in TS 5.2+) to store cross-decorator state.

**Quick reference — most common decorator kinds:**

| Kind | Context type | What `target` is |
|------|--------------|-----------------|
| Method | `ClassMethodDecoratorContext` | the method function |
| Field | `ClassFieldDecoratorContext` | `undefined` (return an init function) |
| Getter | `ClassGetterDecoratorContext` | the getter function |
| `accessor` | `ClassAccessorDecoratorContext` | `{ get, set }` pair |
| Class | `ClassDecoratorContext` | the class constructor |

**When NOT to apply:**
- Code that depends on `emitDecoratorMetadata` for runtime reflection (NestJS, TypeORM circa 2024) — those rely on legacy decorators. Migrate when the framework supports Stage 3; not before.
- When a plain higher-order function would do — decorators are syntactic sugar over function composition, and the syntax cost exceeds the readability benefit for simple wrappers.

**Scope delta:**
- `typescript-refactor`'s `modern-accessor-keyword` mentions the `accessor` keyword as a TS-5 modern feature. This rule goes deeper: the full decorator system (class, method, field, getter, setter, accessor), the context object's shape per kind, and the migration path from legacy decorators.

Reference: [TypeScript 5.0 Release Notes — Decorators](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-0.html#decorators)
