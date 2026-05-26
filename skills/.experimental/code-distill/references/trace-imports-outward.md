---
title: Follow imports outward from the implementation file to map the public surface
tags: trace, imports, public-surface
---

## Follow imports outward from the implementation file to map the public surface

By default once the agent has found *an* implementation file, it reads only that file and reports its contents as "the pattern." This misses the public boundary — the pattern's true surface is *what gets exported from the library's package entry point*, not what happens to be defined in one internal file. The move is to **trace imports outward** until you arrive at the package's public exports, then report the surface, not the internals.

```text
The outward-trace sequence:

  1. From the implementation file `foo.ts`, read the top: what
     does this file import?

       import { X } from "./bar"
       import { Y } from "./baz"
       import type { Z } from "../types"

  2. Of those imports, identify which are PUBLIC API and which are
     INTERNAL utilities. Heuristics:
       - Public if it's re-exported from the package root
         (check `package.json` "main"/"module" → trace from there)
       - Internal if it's used only inside the same dir
         (Grep for the import path across the rest of the repo)

  3. Follow the public ones outward. Each step:
       File → grep for "export.*<symbol>" in the parent / index file
       → if exported, continue outward; if not, stop.

  4. The terminal node is the package's public entry point:
       index.ts at the package root, OR
       a file named in package.json "exports" / "main" / "module"

  5. Report THIS surface to the user — not the internals.

       "The Slot pattern in <library> is exported as `Slot` and
        `Slottable` from the package root. Implementation lives in
        src/internal/slot.ts, but consumers only import the two
        public names."

Why this matters:
  - Internal implementation files often have multiple alternatives,
    deprecated branches, or experimental code. The PUBLIC surface
    is what the maintainers commit to. Confusing the two leads to
    answers that show off non-public internals as if they were
    idiomatic — they aren't; they could disappear in any patch.

  - For TypeScript libraries, the public surface is also enforced
    by `.d.ts` files. The compiled types are the contract.

Anti-pattern:
  Showing an internal helper function (e.g. `_normalizePropsImpl`)
  as if it were the canonical API just because it's where the
  query-grep landed. If the symbol starts with `_` or is not
  re-exported from the package root, it is internal — name it
  as such or stop describing it as part of the pattern.
```

The mechanical trigger: before reporting "the pattern is X" to the user, confirm that X (or the symbol you're describing) appears in the package's public exports. If you cannot find it via the outward trace, you are showing internals and should reframe.

Reference: [The library-reference-distillation skill's `source-priority-ladder` Tier 4 (TypeScript types as ground truth) — same discipline](../../library-reference-distillation/references/source-priority-ladder.md)
