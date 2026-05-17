---
title: Precompute Recommendations Per Cohort Offline
impact: HIGH
impactDescription: 80-95% reduction in Personalize TPS, sub-millisecond serve time
tags: pers, cohort, batch, precompute, personalize
---

## Precompute Recommendations Per Cohort Offline

Most recommendation surfaces don't need per-user real-time inference; they need per-cohort recommendations that update once or twice per day. The pattern: every night, run a batch job that issues one Personalize call per cohort × surface, stores the result in S3 + warm cache, and serves it for the rest of the day. Real-time inference is reserved for surfaces where the session signal genuinely matters (next-item recs after a click). For homepage rails, category landing pages, "popular near you" — the cohort precomputation collapses Personalize TPS by 80-95% and delivers sub-ms latency from cache.

**Incorrect (real-time Personalize call per user per page load):**

```typescript
async function getHomepageRecs(userId: string) {
  // Real-time call on every page view, every user, every surface
  return personalize.getRecommendations({
    campaignArn: HOMEPAGE,
    userId,
  });
}
// 100 req/s × 5 surfaces = 500 real-time calls/s
// Personalize variable bill (tier 1): 500 req/s × 86400 × 30 × $0.0000556 ≈ $72k/month
// (Plus the per-campaign minProvisionedTPS floor across all 5 campaigns.)
// p99 latency: 200-500ms (Personalize SLA)
```

**Correct (nightly batch precomputation per cohort × surface, served from cache):**

```python
# scripts/precompute_recs.py — runs at 02:00 daily via Step Functions
import boto3, json, time

personalize_runtime = boto3.client('personalize-runtime')
redis = redis_client()

# 1. Load the day's cohort definitions (from upstream user-segmentation job)
cohorts = load_cohorts_from_s3('s3://user-segments/today/cohorts.json')
# Each cohort has a "representative" user_id used to call Personalize:
#   [{cohort_id: 'c1', rep_user_id: 'rep-c1', size: 12000, locale: 'en-gb'}, ...]

# 2. Loop over (cohort × surface), batch the calls
SURFACES = ['homepage-trending', 'homepage-similar', 'homepage-popular',
            'category-landing', 'pdp-similar']

for surface in SURFACES:
    campaign_arn = CAMPAIGNS[surface]
    for cohort in cohorts:
        recs = personalize_runtime.get_recommendations(
            campaignArn=campaign_arn,
            userId=cohort['rep_user_id'],
            numResults=50,
        )
        key = f'recs:{surface}:c{cohort["id"]}:{cohort["locale"]}:v{SOLUTION_VERSION[surface]}'
        # 26h TTL — overlaps with tomorrow's run, prevents gap if batch fails
        redis.set(key, json.dumps(recs['itemList']), ex=26 * 3600)
        time.sleep(0.02)  # 50 TPS cap to stay under minProvisionedTPS

# Cost: 5 surfaces × 2000 cohorts = 10000 calls/night
#       ≈ 10k × $0.0000556 ≈ $0.56/night ≈ $17/month   (tier-1 unit price)
#       vs ~$72k/month real-time at 500 req/s tier-1.
#       Plus the cached version serves at <1ms with 99%+ hit rate during the day.
```

**Hybrid pattern:** combine cohort precomputation (cache-from-batch) with session-aware re-ranking ([pers-session-vector-write-through](pers-session-vector-write-through.md)). The batch sets the top-200 candidates; a lightweight in-process scorer reorders the top-50 using the user's session vector. This gets batch cost + real-time responsiveness.

**When NOT to precompute:**
- Surfaces where session signal is the dominant feature (next-item recs after a specific click) — keep these real-time
- Cohort definitions that change faster than batch cadence (real-time segmentation) — use [pers-shared-candidates-private-ranking](pers-shared-candidates-private-ranking.md) instead
- A/B test arms whose traffic share is too small to justify batch overhead (<1% of users)

**Cold path:** during the batch window (02:00-03:00), continue serving the *previous* day's cache. After the new batch completes, atomic swap via Redis MULTI/EXEC or by writing to new keys + rename.

Reference: [Personalize batch recommendations](https://docs.aws.amazon.com/personalize/latest/dg/recommendations-batch.html) · [AWS Blog: batch recommendation pipeline](https://aws.amazon.com/blogs/machine-learning/create-a-batch-recommendation-pipeline-using-amazon-personalize-with-no-code/)
