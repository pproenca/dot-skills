---
title: Apply Throttling per User and per Expensive Endpoint
impact: MEDIUM
impactDescription: prevents one user exhausting expensive downstream quota
tags: api, throttle, drf, rate-limit, abuse
---

## Apply Throttling per User and per Expensive Endpoint

A logged-in user that issues 200 recommendation requests per second (intentional scraper, broken client, or test code left running) can exhaust your Personalize/Databricks quota for everyone else. Without throttling, one misbehaving caller becomes everyone's outage. DRF's `Throttle` classes apply per-user and per-endpoint limits at the Django layer — cheaper than letting requests flow through to expensive downstreams.

Throttling is the user-facing complement to [[protect-client-side-rate-limit]] (which throttles outbound to downstreams). Use both: API throttling bounds *which users* can call you frequently; outbound throttling bounds *how often you call downstreams*.

**Incorrect (no throttling — one user can drain quota for everyone):**

```python
class RecommendationsView(APIView):
    def get(self, request):
        items = expensive_recommendation_call(request.user.id)
        return Response({"items": items})
# A bot can hit this 1000 RPS per user; each call burns Personalize quota
```

**Correct (per-user throttle + per-endpoint anonymous throttle):**

```python
# settings.py
REST_FRAMEWORK = {
    "DEFAULT_THROTTLE_CLASSES": [
        "rest_framework.throttling.UserRateThrottle",
        "rest_framework.throttling.AnonRateThrottle",
    ],
    "DEFAULT_THROTTLE_RATES": {
        "user": "1000/hour",                # default — broad cap
        "anon": "100/hour",                  # anonymous traffic — tighter
        "recommendations_user": "60/minute", # specific expensive endpoint
        "recommendations_anon": "20/minute",
        "search_user": "120/minute",
        "search_anon": "30/minute",
    },
}

# views.py
from rest_framework.throttling import UserRateThrottle, AnonRateThrottle

class RecommendationsUserThrottle(UserRateThrottle):
    scope = "recommendations_user"

class RecommendationsAnonThrottle(AnonRateThrottle):
    scope = "recommendations_anon"

class RecommendationsView(APIView):
    throttle_classes = [RecommendationsUserThrottle, RecommendationsAnonThrottle]

    def get(self, request):
        items = expensive_recommendation_call(request.user.id)
        return Response({"items": items})
```

**Throttle by tier — paying customers get higher limits:**

```python
class TieredUserThrottle(UserRateThrottle):
    """Higher rate limit for paying users."""

    def get_rate(self):
        request = self._request_context
        if request and request.user.is_authenticated:
            if request.user.is_premium:
                return "300/minute"
            if request.user.is_paid:
                return "120/minute"
        return "60/minute"   # free tier
```

**Throttle by IP for anonymous (prevent single-IP abuse):**

```python
class IpThrottle(AnonRateThrottle):
    """Per-IP throttle for anonymous endpoints — different from per-anon-session."""
    scope = "ip"

    def get_ident(self, request):
        # Use the trusted forwarded IP (depends on your proxy setup)
        return request.META.get("HTTP_X_FORWARDED_FOR", "").split(",")[0].strip() \
            or request.META.get("REMOTE_ADDR")
```

**For burst-tolerant traffic, use a token bucket (not DRF's simple bucket):**

DRF's throttle is a sliding window — once the bucket is full, the limit is hard. For traffic that has bursts but stays within average, a token bucket is more permissive:

```python
# Custom DRF throttle backed by Redis token bucket
class TokenBucketThrottle:
    rate = 60       # tokens per minute (sustained rate)
    burst = 20      # extra tokens for short bursts

    def allow_request(self, request, view):
        user_id = request.user.id if request.user.is_authenticated else \
                  request.META.get("REMOTE_ADDR")
        key = f"throttle:{view.__class__.__name__}:{user_id}"
        return redis_token_bucket_acquire(key, self.rate, self.burst)
```

**Throttle by request cost, not just count:**

Some endpoints are 10× more expensive than others (deep search, full personalization). Charge multiple "tokens" per expensive call:

```python
class CostBasedThrottle(BaseThrottle):
    def allow_request(self, request, view):
        cost = getattr(view, "throttle_cost", 1)
        return redis_token_bucket_charge(self._key(request), cost)

class DeepSearchView(APIView):
    throttle_classes = [CostBasedThrottle]
    throttle_cost = 5    # this view costs 5 tokens per call

class CheapEndpointView(APIView):
    throttle_classes = [CostBasedThrottle]
    throttle_cost = 1
```

**Return Retry-After on 429s — clients can honor it ([[protect-honor-retry-after-header]]):**

```python
# DRF does this automatically when throttle.wait() returns a value
class RecommendationsUserThrottle(UserRateThrottle):
    scope = "recommendations_user"
    # DRF automatically sets:
    #   429 Too Many Requests
    #   Retry-After: <seconds>
```

**Bypass throttling for internal traffic (with care):**

```python
class ExternalOnlyThrottle(UserRateThrottle):
    """Skip throttle for requests from internal services (e.g., via a shared secret)."""

    def allow_request(self, request, view):
        if request.META.get("HTTP_X_INTERNAL_API_KEY") == settings.INTERNAL_API_KEY:
            return True
        return super().allow_request(request, view)
```

**Don't throttle on health-check / status endpoints:**

```python
class HealthView(APIView):
    throttle_classes = []  # health checks must always work
    permission_classes = []  # no auth either

    def get(self, request):
        return Response({"status": "ok"})
```

Throttled health checks make load balancers mark instances unhealthy on rate-limit spikes — wrong signal.

**Observability — track throttle hits:**

```python
class ObservableThrottle(UserRateThrottle):
    def throttle_failure(self):
        metrics.increment("throttle.exceeded", tags={
            "scope": self.scope,
            "view": getattr(self.view, "__class__", None).__name__,
        })
        return super().throttle_failure()
```

A spike in `throttle.exceeded` for one scope often surfaces abuse or a broken client.

**Don't throttle so aggressively that legitimate clients break:**

Pick rates by measuring actual traffic from your highest-volume legitimate users (analytics service, mobile app, automated tests) and setting limits well above their natural rate. Throttling should catch outliers, not bound average traffic.

**Symptom of missing throttle:**
- One user/IP causes API-wide latency spikes
- Personalize/Databricks bills correlate with traffic from a single source
- Abuse complaints from competitors trying to scrape

Reference: [DRF — Throttling](https://www.django-rest-framework.org/api-guide/throttling/) | [django-ratelimit](https://django-ratelimit.readthedocs.io/) | [Stripe — Rate Limiters](https://stripe.com/blog/rate-limiters)
