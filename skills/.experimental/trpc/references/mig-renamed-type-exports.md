---
title: Use the TRPC-prefixed type exports
tags: mig, types, deprecations, migration
---

## Use the TRPC-prefixed type exports

Generic tRPC helpers get written against v10 names — `AnyRouter`, `AnyProcedure`, `ProcedureType`, `DataTransformer` — because that is what a decade of tRPC code on the internet uses. v11 prefixed the public type surface with `TRPC` to stop it colliding with application types of the same name. Most of the old names still resolve: they ship as `@deprecated` aliases, so the build is green, the editor shows a strikethrough nobody reads in a diff, and the staleness survives review intact. They are slated for removal, and by then the helper is load-bearing.

| v10 | v11 |
| --- | --- |
| `AnyRouter` | `AnyTRPCRouter` |
| `AnyProcedure` | `AnyTRPCProcedure` |
| `AnyMiddlewareFunction` | `AnyTRPCMiddlewareFunction` |
| `ProcedureType` | `TRPCProcedureType` |
| `DataTransformer` | `TRPCDataTransformer` |
| `CombinedDataTransformer` | `TRPCCombinedDataTransformer` |
| `getErrorShape` | `getTRPCErrorShape` |
| `inferAsyncReturnType<typeof fn>` | `Awaited<ReturnType<typeof fn>>` |
| `createTRPCProxyClient` | `createTRPCClient` |
| `createProxySSGHelpers` / `createSSGHelpers` | `createServerSideHelpers`, from `@trpc/react-query/server` |

`inferAsyncReturnType` has no prefixed replacement — it was a plain TypeScript utility, so use the built-ins. The SSG helper is worth checking against the package rather than the docs: the migration guide says `createProxySSGHelpers` was "renamed to `createSSGHelpers`", but neither identifier exists in 11.18.0 — `@trpc/react-query@11.18.0/src/server/index.ts` re-exports exactly one symbol, `createServerSideHelpers`, and that is what the subpath gives you.

Two more v10 names are **deleted outright, with no alias behind them**:

| deleted in v11 | write instead |
| --- | --- |
| `inferHandlerInput<T>` | `inferProcedureInput<T>` |
| `ProcedureArgs<T>` | `TRPCProcedureOptions`, moved to `@trpc/client` |

The distinction matters for how you find them: the aliased names above keep compiling, so they only surface if someone reads the strikethrough, while these two break the build the moment you upgrade — worth expecting as noise in the first `tsc` run rather than as a real regression. `ProcedureArgs` is also the one entry that changes package: importing `TRPCProcedureOptions` from `@trpc/server` fails.

```ts
import type { AnyTRPCRouter, inferRouterOutputs } from '@trpc/server';
import type { AppRouter } from '~/server/routers/_app';

// generic helpers take the prefixed router type
export function describeRoutes<TRouter extends AnyTRPCRouter>(
  router: TRouter,
): string[] {
  return Object.keys(router._def.procedures);
}

// unchanged in v11 — these two keep their v10 names
type RouterOutputs = inferRouterOutputs<AppRouter>;
type Invoice = RouterOutputs['invoice']['byId'];
```

`inferRouterInputs` and `inferRouterOutputs` were **not** renamed, and neither were `inferProcedureInput` / `inferProcedureOutput`. A rename sweep that regexes `infer*` into `inferTRPC*` breaks a working codebase — the prefix applies to the router, procedure, middleware, and transformer types listed above, not to the inference helpers as a family.

Reference: [tRPC — Migrate from v10 to v11](https://trpc.io/docs/migrate-from-v10-to-v11)
