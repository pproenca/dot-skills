---
title: Key Recommenders by Cohort When Users Outnumber Cohorts
impact: CRITICAL
impactDescription: 50-500x hit rate increase by collapsing N users into K cohorts
tags: key, cohort, personalisation, recommenders, segmentation
---

## Key Recommenders by Cohort When Users Outnumber Cohorts

Per-user caching of recommendations is a contradiction: if the cache key includes `userId` and you have 5M monthly active users on a homepage with 5 recommenders, the upper bound on cache entries is 25M. The working set for "users active today" alone exceeds memory, and hit rate across cache restarts is near zero. The fix is to recognise that personalisation operates at a coarser grain than the individual user — most users behave like one of K cohorts (K = 100-10,000 typically). Key by `cohort × locale × surface × solution-version` and the working set shrinks by 2-4 orders of magnitude.

**Incorrect (user_id in the cache key):**

```typescript
async function getHomepageRecs(userId: string, locale: string) {
  const key = `homepage-recs:${userId}:${locale}`;          // <-- 5M users -> 5M keys
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  const fresh = await personalize.getRecommendations({ userId });
  await redis.set(key, JSON.stringify(fresh), 'EX', 1800);
  return fresh;
}
// Cohorts: implicit (Personalize internally has user embeddings, but you can't see them).
// Hit rate: ~2% — practically no reuse, every user is their own cache miss.
// Cost: Personalize bill scales linearly with active users.
```

**Correct (cohort_id in the cache key, user_id in Personalize call):**

```typescript
// Pre-compute a cohort assignment per user (nightly job from user features)
//   features: country, age_bucket, last_active_bucket, signup_age_months,
//             preferred_category, device_class, ...
// Output:    cohort_id  (numeric, e.g. 1..2000)
// Storage:   small key in Redis: `cohort:${userId}` -> cohortId  (TTL 1 day)

async function getCohortKey(userId: string): Promise<string> {
  const cohortId = await redis.get(`cohort:${userId}`);
  if (cohortId) return cohortId;
  // Compute on the fly for new users (or queue async assignment)
  return await assignCohort(userId);
}

async function getHomepageRecs(userId: string, locale: string) {
  const cohort = await getCohortKey(userId);
  const key = `homepage-recs:c${cohort}:${locale}:${SOLUTION_VERSION}`;
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  // Still call Personalize with the real userId so the model sees the individual,
  // but cache the result against the cohort key for reuse.
  const fresh = await personalize.getRecommendations({ userId });
  await redis.set(key, JSON.stringify(fresh), 'EX', 1800);
  return fresh;
}
// 5M users -> ~2000 cohorts × ~30 locales × 1 solution version = 60k keys
// Hit rate: 85-95% within an hour, because users in the same cohort share recs.
```

**When `userId`-keyed caching IS correct:**
- Mutation-write paths (e.g. user-edited preferences) — write-through with user key
- Per-user session vectors that change second-to-second — see [pers-session-vector-write-through](pers-session-vector-write-through.md)
- Logged-in marketplace-buyer histories — but TTL stays short (<5 min)

**Hybrid pattern for heavy personalisation:** cache the cohort-level **candidate set** (top-200 IDs) for the cohort, then re-rank the top-50 per-user with a lightweight on-the-fly score. This gets cohort-level reuse (~90% hit rate) plus per-user personalisation in the final order.

**Choosing K:** plot hit rate vs cohort count. K=100 cohorts: ~75% hit rate, very low diversity (homepage looks the same for too many users). K=2000-10000: ~90% hit rate, individual-level diversity preserved. K=100000: per-user, hit rate ~5%. The knee is usually in the 1k-10k range.

Reference: [Pinterest: PinnerSage Multi-Modal User Embeddings](https://medium.com/pinterest-engineering/pinnersage-multi-modal-user-embedding-framework-for-recommendations-at-pinterest-bfd116b49475) · [Personalize User-Personalization recipe](https://docs.aws.amazon.com/personalize/latest/dg/native-recipe-new-item-USER_PERSONALIZATION.html)
