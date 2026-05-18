---
title: Prefer Generators Over Lists for Multi-Stage Pipelines
impact: CRITICAL
impactDescription: from peak N×stage memory to O(1) per stage
tags: mem, generators, iterators, lazy-evaluation, pipelines
---

## Prefer Generators Over Lists for Multi-Stage Pipelines

A list comprehension materializes the entire intermediate sequence; a generator expression streams one item at a time. When stages are chained (read → parse → filter → transform → write), every materialized intermediate multiplies peak RAM. Generators turn an N-stage pipeline from "all stages resident at once" into "one row resident at a time" — the same data, the same logic, a fraction of the memory.

**Incorrect (each stage materializes the full intermediate):**

```python
# Three full copies of the data live simultaneously at peak.
lines = open("events.log").readlines()                  # list: every line
parsed = [json.loads(l) for l in lines]                 # list: every dict
filtered = [r for r in parsed if r["status"] == "200"]  # list: subset
for row in filtered:
    sink.write(row)
```

**Correct (generator expressions; only the current row is alive):**

```python
# Each row flows through; only one row's worth of state at any moment.
with open("events.log") as f:
    parsed = (json.loads(line) for line in f)
    filtered = (r for r in parsed if r["status"] == "200")
    for row in filtered:
        sink.write(row)
```

**Implementation pattern (re-usable pipeline stages):**

```python
def parse(lines):
    for line in lines:
        yield json.loads(line)

def only_2xx(rows):
    for r in rows:
        if 200 <= r["status"] < 300:
            yield r

with open("events.log") as f:
    for r in only_2xx(parse(f)):
        sink.write(r)
```

**When NOT to use generators:**
- You need to iterate the same sequence twice — generators are single-pass; `tee` doubles memory and `list()` materializes
- You need random access or `len()` — generators don't support either

Reference: [PEP 289 — Generator Expressions](https://peps.python.org/pep-0289/), [Python docs — Generators](https://docs.python.org/3/tutorial/classes.html#generators)
