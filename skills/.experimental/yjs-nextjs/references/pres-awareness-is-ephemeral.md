---
title: Keep presence in awareness rather than in the document
tags: pres, awareness, presence, cleanup
---

## Keep presence in awareness rather than in the document

Cursors, selections and "who is here" are shared state, so they get written into the `Y.Doc` alongside the content. Everything in a document is permanent and versioned by design: presence entries survive disconnection, accumulate one stale record per visitor forever, and appear in undo history and snapshots. Awareness exists for exactly this data and is deliberately not part of the document — Yjs states that "the feature is not part of the `yjs` module", and the `Awareness` class documents itself as a protocol "for non-persistent data like awareness information (cursor, username, status, ..)" (`y-protocols@1.0.7/awareness.js`). Its state lives in plain maps on the instance and expires on a timer.

**Incorrect (presence written into the document, never cleaned up):**

```typescript
doc.getMap('presence').set(userId, { name, colour, cursor: 42 })
```

**Correct (presence in awareness, keyed automatically by client):**

```typescript
provider.awareness.setLocalStateField('user', { name: session.user.name, colour })

provider.awareness.on('change', () => {
  setCollaborators(
    Array.from(provider.awareness.getStates().entries())
      .filter(([clientId]) => clientId !== doc.clientID)
      .map(([clientId, state]) => ({ clientId, ...state.user })),
  )
})
```

Awareness expires on its own — states must be refreshed within 30 seconds or peers drop them, and the protocol re-broadcasts the local state every 15 seconds to keep it alive — so a crashed tab eventually disappears without intervention. Announcing departure explicitly is still worth doing, because 30 seconds of a ghost avatar is visible to every other user.

Announce it *before* tearing anything down. `WebsocketProvider.destroy()` removes every **remote** client's state from this tab's view and detaches its listeners, but it does not clear your own state for peers: the handler that does that is registered under `if (env.isNode && typeof process !== 'undefined')`, so it never runs in a browser. `doc.destroy()` does clear the local state, but by then the socket is closed and the message reaches nobody — leaving a ghost on every other client until the timeout.

```typescript
useEffect(() => {
  const announceDeparture = () =>
    removeAwarenessStates(provider.awareness, [doc.clientID], 'left')

  window.addEventListener('beforeunload', announceDeparture)

  return () => {
    window.removeEventListener('beforeunload', announceDeparture)
    announceDeparture() // must precede teardown, while the socket can still send
    provider.destroy()
    doc.destroy()
  }
}, [provider, doc])
```

The Yjs documentation frames the call itself as best-effort: "It is not strictly necessary, because the Awareness CRDT will notice that you are offline after a timeout. But you can at least try."

Reference: [y-protocols awareness.js](https://github.com/yjs/y-protocols/blob/v1.0.7/awareness.js)

Reference: [Yjs — Awareness](https://docs.yjs.dev/api/about-awareness)
