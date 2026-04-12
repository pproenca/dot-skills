---
title: Gate experimental fields by runtime presence, not capability flags
impact: MEDIUM-HIGH
impactDescription: enables adding unstable fields to stable methods without duplicating the request type
tags: proto, experimental, macros, versioning
---

## Gate experimental fields by runtime presence, not capability flags

Adding an unstable field to a stable method normally forces you to either duplicate the whole request type (`StableThreadStartParams` vs `ExperimentalThreadStartParams`) or make every caller opt into an "experimental" capability just to call the stable part. Codex has a `#[derive(ExperimentalApi)]` proc-macro plus `#[experimental("method.fieldName")]` attributes. The generated impl walks the struct at runtime and returns a reason string *only if that field is actually present with a non-default value* — empty Vec, false, or None all count as "not using the experimental feature".

**Incorrect (duplicate request types for every experimental field):**

```rust
// Two parallel types, each adds bloat for every stable field:
pub struct StableThreadStartParams { /* 20 fields */ }
pub struct ExperimentalThreadStartParams {
    /* 20 fields + experimental_dynamic_tools: Vec<Tool> */
}
```

**Correct (runtime presence check via derive macro):**

```rust
// codex-experimental-api-macros/src/lib.rs
fn presence_expr_for_access(
    access: proc_macro2::TokenStream,
    ty: &Type,
) -> proc_macro2::TokenStream {
    if let Some(inner) = option_inner(ty) {
        let inner_expr = presence_expr_for_ref(quote!(value), inner);
        return quote! {
            #access.as_ref().is_some_and(|value| #inner_expr)
        };
    }
    if is_vec_like(ty) || is_map_like(ty) {
        return quote! { !#access.is_empty() };
    }
    if is_bool(ty) {
        return quote! { #access };
    }
    quote! { true }
}

// app-server-protocol/src/experimental_api.rs
impl<T: ExperimentalApi> ExperimentalApi for Option<T> {
    fn experimental_reason(&self) -> Option<&'static str> {
        self.as_ref()
            .and_then(ExperimentalApi::experimental_reason)
    }
}
```

Reason strings follow a reverse-DNS-ish scheme (`thread/start.dynamicTools`, `askForApproval.granular`) that maps 1:1 to the wire method and field name. The dispatcher calls `experimental_reason()` after parsing; if the client did not negotiate `experimentalApi: true` during `initialize` and a reason is returned, the method is rejected.

Reference: `codex-rs/codex-experimental-api-macros/src/lib.rs:260`.
