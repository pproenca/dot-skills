---
title: Stream Large Inputs Instead of Loading Them Whole
impact: HIGH
impactDescription: O(n) memory to O(1) — enables processing files larger than RAM
tags: space, streaming, generator, file-io, memory
---

## Stream Large Inputs Instead of Loading Them Whole

Reading a 5GB file with `open(path).read()` allocates 5GB in memory before you can process the first byte. Most line-oriented or chunk-oriented processing doesn't need the whole file resident — the natural shape is "for each line, do X." Iterating over the file handle yields one line at a time, with O(1) memory regardless of file size. The same applies to network streams (use `iter_content`/`iter_lines`), database cursors (`.fetchmany` / server-side cursors), and large API paginated responses. Beyond memory, streaming gives you "first byte" latency — the consumer can start producing output before the whole input is read.

**Incorrect (load entire file — O(file size) memory):**

```python
with open('access.log') as f:
    lines = f.readlines()                  # allocates the whole file
for line in lines:
    process(line)
# 5GB file → 5GB RAM, OOM on small instances
```

**Correct (stream — O(1) memory):**

```python
with open('access.log') as f:
    for line in f:                         # yields one line at a time
        process(line)
# Constant memory regardless of file size
```

**Alternative (Node.js streams for HTTP body / file):**

```javascript
import { createReadStream } from 'node:fs';
import readline from 'node:readline';

const rl = readline.createInterface({ input: createReadStream(path) });
for await (const line of rl) {
  process(line);
}
```

**Alternative (database — server-side cursor):**

```python
# psycopg2: named cursor enables server-side iteration without loading all rows
with conn.cursor(name='stream_rows') as cur:
    cur.itersize = 1000
    cur.execute("SELECT * FROM events")
    for row in cur:                        # batches of 1000, not all at once
        process(row)
```

**When NOT to use this pattern:**
- When the algorithm requires random access across the file (e.g., reverse iteration, sort) — you must materialize, but consider `mmap` for OS-managed paging.
- When the file is small (< 100MB on a modern machine) — load and process is simpler and the memory cost is negligible.

Reference: [Python file objects support iteration line-by-line](https://docs.python.org/3/tutorial/inputoutput.html#methods-of-file-objects)
