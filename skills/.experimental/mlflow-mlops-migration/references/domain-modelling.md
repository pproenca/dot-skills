# Phase 1 — Registry Domain Modelling

The registry is a domain model, not a dumping ground. This phase decides — with the developer,
before any code changes — what gets a name, what the names mean, and what evidence moves a model
between environments. The output is a short document the whole team can read; every later phase
implements it.

## Interview

Work through these in order; write the answers down as you go.

1. **What predictions does the business consume?** Each independently-deployed prediction is one
   registered model *per environment*. A retrained weekly model and its daily-scoring consumer
   are one model; a churn model and an LTV model are two, even if one pipeline trains both.
2. **What does "better" mean, numerically?** For each model: the gate metric (F1, RMSE, AUC…),
   the evaluation dataset it's measured on, and the threshold or minimum improvement over the
   current champion. "The data scientist looks at it" is a valid gate — record it as *manual
   approval* explicitly, with who approves.
3. **Who may promote, per environment?** Dev → staging is usually automatic on a passed gate;
   staging → prod usually adds a human. This becomes auth configuration in phase 2 and pipeline
   shape in phase 4.
4. **What history matters?** Which past experiments/models must survive the migration (feeds the
   phase-2 migrate-or-abandon decision).

## Naming scheme

One registered model per environment × problem, named `<env>.<namespace>.<model_name>`:

```text
dev.growth.churn_classifier        ← every training run registers here
staging.growth.churn_classifier    ← gate-approved candidates, copied by the pipeline
prod.growth.churn_classifier       ← serving reads only from here
```

- `<env>` ∈ `dev | staging | prod` — fixed by this workflow.
- `<namespace>` — team or business domain (`growth`, `risk`); one word, lowercase. Goes in
  `config.json` as `registry_namespace`.
- `<model_name>` — the problem, lowercase snake_case. Not the algorithm: `churn_classifier`,
  not `xgb_v2` — algorithms change inside a model name, that's what versions are for.

Why per-environment models rather than one model with environment aliases: access control binds
to registered models, so `prod.*` can be writable only by the promotion pipeline; and copying a
version preserves full lineage while leaving the source environment's history intact. This is
the official OSS pattern (see sibling rule `reg-per-environment-registered-models`).

## Alias vocabulary

Fix the alias names now so scripts and serving configs never improvise:

| Alias | On | Meaning |
|-------|----|---------|
| `@champion` | staging, prod | What serving loads. Flipping it *is* the deploy. |
| `@challenger` | staging, prod | Candidate under comparison against the champion. |
| `@candidate` | dev, staging | Passed the gate, awaiting promotion to the next env. |

Constraints: alias names `latest` and `v<number>` are reserved by MLflow; keep the vocabulary to
these three unless a real workflow needs more — every extra alias is a pointer someone must keep
truthful.

## Gate state

Gate progress lives in model-version tags (aliases say *what is deployed*, tags say *what has
been checked*): `validation_status` moves `pending → approved | rejected`, set only by the
evaluation pipeline (phase 4), never by hand. Add domain tags sparingly — each one must have a
writer and a reader, or it rots.

## Experiments

One experiment per model per purpose: `churn-classifier` for training runs,
`churn-classifier-eval` if evaluation runs would otherwise drown the training view. Resist
per-developer or per-week experiments — filtering and comparison happen *inside* an experiment,
so scattering runs across many experiments hides exactly the comparisons MLflow is for.

## Deliverable

A one-page doc: the table of registered models (all three envs × each problem), the alias
vocabulary, each model's gate (metric + dataset + threshold + who/what approves), and the
experiment names. Get an explicit yes from the developer, then fill `registry_namespace`,
`model_name`, `experiment_name` in `config.json`.
