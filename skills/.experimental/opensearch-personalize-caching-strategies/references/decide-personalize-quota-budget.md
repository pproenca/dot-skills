---
title: Model Personalize TPS Budget Before Choosing a Cache Strategy
impact: CRITICAL
impactDescription: prevents minProvisionedTPS bills 3-5x above actual usage
tags: decide, personalize, tps, minprovisionedtps, cost-modeling
---

## Model Personalize TPS Budget Before Choosing a Cache Strategy

AWS Personalize bills the higher of (a) `minProvisionedTPS` you set per campaign, or (b) actual TPS during the hour. Each transaction is billed tiered (currently $0.0556 per 1k for the first 72M/month). A campaign with `minProvisionedTPS=10` costs `10 × 86400 × $0.0000556` ≈ $48/day floor even at zero traffic. Personalize auto-scales up but never below the floor. Caching reduces actual TPS but does not reduce minProvisionedTPS — so if your minimum is set too high relative to traffic, caching saves nothing on the campaign bill. Conversely, if minProvisionedTPS is set too low, traffic spikes throttle (HTTP 429) and the cache must absorb the failure. The decision of cache vs minProvisionedTPS-sizing is one decision, not two.

**Incorrect (over-provision and cache, paying twice):**

```python
# Personalize campaign config — set when nobody knew the traffic pattern
campaign_config = {
    "name": "homepage-recommender",
    "solutionVersionArn": "arn:aws:personalize:...:solutionVersion/abc",
    "minProvisionedTPS": 50,  # picked by guessing
}
# Bill: 50 TPS * $0.0000556/req * 86400 s/day = ~$240/day minimum, even at 5 TPS actual.
# Then a Redis cache is added that absorbs 70% of traffic, dropping actual TPS to 1.5.
# Bill is unchanged because minProvisionedTPS still bills 50.
```

**Correct (right-size minProvisionedTPS to the post-cache traffic):**

```python
# Step 1: model expected hit rate before deploying (from shadow cache or simulation)
expected_hit_rate = 0.70
peak_request_rate = 50  # requests/sec at peak hour
post_cache_origin_tps = peak_request_rate * (1 - expected_hit_rate)  # = 15

# Step 2: minProvisionedTPS should sit slightly above post-cache peak,
#         not above raw traffic
SAFETY_MARGIN = 1.3
min_tps = math.ceil(post_cache_origin_tps * SAFETY_MARGIN)  # = 20

# Step 3: configure with the right floor
campaign_config = {
    "name": "homepage-recommender",
    "solutionVersionArn": "arn:aws:personalize:...:solutionVersion/abc",
    "minProvisionedTPS": min_tps,  # 20, not 50
}
# Bill: 20 TPS * $0.0000556/req * 86400 = ~$96/day floor.
# Cache infra: $8/day on ElastiCache.
# Net savings vs over-provisioned: ~$144/day per campaign.
```

**The amplification trap:** a page with 5 recommenders calls Personalize 5 times per page view. If each campaign has minProvisionedTPS=10 because "10 felt safe," you're paying ~5×$48 = $240/day floor across 5 campaigns even at zero traffic. Reduce the number of campaigns (merge recommenders to a single multi-output model where possible) or share cache across them.

**Throttling guidance:** Personalize auto-scales up but there is a short delay during which transactions can be lost. If your cache hit rate drops during a deploy or cache flush, you can briefly exceed minProvisionedTPS and see 429s — design the cache to fail open ([neg-cache-throttled-personalize](neg-cache-throttled-personalize.md)).

Reference: [Amazon Personalize CreateCampaign](https://docs.aws.amazon.com/personalize/latest/dg/API_CreateCampaign.html) · [Personalize endpoints and quotas](https://docs.aws.amazon.com/personalize/latest/dg/limits.html) · [Personalize pricing](https://aws.amazon.com/personalize/pricing/)
