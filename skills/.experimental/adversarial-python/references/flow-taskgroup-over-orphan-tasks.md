---
title: Own task lifecycles with TaskGroup
tags: flow, asyncio, taskgroup, create-task
---

## Own task lifecycles with TaskGroup

Requires Python ≥ 3.11 for `TaskGroup` (the retained-reference half applies on every floor).

A fire-and-forget `asyncio.create_task(...)` has two documented failure modes:
the event loop holds only a weak reference, so a task nobody stores can be
garbage-collected before it finishes; and an exception inside it is reported
nowhere until the task object is collected, long after the cause. The asyncio
docs themselves instruct saving every task reference. `asyncio.TaskGroup`
(3.11) makes the lifecycle structural — tasks cannot outlive the block,
exceptions propagate to the awaiting code (as an `ExceptionGroup`), and
sibling tasks are cancelled on failure instead of racing on.

**Incorrect (task may vanish mid-flight; its exception is silent):**

```python
async def confirm_order(order: Order) -> None:
    await charge(order)
    asyncio.create_task(send_confirmation_email(order))  # never stored, never awaited
```

**Correct (lifecycle and errors owned by the block):**

```python
async def confirm_order(order: Order) -> None:
    await charge(order)
    async with asyncio.TaskGroup() as tg:
        tg.create_task(send_confirmation_email(order))
        tg.create_task(update_inventory(order))
    # both finished (or raised) here
```

**Evidence of violation:** an `asyncio.create_task(...)` (or
`asyncio.ensure_future(...)`) whose return value is neither assigned to a
retained reference (collection, instance/module attribute) nor awaited, on a
Python floor ≥ 3.11. PASS: tasks are created inside an `asyncio.TaskGroup`, or
— for genuinely long-lived background work — the task is stored in a retained
set/attribute with a completion callback that surfaces exceptions (cite both
the storage and the callback; the docs' `background_tasks.add(task)` +
`task.add_done_callback(background_tasks.discard)` pattern). N/A: Python floor
< 3.11 (judge only the retained-reference half, which every floor supports),
or no task creation in the target.

Reference: [asyncio.create_task reference-holding warning and TaskGroup — Python documentation](https://docs.python.org/3/library/asyncio-task.html#asyncio.TaskGroup)
