---
title: Wire many-to-many or one-to-many communication with an event emitter or signal, not a Mediator or Observer class
tags: signal, event-emitter, pub-sub, mediator, observer, reactive
---

## Wire many-to-many or one-to-many communication with an event emitter or signal, not a Mediator or Observer class

Two GoF patterns — Mediator (a central hub brokering many-to-many communication between colleagues) and Observer (one publisher notifying many subscribers) — collapse to the same TypeScript shape: an **event emitter** (or, in reactive systems, a **signal** / **observable**). The class-based forms (`class Mediator { register(c) {} notify() {} }`, `class Subject { observers; attach() {} notify() {} }`) exist because Java/C# don't have first-class functions ergonomic enough to pass as listeners. TS does — `bus.on('user-changed', fn)` is one line per subscription. Reach for the class form only when the topology has typed roles you want the compiler to enforce, when the publisher/subscriber needs lifecycle hooks beyond subscribe/unsubscribe, or when you're integrating with a framework whose conventions are class-based.

### Pick the right tool for the topology

| Topology | Reach for |
|---|---|
| One publisher, many subscribers, untyped events | `EventEmitter` / `mitt` / DOM `EventTarget` |
| One publisher, many subscribers, typed events | Typed `EventEmitter` (e.g., `mitt<Events>()` with TS generics) |
| Reactive state (UI re-renders when state changes) | **Signal** (Solid, Preact, Vue 3 `ref`, MobX), React `useState`, Zustand |
| Stream of values over time with operators | RxJS Observable |
| Many objects all need to consult a shared rulebook | Plain shared module-scope state + functions |
| Cross-component event bus inside a React tree | React Context + `useReducer`, or a state library (Zustand, Jotai, Redux Toolkit) |

### Shapes to recognize

- A `class Subject { private observers: Observer[] = []; attach(o) {} detach(o) {} notify() {} }` and N `class XObserver implements Observer`
- A `class Mediator` (or `FormMediator`, `ChatroomMediator`) holding references to every "colleague" and routing messages between them
- A method `notifyColleagues()` that loops over a list of registered objects and calls `update()` on each
- React state that's "lifted" multiple levels and prop-drilled — usually fixable with a signal or context, not a Mediator

**Incorrect (Observer class hierarchy for state-change notifications):**

```typescript
interface UserObserver {
  update(user: User): void;
}

class UserSubject {
  private observers: UserObserver[] = [];
  attach(o: UserObserver) { this.observers.push(o); }
  detach(o: UserObserver) { this.observers = this.observers.filter((x) => x !== o); }
  notify(user: User) { for (const o of this.observers) o.update(user); }
}

class HeaderObserver implements UserObserver {
  update(user: User) { document.querySelector('#hdr')!.textContent = user.name; }
}

class SidebarObserver implements UserObserver {
  update(user: User) { document.querySelector('#side')!.textContent = `${user.points}pt`; }
}

const userSubject = new UserSubject();
userSubject.attach(new HeaderObserver());
userSubject.attach(new SidebarObserver());

userSubject.notify(updatedUser);
```

**Correct (typed event emitter):**

```typescript
import mitt from 'mitt';

type Events = { 'user-changed': User };
const bus = mitt<Events>();

bus.on('user-changed', (user) => { document.querySelector('#hdr')!.textContent  = user.name; });
bus.on('user-changed', (user) => { document.querySelector('#side')!.textContent = `${user.points}pt`; });

bus.emit('user-changed', updatedUser);
```

Same semantics, no classes, types enforced on the event name and payload. Each subscriber is a closure — no `class XObserver` per UI region.

**For reactive UI, prefer signals or framework state:**

```typescript
// With Preact signals
import { signal, effect } from '@preact/signals-core';

const currentUser = signal<User>(initialUser);

effect(() => { document.querySelector('#hdr')!.textContent  = currentUser.value.name; });
effect(() => { document.querySelector('#side')!.textContent = `${currentUser.value.points}pt`; });

currentUser.value = updatedUser;  // both effects fire automatically
```

The signal IS the publisher; effects ARE the observers. The "subscribe" relationship is inferred from which `.value` reads happen inside the effect closure.

**Mediator (many-to-many) shape with an event bus:**

