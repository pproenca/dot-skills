---
title: Profile With py-spy and strace to Find Hidden Per-Row Syscall Storms
impact: LOW-MEDIUM
impactDescription: 10-100x speedup when a hidden syscall storm is the bottleneck
tags: obs, py-spy, strace, profiling, syscalls
---

## Profile With py-spy and strace to Find Hidden Per-Row Syscall Storms

"It's slow but I don't know why" is solved by two attached-to-a-running-process tools. `py-spy top -p $PID` shows where Python time is going *right now*, without instrumenting the code — perfect for finding `apply()` loops, accidental quadratic blowups, and surprising library hotspots. `strace -c -p $PID` shows kernel time by syscall — perfect for finding per-row syscall storms (one `read(4096)` per record, one `gettimeofday` per log line, one `stat` per file lookup). Together they cover the two layers where slow code hides; both attach to a running process and print results in seconds. Guessing at the cause from code reading often misses both layers entirely.

**Incorrect (guessing at the cause; adding ad-hoc print timings):**

```python
# Guesses the JSON parsing is slow — sprinkles prints, changes the code, restarts the job.
import time

t0 = time.perf_counter()
for line in source:
    record = json.loads(line)
    t1 = time.perf_counter()
    process(record)
    t2 = time.perf_counter()
    if (t2 - t0) > 5:
        print(f"parse={t1-t0:.3f} process={t2-t1:.3f}")
        t0 = t2
# Adds overhead, perturbs timing, and still misses the real hotspot (often a hidden syscall storm).
```

**Correct (attach py-spy + strace to the live process; zero code change):**

```bash
# Step 1 — py-spy: see where Python is spending CPU, live.
sudo py-spy top --pid $PID

# Step 2 — strace -c: count syscalls; tiny reads or stats in the millions = unbuffered I/O.
sudo strace -c -p $PID
# (Let it run ~10 s, then Ctrl-C for the summary.)

# Step 3 — only after the data points at a culprit, edit code and re-measure.
```

```text
Sample py-spy top output:
Total Samples 10000
GIL: 87.00%, Active: 99.00%, Threads: 1

  %Own   %Total  OwnTime  TotalTime  Function (filename:line)
  45.20  45.20    4.50s    4.50s    json.loads (json/__init__.py:357)
  18.10  18.10    1.81s    1.81s    str.format ( ... )

Sample strace -c output:
% time     seconds  usecs/call     calls    errors syscall
 38.21    0.245312          27      9123        --     read
 30.10    0.193288          19     10100        --     write
 25.04    0.160770       80385         2        --     futex
9000+ reads in 10 s → unbuffered tiny I/O.
```

**Capture a flamegraph for offline analysis:**

```bash
sudo py-spy record -o profile.svg --pid $PID --duration 60
```

**Common findings & fixes:**

| py-spy / strace pattern | Likely cause | Fix |
|---|---|---|
| `json.loads` dominates py-spy | JSON parsing on hot path | `orjson`, or switch to a binary format |
| `pd.iterrows` / `apply` dominates | per-row Python loop | Vectorize ([`batch-use-vectorized-apis-not-row-loops`](batch-use-vectorized-apis-not-row-loops.md)) |
| Millions of tiny `read()` syscalls | unbuffered I/O | Wrap in `BufferedReader` ([`io-buffer-explicitly-for-small-records`](io-buffer-explicitly-for-small-records.md)) |
| Many `stat()` / `open()` calls | filesystem walks in hot path | Cache directory listings; index up front |
| High `futex` time | lock contention | Reduce shared state; coarsen / partition locks |
| `gettimeofday` per record | timestamping in inner loop | Sample timestamps; don't capture per row |
| `getaddrinfo` repeated | DNS lookups not cached | Single resolver/connection pool |

**For C-level hotspots — `perf` or `bpftrace`:**

```bash
sudo perf record -F 99 -g -p $PID -- sleep 30
sudo perf script | stackcollapse-perf.pl | flamegraph.pl > flame.svg
```

```bash
# bpftrace — count syscalls system-wide by process.
sudo bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm, args->id] = count(); }'
```

**Quick checklist when "it's slow":**
1. `py-spy top` for ~30 s — find the dominant Python frame
2. `strace -c` for ~10 s — find any syscall over 1k/s suggesting per-row work
3. Verify with `iostat` / `psutil` (see [`obs-measure-iowait-not-just-cpu`](obs-measure-iowait-not-just-cpu.md))
4. Fix the biggest contributor first; re-measure

**When profilers are overkill:**
- The hot loop is obvious from code reading and a one-line change is the fix
- Wall-clock is already acceptable
- Very short tasks where profiler startup dominates

Reference: [py-spy](https://github.com/benfred/py-spy), [strace(1)](https://man7.org/linux/man-pages/man1/strace.1.html), [Brendan Gregg — perf examples](https://www.brendangregg.com/perf.html)
