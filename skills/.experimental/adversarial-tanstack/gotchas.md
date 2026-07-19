# Gotchas

### Contested on dry run: types-justified-nonnull vs process.env.X!
On the initial prove-the-gate dry run (deliberately violating fixture), the two blind
reviewers split N/A vs FAIL on `process.env.DATABASE_URL!` — one read "index access" in
the evidence literally and called a property access out of scope; the other reasoned from
the index-signature type (`string | undefined`). Sharpened the evidence to enumerate
"property access on an index-signature type (`process.env.X!` counts)". A targeted re-run
of the sharpened rule produced a unanimous FAIL.
Fix: keep evidence enumerations type-based, not syntax-based, when the trigger is really
"anything typed `T | undefined`".
Added: 2026-07-11
(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)

### Watch item: as-casts on server-function/query results
Both dry-run reviewers independently marked `data as Project[]` (a `useQuery` result) N/A
under types-parse-external-data because the rule's evidence enumerates `res.json()` /
`JSON.parse` / `localStorage` / route params only — and both flagged it "same smell in
spirit" out of scope. The verdict was stable (N/A + N/A), so the rule stands, but if this
pattern keeps surfacing, decide deliberately: either extend the evidence to cover as-casts
on values that crossed the server-function wire, or keep it excluded because Start types
server-fn results end-to-end and the cast is redundancy, not a boundary hole.
Added: 2026-07-11
(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)

### Dry-run record (proves the gate both ways)
- Clean TanStack Start fixture (validator + POST mutation + auth middleware + getRouter
  factory + useSuspenseQuery + strict tsconfig): PASS + PASS → **PASS**, 0 contested.
- Violating fixture (module-scope process.env + db, `.inputValidator()` passthrough,
  GET-default mutation, beforeLoad-only auth, singleton QueryClient/router, useQuery on
  loader-ensured data, `new Date()` in render, `verbatimModuleSyntax: true`, missing
  noUncheckedIndexedAccess/erasableSyntaxOnly): FAIL + FAIL → **FAIL**, 11 unanimous rule
  failures, every planted violation caught with file:line evidence and a located fix.
Added: 2026-07-11
(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)