```typescript
type FormEvents = {
  'field:changed': { field: string; value: unknown };
  'form:submit':   { values: Record<string, unknown> };
  'form:reset':    void;
};
const formBus = mitt<FormEvents>();

// Field component reacts to other fields' changes:
formBus.on('field:changed', ({ field, value }) => {
  if (field === 'country') {
    formBus.emit('field:changed', { field: 'currency', value: defaultCurrency(value as string) });
  }
});

// Submit button:
formBus.on('form:submit', async ({ values }) => { await api.save(values); });
```

The bus is the mediator. No `class FormMediator { onCountryChanged() … onCurrencyChanged() … }` with N methods coupling every pairwise interaction.

### Common pitfalls

- **Memory leaks from unbound subscriptions.** `bus.on('foo', handler)` keeps `handler` (and everything it closes over) alive until `bus.off('foo', handler)`. In React, always `useEffect(() => { bus.on(...); return () => bus.off(...) }, [])`. In long-lived bridges, document the subscribe/unsubscribe contract.
- **Untyped events.** `emitter.emit('user-chanded', user)` (typo) silently never fires the listener. Use a typed emitter (`mitt<Events>()`) or a `as const` keyed registry to make typos compile errors.
- **Synchronous fan-out blocking the publisher.** `bus.emit('x')` runs all subscribers synchronously in the publisher's stack. A slow subscriber blocks the next. For "fire-and-forget" semantics, wrap subscribers in `queueMicrotask(() => handler(data))` or use async event buses.
- **Subscribers running in undefined order.** Most emitters guarantee insertion order; some don't. If your subscribers depend on each other's effects, they're not properly independent — restructure.
- **Cross-process / cross-tab events.** `bus.emit` in one tab doesn't reach another. Use `BroadcastChannel` (native), `localStorage` events, or a server-side bus.
- **Mediator that grew into a god-object.** A `FormMediator` that handles every possible field-pair interaction becomes unmaintainable. Either split into multiple buses by domain, or move toward derived state (signals: each derived field is `computed(() => fn(deps))`).

### Performance trade-offs

- **Time:** `bus.emit(...)` is O(subscribers). For ~10 subscribers, microseconds. For thousands (highly fanned-out app state in a non-reactive system), measurable — at which point signals/observables (which build dependency graphs and only fire on actual reads) are more efficient.
- **Memory:** each subscription is a closure + an entry in the emitter's internal list. Roughly equivalent to an object reference per listener.
- **Reactive signals are typically faster** than event buses for UI state because the signal library tracks reads — only the effects that actually use a value run when it changes. An event bus broadcasts to every listener regardless of whether the change affected them.
- **No fan-out cost for unused signals.** A `signal()` with zero subscribers does no work on write. A `bus.emit()` with one subscriber that doesn't care still calls the subscriber.

### When NOT to apply (keep Mediator / Observer class)

- **Typed roles with compiler-enforced contracts.** When the system has a fixed set of colleagues (`Pilot`, `Tower`, `GroundCrew`) with specific message types each can send/receive, a typed class-based Mediator can make role mismatches compile errors. A generic event bus can do this with discriminated event types, but the class form is sometimes clearer
- **Framework expects classes.** Some component frameworks (Angular services, NestJS event emitters with decorators, RxJS subjects in class-based services) integrate naturally with class subjects. Match the surrounding style
- **The publisher carries domain state.** A `Subject` that is *itself* a domain object (a `Stock` that notifies of price changes) and not just a pub-sub conduit may earn a class. Even then — the class can use an internal emitter; the public surface is what counts

### Related

- GoF class forms collapsed: [`behavioral-mediator`](../../../.experimental/implementation-design-patterns/references/behavioral-mediator.md), [`behavioral-observer`](../../../.experimental/implementation-design-patterns/references/behavioral-observer.md)
- For tagged state transitions inside one component (State, not Observer): [`match-tagged-union-over-state-visitor-composite`](match-tagged-union-over-state-visitor-composite.md)
- For closures stored in a queue (Command, not Observer): [`closure-as-command`](closure-as-command.md)

Reference: [MDN — `EventTarget`](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget) · [Preact Signals — docs](https://preactjs.com/guide/v10/signals/) · [`mitt` — tiny typed event emitter](https://github.com/developit/mitt)
