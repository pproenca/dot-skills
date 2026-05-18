# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Memory Discipline (mem)

**Impact:** CRITICAL  
**Description:** On a low-compute box, the working set must stay smaller than RAM — slurping the dataset into memory once defeats every downstream optimization and causes OOM kills before any other rule matters.

## 2. I/O Access Patterns (io)

**Impact:** CRITICAL  
**Description:** Disk and network are 10³–10⁶× slower than RAM, so *how* you read (sequential vs random, buffered vs raw, mmap, async, batched roundtrips) dominates wall-clock time and CPU utilization.

## 3. Data Format & Encoding (fmt)

**Impact:** HIGH  
**Description:** The on-disk/on-wire format fixes the lower bound on I/O volume and decode cost — columnar vs row, schema-on-write vs schema-on-read, predicate pushdown — before any application logic runs.

## 4. Chunking & Batching (batch)

**Impact:** HIGH  
**Description:** Granularity controls the memory ceiling and amortizes per-item overhead (syscalls, parsing, transactions); chunk and batch sizes chosen by memory budget and bottleneck dominate throughput.

## 5. Spill-to-Disk & External Memory (spill)

**Impact:** HIGH  
**Description:** When data exceeds RAM, the choice is to spill cleanly (partitions, temp files, streaming engines) or OOM — out-of-core algorithms and spill discipline turn impossible jobs into routine ones.

## 6. Pipelining & Backpressure (pipe)

**Impact:** MEDIUM-HIGH  
**Description:** Multi-stage pipelines must bound buffers between fast producers and slow consumers; without backpressure and checkpointing the slowest stage silently grows memory or loses work on restart.

## 7. Compression & Serialization (codec)

**Impact:** MEDIUM  
**Description:** Codec and serialization choices trade CPU for I/O — zstd vs gzip vs lz4, dictionary encoding, binary vs JSON — and the right defaults save orders of magnitude on bytes moved.

## 8. Concurrency for I/O-Bound Workloads (conc)

**Impact:** MEDIUM  
**Description:** Async, threads, and processes are different tools for different bottlenecks; matching the concurrency model to the actual bottleneck (network, blocking driver, CPU decode) avoids wasted parallelism.

## 9. Observability & Throughput Tuning (obs)

**Impact:** LOW-MEDIUM  
**Description:** You cannot tune what you cannot see — measuring iowait, rows/sec, and per-syscall cost is how you find the *real* bottleneck instead of optimizing the wrong stage.
