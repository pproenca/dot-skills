---
title: Enable strict and noUncheckedIndexedAccess in tsconfig
tags: tscfg, strict, tsconfig, indexed-access
---

## Enable strict and noUncheckedIndexedAccess in tsconfig

The wrong default is scaffolding without `strict` (or disabling a strict-family sub-flag like `strictNullChecks` to silence errors) and omitting `noUncheckedIndexedAccess` on the belief that `strict` covers it. It does not: the TS team keeps indexed-access checking out of the strict bundle for legacy-noise reasons, so `usersById[id].name` compiles while crashing on a missing key. In a new app both belong on — they are the compile-time counterpart of every runtime-validation rule in this gate.

**Evidence of violation:** in `tsconfig.json`: `strict` absent or `false`, any `strict*`/`noImplicit*` key explicitly set `false`, or `noUncheckedIndexedAccess` absent or `false`.

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true
  }
}
```

Reference: [TSConfig — strict](https://www.typescriptlang.org/tsconfig/#strict), [TSConfig — noUncheckedIndexedAccess](https://www.typescriptlang.org/tsconfig/#noUncheckedIndexedAccess)
