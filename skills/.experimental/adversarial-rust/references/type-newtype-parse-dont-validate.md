---
title: Parse into validated newtypes at the boundary — don't re-validate Strings
tags: type, newtype, parse-dont-validate, validation
---

## Parse into validated newtypes at the boundary — don't re-validate Strings

Threading raw `String`/`u64` values through the core and calling `validate_email(&s)` wherever someone remembers is primitive obsession plus validate-don't-parse: the check's result is thrown away, so nothing stops an unvalidated value from reaching a function that assumes validity — every signature says `String`, and they all lie about what they accept. Parse once at the boundary into a newtype whose constructor is the *only* way to obtain one; from then on `EmailAddress` in a signature is a compiler-enforced proof the check happened, and the core stops defensively re-checking.

```rust
pub struct EmailAddress(String); // field private: TryFrom is the only door

impl TryFrom<String> for EmailAddress {
    type Error = InvalidEmail;

    fn try_from(raw: String) -> Result<Self, InvalidEmail> {
        if raw.split_once('@').is_some_and(|(l, d)| !l.is_empty() && d.contains('.')) {
            Ok(EmailAddress(raw))
        } else {
            Err(InvalidEmail)
        }
    }
}

// Boundary parses; the core takes proof, not promises.
pub fn invite(email: EmailAddress, team: TeamId) { /* no re-validation */ }
```

Pair `TryFrom` with `#[serde(try_from = "String")]` so deserialization runs the same validation — the sibling skill's `types-try-from-newtype-validation` shows the codex-rs version of that wiring.

Reference: [Alexis King — Parse, don't validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/) · [Rust API Guidelines — C-NEWTYPE](https://rust-lang.github.io/api-guidelines/type-safety.html#newtypes-provide-static-distinctions-c-newtype)
