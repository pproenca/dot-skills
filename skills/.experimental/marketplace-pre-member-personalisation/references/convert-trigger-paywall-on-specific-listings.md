---
title: Trigger the Paywall on Specific Listings, Not Generic Upgrade Prompts
impact: MEDIUM-HIGH
impactDescription: enables cognitive-ease conversion
tags: convert, specific, paywall
---

## Trigger the Paywall on Specific Listings, Not Generic Upgrade Prompts

The Fogg Behavior Model identifies a trigger as the third leg of any behaviour change, alongside motivation and ability. Generic upgrade triggers ("become a member to unlock features") produce weaker conversion than specific triggers attached to an object the visitor is actively evaluating ("to message Sarah, become a member"). The specific trigger has higher motivation because it references a concrete thing the visitor has already chosen to care about, and lower ability cost because the next step is obvious. Pair the paywall trigger to the specific listing or action the visitor attempted, not to a homepage upgrade CTA.

**Incorrect (generic upgrade modal disconnected from what the visitor clicked):**

```typescript
function PaywallModal({ isOpen, onClose }: Props) {
  return (
    <Modal open={isOpen} onClose={onClose}>
      <h2>Upgrade to membership</h2>
      <p>Unlock all platform features for £129/year.</p>
      <ul>
        <li>Message any sitter</li>
        <li>Apply to any stay</li>
        <li>See verified profiles</li>
      </ul>
      <button>Join now</button>
    </Modal>
  )
}
```

**Correct (paywall trigger references the specific listing the visitor clicked):**

```typescript
function PaywallModal({ listing, triggeringAction }: Props) {
  return (
    <Modal open>
      <ListingCard listing={listing} />
      <h2>
        To {triggeringAction === "message" ? "message" : "apply to"}{" "}
        {listing.sitterFirstName}, become a member
      </h2>
      <p>
        {listing.sitterFirstName} has completed {listing.sitter.completedStays} stays
        and typically replies within {listing.sitter.avgResponseHours} hours.
      </p>
      <p>
        Membership is £129/year — about {Math.round(129 / kennelRate)} nights at a
        local kennel.
      </p>
      <button>Join to message {listing.sitterFirstName}</button>
    </Modal>
  )
}
```

Reference: [BJ Fogg — A Behavior Model for Persuasive Design](https://bjfogg.com/fbm_files/page4_1.pdf)
