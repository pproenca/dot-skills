---
title: Handle or propagate what a broad except catches
tags: flow, exceptions, error-handling, silent-failure
---

## Handle or propagate what a broad except catches

`except Exception: pass` converts every future bug in the guarded block —
typos, broken imports called lazily, wrong types, real I/O failures — into
silence at the exact place a stack trace was about to say what happened. Bare
`except:` is worse still: it catches `SystemExit` and `KeyboardInterrupt`, so
the process resists Ctrl-C. Broad catches are legitimate only at genuine
last-resort boundaries (a request handler, a worker loop, a plugin host), and
there the handler must *do* something: log with the traceback and produce an
explicit outcome. A handler that swallows without recording is not error
handling — it is error deletion.

**Incorrect (every failure in sync() becomes nothing):**

```python
def refresh_all(accounts: list[Account]) -> None:
    for account in accounts:
        try:
            account.sync()
        except Exception:
            pass  # a typo inside sync() now fails silently, forever
```

**Correct (narrow when expected, or log-and-record at a boundary):**

```python
def refresh_all(accounts: list[Account]) -> list[SyncFailure]:
    failures: list[SyncFailure] = []
    for account in accounts:
        try:
            account.sync()
        except SyncTimeout as exc:                # the expected failure, narrowed
            logger.warning("sync timed out for %s", account.id)
            failures.append(SyncFailure(account.id, exc))
    return failures
```

**Evidence of violation:** an `except Exception:` or bare `except:` handler in
the target whose body neither re-raises, logs with the exception
(`logger.exception(...)` or `exc_info=True`), nor records/returns an explicit
error outcome — bodies consisting of `pass`, `continue`, a bare `return`, or
`return None` are the canonical shapes. PASS: expected failures are caught by
their specific exception types; broad handlers exist only at cited last-resort
boundaries (top of a worker/request loop) and both log the traceback and
produce an explicit outcome. `contextlib.suppress(SpecificError)` around a
statement is a PASS (it is narrow and declared). N/A: no exception handlers in
the target.

Reference: [PEP 8 — bare except and exception-handling guidance](https://peps.python.org/pep-0008/#programming-recommendations)
