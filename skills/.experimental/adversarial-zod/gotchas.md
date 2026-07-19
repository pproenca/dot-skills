# Gotchas

### Codec-rule evidence had to be token-anchored before it was decidable
The initial evidence for `compose-codec-for-bidirectional` ("a transform decoding a
serialization format with a hand-written inverse *nearby*") stacked three judgment calls
(what counts as decoding, how near is nearby, is that function really the inverse). The
skill-reviewer flagged it as the gate's contest magnet before any run. Sharpened to: same
module, output type crosses a representation boundary (Date/number/bigint/URL/bytes/parsed
JSON), and the encoder uses a recognizable formatter (`.toISOString()`, `.toString()`,
`JSON.stringify`) on the same field. Both dry-run reviewers then flagged the planted
violation unanimously with identical line spans.
Fix: when a rule's trigger is a *relationship* between two code sites, anchor every leg —
scope (same module), type boundary, and a token the encoder must contain.
Added: 2026-07-11
(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)

### Fail-closed carve-outs keep judgment rules stable
`sem-prefault-for-parsed-defaults` originally excused defaults "written in the input form"
— a semantic judgment. Rewritten so the trigger is purely structural (`.default()` on a
transform/pipe/coerce chain) and the only PASS carve-out is a *demonstrable* fixed point,
with "not demonstrable → FAIL" stated in the rule. Both dry-run reviewers applied the
fixed-point test identically to `.transform(trim).default("  anonymous  ")`.
Added: 2026-07-11
(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)

### Watch item: N/A vs PASS splits on absence-of-subject rules
On the clean fixture the reviewers split N/A/PASS twice (gone-record-two-args: one counted
`z.partialRecord` as a record-family call, the other did not; gone-no-z-interface: one
treated "recursion present, done correctly" as PASS, the other as N/A). Both splits resolve
to PASS under the merge table, so the verdicts were stable — but if a FAIL/N/A split ever
shows up on these rules, tighten what "the rule's subject occurs" means in each rule.
Added: 2026-07-11
(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)

### Dry-run record (proves the gate both ways)
- Clean TanStack Start fixture (top-level formats, strictObject, error param, partialRecord,
  stringbool, getter recursion, z.codec, bare-schema `.validator()`, adapter-free
  validateSearch, root import): PASS + PASS → **PASS**, 0 contested.
- Violating fixture (21 planted violations: transform+`.default()`, exhaustive enum record
  w/ Partial cast, `z.coerce.boolean()` on env, `.ip()`, single-arg `z.record`,
  `required_error`, `.error.errors`, `message` param, `.flatten()`, string-format methods,
  `.strict()`, `.merge()`×2, `z.nativeEnum`, `z.number().int()`, ZodType+lazy recursion,
  transform+manual inverse, `zod-to-json-schema`, `.inputValidator()` + parse-wrapper
  `.validator()`, `zodValidator` adapter, `zod/v4` import, `zod/mini` in a server file):
  FAIL + FAIL → **FAIL**, 21 unanimous rule failures, every planted violation caught with
  file:line evidence and a located fix; the 3 unplanted rules (function factory,
  z.interface, z.promise) went N/A + N/A.
Added: 2026-07-11
(Recorded under the earlier two-reviewer protocol; the gate now dispatches a single blind reviewer.)
