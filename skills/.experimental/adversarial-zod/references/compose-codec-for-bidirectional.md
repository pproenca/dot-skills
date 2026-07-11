---
title: Use z.codec() for bidirectional wire transforms
tags: compose, codecs, transforms, serialization
---

## Use z.codec() for bidirectional wire transforms

The wrong default is Zod 3-era one-way thinking: a `.transform()` schema that decodes a wire format (ISO string to Date, string to number, JSON string to object) paired with a hand-written inverse function to encode on the way back out. The two directions drift independently and only one of them is validated. Since zod@4.1, `z.codec(inputSchema, outputSchema, { decode, encode })` declares both directions in one place, and `z.decode()` / `z.encode()` (plus `safeDecode`/`safeEncode`/async variants) validate both. Calling `z.encode()` on a plain `.transform()` schema throws — transforms are one-way by design.

**Evidence of violation:** both of these in the **same module**: (a) a `.transform()` whose decode crosses a representation boundary — its output is a `Date`, `number`, `bigint`, `URL`, byte array, or object parsed from a string input; and (b) a function or sibling schema that maps that same schema's output type back to its input representation via `.toISOString()`, `.toString()`, `String(...)`, `JSON.stringify`, or an equivalent formatter applied to the same field. Normalizing transforms that stay in the same representation (`.trim()`, `.toLowerCase()`) are out of scope, and a decode with no in-module encoder is a PASS for this rule.

**Incorrect (decode is validated, the hand-rolled encode is not):**

```ts
const Meeting = z.object({
  startsAt: z.iso.datetime().transform((s) => new Date(s)),
})

function serializeMeeting(m: { startsAt: Date }) {
  return { startsAt: m.startsAt.toISOString() } // drifts independently of the schema
}
```

**Correct (one codec, both directions validated):**

```ts
const isoDatetimeToDate = z.codec(z.iso.datetime(), z.date(), {
  decode: (iso) => new Date(iso),
  encode: (date) => date.toISOString(),
})

const Meeting = z.object({ startsAt: isoDatetimeToDate })

const parsed = z.decode(Meeting, { startsAt: "2026-07-11T10:00:00Z" }) // { startsAt: Date }
const wire = z.encode(Meeting, parsed)                                 // { startsAt: string }
```

One-way `.transform()` remains correct when nothing ever encodes back — the violation requires both directions to exist in the target.

Reference: [Zod — codecs](https://zod.dev/codecs)
