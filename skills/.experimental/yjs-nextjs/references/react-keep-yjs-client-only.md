---
title: Keep provider construction behind the client boundary
tags: react, server-components, hydration, next
---

## Keep provider construction behind the client boundary

In an App Router codebase the default is a Server Component, and a Yjs editor placed there fails on its dependencies rather than on anything Yjs-specific: `WebsocketProvider` needs `WebSocket` and `IndexeddbPersistence` needs `indexedDB`, neither of which exists during a server render. The more expensive version of the mistake compiles and runs: a `'use client'` component still renders on the server for the initial HTML, so a provider created in the component body opens a connection during SSR, and the document it produces differs between server and client output.

**Incorrect (module-level provider runs during server render):**

```tsx
'use client'
const doc = new Y.Doc()
const provider = new WebsocketProvider(url, 'brief', doc) // constructed while SSR runs

export function BriefEditor() {
  return <Editor doc={doc} />
}
```

**Correct (server renders a shell; the connection opens in an effect):**

```tsx
// app/briefs/[briefId]/page.tsx — Server Component
export default async function BriefPage({ params }: { params: Promise<{ briefId: string }> }) {
  const { briefId } = await params
  const brief = await getBrief(briefId)

  return (
    <main>
      <h1>{brief.title}</h1>
      <BriefEditor briefId={briefId} /> {/* 'use client', connects in useEffect */}
    </main>
  )
}
```

The server can still do useful work: it renders the surrounding page, fetches the brief record, and authorizes access before the client ever asks for a room token. What it cannot do is hold the document.

**Alternative (skip the server render for the editor entirely):** when an editor pulls in a large client-only dependency such as Tiptap, `dynamic(() => import('./brief-editor'), { ssr: false })` keeps it out of the server bundle and out of hydration. Note that `ssr: false` is rejected inside a Server Component, so the `dynamic` call belongs in a `'use client'` module.

Reference: [Next.js — Server and Client Components](https://nextjs.org/docs/app/getting-started/server-and-client-components)
