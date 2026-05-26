---
title: Pin version by API velocity — metadata only for stable, explicit range in SKILL.md for moving
tags: pin, versioning, velocity
---

## Pin version by API velocity — metadata only for stable, explicit range in SKILL.md for moving

By default the agent either pins nothing (the skill silently rots when upstream breaks an API) or pins everything (every minor version bump invalidates the skill). The convention across shipped library-ref skills is to **let API velocity decide the pinning surface**. Pinning is not a uniform discipline — it is a tradeoff between staleness signal and false invalidation.

```text
Stable APIs (Zod 4, React Hook Form v7, MSW v2):
  - SKILL.md heading: NO version mentioned
  - metadata.json:   "version": "1.x.y" (the SKILL version, not the
                      library version)
  WHY: The library's public API has been stable for years. Naming
  the library version in SKILL.md adds noise and creates false
  staleness — readers think the skill expired when it didn't.

Fast-moving APIs (nuqs v2.5–v2.8, Tailwind v4 features in
                  emilkowal-animations):
  - SKILL.md heading: explicit version RANGE
    e.g. "Rules apply to nuqs v2.5 through v2.8"
  - metadata.json:   skill version, plus references[] pointing to
                     pinned changelog URLs
  WHY: The author shipped breaking idiom changes recently. The
  range in the heading is a tripwire — when the upstream releases
  v2.9 with a new pattern, the skill's range is now visibly stale
  and triggers /dev-skill:evolve.

The discriminator:
  - Have ≥2 breaking-idiom changes shipped in the last 12 months?
    → fast-moving → explicit range in SKILL.md
  - Is the public API surface dominated by a few stable verbs the
    author has not touched in years (parse, useForm, http)?
    → stable → metadata only

Anti-pattern:
  Pinning the library version inside metadata.json's "version"
  field. That field is the SKILL's semver, not the library's.
  Conflating them breaks /dev-skill:check-versions.
```

The test: re-read your SKILL.md six months from now. If a stable-API skill names a version it tempts a reader into thinking the skill is outdated when it isn't; if a fast-moving-API skill doesn't name a version range, the rules will silently lie. Pin to match the velocity, not to a uniform discipline.

Reference: [nuqs SKILL.md with explicit "nuqs v2.5–v2.8" range vs zod SKILL.md with no library version](../../../../skills/.curated/nuqs/SKILL.md)
