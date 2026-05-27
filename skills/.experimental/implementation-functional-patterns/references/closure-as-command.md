---
title: Store a closure in the queue instead of a Command class when nothing inspects or serializes it
tags: closure, command-alternative, queue, deferred-execution
---

## Store a closure in the queue instead of a Command class when nothing inspects or serializes it

A model trained on the Command pattern will define a `Command` interface with `execute()`, a `ConcreteCommand` class per operation, and a `CommandQueue` that holds `Command[]`. When the queue's only operation is "call them in order and discard," a closure `() => void` is the same thing without the class. The closure captures its arguments by reference; the queue holds plain functions. Reach for the class form only when something downstream must look inside the command — undo (needs a paired reverse operation), serialization (must survive a process restart), introspection (logging, retry policy by op-type), or macro recording (the queue itself is a serializable script).

### Shapes to recognize

- A `Command` interface with one method `execute()` (no `undo`, no `describe`, no `cost`)
- A queue or scheduler that does `queue.forEach(c => c.execute())` and nothing else
- Every concrete Command class has constructor params, no fields beyond those params, and an `execute` that uses them once
- The system is in-process only — commands never cross a wire or get persisted

**Incorrect (Command class for fire-and-forget queue):**

```typescript
interface Command {
  execute(): void;
}

class SendEmailCommand implements Command {
  constructor(private to: string, private subject: string, private body: string) {}
  execute() {
    emailClient.send(this.to, this.subject, this.body);
  }
}

class LogAuditCommand implements Command {
  constructor(private userId: string, private action: string) {}
  execute() {
    auditLog.write({ userId: this.userId, action: this.action, at: Date.now() });
  }
}

const afterCommit: Command[] = [];
afterCommit.push(new SendEmailCommand(user.email, 'Welcome', renderWelcome(user)));
afterCommit.push(new LogAuditCommand(user.id, 'signup'));
// later, on commit:
for (const c of afterCommit) c.execute();
```

**Correct (closure carries the captured arguments):**

```typescript
type DeferredAction = () => void;

const afterCommit: DeferredAction[] = [];
afterCommit.push(() => emailClient.send(user.email, 'Welcome', renderWelcome(user)));
afterCommit.push(() => auditLog.write({ userId: user.id, action: 'signup', at: Date.now() }));
// later, on commit:
for (const run of afterCommit) run();
```

The captured `user.email`, `user.id`, etc. are closed over at the time of `push` — the same semantic as the class constructor. Adding a new deferred action is one line at the call site, not a new file.

### When NOT to apply (keep the Command class)

- **Undo/redo:** undo requires the inverse operation tied to the forward one. A `Command` class with paired `execute()` and `undo()` keeps them together; closures fragment the inverse logic
- **Serialization:** if the queue must survive a process crash, page reload, or distributed job runner, you need a serializable representation — `{ type: 'send-email', to, subject, body }` plus a dispatcher. Closures can't be serialized
- **Introspection / logging:** if "what's in the queue" must be observable — for a debug UI, retry policy by op-type, dead-letter routing — typed command objects beat opaque closures
- **Macro recording:** when the queue itself is the user's saved program (e.g., a keyboard-macro recorder, a CI workflow), each command needs a name and parameters for the user to inspect and edit

### Related

- GoF class form: [`behavioral-command`](../../implementation-design-patterns/references/behavioral-command.md)
- Higher-order-function counterpart for one-shot operations: [`hof-lambda-as-strategy`](hof-lambda-as-strategy.md)

Reference: [MDN — Closures](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures)
