---
title: Use one vocabulary across code, tests, docs, and customer-facing surfaces
tags: lang, ubiquitous-language, documentation, stakeholders
---

## Use one vocabulary across code, tests, docs, and customer-facing surfaces

The wrong default is letting each audience get its own dialect: the model says `Booking`, the README says "reservation", the UI says "Trip", the tests say "trip request". Ubiquitous means ubiquitous — the same words in conversation with stakeholders, in the docs, in the tests, and in the code. Every dialect boundary is a place where a requirement gets silently mistranslated, and it is precisely the team↔stakeholder boundary where the cost lands.

**Evidence of violation:** within the target, (a) its own docs or comments use term X two or more times for the concept the code names Y, with no stated alias tying them; (b) user-facing strings, UI copy, or public API field names use a different noun than the model type that backs them — cite the string and the type (`"Your Trip is confirmed"` rendered from a `Booking`); or (c) test names or descriptions use a different noun (two or more occurrences) than the code under test. One stray word is noise; a repeated parallel vocabulary is the violation.

**Carve-outs (must be cited to claim):** a deliberate customer-facing brand name recorded in the glossary as an alias ("Booking — marketed as *Trip* in the consumer app") — cite the glossary entry. An unrecorded marketing name is the violation, not the excuse.

**Incorrect (three dialects for one concept):**

```ts
// domain/booking.ts
export class Booking { /* ... */ }

// ui/confirmation.tsx
<h1>Your trip is confirmed</h1>

// booking.test.ts
it("creates a reservation when payment clears", () => { /* ... */ })
```

**Correct (one word everywhere, or a recorded alias):**

```ts
// domain/booking.ts
export class Booking { /* ... */ }

// ui/confirmation.tsx — glossary records: "Booking — shown to customers as-is"
<h1>Your booking is confirmed</h1>

// booking.test.ts
it("creates a booking when payment clears", () => { /* ... */ })
```

Reference: [Martin Fowler — UbiquitousLanguage](https://martinfowler.com/bliki/UbiquitousLanguage.html), [Eric Evans — Domain-Driven Design Reference](https://www.domainlanguage.com/ddd/reference/)
