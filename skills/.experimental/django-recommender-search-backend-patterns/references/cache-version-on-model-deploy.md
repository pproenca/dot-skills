---
title: Version Cache Keys by Model Deploy
impact: HIGH
impactDescription: prevents serving stale recommendations after model retrain
tags: cache, versioning, model-deploy, invalidation
---

## Version Cache Keys by Model Deploy

Personalize, Databricks, or your in-house ranker just got retrained — the new model returns different recommendations. But your Redis cache holds 300,000 entries keyed `recs:user:{user_id}` with the *old* model's outputs and a 1-hour TTL. For the next hour, you serve old-model results to users while only newly-uncached requests get the new model. Worse, an explicit `redis.flushdb()` is a stampede (every user becomes a cache miss simultaneously).

The pattern: bake the model version into every cache key. `recs:user:42:v23` and `recs:user:42:v24` are independent entries; switching the version variable instantly diverts new lookups to the new namespace while old entries quietly expire. No flush, no stampede.

**Incorrect (cache keys don't reflect model version — model swap serves stale):**

```python
async def get_recommendations(user_id: str):
    key = f"recs:user:{user_id}"   # ❌ no version
    cached = await redis.get(key)
    if cached:
        return json.loads(cached)
    items = await personalize_client.get_recommendations(user_id)
    await redis.setex(key, 3600, json.dumps(items))
    return items
# Model swap → app keeps serving old-model results from cache for an hour
```

**Correct (model version in the key):**

```python
# settings.py — bumped on each model deploy (CI/CD updates this env var)
RECOMMENDER_MODEL_VERSION = os.getenv("RECOMMENDER_MODEL_VERSION", "v1")
PERSONALIZE_CAMPAIGN_VERSION = os.getenv("PERSONALIZE_CAMPAIGN_VERSION", "v23")

# clients/personalize.py
async def get_recommendations(user_id: str):
    key = f"recs:user:{user_id}:{PERSONALIZE_CAMPAIGN_VERSION}"
    cached = await redis.get(key)
    if cached:
        return json.loads(cached)
    items = await personalize_client.get_recommendations(user_id)
    await redis.setex(key, 3600, json.dumps(items))
    return items
# Bump PERSONALIZE_CAMPAIGN_VERSION → all new lookups go to a fresh namespace
# Old entries naturally expire over the next hour
```

**Configure where the version comes from — env var, ConfigMap, or live config service:**

```python
# Option A: env var, requires deploy to change
PERSONALIZE_CAMPAIGN_VERSION = os.getenv("PERSONALIZE_CAMPAIGN_VERSION", "v23")

# Option B: read from a control plane (no deploy needed)
async def get_active_model_version() -> str:
    # Could be DynamoDB, Redis, Consul, etcd — anything atomic
    return await redis.get("active_model:personalize") or "v23"

# Option C: derive from the campaign ARN
# AWS Personalize: get the latest solution version associated with the campaign
async def get_solution_version_from_campaign(campaign_arn: str) -> str:
    response = await asyncio.to_thread(
        personalize_runtime.describe_campaign, campaignArn=campaign_arn
    )
    return response["campaign"]["solutionVersionArn"].split("/")[-1]
# Cache this lookup itself with a 5min TTL so you're not calling describe_campaign on every request
```

**Pattern for multi-source versioning:**

```python
async def get_blended_recommendations(user_id: str):
    # Different sources have different versions
    versions = {
        "personalize": settings.PERSONALIZE_VERSION,
        "databricks":  settings.DATABRICKS_MODEL_VERSION,
        "blender":     settings.BLENDER_VERSION,  # blending logic itself versions
    }
    composite = ".".join(f"{k}{v}" for k, v in sorted(versions.items()))
    key = f"recs:blended:{user_id}:{composite}"

    cached = await redis.get(key)
    if cached:
        return json.loads(cached)
    # ... fetch + blend
```

**Hot-swap traffic between model versions (blue-green model deploy):**

```python
# control plane / feature flag
async def get_user_model_version(user_id: str) -> str:
    """Decide which model the user sees — for canary rollouts."""
    canary_pct = await redis.get("personalize:canary_pct") or "0"
    if int(canary_pct) == 0:
        return settings.PERSONALIZE_STABLE_VERSION  # "v23"
    # Stable user-based bucketing — same user always sees same version during canary
    bucket = hash(user_id) % 100
    if bucket < int(canary_pct):
        return settings.PERSONALIZE_CANARY_VERSION  # "v24"
    return settings.PERSONALIZE_STABLE_VERSION

# Cache key automatically includes the right version per user
async def get_recommendations(user_id: str):
    version = await get_user_model_version(user_id)
    key = f"recs:user:{user_id}:{version}"
    # ...
```

**Lazy cleanup of old-version keys:**

You don't need to actively delete old entries — TTL handles them. But if memory pressure matters (millions of stale keys), use a SCAN job that finds keys with old versions and deletes them in batches:

```python
async def cleanup_old_version_keys(active_version: str, dry_run: bool = True):
    """Remove cache entries for retired model versions.
    Run after a model deploy is fully ramped (e.g., 24h later)."""
    cursor = 0
    deleted = 0
    while True:
        cursor, keys = await redis.scan(cursor, match="recs:user:*:v*", count=500)
        for key in keys:
            version_suffix = key.decode().split(":")[-1]
            if version_suffix != active_version:
                if not dry_run:
                    await redis.delete(key)
                deleted += 1
        if cursor == 0:
            break
    return deleted
```

**Symptom of missing model versioning:**
- After a model deploy, A/B test results look mixed for hours
- "We can't tell if the new model is better — half the responses are still old"
- Cache flush after deploys causes brief outages or latency spikes

**Pair with [[cache-redis-with-stampede-protection]]:** new model version = new key namespace = cold cache. The first request per user is a miss; protect it.

Reference: [AWS Personalize — Campaign versions](https://docs.aws.amazon.com/personalize/latest/dg/campaigns.html)
