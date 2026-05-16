---
title: Fix the Type That Makes the Null Checks Necessary
impact: MEDIUM
impactDescription: eliminates cascading null checks by modelling the actual cases
tags: defense, null, types, modelling
---

## Fix the Type That Makes the Null Checks Necessary

When a function is half null-check by line count — `if (!user) return; if (!user.profile) return; if (!user.profile.address) return;` — the type is misshapen, not the function. The engineer made everything optional "just in case," and now every reader has to walk through the safety dance. Usually one of these is true: the value is *always* present (drop the `| null`), or the value's absence means a *different case* worth modelling (lift it into a discriminated union).

**Incorrect (a path of null checks because the type was modelled lazily):**

```typescript
type User = {
  id: string;
  profile?: {
    name?: string;
    address?: {
      street?: string;
      city?: string;
      country?: string;
    };
  };
};

function shippingLabel(user: User): string {
  if (!user.profile) return 'No profile';
  if (!user.profile.address) return 'No address';
  if (!user.profile.address.street) return 'Incomplete address';
  if (!user.profile.address.city) return 'Incomplete address';
  if (!user.profile.address.country) return 'Incomplete address';
  return `${user.profile.address.street}, ${user.profile.address.city}, ${user.profile.address.country}`;
  // 6 lines of guarding. Three of them collapse to "incomplete address."
  // The type lets you have a profile with a half-complete address — but does the business?
}
```

**Correct (model the actual cases; the function becomes a switch):**

```typescript
type Address = { street: string; city: string; country: string };

type User =
  | { kind: 'no-profile';  id: string }
  | { kind: 'no-address';  id: string; name: string }
  | { kind: 'shippable';   id: string; name: string; address: Address };

function shippingLabel(user: User): string {
  switch (user.kind) {
    case 'no-profile': return 'No profile';
    case 'no-address': return 'No address';
    case 'shippable':  return `${user.address.street}, ${user.address.city}, ${user.address.country}`;
  }
  // Three cases. Each has exactly the fields it needs.
  // The "partial address" state literally can't exist — the type rules it out.
  // The set of business states is now visible.
}
```

**Or, when the value is genuinely "always there" in this context:**

```typescript
type AuthenticatedUser = {
  id: string;
  profile: { name: string; address: Address };  // no optionality
};

function shippingLabel(user: AuthenticatedUser): string {
  const { street, city, country } = user.profile.address;
  return `${street}, ${city}, ${country}`;
  // The type carries the guarantee. The check happened once, when the user authenticated.
}
```

**Symptoms of "the type is lying about what's optional":**

- A function whose first half is a chain of `if (!x) return ...` and second half is the real work.
- The same chain appears in multiple functions that all consume the same type.
- Optionality on fields that are *always* set together (you have all three or none) — that's a union of cases, not three independent optionals.
- Optionality added because "the API might not return it" — and the API has *always* returned it for years.

**When NOT to use this pattern:**

- The value really is optional, and each absence has its own meaning that the caller cares about. Then the chain is real — use optional chaining (`user.profile?.address?.street ?? 'unknown'`) for readability.
- Modelling discriminated unions across a large codebase is genuinely too disruptive *right now* — defensive checks are fine as an interim. Schedule the real fix.

Reference: [Make Illegal States Unrepresentable](https://blog.janestreet.com/effective-ml-revisited/) (Yaron Minsky); [Parse, Don't Validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/) (Alexis King)
