# Elixir / OTP / Ecto / Phoenix

**Version 0.1.0**  
dot-skills  
July 2026

---

## Abstract

Adversarial, architecture-level review and refactoring of Elixir on the BEAM: names the alien mental model existing code betrays (OO/enterprise layering, processes-as-objects, anemic data, defensive control flow, imperative iteration, needless metaprogramming) and prescribes the deep, layer-flattening refactor back to idiomatic Elixir. The diagnostic counterpart to greenfield idiom advice.

---

## Table of Contents

1. [Enterprise Ceremony & Layering](references/_sections.md#1-enterprise-ceremony-&-layering)
   - 1.1 [Collapse stateless Service/Manager modules into contexts](references/arch-context-over-service-objects.md)
   - 1.2 [Delete the Repository/DAO wrapper — Ecto is already the data-mapper](references/arch-delete-repository-over-ecto.md)
   - 1.3 [Drop the dependency-injection behaviour for a single implementation](references/arch-drop-di-behaviour-single-impl.md)
   - 1.4 [Extract decisions into a pure core; keep processes and web a thin shell](references/arch-functional-core-imperative-shell.md)
2. [Processes as Objects](references/_sections.md#2-processes-as-objects)
   - 2.1 [Avoid a single global Manager GenServer that all traffic funnels through](references/proc-no-singleton-manager.md)
   - 2.2 [Avoid using an Agent/GenServer as a mutable variable](references/proc-no-process-as-variable.md)
   - 2.3 [Stop modeling each entity as a process — processes are not objects](references/proc-not-objects.md)
   - 2.4 [Wrap a process behind named client functions, not scattered GenServer.call](references/proc-consolidate-interface.md)
3. [Anemic Data Modeling](references/_sections.md#3-anemic-data-modeling)
   - 3.1 [Decompose a god-struct into composed structs by cohesion](references/type-split-god-struct.md)
   - 3.2 [Dispatch on type with a protocol, not a hand-rolled case/is_* switch](references/type-protocol-over-type-dispatch.md)
   - 3.3 [Encode state as one atom/tagged tuple, not several booleans or strings](references/type-tagged-state-over-flags.md)
   - 3.4 [Model domain entities as structs, not free-form maps](references/type-struct-over-bare-map.md)
4. [Defensive Control Flow](references/_sections.md#4-defensive-control-flow)
   - 4.1 [Assert the expected shape; don't defensively nil-guard everything](references/flow-assertive-over-defensive.md)
   - 4.2 [Model expected outcomes as tagged tuples, not raise/rescue control flow](references/flow-no-exceptions-for-control.md)
   - 4.3 [Validate untrusted input once at the boundary, then trust it in the core](references/flow-normalize-at-boundary.md)
5. [Imperative Iteration](references/_sections.md#5-imperative-iteration)
   - 5.1 [Replace transliterated loops with the named Enum/Stream combinator](references/iter-named-combinator-over-manual-loop.md)
6. [Needless Metaprogramming & Coupling](references/_sections.md#6-needless-metaprogramming-&-coupling)
   - 6.1 [Express configuration as data and functions, not a macro DSL](references/meta-functions-not-macro-dsl.md)
   - 6.2 [Read another module's data at runtime, not into a compile-time attribute](references/meta-no-compile-time-coupling.md)
   - 6.3 [Use import/alias for functions; reserve `use` for real code injection](references/meta-use-is-not-import.md)

---

## References

1. [https://hexdocs.pm/elixir/design-anti-patterns.html](https://hexdocs.pm/elixir/design-anti-patterns.html)
2. [https://hexdocs.pm/elixir/code-anti-patterns.html](https://hexdocs.pm/elixir/code-anti-patterns.html)
3. [https://hexdocs.pm/elixir/process-anti-patterns.html](https://hexdocs.pm/elixir/process-anti-patterns.html)
4. [https://hexdocs.pm/elixir/macro-anti-patterns.html](https://hexdocs.pm/elixir/macro-anti-patterns.html)
5. [https://hexdocs.pm/elixir/protocols.html](https://hexdocs.pm/elixir/protocols.html)
6. [https://hexdocs.pm/elixir/Enum.html](https://hexdocs.pm/elixir/Enum.html)
7. [https://hexdocs.pm/ecto/Ecto.Repo.html](https://hexdocs.pm/ecto/Ecto.Repo.html)
8. [https://hexdocs.pm/ecto/Ecto.Changeset.html](https://hexdocs.pm/ecto/Ecto.Changeset.html)
9. [https://hexdocs.pm/phoenix/contexts.html](https://hexdocs.pm/phoenix/contexts.html)
10. [https://hexdocs.pm/mox/Mox.html](https://hexdocs.pm/mox/Mox.html)
11. [https://www.erlang.org/doc/apps/stdlib/ets.html](https://www.erlang.org/doc/apps/stdlib/ets.html)
12. [https://www.theerlangelist.com/article/spawn_or_not](https://www.theerlangelist.com/article/spawn_or_not)
13. [https://pragprog.com/titles/jgotp/designing-elixir-systems-with-otp/](https://pragprog.com/titles/jgotp/designing-elixir-systems-with-otp/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |