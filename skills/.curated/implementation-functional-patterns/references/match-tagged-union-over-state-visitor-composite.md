---
title: Model State, Visitor, and Composite as a discriminated union with an exhaustive match
tags: match, tagged-union, discriminated-union, state-machine, visitor, composite, exhaustive
---

## Model State, Visitor, and Composite as a discriminated union with an exhaustive match

Three GoF patterns — State (class per state with transitions), Visitor (double-dispatch over class hierarchies), Composite (Leaf and Branch classes with shared interface) — collapse to the same TypeScript shape: a **discriminated union** plus a **function that switches on the tag**. The tag (`kind`/`type`/`status`) makes the cases mutually exclusive at the type level; an `assertNever` at the end of the switch turns "I forgot a case" into a compile error. This is arguably the most consequential functional pattern in idiomatic TS — it deletes class hierarchies, replaces virtual dispatch with pattern matching, and makes adding a new operation a one-function diff rather than a class-edit per variant.

### Shapes to recognize

- A `State` interface with `transition()` / `handle()`, and N `ConcreteState` classes each implementing it
- A `Visitor` interface with `visitConcreteA(node)`, `visitConcreteB(node)`, … and `accept(visitor)` methods on every node class — double dispatch
- A `Component` base class with `Leaf` and `Composite` subclasses, all forwarding to children
- A class with a `status: string` field and a giant method that switches on it
- A recursive function that does `if (node instanceof Branch) … else if (node instanceof Leaf) …`

**Incorrect (State as a class hierarchy):**

```typescript
abstract class ConnectionState {
  abstract send(ctx: Connection, msg: string): ConnectionState;
}

class Idle extends ConnectionState {
  send(ctx: Connection): ConnectionState {
    return new Connecting(ctx.url);
  }
}

class Connecting extends ConnectionState {
  constructor(public url: string) { super(); }
  send(): ConnectionState { throw new Error('not connected yet'); }
}

class Open extends ConnectionState {
  constructor(public socket: WebSocket) { super(); }
  send(_ctx: Connection, msg: string): ConnectionState {
    this.socket.send(msg);
    return this;
  }
}

class Closed extends ConnectionState {
  constructor(public reason: string) { super(); }
  send(): ConnectionState { throw new Error(`closed: ${this.reason}`); }
}
```

**Correct (discriminated union + exhaustive match):**

```typescript
type ConnectionState =
  | { tag: 'idle' }
  | { tag: 'connecting'; url: string }
  | { tag: 'open'; socket: WebSocket }
  | { tag: 'closed'; reason: string };

const assertNever = (x: never): never => {
  throw new Error(`Unhandled variant: ${JSON.stringify(x)}`);
};

function send(state: ConnectionState, msg: string): ConnectionState {
  switch (state.tag) {
    case 'idle':       return { tag: 'connecting', url: 'wss://…' };
    case 'connecting': throw new Error('not connected yet');
    case 'open':       state.socket.send(msg); return state;
    case 'closed':     throw new Error(`closed: ${state.reason}`);
    default:           return assertNever(state);
  }
}
```

Adding a new state (`'reconnecting'`) is one type addition + one `case` — the compiler points at `assertNever` until every `match` site handles it. Adding a new operation (`disconnect`, `keepalive`, `metrics`) is one new function — no class edits, no double-dispatch ceremony.

The Visitor pattern collapses the same way:

```typescript
type Expr =
  | { tag: 'num'; value: number }
  | { tag: 'add'; left: Expr; right: Expr }
  | { tag: 'mul'; left: Expr; right: Expr };

const evaluate  = (e: Expr): number =>
  e.tag === 'num' ? e.value :
  e.tag === 'add' ? evaluate(e.left) + evaluate(e.right) :
  e.tag === 'mul' ? evaluate(e.left) * evaluate(e.right) :
  assertNever(e);

const prettyPrint = (e: Expr): string =>
  e.tag === 'num' ? String(e.value) :
  e.tag === 'add' ? `(${prettyPrint(e.left)} + ${prettyPrint(e.right)})` :
  e.tag === 'mul' ? `(${prettyPrint(e.left)} * ${prettyPrint(e.right)})` :
  assertNever(e);
```

Each "visitor" is just a function. Composite is the same shape with a recursive case.

### Common pitfalls

- **Forgotten `default: assertNever(x)`.** Without it, adding a new variant fails silently — the switch returns `undefined` and you find out at runtime. Always finalize the switch with `assertNever` (or `const _exhaustive: never = state`).
- **Tag field naming inconsistency.** Pick one — `kind`, `type`, or `tag` — and stick to it across the codebase. `type` collides with the TypeScript keyword in mental parsing; many style guides recommend `kind` or `tag`.
- **`instanceof` on the union.** Once you've gone to a discriminated union, never reach for `instanceof` again — it tests the runtime class, which the union doesn't have. Tag-check is correct; `instanceof` is wrong.
- **Mutable transitions.** State transitions should return a *new* state value, not mutate the current one. `state.tag = 'open'` is illegal TypeScript on a readonly union and conceptually wrong (the union narrowed the type — you can't change its tag in place).
- **Class-and-tag both.** Sometimes legacy code has classes that also have a `kind` field. Pick one: drop the classes and use plain object literals, or keep the classes and use `instanceof`. Mixing both invites bugs.

### Performance trade-offs

- **Time:** switch on a string tag is O(1) in V8 (often compiled to a jump table for small unions); class-based virtual dispatch is also O(1). Performance-equivalent at the per-call level.
- **Memory:** an object literal `{ tag: 'open', socket }` is typically *smaller* than a class instance with the same fields — no prototype chain reference per instance, no constructor overhead. Often 16–24 bytes less per state value.
- **Bundle size:** a discriminated-union match function tree-shakes — unused operations on a type don't get bundled. Unused methods on a class don't tree-shake if the class is exported.
- **Inference cost:** TypeScript compile time grows with the size of the union, but is rarely the bottleneck below ~50 variants. Beyond that, splitting the union into nested unions helps.

### When NOT to apply (keep the class hierarchy)

- The variants carry **per-instance lifecycle** that classes model honestly (a state that owns a network connection, disposes a resource, holds a `Symbol.dispose`-able). Tagged unions can still own these, but the cleanup discipline is on you, not the class
- You're integrating with a **framework that expects classes** — UI libraries, ORMs, decorators that work on class methods, the `using` declaration's `Symbol.dispose` contract
- The variants form a **rich domain** with shared behavior worth inheriting (rare and almost always overstated — re-check if it's really inheritance or just "they happen to have similar fields")
- You need **runtime introspection** of the variant set — listing all states for a debug UI, generating documentation per state — both are possible with discriminated unions plus a registry, but classes plus reflection are sometimes more convenient

### Related

- GoF class forms collapsed: [`behavioral-state`](../../../.experimental/implementation-design-patterns/references/behavioral-state.md), [`behavioral-visitor`](../../../.experimental/implementation-design-patterns/references/behavioral-visitor.md), [`structural-composite`](../../../.experimental/implementation-design-patterns/references/structural-composite.md)
- Adjacent: closures that *carry* state are a different shape — see [`closure-as-command`](closure-as-command.md)
- The factory function that *produces* tagged values: [`create-factory-function-over-factory-classes`](create-factory-function-over-factory-classes.md)

Reference: [TS Handbook — Discriminated Unions](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#discriminated-unions) · [TS Handbook — `never`](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#the-never-type)
