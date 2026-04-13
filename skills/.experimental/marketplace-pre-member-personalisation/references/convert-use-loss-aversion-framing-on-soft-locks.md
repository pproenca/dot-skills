---
title: Use Loss-Aversion Framing on Soft-Locked Content
impact: MEDIUM-HIGH
impactDescription: 2-3x stronger than equivalent gain framing
tags: convert, loss-aversion, kahneman
---

## Use Loss-Aversion Framing on Soft-Locked Content

Kahneman and Tversky's prospect theory showed that losses are psychologically weighted roughly 2-3× gains of the same magnitude, and decades of replication confirm the effect holds across domains. For pre-member conversion, this means that framing the paywall as "you will lose access to the sitters you bookmarked" converts materially better than "upgrade to save your bookmarks". The visitor must have first invested something to lose — bookmarks, saved searches, draft messages — which is why the soft-lock pattern (let the visitor accumulate state, then reference the loss when they hit the paywall) outperforms an immediate hard wall.

**Incorrect (generic gain framing with nothing for the visitor to lose):**

```typescript
function UpgradePrompt() {
  return (
    <div>
      <h3>Upgrade for more features</h3>
      <p>Save listings, contact sitters, and apply to stays.</p>
      <button>Upgrade</button>
    </div>
  )
}
```

**Correct (loss framing references specific accumulated state):**

```typescript
async function UpgradePrompt({ visitorId }: { visitorId: string }) {
  const bookmarked = await savedListings.count(visitorId)
  const drafted = await drafts.count(visitorId)

  if (bookmarked === 0 && drafted === 0) {
    return <SoftCTA>Browse more listings to save your favourites</SoftCTA>
  }

  return (
    <div>
      <h3>Don't lose what you've built</h3>
      <p>
        You have{" "}
        {bookmarked > 0 && <strong>{bookmarked} saved sitters</strong>}
        {bookmarked > 0 && drafted > 0 && " and "}
        {drafted > 0 && <strong>{drafted} draft messages</strong>}
        {" "}waiting for you. Join now to keep them.
      </p>
      <button>Save my progress and join</button>
    </div>
  )
}
```

Reference: [Kahneman and Tversky — Prospect Theory: An Analysis of Decision under Risk (Econometrica 1979)](https://www.jstor.org/stable/1914185)
