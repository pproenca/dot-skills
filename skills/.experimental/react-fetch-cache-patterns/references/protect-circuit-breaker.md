---
title: Use Circuit Breakers on Persistently Failing Endpoints
impact: HIGH
impactDescription: prevents retry storms on persistent failure
tags: protect, circuit-breaker, resilience, backoff
---

## Use Circuit Breakers on Persistently Failing Endpoints

Retries with backoff handle transient failure. But if an endpoint is *persistently* down — wrong URL, deprecated API, dependency outage — every retry is wasted load. A circuit breaker tracks failure rate per endpoint and short-circuits subsequent calls for a cooldown window once failures cross a threshold. The user sees an immediate fallback; the backend gets a chance to recover.

Three states: **closed** (calls pass through), **open** (calls reject instantly with a stale-cache fallback), **half-open** (one trial call after the cooldown; if it succeeds, close).

**Incorrect (every component independently retries a failing endpoint):**

```tsx
// 50 components on the screen, each retrying /recommendations 3x with backoff
// → 150 wasted requests to a known-failing endpoint over 30 seconds
function Carousel({ kind }: { kind: string }) {
  const { data, error } = useQuery({
    queryKey: ['recs', kind],
    queryFn: () => fetchRecommendations(kind),
    retry: 3,
  });
}
```

**Correct (shared circuit breaker per endpoint):**

```ts
type CircuitState = 'closed' | 'open' | 'half-open';

class CircuitBreaker {
  private state: CircuitState = 'closed';
  private failures = 0;
  private openedAt = 0;
  constructor(
    private threshold: number,    // failures to open the circuit
    private cooldownMs: number,   // open → half-open after this
  ) {}

  async run<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'open') {
      if (Date.now() - this.openedAt < this.cooldownMs) {
        throw new Error('circuit-open');
      }
      this.state = 'half-open'; // allow one trial
    }

    try {
      const result = await fn();
      this.failures = 0;
      this.state = 'closed';
      return result;
    } catch (e) {
      this.failures++;
      if (this.state === 'half-open' || this.failures >= this.threshold) {
        this.state = 'open';
        this.openedAt = Date.now();
      }
      throw e;
    }
  }
}

// One breaker per endpoint, shared across components
const recsBreaker = new CircuitBreaker(5, 30_000);

useQuery({
  queryKey: ['recs', kind],
  queryFn: () => recsBreaker.run(() => fetchRecommendations(kind)),
  retry: (attempt, e) => attempt < 2 && (e as Error).message !== 'circuit-open',
});
```

**Pair with stale-cache fallback ([[resilience-stale-fallback]])**: when the breaker is open, render the last-known-good cached result rather than an error — most users won't notice.

**Tuning:**
- Threshold: 3-10 failures (lower for critical paths, higher for noisy endpoints)
- Cooldown: 10-60s (long enough for backend recovery, short enough to retry promptly)

Reference: [Hystrix — Circuit Breaker pattern](https://github.com/Netflix/Hystrix/wiki/How-it-Works#circuit-breaker)
