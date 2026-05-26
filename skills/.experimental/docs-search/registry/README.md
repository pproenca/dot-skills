# Registry — Per-Library Topography Records

This directory holds **topography records** — one file per library — capturing the canonical entry points into that library's official documentation. Each record is reference data, not a rule pack: ~30 lines of pure facts that let the next doc-search session skip the discovery phase.

The registry is **intentionally empty at v0.1.0**. The radical-simplification recommendation that produced this skill said: do not pre-empt; add the first entry when a real lookup demands it. If you find yourself writing a record for a library you have not actually queried in this session, stop — the record will rot before it's used.

## When to add a record

Add a record at the **end of a successful doc-search session** for a library that does not yet have one. The work to discover the topography was already done during the lookup; capturing it costs seconds.

See [`references/capture-registry-record.md`](../references/capture-registry-record.md) for the full rule.

## Record format

Each library gets its own file: `registry/<library>.md`, where `<library>` is the lowercase, hyphen-separated name as the library calls itself (`stripe`, `react-hook-form`, `tailwindcss`).

```yaml
---
library: <library-slug>
docs-root: <root-URL-of-docs-site>
llms-txt: <URL of llms.txt> | null   # probed YYYY-MM-DD if null
api-reference: <path or URL>
changelog: <URL>
version-model: semver | dated | unversioned | other
version-selector: <where to find it on docs site, or "none">
upgrades: <URL of migration guides, or null>
samples-repo: <URL, or null>
status-page: <URL, or null>
discord-or-forum: <URL, or null>
notable-landmarks:
  - <one-line description of a useful page or resource>
  - <...>
last-verified: YYYY-MM-DD
---

## <Library name> — topography notes

(Optional prose section: anything that doesn't fit the structured frontmatter
but is useful for the next agent — e.g. "the API reference is split between
/docs/api/<resource> and /docs/<resource>; the former is per-language, the
latter is per-concept", or "the changelog calls breaking changes 'API
Updates', not 'BREAKING'".)
```

## What does NOT belong in a record

- **Idiomatic rules** ("always use X over Y"). Those belong in a full library-reference distillation skill — see [`library-reference-distillation`](../../library-reference-distillation/SKILL.md).
- **API method documentation**. The docs themselves are the source; do not duplicate.
- **Opinions about the library**. Topography is observable; opinions are not.
- **Stale URLs**. If a URL no longer resolves during a lookup that uses this record, the same session must update or remove it.

## Refreshing records

- On every lookup for a library: spot-check the changelog URL still resolves
- If `llms-txt` was `null` and ≥ 90 days have passed: re-probe; the `llms.txt` convention is spreading
- On the library's major version bump: full re-verification of all URLs (docs sites get reorganized at major bumps)
- When a lookup fails because a recorded URL 404s: update the record in the same session

## Retirement

When a full [`library-reference-distillation`](../../library-reference-distillation/SKILL.md) skill ships for a library `X`, retire `registry/X.md` — the full skill subsumes the topography. The registry is for libraries that don't (yet) have a full skill.
