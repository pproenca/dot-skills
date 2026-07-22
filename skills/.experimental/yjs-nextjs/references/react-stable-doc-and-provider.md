---
title: Create the document and provider once per room
tags: react, lifecycle, strict-mode, useeffect
---

## Create the document and provider once per room

A `Y.Doc` constructed in a component body is a new document on every render, which loses local state and opens a fresh connection each time. The instinctive fix — `useMemo` — is worse than it looks, because a memoized value has no cleanup path, so React can discard it without the provider ever disconnecting. Strict Mode then exposes the third variant: React "will also run one extra setup+cleanup cycle in development for every Effect," so an effect that creates a document but tears it down partially leaves the second mount holding a destroyed document, and the editor is dead in development while working in production.

Own the whole lifecycle in one effect keyed by the room, and render nothing until it exists.

**Incorrect (new document per render, no teardown path):**

```tsx
export function BriefEditor({ briefId }: { briefId: string }) {
  const doc = useMemo(() => new Y.Doc(), []) // never destroyed; survives nothing
  const provider = useMemo(() => new WebsocketProvider(url, briefId, doc), [briefId])
```

**Correct (created and destroyed together, keyed by room):**

```tsx
export function BriefEditor({ briefId }: { briefId: string }) {
  const [session, setSession] = useState<{ doc: Y.Doc; provider: WebsocketProvider } | null>(null)

  useEffect(() => {
    const doc = new Y.Doc()
    const provider = new WebsocketProvider(process.env.NEXT_PUBLIC_COLLAB_URL!, `brief:${briefId}`, doc)
    setSession({ doc, provider })

    return () => {
      provider.destroy() // disconnects, removes awareness and doc listeners
      doc.destroy()
      setSession(null)
    }
  }, [briefId])

  if (!session) return <EditorSkeleton />
  return <BriefFields doc={session.doc} provider={session.provider} />
}
```

Teardown has to be complete for the Strict Mode remount to succeed: `provider.destroy()` clears the reconnect timers and detaches the awareness and document listeners, where `provider.disconnect()` only closes the socket and leaves the instance subscribed. Destroying the document last also cascades to any persistence provider attached to it.

Reference: [React — StrictMode](https://react.dev/reference/react/StrictMode)
