---
title: {Decision-oriented title — the decision this rule settles}
tags: {prefix}, {concept}, {concept}
---

## {Same title as the frontmatter}

{1–3 sentences of WHY. Name the wrong default a capable model has here, and the
concrete consequence of leaving it uncorrected. For this skill the consequence is
usually one of: a widget that renders empty, a number that is wrong without any
error, or a payload the API rejects. Say which.}

```json
{the canonical form — realistic service and metric names, never placeholders}
```

{Optional: a second paragraph for the constraint, exception, or neighbouring trap
that follows from the same reasoning.}

Reference: [{source title}]({url})

## Notes for adding a rule here

- The first tag must equal the filename prefix (`query-foo.md` → first tag `query`).
- The H2 must match the frontmatter `title` exactly.
- Every fenced block needs a language (`json`, `text`, `bash`).
- Add an `**Incorrect (why it fails):**` / `**Correct (what changes):**` pair only
  when the wrong way is a real trap someone would write. A strawman costs tokens
  and teaches nothing. Annotations must describe the specific failure, not "(bad)".
- Do not restate widget schemas — `get_widget_reference` returns them current at
  call time. Rules here cover what that tool cannot tell you.
- Cite Datadog primary sources only: docs.datadoghq.com, datadoghq.dev, the
  Datadog engineering blog, or the published OpenAPI specs.
- Datadog ships continuously. When adding a rule, note what you verified and when,
  so the next editor knows what has aged.
