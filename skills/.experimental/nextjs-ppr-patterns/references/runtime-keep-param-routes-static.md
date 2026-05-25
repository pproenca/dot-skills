---
title: Keep dynamic-segment routes in the shell with generateStaticParams
tags: runtime, params, generate-static-params, prerender
---

## Keep dynamic-segment routes in the shell with generateStaticParams

The model assumes a dynamic-segment route like `app/blog/[slug]` can't be part of the static shell, so it streams everything behind a boundary. In fact `params` prerenders statically when you provide samples via `generateStaticParams`: those paths render into the shell at build time, and only un-listed params fall back to request-time (which then needs a `<Suspense>` boundary). Supplying `generateStaticParams` is how you keep known dynamic routes fully static.

```tsx
// app/blog/[slug]/page.tsx
export async function generateStaticParams() {
  const slugs = await getAllPostSlugs()
  return slugs.map((slug) => ({ slug })) // these paths prerender into the shell
}

export default async function PostPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params // async in Next.js 16
  return <Article post={await getPost(slug)} />
}
```

Reference: [Caching — runtime APIs (params)](https://nextjs.org/docs/app/getting-started/caching#working-with-runtime-apis)
