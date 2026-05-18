---
name: io-bound-data-processing
description: Use this skill whenever processing, transforming, or moving datasets that might exceed RAM on a single low-compute box — covers memory discipline (streaming, generators, dtype shrinkage), I/O access patterns (sequential vs random, mmap, async, zero-copy, buffered fds), data formats (Parquet vs CSV vs JSON, predicate pushdown, dictionary encoding), chunking & batching (chunk-size from memory budget, vectorized APIs, batch network round-trips, keyset pagination), spill-to-disk (external merge sort, hash partitioning, SpooledTemporaryFile, engines like DuckDB/Polars), pipelining (bounded queues, backpressure, checkpointing for resumability), codec selection (zstd vs lz4 vs gzip, trained dictionaries, binary protocols), concurrency for I/O-bound workloads (asyncio for waits, threads for blocking drivers, prefetch overlap, bottleneck-driven parallelism), and observability (iowait vs CPU%, rows/sec instrumentation, py-spy/strace for syscall storms). Trigger on tasks involving "process a large file", "stream this", "ETL on a small box", "out-of-core", "OOM kill", "this is slow", code with `pd.read_csv` of multi-GB files, `requests.get(...).content` on big bodies, `BytesIO` on unbounded inputs, per-row INSERTs, sequential `requests.get` over many URLs, unbuffered `os.read`, gzip-by-default, `tqdm` showing falling rates — even if the user doesn't mention "I/O" or "memory" explicitly. Complement to computer-science-algorithms.
---

# Community I/O-bound data processing on constrained resources Best Practices

A reference for engineers processing datasets larger than RAM on a single low-compute box. Organized by execution-lifecycle impact: rules near the top of the table govern *whether the job runs at all*; rules near the bottom shave the last 10 %. Optimize from the top of the waterfall.

**Scope:** the patterns that show up in real ETL / data-engineering / batch work on a laptop, a 2-vCPU container, or a Raspberry Pi-class node — streaming, formats, chunking, spill, backpressure, codecs, and the concurrency model that actually matches an I/O-bound bottleneck. Out of scope (covered elsewhere): the algorithmic primitives themselves (see [`computer-science-algorithms`](../computer-science-algorithms/)), distributed compute beyond a single box (use Spark/Dask), and database-engine internals (see official docs).

