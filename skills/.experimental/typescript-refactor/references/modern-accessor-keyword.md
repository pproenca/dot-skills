---
title: Use accessor for Auto-Generated Getters and Setters
impact: MEDIUM
impactDescription: reduces boilerplate while maintaining encapsulation
tags: modern, accessor, class-fields, encapsulation
---

## Use accessor for Auto-Generated Getters and Setters

The `accessor` keyword (TS 4.9+) automatically generates a private backing field with public getter/setter. Use it when you want observable or validated properties without writing boilerplate get/set methods.

**Incorrect (manual getter/setter boilerplate):**

```typescript
class FormField {
  private _value: string = ""
  private _touched: boolean = false

  get value(): string {
    return this._value
  }

  set value(newValue: string) {
    this._value = newValue
    this._touched = true
  }

  get touched(): boolean {
    return this._touched
  }
}
```

**Correct (accessor reduces boilerplate with decorators):**

```typescript
function tracked<T>(target: ClassAccessorDecoratorTarget<unknown, T>, context: ClassAccessorDecoratorContext) {
  return {
    set(this: unknown, value: T) {
      target.set.call(this, value)
      console.log(`${String(context.name)} changed to ${value}`)
    },
  } satisfies ClassAccessorDecoratorResult<unknown, T>
}

class FormField {
  @tracked accessor value: string = ""
  @tracked accessor touched: boolean = false
}
```

**When NOT to use this pattern:**
- Simple data classes with no interception logic — plain fields are simpler

Reference: [TypeScript 4.9 - accessor keyword](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-9.html)
