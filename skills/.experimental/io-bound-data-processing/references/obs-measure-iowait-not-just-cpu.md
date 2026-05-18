---
title: Measure iowait, Not Just CPU
impact: LOW-MEDIUM
impactDescription: prevents optimizing the wrong stage; finds the actual bottleneck
tags: obs, iowait, bottleneck, use-method, top
---

## Measure iowait, Not Just CPU

"CPU is at 30 % — we have headroom" is the most expensive sentence in performance work. CPU% counts cycles spent executing instructions; it does *not* count cycles the process spent blocked waiting for disk or network. `iowait` is what fills the gap: time the CPU was idle because a process was waiting on I/O. A job at 30 % CPU and 65 % iowait isn't underutilized — it's I/O-bound, and adding more workers will hurt. The fix is to *always* read CPU% next to iowait, network throughput, and disk queue depth, and to design tuning decisions around the actually-saturated resource.

**Incorrect (looking at CPU% alone):**

```bash
# `top` shows 30% CPU. "There's room — let's add 20 more workers."
# Actually iowait is 65% — adding workers just queues more I/O.
top -n1 | head -5
```

**Correct (read CPU + iowait + per-device I/O):**

```bash
# iostat: %iowait + per-device utilization (%util) + queue depth (avgqu-sz).
iostat -x 1 5

# Or: vmstat — `wa` column is iowait, `r`/`b` are run/blocked queues.
vmstat 1 10

# Per-process I/O view — find which PID is blocked on what.
sudo iotop -o
```

```python
# In-process: psutil exposes the same counters.
import psutil
cpu = psutil.cpu_times_percent(interval=1)
print(f"user={cpu.user}% system={cpu.system}% idle={cpu.idle}% iowait={cpu.iowait}%")
# High iowait = I/O bottleneck.
```

**Brendan Gregg's USE method — check Utilization, Saturation, Errors for every resource:**

| Resource | Utilization | Saturation | Errors |
|---|---|---|---|
| CPU | `top` user+system | `vmstat r` (run queue length) | Microcode errors (rare) |
| Disk | `iostat -x` %util | `iostat avgqu-sz` (queue depth > 1) | `dmesg` (I/O errors) |
| Network | `ifstat` Mbps vs NIC line rate | TCP retransmits (`netstat -s`) | Interface errors (`ip -s link`) |
| Memory | `free` used vs total | `vmstat si/so` (swap activity) | OOM in `dmesg` |

**Bottleneck → action matrix:**

| Symptom | Likely cause | Action |
|---|---|---|
| High CPU%, low iowait | CPU-bound | Vectorize / parallelize compute |
| Low CPU%, high iowait | I/O-bound | Larger reads, async, prefetch, columnar |
| High iowait, %util ≈ 100 | Disk saturated | Reduce I/O volume, faster disk, parallel disks |
| High network, low disk | Network-bound | Compress, batch, move closer |
| Low CPU, low iowait, slow | Locks/coordination | Profile contention; check DB locks |

**Per-syscall view — sometimes the loss is syscall storm:**

```bash
# Count syscalls by type for a running process.
sudo strace -c -p $PID
# Look for very high counts of read/write with tiny sizes — suggests unbuffered I/O.
```

**When CPU% alone is enough:**
- Pure-compute jobs with no I/O (matrix multiply on in-memory data)
- Quick sanity checks where iowait is known to be ~zero
- Tight kernels measured in microseconds where the syscall overhead of iostat dominates

Reference: [Brendan Gregg — USE method](https://www.brendangregg.com/usemethod.html), [Linux man — iostat(1)](https://man7.org/linux/man-pages/man1/iostat.1.html), [psutil — cpu_times_percent](https://psutil.readthedocs.io/en/latest/#psutil.cpu_times_percent)
