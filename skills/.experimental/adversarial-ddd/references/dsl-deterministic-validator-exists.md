---
title: Ship every external DSL with a deterministic validator
tags: dsl, validation, schema, harness
---

## Ship every external DSL with a deterministic validator

The wrong default is an external DSL — a YAML spec, a JSON config, a text format — whose only validation is whatever the consuming code happens to trip over: unknown fields silently ignored, missing fields silently defaulted, a typo in a key becoming a behavior change. A DSL without a validator gives its authors (human or LLM) no way to know a statement is wrong before it acts, and the errors that do surface are phrased at the implementation's level, not the domain's. The validator is what turns a file format into a language.

**Evidence of violation:** the target defines or consumes an external DSL and no deterministic validation exists anywhere in it — no schema (JSON Schema, protobuf, a typed parse), no parser that rejects malformed input, no check that rejects unknown or missing fields. **Absence is FAIL, not N/A**, whenever the target includes an external DSL — the missing validator is the violation. Demonstrate it: name a malformed input (an unknown key, a missing required field) that the target accepts silently. Internal DSLs in typed host languages pass through the host compiler — cite the compiler as the validator. When the target contains no DSL at all, the rule is N/A — say so.

**Carve-outs (must be cited to claim):** validation living in the consuming tool rather than beside the format is fine — cite where it runs and that it rejects the malformed input above.

**Incorrect (a typo is a silent behavior change):**

```yaml
# deploy.yaml — consumed by a loader that reads known keys and ignores the rest
service: checkout
replicas: 3
helthcheck: /ping   # typo: silently ignored; the service ships with no health check
```

**Correct (the same typo is a domain-level error before anything runs):**

```ts
const DeploySpec = z.strictObject({
  service: z.string(),
  replicas: z.number().int().positive(),
  healthcheck: z.string().startsWith("/"),
})
// strictObject rejects unknown keys:
// "Unrecognized key: 'helthcheck'" — caught at load, phrased at the spec's level
```

Reference: [Unmesh Joshi — DSLs Enable Reliable Use of LLMs (the validator as harness)](https://martinfowler.com/articles/llm-and-dsls.html), [Martin Fowler — Domain-Specific Languages](https://martinfowler.com/dsl.html)
