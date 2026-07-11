---
title: Import from the package root — "zod", not "zod/v4" or "@zod/mini"
tags: pkg, imports, packaging
---

## Import from the package root — "zod", not "zod/v4" or "@zod/mini"

The wrong default is transition-era import paths. `"zod/v4"` was the opt-in subpath while zod@3 still owned the package root; since `zod@4.0.0` (July 2025) the root `"zod"` exports Zod 4, and the subpath survives only as legacy compatibility. `"@zod/mini"` is a stale package name — mini lives at the `"zod/mini"` subpath (with `"zod/v4-mini"` as the legacy alias). Mixed paths in one repo mean two module identities for the same library: duplicated bundles and `instanceof`/registry checks that fail across the seam.

**Evidence of violation:** `from "zod/v4"`, `from "zod/v4-mini"`, or `from "@zod/mini"` in source while `package.json` pins `zod` at major 4.

**Incorrect (transition-era paths on a zod@4 project):**

```ts
import * as z from "zod/v4"
```

**Correct (package root):**

```ts
import * as z from "zod"
```

`"zod/v3"` is the deliberate escape hatch for pinning old behavior during a migration — flag it only if the project claims to be fully on 4.

Reference: [Zod — versioning](https://zod.dev/v4/versioning)
