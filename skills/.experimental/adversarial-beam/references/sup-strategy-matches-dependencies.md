---
title: Match the restart strategy to inter-child dependencies
tags: sup, supervisor, restart-strategy, rest-for-one
---

## Match the restart strategy to inter-child dependencies

`:one_for_one` is the strategy every generator emits, so it gets pasted even where children depend on each other. If child B captures child A's pid at init, subscribes to A, or reads an ETS table A owns, then restarting A alone leaves B holding a dead pid, a dropped subscription, or a vanished table — B is now permanently broken *while looking alive*, the worst failure mode on the BEAM. The children list is ordered by startup dependency; `:rest_for_one` makes the restart order honor the same dependency, restarting the crashed child and everything that depends on it.

**Evidence of violation:** a supervisor with strategy `:one_for_one` (or an unstated strategy defaulting to it) whose children list contains a later child that establishes state from an earlier child *at startup* — captures its pid, monitors or subscribes to it in `init`, or uses an ETS table the earlier child creates and owns. PASS: `:rest_for_one`/`:one_for_all` where such dependencies exist, or `:one_for_one` where children are genuinely independent. N/A: no supervisor with two or more children in the target. Carve-out (citable): the dependent child re-establishes the dependency at use time rather than holding it — it resolves the sibling by registered name on every call, or re-subscribes from a `handle_info` `:DOWN`/retry clause — cite the re-resolution code; a pid or subscription taken once in `init` under `:one_for_one` is the violation.

```elixir
# The consumer subscribes to the connection at init — if the connection dies,
# the consumer must be restarted with it. Order + :rest_for_one encode that.
children = [
  MyApp.Repo,
  MyApp.MarketData.Connection,
  {MyApp.MarketData.Consumer, subscribe_to: MyApp.MarketData.Connection}
]

Supervisor.init(children, strategy: :rest_for_one)
```

Reference: [Erlang/OTP Design Principles — Supervisor Behaviour](https://www.erlang.org/doc/system/sup_princ.html)
