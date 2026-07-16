---
title: Make illegal DSL statements unconstructible or fail-fast at build
tags: dsl, type-state, progressive-interfaces, validation
---

## Make illegal DSL statements unconstructible or fail-fast at build

The wrong default is a permissive surface: a builder that accepts calls in any order and any combination, deferring every domain constraint to a runtime failure deep in execution — or worse, to silence. A DSL's value is that its grammar carries the domain's rules; a surface that lets forbidden statements build has a grammar that says nothing. In typed hosts, progressive interfaces make the illegal statement not compile; in dynamic hosts or external formats, immediate validation at the build call is the equivalent.

**Evidence of violation:** a concrete statement or call ordering that the DSL's own documentation, tests, or error messages declare invalid, which nevertheless **builds without immediate error** — it compiles or parses, and fails only during execution or not at all. The reviewer must exhibit the illegal construction and cite the source declaring it invalid (the doc line, the test, the downstream error). Applies only when the target contains a DSL, builder surface, or declarative spec format; otherwise N/A — say so.

**Carve-outs (must be cited to claim):** a constraint enforced by an **immediate error at the building call** (fail-fast) passes even without type-level enforcement — cite the guard. Constraints that genuinely depend on execution-time state (whether a node is reachable) cannot be enforced at build and are out of this rule's reach — cite why the constraint is runtime-only.

**Incorrect (the forbidden statement builds, and fails an hour into the run):**

```ts
// docs: "a step cannot be declared before the topology is set"
const scenario = new ScenarioBuilder()
  .step(client("alice").writes("key", "v1")) // no topology yet — accepted silently
  .servers("athens", "byzantium")
  .build() // explodes at tick 4_000 with a null peer list
```

**Correct (the grammar itself forbids the ordering):**

```ts
// servers() returns TopologyStage; only TopologyStage has step()
const scenario = ScenarioBuilder.scenario("lost update")
  .servers("athens", "byzantium")   // ScenarioStage → TopologyStage
  .step(client("alice").writes("key", "v1")) // now available
  .build()
// declaring the step first does not compile
```

Reference: [Unmesh Joshi — DSLs Enable Reliable Use of LLMs (progressive interfaces)](https://martinfowler.com/articles/llm-and-dsls.html), [Martin Fowler — Domain-Specific Languages](https://martinfowler.com/dsl.html)
