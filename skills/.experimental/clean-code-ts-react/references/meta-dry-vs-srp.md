---
title: Bend DRY When Concepts Drift Apart
impact: MEDIUM
impactDescription: prevents wrong-abstraction lock-in across modules
tags: meta, dry, srp, coupling
---

## Bend DRY When Concepts Drift Apart

DRY says "extract duplication." SRP says "each module has one reason to change." When two modules look identical today but have **different reasons to change**, DRY forces them to share a fate they shouldn't share. The signal isn't textual similarity — it's whether changes to one should imply changes to the other.

**Incorrect (dogmatic DRY — collapsing distinct concepts):**

```ts
// One function, three callers (Person, User, Customer). Today they all
// just trim and uppercase. Then marketing wants Customer names in title
// case. Then localization team needs Person names with locale rules.
// Then security wants User display names sanitized differently.
// Now formatName is a parameter dump and four callers fear touching it.
function formatName(
  entity: Person | User | Customer,
  opts?: { titleCase?: boolean; sanitize?: boolean; locale?: string }
): string {
  let result = entity.name.trim();
  if (opts?.titleCase) result = toTitleCase(result);
  if (opts?.sanitize) result = sanitizeForDisplay(result);
  if (opts?.locale) result = applyLocaleRules(result, opts.locale);
  return result.toUpperCase();
}
```

**Correct (balanced — separate fates, even at the cost of repetition):**

```ts
// Three callers, three concepts that LOOK the same today but evolve
// independently. Each can grow without breaking the others.
function formatPersonName(person: Person, locale: string): string {
  return applyLocaleRules(person.name.trim(), locale);
}

function formatUserName(user: User): string {
  return sanitizeForDisplay(user.name.trim());
}

function formatCustomerName(customer: Customer): string {
  return toTitleCase(customer.name.trim());
}

// When three of them genuinely converge on identical rules — not before —
// extract the common shape THEN.
```

**When NOT to apply this pattern:**
- When the duplicated code is genuinely the SAME concept (formatting currency for display across the app — one concept, one place).
- When the alternative is bug-prone copy-paste of security-critical or complex logic (validation rules, auth checks, money math) — duplication risk outweighs coupling risk.
- Shared domain types and interfaces — you DO want one canonical `User` type even though it's referenced in many places.

**Why this matters:** DRY removes duplication; SRP separates change. When they conflict, change-locality wins — coupled code that evolves together is fine, decoupled code forced to evolve together becomes a graveyard of conditionals.

Reference: [Clean Code, Chapter 17: Smells and Heuristics](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Sandi Metz — The Wrong Abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction)
