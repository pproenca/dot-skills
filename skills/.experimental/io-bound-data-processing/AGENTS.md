# I/O-bound data processing on constrained resources

**Version 0.1.0**  
Community  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

A practitioner reference for processing datasets larger than RAM on a single low-compute box. 41 rules across 9 categories — memory discipline, I/O access patterns, data format & encoding, chunking & batching, spill-to-disk, pipelining & backpressure, compression & serialization, concurrency for I/O-bound workloads, and observability — organized by execution-lifecycle impact and the cascade effect, with incorrect/correct Python examples and pointers to canonical sources (Apache Arrow/Parquet, Polars, DuckDB, pandas, Linux man pages, Brendan Gregg's Systems Performance, Designing Data-Intensive Applications, zstd/lz4 benchmarks). Designed to complement the algorithmic primitives in computer-science-algorithms with the I/O-pragmatic patterns needed to actually move bytes through a constrained box.

---

## Table of Contents

1. [Memory Discipline](references/_sections.md#1-memory-discipline) — **CRITICAL**
   - 1.1 [Bound the Working Set to a Measured Memory Budget](references/mem-bound-the-working-set.md) — CRITICAL (prevents OOM kills; enables predictable scaling)
   - 1.2 [Prefer Generators Over Lists for Multi-Stage Pipelines](references/mem-prefer-generators-over-lists-for-pipelines.md) — CRITICAL (from peak N×stage memory to O(1) per stage)
   - 1.3 [Release References Explicitly After Use](references/mem-release-references-explicitly.md) — CRITICAL (prevents reference leaks; up to N×working-set peak)
   - 1.4 [Shrink Dtypes at Load Time](references/mem-shrink-dtypes-before-loading.md) — CRITICAL (2-8x memory reduction)
   - 1.5 [Stream Files; Don't Read Them All Into Memory](references/mem-stream-dont-slurp.md) — CRITICAL (from O(file size) RAM to O(chunk size) RAM)
   - 1.6 [Use Views, Not Copies, for Slices and Masks](references/mem-use-views-not-copies.md) — CRITICAL (from O(slice) to O(1) memory)
2. [I/O Access Patterns](references/_sections.md#2-i/o-access-patterns) — **CRITICAL**
   - 2.1 [Batch and Pipeline Network Roundtrips](references/io-batch-and-pipeline-network-roundtrips.md) — CRITICAL (10-1000x throughput; N roundtrips collapse to 1)
   - 2.2 [Prefer Sequential Reads Over Random](references/io-prefer-sequential-over-random.md) — CRITICAL (10-100x throughput on HDD; 2-10x on SSD)
   - 2.3 [Stream HTTP Response Bodies; Never Materialize the Whole Body](references/io-stream-http-bodies-with-iter-content.md) — CRITICAL (from O(body size) RAM to O(chunk) RAM; prevents OOM on large downloads)
   - 2.4 [Use Asyncio for Many Concurrent Network Streams](references/io-async-for-many-concurrent-streams.md) — CRITICAL (10-100x more concurrent connections per core)
   - 2.5 [Use mmap for Random Access or Shared Read-Mostly Files](references/io-mmap-for-random-or-shared-large-files.md) — CRITICAL (10-100x faster random access; zero-copy)
   - 2.6 [Use Zero-Copy When Moving Bytes As-Is](references/io-zero-copy-when-moving-bytes-as-is.md) — CRITICAL (2-4x throughput on bulk transfers; 50% CPU reduction)
   - 2.7 [Wrap Raw File Descriptors with a Buffered Reader/Writer](references/io-buffer-explicitly-for-small-records.md) — CRITICAL (10-1000x fewer syscalls)
3. [Data Format & Encoding](references/_sections.md#3-data-format-&-encoding) — **HIGH**
   - 3.1 [Avoid Deeply Nested JSON for Hot Paths](references/fmt-avoid-deeply-nested-json-for-hot-paths.md) — HIGH (3-30x decode cost; 2-5x size)
   - 3.2 [Prefer Schema-on-Write When You Control the Producer](references/fmt-prefer-schema-on-write-when-possible.md) — HIGH (2-10x smaller; 5-50x faster reads; type errors caught at write)
   - 3.3 [Push Predicates Into the Reader, Not the Loop](references/fmt-push-predicates-into-the-reader.md) — HIGH (5-100x less I/O when row-group statistics prune)
   - 3.4 [Use a Columnar Format for Analytical Scans](references/fmt-columnar-for-analytical-scans.md) — HIGH (10-100x less I/O on projection-heavy queries)
   - 3.5 [Use Line-Delimited Formats for Streaming Row Ingest](references/fmt-line-delimited-for-streaming-row-ingest.md) — HIGH (O(1) memory per record vs O(file) for arrayed JSON)
4. [Chunking & Batching](references/_sections.md#4-chunking-&-batching) — **HIGH**
   - 4.1 [Coalesce Writes; Don't Flush One Record at a Time](references/batch-coalesce-writes-with-buffered-output.md) — HIGH (10-1000x write throughput)
   - 4.2 [Pick Chunk Size from the Memory Budget, Not a Round Number](references/batch-pick-chunk-size-by-memory-budget.md) — HIGH (prevents OOM; 2-5x throughput vs default)
   - 4.3 [Use Keyset Pagination, Not OFFSET, for Large Cursors](references/batch-keyset-pagination-over-offset.md) — HIGH (O(1) per page vs O(N) for OFFSET)
   - 4.4 [Use Stable Batch Iterators From Format Libraries](references/batch-process-with-stable-iterators.md) — HIGH (O(batch) memory; matches reader's natural granularity)
   - 4.5 [Use Vectorized APIs Instead of Per-Row Python Loops](references/batch-use-vectorized-apis-not-row-loops.md) — HIGH (10-100x speedup)
5. [Spill-to-Disk & External Memory](references/_sections.md#5-spill-to-disk-&-external-memory) — **HIGH**
   - 5.1 [Partition by Hash for Out-of-Core GroupBy and Join](references/spill-partition-by-hash-for-out-of-core-groupby-join.md) — HIGH (enables out-of-core join/aggregate; O(sqrt(N)) working memory)
   - 5.2 [Spill to External Merge Sort When Data Exceeds RAM](references/spill-external-merge-sort-when-data-exceeds-ram.md) — HIGH (enables O(N) sort on N >> RAM with O(sqrt(N)) memory)
   - 5.3 [Spill to Temp Files; Don't Use BytesIO for Out-of-Memory Buffers](references/spill-use-temp-files-not-process-memory.md) — HIGH (prevents OOM; spill cost ~O(disk write time) not O(process death))
   - 5.4 [Use Engines That Spill Automatically; Don't Hand-Roll Out-of-Core](references/spill-use-engines-that-spill-automatically.md) — HIGH (5-50x faster than hand-rolled; handles spill, parallelism, optimization)
6. [Pipelining & Backpressure](references/_sections.md#6-pipelining-&-backpressure) — **MEDIUM-HIGH**
   - 6.1 [Bound Producer-Consumer Queues to a Fixed Size](references/pipe-use-bounded-queues-for-producer-consumer.md) — MEDIUM-HIGH (prevents unbounded memory growth; caps RAM at queue_size × item_size)
   - 6.2 [Checkpoint Progress for Resumability](references/pipe-checkpoint-progress-for-resumability.md) — MEDIUM-HIGH (prevents full restart on crash; bounds redo work to one checkpoint interval)
   - 6.3 [Prefer Pull Iteration Over Push Callbacks](references/pipe-prefer-pull-iteration-over-push-callbacks.md) — MEDIUM-HIGH (backpressure for free; prevents unbounded buffering)
   - 6.4 [Propagate Backpressure From the Slowest Stage](references/pipe-apply-backpressure-from-slow-stages.md) — MEDIUM-HIGH (prevents unbounded buffering; matches pipeline throughput to the bottleneck)
7. [Compression & Serialization](references/_sections.md#7-compression-&-serialization) — **MEDIUM**
   - 7.1 [Default to zstd or lz4; Treat gzip as Legacy](references/codec-zstd-or-lz4-as-defaults-not-gzip.md) — MEDIUM (2-10x faster decode; 10-30% better ratio)
   - 7.2 [Prefer Binary Protocols Over JSON for High-Volume RPC](references/codec-prefer-binary-protocols-over-json-for-rpc.md) — MEDIUM (3-10x smaller payloads; 5-20x faster decode)
   - 7.3 [Train a zstd Dictionary When Compressing Many Small Payloads](references/codec-train-a-zstd-dictionary-for-many-small-payloads.md) — MEDIUM (2-10x better ratio on small messages (< 1 KB))
   - 7.4 [Use Dictionary Encoding for Repetitive String Columns](references/codec-dictionary-encoding-for-repetitive-strings.md) — MEDIUM (5-50x size reduction on low-cardinality columns)
8. [Concurrency for I/O-Bound Workloads](references/_sections.md#8-concurrency-for-i/o-bound-workloads) — **MEDIUM**
   - 8.1 [Overlap Compute With Prefetch](references/conc-overlap-compute-with-prefetch.md) — MEDIUM (1.5-2x throughput when I/O time ≈ compute time)
   - 8.2 [Tune Parallelism to the Bottleneck Resource](references/conc-tune-parallelism-to-the-bottleneck.md) — MEDIUM (prevents wasted parallelism; 2-10x latency improvement when tuned)
   - 8.3 [Use Asyncio Only When the Bottleneck Is Waiting on I/O](references/conc-asyncio-for-many-network-streams-not-for-cpu.md) — MEDIUM (prevents misapplied concurrency; 10x faster for I/O, no help for CPU)
   - 8.4 [Use Thread Pools for Blocking I/O Libraries](references/conc-thread-pools-for-blocking-io-libraries.md) — MEDIUM (5-50x speedup on blocking-driver I/O; GIL released during syscalls)
9. [Observability & Throughput Tuning](references/_sections.md#9-observability-&-throughput-tuning) — **LOW-MEDIUM**
   - 9.1 [Instrument Throughput in Rows-per-Second, Not Just Wall-Clock](references/obs-instrument-throughput-rows-per-second.md) — LOW-MEDIUM (catches regressions wall-clock hides; enables apples-to-apples comparison)
   - 9.2 [Measure iowait, Not Just CPU](references/obs-measure-iowait-not-just-cpu.md) — LOW-MEDIUM (prevents optimizing the wrong stage; finds the actual bottleneck)
   - 9.3 [Profile With py-spy and strace to Find Hidden Per-Row Syscall Storms](references/obs-profile-with-py-spy-or-strace-for-syscall-storms.md) — LOW-MEDIUM (10-100x speedup when a hidden syscall storm is the bottleneck)

---

## References

1. [https://arrow.apache.org/docs/](https://arrow.apache.org/docs/)
2. [https://parquet.apache.org/docs/](https://parquet.apache.org/docs/)
3. [https://docs.pola.rs/](https://docs.pola.rs/)
4. [https://duckdb.org/docs/](https://duckdb.org/docs/)
5. [https://pandas.pydata.org/docs/user_guide/scale.html](https://pandas.pydata.org/docs/user_guide/scale.html)
6. [https://docs.python.org/3/library/mmap.html](https://docs.python.org/3/library/mmap.html)
7. [https://docs.python.org/3/library/asyncio.html](https://docs.python.org/3/library/asyncio.html)
8. [https://man7.org/linux/man-pages/](https://man7.org/linux/man-pages/)
9. [https://www.brendangregg.com/usemethod.html](https://www.brendangregg.com/usemethod.html)
10. [https://dataintensive.net/](https://dataintensive.net/)
11. [https://github.com/facebook/zstd](https://github.com/facebook/zstd)
12. [https://jsonlines.org/](https://jsonlines.org/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |