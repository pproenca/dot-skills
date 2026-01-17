---
title: Use TaskGroup for Structured Concurrency
impact: HIGH
impactDescription: prevents resource leaks on failure
tags: conc, taskgroup, asyncio, error-handling
---

## Use TaskGroup for Structured Concurrency

`asyncio.gather()` doesn't cancel remaining tasks on error by default. `TaskGroup` (Python 3.11+) provides structured concurrency with automatic cancellation.

**Incorrect (tasks continue after failure):**

```python
async def fetch_all_data(user_ids: list[int]) -> list[dict]:
    tasks = [fetch_user(uid) for uid in user_ids]
    results = await asyncio.gather(*tasks)  # If one fails, others continue
    return results
    # Exception from one task doesn't stop others
```

**Correct (automatic cancellation on error):**

```python
async def fetch_all_data(user_ids: list[int]) -> list[dict]:
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch_user(uid)) for uid in user_ids]
    # If any task fails, all others are cancelled
    # ExceptionGroup raised with all errors
    return [task.result() for task in tasks]
```

**Alternative (gather with return_exceptions):**

```python
async def fetch_all_data(user_ids: list[int]) -> list[dict | Exception]:
    tasks = [fetch_user(uid) for uid in user_ids]
    results = await asyncio.gather(*tasks, return_exceptions=True)
    # Exceptions returned as values, not raised
    return [r for r in results if not isinstance(r, Exception)]
```

**Benefits of TaskGroup:**
- Automatic cancellation on first error
- Proper cleanup of all tasks
- Clear lifetime boundaries
- ExceptionGroup for handling multiple errors

Reference: [asyncio.TaskGroup documentation](https://docs.python.org/3/library/asyncio-task.html#asyncio.TaskGroup)
