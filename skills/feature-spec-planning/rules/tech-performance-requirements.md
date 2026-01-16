---
title: Specify Performance Requirements Upfront
impact: MEDIUM
impactDescription: avoids 40% of late-stage performance rewrites
tags: tech, performance, latency, scalability
---

## Specify Performance Requirements Upfront

Define performance targets before implementation, not after users complain. Retrofitting performance is 5-10× more expensive than building it in. What gets measured gets optimized.

**Incorrect (performance as afterthought):**

```markdown
## Feature: Dashboard Analytics

Display user analytics on dashboard.

// Shipped feature loads in 8 seconds
// PM: "This is too slow"
// Dev: "How fast should it be?"
// PM: "Fast enough"
// Result: Undefined target, endless optimization cycles
```

**Correct (explicit performance requirements):**

```markdown
## Feature: Dashboard Analytics - Performance Requirements

### Response Time Targets

| Operation | p50 | p95 | p99 | Max |
|-----------|-----|-----|-----|-----|
| Dashboard initial load | 500ms | 1s | 2s | 5s |
| Widget data fetch | 200ms | 500ms | 1s | 3s |
| Date range change | 300ms | 800ms | 1.5s | 3s |
| Export to CSV | 2s | 5s | 10s | 30s |

### Throughput Requirements

| Metric | Target | Measurement |
|--------|--------|-------------|
| Concurrent users | 1,000 | Load test |
| Requests per second | 500 | APM |
| Dashboard loads per minute | 2,000 | Analytics |

### Resource Constraints

| Resource | Limit | Rationale |
|----------|-------|-----------|
| Memory per request | 50MB | Container limits |
| CPU time per request | 500ms | Fair scheduling |
| Database connections | 20 max | Pool size |
| External API calls | 3 max | Latency budget |

### Latency Budget Breakdown

Total budget: 1000ms (p95 target)

```text
┌─────────────────────────────────────────────────────────┐
│                    Latency Budget                        │
├─────────────────────────────────────────────────────────┤
│ Network (client → server)          │ 100ms │ Fixed     │
│ Authentication/Authorization       │  50ms │ Cached    │
│ Database queries (parallel)        │ 300ms │ Indexed   │
│ Data aggregation                   │ 200ms │ In-memory │
│ Response serialization             │  50ms │ Streaming │
│ Network (server → client)          │ 100ms │ Fixed     │
│ Client-side rendering              │ 200ms │ Virtual   │
├─────────────────────────────────────────────────────────┤
│ TOTAL                              │1000ms │           │
│ Buffer for variance                │ 200ms │           │
└─────────────────────────────────────────────────────────┘
```

### Scalability Requirements

**Current state:**
- Active users: 10,000
- Peak concurrent: 500
- Data volume: 50GB

**Design for (2-year horizon):**
- Active users: 100,000 (10×)
- Peak concurrent: 5,000 (10×)
- Data volume: 500GB (10×)

### Performance Testing Plan

**Before launch:**
1. Load test: 2× expected peak traffic
2. Stress test: Find breaking point
3. Soak test: 24-hour sustained load
4. Chaos test: Database failover during load

**Acceptance criteria:**
```yaml
load_test:
  users: 2000
  duration: 30m
  assertions:
    - p95_response_time < 1000ms
    - error_rate < 0.1%
    - cpu_usage < 70%
    - memory_usage < 80%
```

### Degradation Strategy

When load exceeds capacity:

| Load Level | Response |
|------------|----------|
| Normal (< 80%) | Full functionality |
| High (80-95%) | Disable non-essential features |
| Critical (> 95%) | Serve cached/stale data |
| Overload | Queue requests, show wait time |

**Degradation priority (disable first → last):**
1. Real-time updates (switch to polling)
2. Detailed breakdowns (show summaries only)
3. Historical comparisons (current period only)
4. Interactive filters (preset ranges only)
```

**Performance requirement checklist:**
- Latency targets by percentile
- Throughput targets defined
- Resource limits specified
- Scalability horizon documented
- Degradation strategy planned

Reference: [Google SRE Book - Service Level Objectives](https://sre.google/sre-book/service-level-objectives/)
