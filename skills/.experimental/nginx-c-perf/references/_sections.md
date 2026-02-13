# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Buffer & Zero-Copy I/O (buf)

**Impact:** CRITICAL
**Description:** Buffer chain reuse and zero-copy patterns are the #1 throughput multiplier — unnecessary memory copies waste CPU cycles on every byte of every request.

## 2. Connection Efficiency (conn)

**Impact:** CRITICAL
**Description:** Connection pooling, reuse queue management, and socket tuning directly determine maximum concurrent connections per worker process.

## 3. Lock Contention & Atomics (lock)

**Impact:** HIGH
**Description:** Shared memory lock contention is the primary scaling bottleneck in multi-worker deployments — minimizing critical sections yields linear worker scaling.

## 4. Error Recovery & Resilience (err)

**Impact:** HIGH
**Description:** Graceful error propagation and resource exhaustion recovery prevent cascading failures that turn partial outages into full service loss.

## 5. Timeout & Retry Strategy (timeout)

**Impact:** MEDIUM-HIGH
**Description:** Correct timeout tuning and retry patterns determine whether upstream failures cascade across the request pipeline or stay isolated.

## 6. Response Caching (cache)

**Impact:** MEDIUM
**Description:** In-module caching with shared memory zones eliminates redundant upstream calls — cache stampede prevention is critical at scale.

## 7. Worker & Process Tuning (worker)

**Impact:** MEDIUM
**Description:** Accept mutex control, connection pre-allocation, and graceful shutdown patterns determine system behavior under load spikes and deployments.

## 8. Logging & Metrics (log)

**Impact:** LOW-MEDIUM
**Description:** Efficient logging avoids becoming a bottleneck — debug logging without level checks costs ~50ns per call even when disabled at runtime.
