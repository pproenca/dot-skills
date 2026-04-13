---
title: Persist Anonymous Profile Across Tabs and Reloads
impact: MEDIUM-HIGH
impactDescription: prevents profile reset on page refresh
tags: profile, persistence, session-continuity
---

## Persist Anonymous Profile Across Tabs and Reloads

A visitor who refreshes the page, opens a listing in a new tab, or returns an hour later should find their accumulated profile intact — losing it forces the system to cold-start every tab and every return visit, which is exactly the state pre-member personalisation is supposed to escape. The profile must be persisted in a store keyed by the anonymous session token (not by tab state or in-memory Redux), so that any subsequent request for the same session can hydrate the full profile and continue where the previous request left off. This is the essential plumbing that makes progressive profiling actually work.

**Incorrect (profile held in browser tab state, lost on refresh):**

```typescript
const profile = {
  clickedRegions: [] as string[],
  clickedSpecies: [] as string[],
}

function onListingClick(listing: Listing): void {
  profile.clickedRegions.push(listing.region)
  profile.clickedSpecies.push(listing.speciesAccepted)
  rerankHomefeed(profile)
}
```

**Correct (profile persisted in a session-keyed store on the server):**

```typescript
async function onListingClick(anonSession: string, listing: Listing): Promise<void> {
  await profileStore.update(anonSession, {
    clickedRegions: { append: listing.region },
    clickedSpecies: { append: listing.speciesAccepted },
    lastActiveAt: { set: new Date().toISOString() },
  })
  await rerankHomefeed(anonSession)
}

async function hydrateProfile(anonSession: string): Promise<Profile> {
  return profileStore.get(anonSession) ?? emptyProfile()
}
```

Reference: [Treasure Data — Real-Time ID Stitching](https://docs.treasuredata.com/products/customer-data-platform/real-time/real-time-id-stitching-overview)
