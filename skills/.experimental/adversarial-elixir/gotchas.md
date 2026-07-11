# Gotchas

Failure points discovered while running this gate. Append-only, with dates.

### Gate proven both ways at conversion (dry run, 2026-07-11)

Two blind reviewers per artifact, identical composed prompt, Elixir ~> 1.18 / Phoenix + Ecto stack:

- **Planted-violation artifact** (three-file "shop" app, all 19 rules violated): both reviewers returned overall FAIL and unanimously failed all 19 rules, each with file:line evidence and a concrete fix. Zero contested rules. The two highest split-risk rules decided cleanly: `arch-functional-core-imperative-shell` (both cited the same `cond`-on-domain-data legs AND the `Repo.insert!/update!` effect legs in one `handle_call`) and `flow-assertive-over-defensive` (both cited the `Map.get` + `else: :ok` swallowing pair).
- **Clean equivalent artifact**: both reviewers returned overall PASS with per-rule evidence; `arch-context-over-service-objects` merged N/A vs N/A → N/A. Zero contested rules.
- Carve-out traps behaved as designed — each PASS was claimed with the required citation, not asserted: the DI behaviour passed only after both reviewers cited the external HTTP boundary AND the `Mox.defmock` line; the multi-aggregate `reduce` passed because no single combinator covers the whole loop (name-the-replacement fired fail-open as intended); the closed three-variant single-site `case` passed via the in-rule carve-out; the `__using__` injecting `@behaviour` + `def` + `defoverridable` passed `meta-use-is-not-import`.
- Convergence note worth keeping: both reviewers independently ruled that message tuples confined to a **dedicated client module** wrapping a per-key server (`Shop.Inventory` client functions over `Shop.Inventory.SkuServer`) do NOT fail `proc-consolidate-interface` — the protocol is confined, not scattered, and the split mirrors the `proc-no-singleton-manager` correct example. Treat that shape as PASS.

Added: 2026-07-11

### Scope guards the reviewers must not override (pre-recorded at conversion)

- This gate judges **architecture the code imported from another paradigm**, not general Elixir style. Pipe-chain taste, `with` versus nested `case`, module length, typespec presence, and test coverage are out of scope — reviewers trained on community lore will try to fail them; the prompt forbids it.
- Two rules FAIL only when the reviewer can produce the replacement: `iter-named-combinator-over-manual-loop` (name the exact combinator) and `meta-functions-not-macro-dsl` (sketch the data + interpreter equivalent). "This reduce looks replaceable" without the name is a PASS.
- `type-split-god-struct` is numeric: the FAIL line is 32 fields (the documented runtime-representation cliff). A 20-field struct that smells incohesive is N/A for the gate, `Out of scope` at most.
- Third-party `use` sites (`use GenServer`, `use Phoenix.LiveView`) and third-party DSLs (Ecto schema, Phoenix router, Absinthe) are never violations of the `meta-` rules — those rules judge only DSLs and `__using__` macros the target itself defines.

Added: 2026-07-11
