---
title: On evolve, diff the skill against upstream HEAD and codify the drift
tags: pin, evolve, refresh, drift
---

## On evolve, diff the skill against upstream HEAD and codify the drift

By default `/dev-skill:evolve` is treated as "look for things to add." This misses the more dangerous case: the skill's existing rules silently lie because the upstream renamed, restructured, or removed the very API they cite. The move is to **diff your skill against the upstream HEAD before adding anything new**, and codify each drift as either a rule update or a deprecation note. Skills do not grow by accretion; they grow by reconciling with reality.

```text
The drift pattern (canonical case: openai-codex-rust-patterns):

  Skill written against codex-rs at HEAD abc1234 (Jan 2026)
    Rule: "codex.rs::Session never holds connection state directly"

  Six months later, refresh vs HEAD 8a94430 (May 2026)
    codex.rs has been SPLIT into:
      session/lifecycle.rs
      session/transport.rs
      session/state.rs
    The rule's absolute "never does X" is now structurally
    unverifiable — the file it cites no longer exists.

The refresh-vs-HEAD checklist (apply at every /dev-skill:evolve):

  1. Re-clone or pull the upstream repo at HEAD; record the SHA.
  2. For every rule that cites a specific file path, function, or
     type name — grep the upstream for that exact identifier.
       grep -r "codex.rs::Session" .  → 0 matches → drift.
  3. For every rule with an absolute claim ("never", "always",
     "exactly", "only"), grep-check the claim. Codex drift lesson:
     absolutes age the fastest.
  4. For every changelog entry since the last refresh, ask: does
     this entry invalidate or extend any existing rule?
  5. ONLY THEN consider net-new rules.

Output of the refresh: a diff of the skill, not a feature list.
Sometimes the right outcome is "deleted 3 rules, updated 5,
added 1" — and that is healthier than "added 10 new rules" on a
skill whose existing rules secretly drifted.
```

The mechanical trigger: before any `/dev-skill:evolve` work, run a grep-check pass on every absolute claim and every file-path cite. The skills that hold up across upstream changes are the ones where this pass is non-negotiable.

Reference: [openai-codex-rust-patterns skill, refreshed vs HEAD 8a94430 — codex.rs to session/ split](../../../../skills/.experimental/openai-codex-rust-patterns/SKILL.md)
