# Next.js 16 App Router — Partial Prerendering / Cache Components (React 19.2)

**Version 0.1.0**  
dot-skills  
May 2026

---

## Abstract

Partial Prerendering (PPR) patterns for the Next.js 16 App Router under the Cache Components model, from the simplest static-shell-plus-one-hole page to forms and multi-step wizards. Corrects the wrong defaults of a model trained on Next.js 14/15: the removed experimental.ppr flags, implicit caching, Suspense as the static/dynamic boundary, the 'use cache' directive and its constraints, async runtime APIs, server-to-client Promise streaming with use(), and read-your-writes mutations with updateTag.

---

## Table of Contents

1. [Setup & Mental Model](references/_sections.md#1-setup-&-mental-model)
   - 1.1 [Enable PPR with cacheComponents, not the removed experimental flags](references/setup-enable-cache-components.md)
   - 1.2 [Treat everything as dynamic by default and opt into caching](references/setup-dynamic-by-default.md)
2. [The Suspense Boundary](references/_sections.md#2-the-suspense-boundary)
   - 2.1 [Know that Suspense alone does not make work dynamic](references/shell-suspense-does-not-force-dynamic.md)
   - 2.2 [Place Suspense boundaries around the dynamic leaf, not the page](references/shell-place-boundaries-low.md)
   - 2.3 [Treat Suspense as the static/dynamic boundary, not a spinner](references/shell-suspense-is-the-boundary.md)
   - 2.4 [Wrap uncached or runtime reads in Suspense or the build fails](references/shell-wrap-uncached-data.md)
3. [Caching with `'use cache'`](references/_sections.md#3-caching-with-`'use-cache'`)
   - 3.1 [Control cache lifetime and invalidation with cacheLife and cacheTag](references/cache-set-lifetime-and-tags.md)
   - 3.2 [Know that in-memory use cache is not durable on serverless](references/cache-in-memory-not-durable-serverless.md)
   - 3.3 [Let arguments and closures form the cache key automatically](references/cache-keys-are-automatic.md)
   - 3.4 [Mark static and cacheable work with the use cache directive](references/cache-use-cache-directive.md)
   - 3.5 [Pass dynamic children and Server Actions through a cached component](references/cache-pass-through-children-and-actions.md)
   - 3.6 [Read runtime APIs outside the cache and pass values in as props](references/cache-pass-runtime-values-as-props.md)
4. [Runtime APIs & Non-Determinism](references/_sections.md#4-runtime-apis-&-non-determinism)
   - 4.1 [Gate randomness and time behind connection or cache the value](references/runtime-gate-nondeterminism-with-connection.md)
   - 4.2 [Keep dynamic-segment routes in the shell with generateStaticParams](references/runtime-keep-param-routes-static.md)
   - 4.3 [Know that request APIs force a dynamic boundary and are async](references/runtime-request-apis-force-a-boundary.md)
5. [Page Composition Recipes](references/_sections.md#5-page-composition-recipes)
   - 5.1 [Build the canonical page as a static shell with one dynamic hole](references/compose-single-dynamic-hole.md)
   - 5.2 [Do not opt the whole app out of the static shell to silence an error](references/compose-do-not-opt-out-the-shell.md)
   - 5.3 [Give each independent widget its own boundary to stream in parallel](references/compose-parallel-holes.md)
   - 5.4 [Stream server data into a client component with an unawaited Promise and use](references/compose-stream-to-client-with-use.md)
6. [Forms, Mutations & Wizards](references/_sections.md#6-forms,-mutations-&-wizards)
   - 6.1 [Drive wizard steps from the URL and let Activity preserve field state](references/mutate-wizard-url-driven-steps.md)
   - 6.2 [Pick updateTag for read-your-writes after a form mutation](references/mutate-updatetag-vs-revalidatetag.md)

---

## References

1. [https://nextjs.org/blog/next-16](https://nextjs.org/blog/next-16)
2. [https://nextjs.org/docs/app/getting-started/partial-prerendering](https://nextjs.org/docs/app/getting-started/partial-prerendering)
3. [https://nextjs.org/docs/app/getting-started/caching](https://nextjs.org/docs/app/getting-started/caching)
4. [https://nextjs.org/docs/app/getting-started/fetching-data](https://nextjs.org/docs/app/getting-started/fetching-data)
5. [https://nextjs.org/docs/app/api-reference/directives/use-cache](https://nextjs.org/docs/app/api-reference/directives/use-cache)
6. [https://nextjs.org/docs/app/api-reference/config/next-config-js/cacheComponents](https://nextjs.org/docs/app/api-reference/config/next-config-js/cacheComponents)
7. [https://nextjs.org/docs/app/api-reference/functions/cacheLife](https://nextjs.org/docs/app/api-reference/functions/cacheLife)
8. [https://nextjs.org/docs/app/api-reference/functions/cacheTag](https://nextjs.org/docs/app/api-reference/functions/cacheTag)
9. [https://nextjs.org/docs/app/api-reference/functions/connection](https://nextjs.org/docs/app/api-reference/functions/connection)
10. [https://nextjs.org/docs/app/api-reference/functions/generate-static-params](https://nextjs.org/docs/app/api-reference/functions/generate-static-params)
11. [https://nextjs.org/docs/app/guides/preserving-ui-state](https://nextjs.org/docs/app/guides/preserving-ui-state)
12. [https://nextjs.org/docs/app/guides/upgrading/version-16](https://nextjs.org/docs/app/guides/upgrading/version-16)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |