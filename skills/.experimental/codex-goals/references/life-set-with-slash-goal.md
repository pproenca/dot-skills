---
title: Set a Goal with `/goal <text>` — Available from Codex 0.128.0
impact: HIGH
impactDescription: prevents fallback to manual "keep going" prompts that miss the persistence and audit guarantees
tags: life, slash-goal, activation, version
---

## Set a Goal with `/goal <text>` — Available from Codex 0.128.0

Goals are activated by typing `/goal` followed by the objective text. The Goal then persists across turns in the thread, with continuation, evidence checks, and budget accounting attached. Goals require Codex 0.128.0 or later. Before relying on them in a workflow, confirm the installed version with `codex --version`. Older versions silently ignore the command and fall back to treating it as plain text — which means you think you have a persistent objective when you actually have a prompt. Upgrade with `npm install -g @openai/codex@latest` or `brew upgrade --cask codex`.

**Also check feature gating.** Goals shipped as an experimental feature; depending on your version, `/goal` may need to be explicitly enabled (in `config.toml`, via an `/experimental` toggle, or via a CLI flag — the exact mechanism varies by release). The failure mode is the same as version mismatch: the command falls through as plain text and you have a prompt instead of a Goal. If `codex --version` confirms 0.128.0+ but `/goal` doesn't behave persistently, check `codex --help` and the current Codex docs for the feature-enablement step before assuming the Goal is active.

**Incorrect (using a Codex version that doesn't support Goals):**

```bash
$ codex --version
codex 0.124.3

$ codex
> /goal Reduce p95 latency below 120 ms
[Codex treats this as a normal prompt — no Goal is set]
[Next turn: no continuation, no evidence audit, no budget]
```

```text
# The "/goal" text was treated as a regular message. No persistent
# objective exists. The user believes the Goal is active when it isn't.
```

**Correct (verify version, then set Goal):**

```bash
$ codex --version
codex 0.128.0

$ codex
> /goal Reduce p95 checkout latency below 120 ms on bench/checkout
while keeping the correctness suite green
[Goal active]
```

```text
# Version supports Goals. The /goal command sets a persistent objective.
# Subsequent turns benefit from continuation, evidence audit, and
# budget accounting.
```

Reference: [Using Goals in Codex — Quickstart](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
