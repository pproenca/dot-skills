---
title: Nest reactors with compose, never by calling Reactor.run inside a step
tags: comp, compose, nesting, rollback
---

## Nest reactors with compose, never by calling Reactor.run inside a step

Calling `Reactor.run(ChildReactor, args)` inside a step's `run` looks like
composition but severs every guarantee that makes nesting safe. The child's
completed steps sit outside the parent's saga — when the parent later fails
and rolls back, nothing can undo the child's work, because the parent sees one
opaque step, not the child's steps. The `compose` entity is the supported
seam: it embeds the child into the parent's plan, propagates rollback into it
(`support_undo?` defaults to `true`), shares concurrency accounting instead of
letting the child spawn its own unbudgeted tasks, and exposes the child's
returned value as `result(:composed_step)` for downstream dependencies.

**Evidence of violation:** a call to `Reactor.run(`/`Reactor.run!(` inside a
step's `run` fn or `run/3` callback body. PASS: all reactor nesting in the
target goes through `compose`. N/A: the target nests no reactors. Carve-out
(citable): the inner run is genuinely a *new top-level workflow* — fired from
a job worker, a controller, or a resume path, not composed into the calling
reactor's transaction of work — cite the call site's role.

```elixir
defmodule Onboarding.SignupFlow do
  use Reactor

  input :email

  # The child's steps join this plan: parent rollback undoes them,
  # and its result is addressable like any step's.
  compose :provision, Onboarding.ProvisionWorkspace do
    argument :email, input(:email)
  end

  step :send_welcome, Onboarding.SendWelcome do
    argument :workspace, result(:provision)
  end

  return :provision
end
```

Reference: [Reactor — Composition guide](https://reactor.hexdocs.pm/04-composition.html)
