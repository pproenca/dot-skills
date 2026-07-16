---
title: Separate the semantic model from the DSL's carrier syntax
tags: dsl, semantic-model, separation, architecture
---

## Separate the semantic model from the DSL's carrier syntax

The wrong default is executing while parsing: builder methods that fire the network call, parser branches that mutate the live system as they walk the tree. When syntax and execution are welded together there is no model to inspect, validate, test, or reinterpret — the DSL cannot be dry-run, its statements cannot be checked before they act, and every syntax change is an execution change. The semantic model — a plain data structure the syntax builds and an interpreter consumes — is what makes a DSL a domain artifact rather than a macro.

**Evidence of violation:** DSL, builder, or parser code that performs I/O or mutates live system state **during construction or parsing** — a network call, database write, file write, or process spawn inside builder methods or parse branches — such that the statements cannot be constructed without being executed. Cite the side-effecting call inside the building code and the absence of any intermediate representation between syntax and execution. This rule applies only when the target contains a DSL, fluent builder surface, or declarative spec format; otherwise N/A — say so.

**Carve-outs (must be cited to claim):** build-time **validation** (throwing on an illegal statement while building) is not execution — failing fast is encouraged. A deliberately syntax-tree-as-model design passes when construction and execution are still separate steps: cite the point where the built structure is handed to a distinct run/interpret call.

**Incorrect (constructing the scenario is running the scenario):**

```ts
class DeploymentPlan {
  service(name: string): this {
    kubectl.apply(manifestFor(name)) // executes during construction
    return this
  }
}
```

**Correct (the builder produces a model; an interpreter executes it):**

```ts
class DeploymentPlan {
  private steps: DeployStep[] = []
  service(name: string): this {
    this.steps.push({ kind: "apply", service: name }) // pure data
    return this
  }
  build(): DeploySpec { return { steps: this.steps } }
}

// separate step — the spec can be validated, diffed, and dry-run first
await interpreter.execute(plan.build())
```

Reference: [Martin Fowler — DSL Catalog: Semantic Model](https://martinfowler.com/dslCatalog/semanticModel.html), [Unmesh Joshi — DSLs Enable Reliable Use of LLMs](https://martinfowler.com/articles/llm-and-dsls.html)
