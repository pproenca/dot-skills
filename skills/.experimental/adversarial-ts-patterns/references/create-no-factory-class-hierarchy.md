---
title: No factory-class hierarchies whose subclasses only override a create method
tags: create, factory-method, abstract-factory, gof
---

## No factory-class hierarchies whose subclasses only override a create method

The wrong default is the textbook Factory Method structure — an abstract `Creator` class with one abstract `create*` method and a concrete subclass per product. The pattern exists because Java could not pass a constructor as a value; in TypeScript a factory is a function, and a family of factories is a record of functions selected by key. The class hierarchy adds a file per variant and an inheritance relationship that carries no state or shared behavior — it is a lookup table wearing a class hierarchy.

**Evidence of violation:** an abstract class (or interface) whose contract is a single `create*`/`make*`/`build*` method, implemented by two or more concrete classes whose bodies contain only that override — no fields, no other methods. The carve-out is a registry genuinely populated across package boundaries at runtime (plugins registering their own creators); inside one application, a `Record<Kind, () => Product>` is the whole pattern.

**Incorrect (class per variant, each body one method):**

```ts
abstract class NotifierFactory {
  abstract create(): Notifier
}
class EmailNotifierFactory extends NotifierFactory {
  create() { return new EmailNotifier() }
}
class SmsNotifierFactory extends NotifierFactory {
  create() { return new SmsNotifier() }
}
```

**Correct (a record of constructors is the factory family):**

```ts
const notifierFactories = {
  email: () => new EmailNotifier(),
  sms:   () => new SmsNotifier(),
} satisfies Record<Channel, () => Notifier>

const notifier = notifierFactories[channel]()
```

Reference: [Refactoring Guru — Factory Method (structure and applicability)](https://refactoring.guru/design-patterns/factory-method)
