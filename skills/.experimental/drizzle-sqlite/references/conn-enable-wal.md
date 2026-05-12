---
title: Enable WAL journal mode for concurrent reads + one writer
impact: MEDIUM-HIGH
impactDescription: 10-100x tail-latency reduction under write load
tags: conn, wal, pragma, concurrency
---

## Enable WAL journal mode for concurrent reads + one writer

SQLite's default `journal_mode=DELETE` uses rollback journals — readers and writers block each other on the same file. `journal_mode=WAL` (write-ahead log) changes the model: readers see a consistent snapshot while one writer appends to the WAL file, and readers don't block the writer. The pragma is **persistent** — once set on a database, it stays set across connections. Set it once, on the first connection, before any heavy traffic.

**Incorrect (rollback journal — reads block on writers):**

```typescript
import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';

const sqlite = new Database('./app.db'); // default journal_mode=DELETE
export const db = drizzle(sqlite);
```

Under load: a write transaction takes ~50 ms, every concurrent read waits the full 50 ms. Tail latency spikes correlate with write traffic.

**Correct (WAL mode — readers proceed during writes):**

```typescript
import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';

const sqlite = new Database('./app.db');

// Persistent pragmas — only need to set once per database, but cheap to re-apply:
sqlite.pragma('journal_mode = WAL');
sqlite.pragma('synchronous = NORMAL');         // safe with WAL; full fsync is overkill
sqlite.pragma('foreign_keys = ON');            // see conn-foreign-keys-pragma
sqlite.pragma('busy_timeout = 5000');          // see conn-set-busy-timeout

export const db = drizzle(sqlite);
```

**WAL files to be aware of:**
- `app.db` — the main database file.
- `app.db-wal` — the write-ahead log. Grows during writes, checkpointed back into `app.db` periodically.
- `app.db-shm` — shared memory file. Required for WAL coordination.

Back these up together; copying only `app.db` while WAL has uncheckpointed writes loses data. Use `VACUUM INTO` or the SQLite backup API for hot backups.

**For libsql (Turso embedded / local):**

```typescript
import { createClient } from '@libsql/client';
import { drizzle } from 'drizzle-orm/libsql';

const client = createClient({ url: 'file:local.db' });
// libsql defaults to WAL; no pragma needed for local files.
// Remote (Turso): no pragma — the server manages journal mode.
export const db = drizzle(client);
```

**When NOT to use WAL:**
- Network filesystems (NFS, SMB) — WAL relies on shared memory and breaks. Use rollback journal or copy the file locally.
- Read-only databases — `journal_mode=OFF` is fine and saves a few syscalls.

Reference: [SQLite — WAL mode](https://www.sqlite.org/wal.html) · [SQLite — PRAGMA journal_mode](https://www.sqlite.org/pragma.html#pragma_journal_mode)
