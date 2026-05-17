---
title: Pin TTL to Personalize Solution Version, Not Wall Clock
impact: HIGH
impactDescription: prevents serving previous-model output for hours after retrain
tags: ttl, personalize, solution-version, retrain, invalidation
---

## Pin TTL to Personalize Solution Version, Not Wall Clock

A wall-clock TTL ("expires 30 minutes from write") is independent of the model's actual freshness. When Personalize retrains at 02:00, every cache entry from 01:50-02:00 keeps serving the previous model's output until its individual TTL expires — sometimes hours after the model retrained. The fix is to bind TTL to the *solution version*: when the version changes, the cache invalidates immediately. This combines two mechanisms: (1) the solution version in the cache key so old keys become orphan ([key-version-the-model](key-version-the-model.md)), and (2) on retrain event, sweep or invalidate the old keys so memory frees.

**Incorrect (wall-clock TTL only — old-model results linger):**

```typescript
// Cache key has no version info
async function getRecs(cohort: string, surface: string, locale: string) {
  const key = `recs:${surface}:${cohort}:${locale}`;
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  const fresh = await personalize.getRecommendations({ /* ... */ });
  await redis.set(key, JSON.stringify(fresh), 'EX', 1800);  // 30 min
  return fresh;
}

// 02:00: retrain finishes. Active solution version → v43.
// 02:00-02:30: half the traffic continues to read cache entries from v42.
//   - A/B logs split between v42 and v43 for the same user, in the same hour.
//   - "We deployed the new model at 02:00 but it took 4 hours to fully take effect."
```

**Correct (solution version in the key + event-driven sweep):**

```typescript
// Track the active version per campaign (refreshed every 30s or via EventBridge)
let ACTIVE_VERSIONS: Record<string, string> = await fetchActiveVersions();
setInterval(async () => { ACTIVE_VERSIONS = await fetchActiveVersions(); }, 30_000);

function buildKey(surface: string, cohort: string, locale: string) {
  const v = versionTag(ACTIVE_VERSIONS[surface]);
  return `recs:${surface}:${cohort}:${locale}:v${v}`;
}

async function getRecs(cohort: string, surface: string, locale: string) {
  const key = buildKey(surface, cohort, locale);
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  const fresh = await personalize.getRecommendations({ /* ... */ });
  await redis.set(key, JSON.stringify(fresh), 'EX', 1800);
  return fresh;
}

// EventBridge handler — fires on Personalize "Campaign Updated"
export async function onCampaignUpdated(event: CampaignUpdatedEvent) {
  const { campaignArn, latestSolutionVersionArn } = event.detail;
  const surface = SURFACE_BY_CAMPAIGN[campaignArn];

  // 1. Update active version atomically
  ACTIVE_VERSIONS[surface] = latestSolutionVersionArn;

  // 2. Sweep old version's keys (Redis SCAN with prefix match — cheap)
  const oldVersionTag = versionTag(getPreviousVersion(campaignArn));
  await scanAndDelete(`recs:${surface}:*:v${oldVersionTag}`);

  // 3. Trigger warm-up so new-version cache is populated before traffic
  await triggerWarmUp(surface);
}
```

**The version-in-key is sufficient for correctness.** The sweep step is an optimisation: without it, old-version keys sit unused until their TTL expires, consuming memory. With sweep, memory is freed within seconds of retrain.

**The fetch-active-version path:** there's a 30-second window where some instances may have the old version cached locally. During this window, some traffic uses the old key (and old data); some uses the new key (and triggers a miss). Acceptable for most products. For strict consistency, use EventBridge (sub-second propagation) instead of polling.

**OpenSearch parallel:** if your retrieval uses an LTR model deployed via the OpenSearch LTR plugin, the *model version* belongs in the key too. Same pattern: version-in-key + on-deploy sweep.

**Don't apply to anything BUT the model-version-dependent cache.** Catalog data, user profile, geo lookups — these aren't bound to a Personalize version. Keep their TTLs wall-clock.

Reference: [Personalize EventBridge events](https://docs.aws.amazon.com/personalize/latest/dg/eventbridge.html) · [Personalize Campaign Updates](https://docs.aws.amazon.com/personalize/latest/dg/updating-campaign.html)
