# tRPC

**Version 0.1.0**  
community  
July 2026

---

## Abstract

Corrects the wrong defaults a capable model has when writing tRPC v11, pinned to 11.18.0. Covers the v10-to-v11 drift that leaves stale code compiling but wrong — the React client flipping to @trpc/tanstack-react-query, transformers moving into links, renamed type exports, observable subscriptions replaced by async generators over SSE — alongside the defaults that are unsafe rather than merely stale, such as uncapped batching, CDN cache headers that cross users, and middleware ordered ahead of input validation.

---

## Table of Contents

1. [React Client Surface](references/_sections.md#1-react-client-surface)
   - 1.1 [Build React data fetching on the TanStack Query integration](references/client-tanstack-integration.md)
   - 1.2 [Derive query keys from the options proxy](references/client-derive-query-keys.md)
   - 1.3 [Invalidate through queryClient with tRPC query filters](references/client-invalidate-with-query-filters.md)
   - 1.4 [Subscribe with subscriptionOptions on the new client](references/client-subscription-options.md)
2. [v10 → v11 Drift](references/_sections.md#2-v10-→-v11-drift)
   - 2.1 [Match the TypeScript version tRPC and the editor both resolve](references/mig-typescript-version-floor.md)
   - 2.2 [Read unvalidated input with await getRawInput()](references/mig-await-get-raw-input.md)
   - 2.3 [Send FormData as a native input, not through the experimental upload APIs](references/mig-formdata-is-native.md)
   - 2.4 [Use the TRPC-prefixed type exports](references/mig-renamed-type-exports.md)
3. [Router & Procedure Construction](references/_sections.md#3-router-&-procedure-construction)
   - 3.1 [Chain .input() only with object schemas](references/proc-merge-only-object-inputs.md)
   - 3.2 [Compose cross-instance middleware with .concat()](references/proc-concat-over-standalone-middleware.md)
   - 3.3 [Declare .input() before the middleware that reads it](references/proc-input-before-use.md)
   - 3.4 [Initialize tRPC exactly once per application](references/proc-single-trpc-instance.md)
   - 3.5 [Return next({ ctx }) so the guard narrows downstream](references/proc-narrow-ctx-in-middleware.md)
4. [Error & Validation Semantics](references/_sections.md#4-error-&-validation-semantics)
   - 4.1 [Format validation issues from Standard Schema, not just Zod](references/err-format-standard-schema-issues.md)
   - 4.2 [Set isDev explicitly so stack traces never ship](references/err-set-isdev-explicitly.md)
   - 4.3 [Type infinite-query cursors as .nullish()](references/err-nullish-cursor.md)
   - 4.4 [Use .output() as a field-leakage control](references/err-output-strips-fields.md)
5. [Links, Transport & Serialization](references/_sections.md#5-links,-transport-&-serialization)
   - 5.1 [Cap batch size on both the client and the server](references/link-cap-batch-size.md)
   - 5.2 [Configure the data transformer on every terminating link](references/link-transformer-on-terminating-links.md)
   - 5.3 [Default to httpBatchLink, not the streaming variant](references/link-default-to-httpbatchlink.md)
   - 5.4 [Gate responseMeta cache headers on auth, type, and errors](references/link-gate-cache-headers.md)
   - 5.5 [Match the fetch adapter endpoint to the real mount path](references/link-endpoint-matches-mount-path.md)
   - 5.6 [Read batch link headers from opList](references/link-read-batch-headers-from-oplist.md)
   - 5.7 [Route subscriptions through httpSubscriptionLink](references/link-route-subscriptions-separately.md)
   - 5.8 [Scope body parsers away from the tRPC mount path](references/link-scope-body-parsers.md)
6. [SSR, RSC & Server-Side Calls](references/_sections.md#6-ssr,-rsc-&-server-side-calls)
   - 6.1 [Create a QueryClient per request on the server](references/rsc-query-client-per-request.md)
   - 6.2 [Dehydrate pending queries so prefetches stream](references/rsc-dehydrate-pending-queries.md)
   - 6.3 [Prefetch through the server options proxy, not a caller](references/rsc-prefetch-through-options-proxy.md)
   - 6.4 [Share logic as plain functions, not nested callers](references/rsc-share-logic-not-callers.md)
7. [Subscriptions & Streaming](references/_sections.md#7-subscriptions-&-streaming)
   - 7.1 [Attach the event listener before fetching the backlog](references/sub-attach-listener-before-backlog.md)
   - 7.2 [Enable SSE keepalive explicitly](references/sub-enable-sse-keepalive.md)
   - 7.3 [Keep subscription credentials out of the URL](references/sub-keep-credentials-out-of-urls.md)
   - 7.4 [Write subscriptions as async generators](references/sub-write-async-generators.md)

---

## References

1. [https://trpc.io/blog/introducing-tanstack-react-query-client](https://trpc.io/blog/introducing-tanstack-react-query-client)
2. [https://trpc.io/docs/client/links](https://trpc.io/docs/client/links)
3. [https://trpc.io/docs/client/links/httpBatchLink#limiting-batch-size](https://trpc.io/docs/client/links/httpBatchLink#limiting-batch-size)
4. [https://trpc.io/docs/client/links/httpBatchLink#options](https://trpc.io/docs/client/links/httpBatchLink#options)
5. [https://trpc.io/docs/client/links/httpSubscriptionLink#connectionParams](https://trpc.io/docs/client/links/httpSubscriptionLink#connectionParams)
6. [https://trpc.io/docs/client/links/httpSubscriptionLink#server-ping](https://trpc.io/docs/client/links/httpSubscriptionLink#server-ping)
7. [https://trpc.io/docs/client/links/httpSubscriptionLink#setup](https://trpc.io/docs/client/links/httpSubscriptionLink#setup)
8. [https://trpc.io/docs/client/react/useInfiniteQuery](https://trpc.io/docs/client/react/useInfiniteQuery)
9. [https://trpc.io/docs/client/tanstack-react-query/server-components](https://trpc.io/docs/client/tanstack-react-query/server-components)
10. [https://trpc.io/docs/client/tanstack-react-query/setup](https://trpc.io/docs/client/tanstack-react-query/setup)
11. [https://trpc.io/docs/client/tanstack-react-query/usage](https://trpc.io/docs/client/tanstack-react-query/usage)
12. [https://trpc.io/docs/client/tanstack-react-query/usage#queryFilter](https://trpc.io/docs/client/tanstack-react-query/usage#queryFilter)
13. [https://trpc.io/docs/client/tanstack-react-query/usage#queryKey](https://trpc.io/docs/client/tanstack-react-query/usage#queryKey)
14. [https://trpc.io/docs/migrate-from-v10-to-v11](https://trpc.io/docs/migrate-from-v10-to-v11)
15. [https://trpc.io/docs/server/adapters/fetch](https://trpc.io/docs/server/adapters/fetch)
16. [https://trpc.io/docs/server/caching](https://trpc.io/docs/server/caching)
17. [https://trpc.io/docs/server/data-transformers](https://trpc.io/docs/server/data-transformers)
18. [https://trpc.io/docs/server/error-formatting](https://trpc.io/docs/server/error-formatting)
19. [https://trpc.io/docs/server/error-handling](https://trpc.io/docs/server/error-handling)
20. [https://trpc.io/docs/server/middlewares#concat](https://trpc.io/docs/server/middlewares#concat)
21. [https://trpc.io/docs/server/middlewares#context-extension](https://trpc.io/docs/server/middlewares#context-extension)
22. [https://trpc.io/docs/server/non-json-content-types](https://trpc.io/docs/server/non-json-content-types)
23. [https://trpc.io/docs/server/procedures#reusable-base-procedures](https://trpc.io/docs/server/procedures#reusable-base-procedures)
24. [https://trpc.io/docs/server/routers](https://trpc.io/docs/server/routers)
25. [https://trpc.io/docs/server/server-side-calls](https://trpc.io/docs/server/server-side-calls)
26. [https://trpc.io/docs/server/subscriptions](https://trpc.io/docs/server/subscriptions)
27. [https://trpc.io/docs/server/subscriptions#tracked](https://trpc.io/docs/server/subscriptions#tracked)
28. [https://trpc.io/docs/server/validators#input-merging](https://trpc.io/docs/server/validators#input-merging)
29. [https://trpc.io/docs/server/validators#library-integrations](https://trpc.io/docs/server/validators#library-integrations)
30. [https://trpc.io/docs/server/validators#output-validators](https://trpc.io/docs/server/validators#output-validators)
31. [https://trpc.io/faq](https://trpc.io/faq)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |