---
title: Represent Birth Dates as `{day, month, year}` Hashes
impact: CRITICAL
impactDescription: eliminates locale-string parsing ambiguity for collected dates
tags: resource, dates, birthdate, structured
---

## Represent Birth Dates as `{day, month, year}` Hashes

Birth dates and other dates collected via three separate form inputs should be represented as a hash with integer `day`, `month`, and `year` fields — not as a string. UIs collect them as three discrete inputs; a structured object maps naturally to those inputs, removes locale-parsing ambiguity (`"02/03/1990"` is March 2 in the US and February 3 almost everywhere else), and avoids the silent failure of a consumer treating DD/MM/YYYY as MM/DD/YYYY.

Stripe applies this pattern to dob fields on Persons (Connect) and Identity Verification. The integer triple is unambiguous, sortable component-by-component, and trivially convertible to any locale's display format.

**Incorrect (locale-string date):**

```json
{
  "dob": "14/02/1990"
}
```

```text
// UK locale: 14 February 1990. US locale: invalid (no month 14).
// Round-tripping through Date constructors guesses wrong half the time.
// Form inputs in three fields had to be concatenated and re-parsed.
```

**Incorrect (ISO 8601 string for a structured form input):**

```json
{
  "dob": "1990-02-14"
}
```

```text
// Better than locale strings, but still wrong shape for a 3-field UI.
// Forces client to concatenate three inputs into a string and back.
// Partial dates (year known, month unknown) cannot be represented.
```

**Correct (`{day, month, year}` integer hash):**

```json
{
  "dob": {
    "day": 14,
    "month": 2,
    "year": 1990
  }
}
```

```text
// Maps one-to-one with the three form inputs.
// Each field is a small integer — no parsing, no locale guesswork.
// Partial dates degrade gracefully (omit the unknown component).
```

**Common use cases:**
- Birth dates on KYC, Connect Persons, Identity Verification
- Expiration dates for cards (`exp_month`, `exp_year` integer pair — same principle)
- Any "date assembled from discrete user inputs" field

**For date-only values that aren't assembled from user inputs** (billing dates, period boundaries), use ISO 8601 date strings — see [`resource-iso-date-only`](resource-iso-date-only.md). For datetimes with a time component, see [`resource-unix-seconds-timestamps`](resource-unix-seconds-timestamps.md).

Reference: [Stripe Person.dob (Connect)](https://docs.stripe.com/api/persons/object#person_object-dob)