Distilled from [Apache Arrow / Parquet docs](https://arrow.apache.org/docs/), [Polars User Guide](https://docs.pola.rs/), [DuckDB docs](https://duckdb.org/docs/), [pandas — Scaling to large datasets](https://pandas.pydata.org/docs/user_guide/scale.html), Linux man pages ([mmap(2)](https://man7.org/linux/man-pages/man2/mmap.2.html), [sendfile(2)](https://man7.org/linux/man-pages/man2/sendfile.2.html), [posix_fadvise(2)](https://man7.org/linux/man-pages/man2/posix_fadvise.2.html)), Brendan Gregg's [USE method](https://www.brendangregg.com/usemethod.html) and *Systems Performance*, Kleppmann's [*Designing Data-Intensive Applications*](https://dataintensive.net/), and the [zstd](https://github.com/facebook/zstd) / [lz4](https://github.com/lz4/lz4) reference benchmarks.

## When to Apply

Reach for these rules when:

- A job OOM-kills, swaps, or runs much slower than expected on a small box
- Input is *larger* than RAM and you need to scan, filter, aggregate, sort, or join it
- A pipeline has unbounded buffers between stages, or memory grows linearly during a "streaming" job
- You see one-row-per-RTT writes (`INSERT` per row, `requests.get` per URL, `f.read(32)` per record)
- You're picking a format/codec/serializer and the choice matters at scale
- A `top` shows low CPU and high iowait, or you don't know which it is
- "It's slow but I don't know why" — start at the obs- category

## Rule Categories By Priority

| # | Category | Prefix | Impact | Why it cascades |
|---|----------|--------|--------|-----------------|
| 1 | Memory Discipline | `mem-` | CRITICAL | Slurping into RAM defeats every downstream technique on a constrained box |
| 2 | I/O Access Patterns | `io-` | CRITICAL | Disk/net are 10³–10⁶× slower than RAM; access pattern dominates wall-clock |
| 3 | Data Format & Encoding | `fmt-` | HIGH | Format fixes the lower bound on I/O volume + decode cost before any logic runs |
| 4 | Chunking & Batching | `batch-` | HIGH | Granularity controls peak memory and amortizes per-item overhead |
| 5 | Spill-to-Disk & External Memory | `spill-` | HIGH | When data > RAM, the choice is "spill cleanly" or "OOM" |
| 6 | Pipelining & Backpressure | `pipe-` | MEDIUM-HIGH | Unbounded buffers between fast producers and slow sinks = OOM |
| 7 | Compression & Serialization | `codec-` | MEDIUM | Trades CPU for I/O; right codec saves orders of magnitude |
| 8 | Concurrency for I/O-Bound Workloads | `conc-` | MEDIUM | Async / threads / processes are different tools; wrong model wastes CPU |
| 9 | Observability & Throughput Tuning | `obs-` | LOW-MEDIUM | Can't tune what you don't measure; iowait ≠ CPU-bound |

## Quick Reference

### 1. Memory Discipline (CRITICAL)

- [`mem-stream-dont-slurp`](references/mem-stream-dont-slurp.md) — Iterate sources chunk-by-chunk; peak RAM = chunk size, not file size
- [`mem-prefer-generators-over-lists-for-pipelines`](references/mem-prefer-generators-over-lists-for-pipelines.md) — Generators flow; lists materialize
- [`mem-shrink-dtypes-before-loading`](references/mem-shrink-dtypes-before-loading.md) — Narrow ints, categoricals; 2-8× memory reduction at load time
- [`mem-use-views-not-copies`](references/mem-use-views-not-copies.md) — Slicing without copying; NumPy/Arrow zero-copy semantics
- [`mem-bound-the-working-set`](references/mem-bound-the-working-set.md) — Chunk size = budget ÷ row-size × amplification, not a round number
- [`mem-release-references-explicitly`](references/mem-release-references-explicitly.md) — Drop intermediates so peak ≠ N × chunk

### 2. I/O Access Patterns (CRITICAL)

- [`io-prefer-sequential-over-random`](references/io-prefer-sequential-over-random.md) — Sort offsets, advise the kernel, let readahead help
- [`io-buffer-explicitly-for-small-records`](references/io-buffer-explicitly-for-small-records.md) — `BufferedReader` collapses 1000× syscalls
- [`io-stream-http-bodies-with-iter-content`](references/io-stream-http-bodies-with-iter-content.md) — `stream=True` + `iter_content` instead of `.content`
- [`io-mmap-for-random-or-shared-large-files`](references/io-mmap-for-random-or-shared-large-files.md) — Zero-copy + on-demand paging for random access
- [`io-async-for-many-concurrent-streams`](references/io-async-for-many-concurrent-streams.md) — One thread, thousands of awaits
- [`io-batch-and-pipeline-network-roundtrips`](references/io-batch-and-pipeline-network-roundtrips.md) — `COPY`, pipelines, multi-key endpoints, HTTP/2
- [`io-zero-copy-when-moving-bytes-as-is`](references/io-zero-copy-when-moving-bytes-as-is.md) — `sendfile`, `copy_file_range`, `shutil.copyfile`

### 3. Data Format & Encoding (HIGH)

- [`fmt-columnar-for-analytical-scans`](references/fmt-columnar-for-analytical-scans.md) — Parquet/Arrow for filter+project workloads
- [`fmt-line-delimited-for-streaming-row-ingest`](references/fmt-line-delimited-for-streaming-row-ingest.md) — NDJSON over JSON-array for streaming
- [`fmt-push-predicates-into-the-reader`](references/fmt-push-predicates-into-the-reader.md) — Row-group statistics skip whole chunks
- [`fmt-prefer-schema-on-write-when-possible`](references/fmt-prefer-schema-on-write-when-possible.md) — Typed columns beat schema-on-read every time
- [`fmt-avoid-deeply-nested-json-for-hot-paths`](references/fmt-avoid-deeply-nested-json-for-hot-paths.md) — Flat schema, or binary on hot pipes

### 4. Chunking & Batching (HIGH)

- [`batch-pick-chunk-size-by-memory-budget`](references/batch-pick-chunk-size-by-memory-budget.md) — Compute from budget, not a constant
- [`batch-use-vectorized-apis-not-row-loops`](references/batch-use-vectorized-apis-not-row-loops.md) — NumPy / Polars / Arrow kernels, not `iterrows`
- [`batch-process-with-stable-iterators`](references/batch-process-with-stable-iterators.md) — `iter_batches`, `chunksize=`, `collect(streaming=True)`
- [`batch-coalesce-writes-with-buffered-output`](references/batch-coalesce-writes-with-buffered-output.md) — `COPY` / `executemany`, sized write buffers
- [`batch-keyset-pagination-over-offset`](references/batch-keyset-pagination-over-offset.md) — `WHERE id > $last_id`, never `OFFSET N` on deep cursors

### 5. Spill-to-Disk & External Memory (HIGH)

- [`spill-external-merge-sort-when-data-exceeds-ram`](references/spill-external-merge-sort-when-data-exceeds-ram.md) — Out-of-core sort; delegate to `sort` / DuckDB when possible
- [`spill-partition-by-hash-for-out-of-core-groupby-join`](references/spill-partition-by-hash-for-out-of-core-groupby-join.md) — Hash-partition both sides; process per partition
- [`spill-use-temp-files-not-process-memory`](references/spill-use-temp-files-not-process-memory.md) — `SpooledTemporaryFile`, never unbounded `BytesIO`
- [`spill-use-engines-that-spill-automatically`](references/spill-use-engines-that-spill-automatically.md) — DuckDB / Polars / Dask manage spill for you

### 6. Pipelining & Backpressure (MEDIUM-HIGH)

- [`pipe-use-bounded-queues-for-producer-consumer`](references/pipe-use-bounded-queues-for-producer-consumer.md) — Bounded `Queue` is the backpressure mechanism
- [`pipe-apply-backpressure-from-slow-stages`](references/pipe-apply-backpressure-from-slow-stages.md) — Slow sink throttles the fast source
- [`pipe-prefer-pull-iteration-over-push-callbacks`](references/pipe-prefer-pull-iteration-over-push-callbacks.md) — Pull backpressures naturally; push needs policy
- [`pipe-checkpoint-progress-for-resumability`](references/pipe-checkpoint-progress-for-resumability.md) — Atomic checkpoint after each batch; redo bounded

### 7. Compression & Serialization (MEDIUM)

- [`codec-zstd-or-lz4-as-defaults-not-gzip`](references/codec-zstd-or-lz4-as-defaults-not-gzip.md) — Pick codec by access pattern; gzip is legacy
- [`codec-dictionary-encoding-for-repetitive-strings`](references/codec-dictionary-encoding-for-repetitive-strings.md) — 5-50× on low-cardinality columns
- [`codec-prefer-binary-protocols-over-json-for-rpc`](references/codec-prefer-binary-protocols-over-json-for-rpc.md) — Protobuf / Arrow IPC / MsgPack on hot wires
- [`codec-train-a-zstd-dictionary-for-many-small-payloads`](references/codec-train-a-zstd-dictionary-for-many-small-payloads.md) — `zstd --train` for sub-1 KB messages

### 8. Concurrency for I/O-Bound Workloads (MEDIUM)

- [`conc-asyncio-for-many-network-streams-not-for-cpu`](references/conc-asyncio-for-many-network-streams-not-for-cpu.md) — Asyncio multiplexes waits; useless for compute
- [`conc-thread-pools-for-blocking-io-libraries`](references/conc-thread-pools-for-blocking-io-libraries.md) — GIL releases during blocking I/O; threads work
- [`conc-overlap-compute-with-prefetch`](references/conc-overlap-compute-with-prefetch.md) — One batch ahead via background thread / coroutine
- [`conc-tune-parallelism-to-the-bottleneck`](references/conc-tune-parallelism-to-the-bottleneck.md) — Match worker count to the binding resource

### 9. Observability & Throughput Tuning (LOW-MEDIUM)

- [`obs-measure-iowait-not-just-cpu`](references/obs-measure-iowait-not-just-cpu.md) — `iostat -x`, `vmstat`, psutil — find the real bottleneck
- [`obs-instrument-throughput-rows-per-second`](references/obs-instrument-throughput-rows-per-second.md) — Rates normalize across runs; catch regressions
- [`obs-profile-with-py-spy-or-strace-for-syscall-storms`](references/obs-profile-with-py-spy-or-strace-for-syscall-storms.md) — Attach, don't guess

## How to Use

Start with the question that matches the problem:

- **"It OOMs / RAM grows linearly during a streaming job"** → `mem-` and `pipe-` (likely an unbounded buffer or per-iteration accumulation)
- **"Disk is 100 % busy but CPU is idle"** → `io-` (likely random access, unbuffered I/O, or wrong format)
- **"Why is reading this 10 GB file so slow?"** → start with `fmt-columnar-for-analytical-scans` and `io-buffer-explicitly-for-small-records`
- **"How big should the chunk be?"** → [`batch-pick-chunk-size-by-memory-budget`](references/batch-pick-chunk-size-by-memory-budget.md)
- **"Data doesn't fit in RAM"** → `spill-` (and prefer an engine that does it for you: [`spill-use-engines-that-spill-automatically`](references/spill-use-engines-that-spill-automatically.md))
- **"Lots of small network calls"** → [`io-batch-and-pipeline-network-roundtrips`](references/io-batch-and-pipeline-network-roundtrips.md), [`io-async-for-many-concurrent-streams`](references/io-async-for-many-concurrent-streams.md)
- **"Adding workers didn't help"** → [`conc-tune-parallelism-to-the-bottleneck`](references/conc-tune-parallelism-to-the-bottleneck.md), [`obs-measure-iowait-not-just-cpu`](references/obs-measure-iowait-not-just-cpu.md)
- **"It's slow but I don't know why"** → `obs-` first; profile before changing anything

Code examples are in Python (most readable across audiences). The reasoning generalizes — equivalent libraries in other ecosystems (Arrow C++/Rust/Java, Polars Rust, DuckDB everywhere, libuv-style async) follow the same patterns.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for adding new rules |
| [metadata.json](metadata.json) | Version and reference information |
| [AGENTS.md](AGENTS.md) | Auto-built TOC navigation |

## Related Skills

- [`computer-science-algorithms`](../computer-science-algorithms/) — Algorithmic primitives this skill builds on (external merge sort, sketches, hash partitioning, sampling)
