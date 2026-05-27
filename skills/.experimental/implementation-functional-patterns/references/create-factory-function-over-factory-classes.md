---
title: Return a tagged object from a factory function instead of a Factory class hierarchy
tags: create, factory-function, abstract-factory, prototype, memento, tagged-object
---

## Return a tagged object from a factory function instead of a Factory class hierarchy

Four GoF patterns — Factory Method (subclass decides which product to create), Abstract Factory (produce families of related products), Prototype (clone via `.clone()`), and Memento (capture/restore state) — collapse to a single TS shape: a **function that returns a value**. For Factory Method, the value is a tagged object whose shape depends on the input. For Abstract Factory, the value is a *record of constructors* parametrized by the family theme. For Prototype, the "clone" is `structuredClone(value)` or a spread. For Memento, the snapshot is `structuredClone(state)`. The class hierarchy of `Factory → ConcreteFactoryA / B` exists only because Java/C# can't return arbitrary objects from a function with a polymorphic return type — TypeScript can, so the hierarchy is ceremony.

### Shapes to recognize

- An `abstract class Factory { abstract create(): Product }` with subclasses overriding `create()` to return one variant
- A `UIFactory` interface with `createButton()`, `createInput()`, `createDialog()`, plus `LightThemeFactory` and `DarkThemeFactory` implementing all three
- A `Cloneable` interface with `clone()` method on every class that wants to be deep-copied
- A `Memento` class storing a snapshot of an `Originator`'s state, with `save()` / `restore()` methods
- Any "produce object X" code that uses inheritance to pick between concrete shapes — the inheritance is almost certainly accidental

**Incorrect (Factory class hierarchy for one product family):**

```typescript
abstract class NotificationFactory {
  abstract create(message: string): Notification;
}

class EmailNotificationFactory extends NotificationFactory {
  create(message: string) { return new EmailNotification(message); }
}

class SmsNotificationFactory extends NotificationFactory {
  create(message: string) { return new SmsNotification(message); }
}

class PushNotificationFactory extends NotificationFactory {
  create(message: string) { return new PushNotification(message); }
}

const factory: NotificationFactory = userPrefersEmail
  ? new EmailNotificationFactory()
  : new SmsNotificationFactory();
const n = factory.create('Welcome');
```

**Correct (factory function returning a tagged object):**

```typescript
type Notification =
  | { kind: 'email'; message: string; to: string }
  | { kind: 'sms';   message: string; phone: string }
  | { kind: 'push';  message: string; deviceToken: string };

function notify(channel: Notification['kind'], message: string, recipient: string): Notification {
  switch (channel) {
    case 'email': return { kind: 'email', message, to: recipient };
    case 'sms':   return { kind: 'sms',   message, phone: recipient };
    case 'push':  return { kind: 'push',  message, deviceToken: recipient };
  }
}

const n = notify(user.preferredChannel, 'Welcome', user.contact);
```

The "subclass decides" of Factory Method becomes the `switch` (or a record lookup). Adding a new channel is a union variant + a case, not a new class.

**Abstract Factory becomes a function returning a record:**

```typescript
type Theme = 'light' | 'dark';

function uiFactory(theme: Theme) {
  const palette = theme === 'light' ? lightPalette : darkPalette;
  return {
    Button: (props: ButtonProps) => <button style={palette.button} {...props} />,
    Input:  (props: InputProps)  => <input style={palette.input} {...props} />,
    Card:   (props: CardProps)   => <div style={palette.card} {...props} />,
  };
}

const { Button, Input, Card } = uiFactory(currentTheme);
```

The family is a record; the theme is captured in the closure. No `LightThemeFactory` class with three methods needed.

**Prototype and Memento collapse to `structuredClone`:**

```typescript
const snapshot = structuredClone(currentState);  // Prototype.clone() / Memento.save()
// …mutate or replace state…
setState(snapshot);                              // Memento.restore()
```

The class-based `Cloneable` interface and `Memento` save/restore methods are noise around what is a one-line standard-library call. `structuredClone` handles deeply-nested data, cyclic structures, Maps, Sets, typed arrays, dates — everything a hand-rolled `clone()` would have to handle.

### Common pitfalls

- **`structuredClone` doesn't clone functions, DOM nodes, or class instances with private state.** Functions throw `DataCloneError`. For state values, this is usually fine — most state is data. If your state holds a function reference, restructure so the function is recoverable (look up by name) rather than stored.
- **Factory function that returns `any` or a wide union without narrowing.** If `notify('sms', ...)` returns `Notification` rather than `Notification & { kind: 'sms' }`, the caller can't access channel-specific fields. Use overloads or generic constraints for type-narrowed returns.
- **Mixing factories and `new`.** `function makeUser(...) { return new User(...) }` keeps the class. That's still a factory function, but you've kept the class for its identity (`instanceof`), validation in the constructor, or method bag. Be explicit about *why* — if the class has nothing the data doesn't, drop it.
- **`Object.create(prototype)` for Prototype pattern.** This is the historic JS Prototype-pattern shape and is almost never the right answer — `structuredClone` or spread is what you want for value cloning. `Object.create` is for prototype-chain manipulation, which is a different concern.

### Performance trade-offs

- **Time:** factory function call ≈ class constructor + method call. Same order; same hot-path performance.
- **Memory:** plain object literal `{ kind, message, ... }` is smaller than a class instance with the same fields (no prototype reference per instance). For collections of thousands of products, the saving is real but rarely material.
- **`structuredClone` is faster than `JSON.parse(JSON.stringify(x))`** (the common naïve clone) by 2–5× because it avoids string serialization, and it handles types JSON can't (Map, Set, Date, typed arrays, cycles).
- **Bundle size:** factory functions tree-shake; unused factory classes don't if any method is referenced. A 5-factory module with 3 unused factories ships only 2 functions with tree-shaking but all 5 classes without.

### When NOT to apply (keep the class)

- **Branded identity via `instanceof`.** When callers downstream use `instanceof Notification` for routing or validation, a class-based Notification carries that. A tagged union doesn't — though `kind`-based switching is the idiomatic replacement
- **Constructor validation invariants.** A `class User { constructor(...) { if (!validEmail(email)) throw … } }` enforces invariants at construction. A factory function can do the same, but classes pair naturally with private fields and readonly invariants
- **Method-rich values** — values where you genuinely want `n.deliver()`, `n.retry()`, `n.metrics()` as methods rather than `deliver(n)`. Often the method form is just stylistic preference; classes win only when there are several methods that meaningfully share private state
- **Cross-process serialization.** If notifications cross a wire (queue, RPC, structured cloning postMessage), a tagged-object data type is *better* than a class — but if the receiver needs to reconstruct named class instances by tag, classes plus a registry are sometimes more convenient

### Related

- GoF class forms collapsed: [`creational-factory-method`](../../implementation-design-patterns/references/creational-factory-method.md), [`creational-abstract-factory`](../../implementation-design-patterns/references/creational-abstract-factory.md), [`creational-prototype`](../../implementation-design-patterns/references/creational-prototype.md), [`behavioral-memento`](../../implementation-design-patterns/references/behavioral-memento.md)
- The match function that *consumes* tagged objects: [`match-tagged-union-over-state-visitor-composite`](match-tagged-union-over-state-visitor-composite.md)
- For module-scope unique values (Singleton): [`create-module-scope-over-singleton`](create-module-scope-over-singleton.md)

Reference: [MDN — `structuredClone`](https://developer.mozilla.org/en-US/docs/Web/API/structuredClone) · [TS Handbook — Discriminated Unions](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#discriminated-unions)
