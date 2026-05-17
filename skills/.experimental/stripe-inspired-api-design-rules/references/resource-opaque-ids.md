---
title: Treat IDs as Opaque Strings up to 255 Characters
impact: CRITICAL
impactDescription: preserves freedom to change ID format without a version bump
tags: resource, identifiers, opacity, schema-evolution
---

## Treat IDs as Opaque Strings up to 255 Characters

Document and treat every ID as an opaque string of up to 255 characters (`VARCHAR(255) COLLATE utf8_bin` in SQL terms). Don't promise a specific length, character set, or sortability — those guarantees turn into a compatibility contract you can never escape. Stripe explicitly lists "changing the length or format of opaque strings, such as object IDs, error messages, and other human-readable strings" as a backwards-compatible change, which is only true because they never promised the format in the first place.

Integrators who parse, slice, or right-pad your IDs ship code that breaks when you grow from 14 characters to 24. Integrators who store them in fixed-width columns truncate silently. The 255-char ceiling is generous enough to fit any reasonable scheme; the open-ended interior protects every future change.

**Incorrect (documenting structure invites parsing):**

```yaml
# OpenAPI fragment
charge_id:
  type: string
  pattern: "^ch_[a-zA-Z0-9]{24}$"
  description: "Charge ID — always 27 characters: 'ch_' followed by 24 alphanumerics."
```

```text
// Now you can never:
//   - extend to 32 chars when the keyspace runs out
//   - migrate to base62 or another encoding
//   - add a new prefix like `ch_live_` without a major version bump
// Integrators will write `id.slice(3)` and `id.length === 27` checks.
```

**Correct (opaque, length-bounded, format-undocumented):**

```yaml
# OpenAPI fragment
charge_id:
  type: string
  maxLength: 255
  description: "Unique identifier for the charge. Treat as opaque; the format may change."
```

```text
// You can later:
//   - lengthen IDs as scale grows
//   - swap encodings (base62 → base64url)
//   - introduce or retire prefixes
// All non-breaking because clients can't have built dependencies on the format.
```

**Warning:** Be especially careful with fixed-width database columns on the integrator side. Pin documentation to "store in a column wide enough for 255 chars; do not parse."

Reference: [Stripe upgrades — backwards-compatible changes](https://docs.stripe.com/upgrades)
