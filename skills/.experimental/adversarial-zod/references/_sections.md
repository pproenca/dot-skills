# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
decisions that come up most often and cost most when wrong go first.

---

## 1. Silent Semantic Breaks (sem)

**Description:** Zod 3 intuitions that still type-check on zod@4 but behave differently at runtime — defaults that skip parsing, enum-keyed records that became exhaustive, truthiness coercion on string flags. The costliest class because neither tsc nor tests written against the old mental model catch them.

## 2. Removed APIs (gone)

**Description:** Zod 3 surface that no longer exists in zod@4 — code that fails to compile, throws, or references properties that are gone. Includes the `z.interface()` hallucination that never shipped in any stable release.

## 3. Error Customization & Formatting (err)

**Description:** The unified `error` param that replaced `message`, and the top-level tree-shakable error formatters that replaced ZodError methods. Error-handling code is user-facing, so stale patterns here ship visible regressions.

## 4. Deprecated Method Forms (dep)

**Description:** Method chains superseded by top-level functions — string formats, object strictness variants, `.merge()`, `z.nativeEnum()`, number integer checks, promise schemas. Still working today, scheduled for removal in the next major, and the highest-frequency stale pattern in model-generated code.

## 5. Composition, Recursion & Codecs (compose)

**Description:** Schema composition patterns v4 made obsolete — annotation-heavy `z.lazy()` recursion, hand-paired transform/inverse functions at wire boundaries, and the external `zod-to-json-schema` dependency replaced by native conversion.

## 6. TanStack Start Integration (start)

**Description:** Passing Zod 4 schemas directly where Standard Schema support made adapters and wrappers obsolete — server-function validators and route search-param validation.

## 7. Packaging & Imports (pkg)

**Description:** Import-path currency and the zod/mini decision. Legacy subpaths and the functional mini API in contexts where its DX tax buys nothing.
