---
title: Use Async ORM Methods in Async Views
impact: MEDIUM-HIGH
impactDescription: prevents event-loop blocking on ORM calls
tags: async, orm, sync-to-async, django, blocking
---

## Use Async ORM Methods in Async Views

Inside an `async def` view, calling `Model.objects.get(...)` is synchronous. It blocks the event loop for the duration of the database query. Django 4.1+ provides native async ORM methods (`aget`, `afilter`, `acreate`, `asave`, `adelete`) that integrate properly with the event loop. For pre-4.1 code (or for libraries that don't provide async equivalents), wrap with `sync_to_async`.

The trap: `sync_to_async` is often used incorrectly — without `thread_sensitive=True`, it spawns a fresh thread for each call, losing database connection reuse and serializing all DB access through `ASGI_THREADS` (default 1 in some deployments).

**Incorrect (sync ORM call in async view — blocks event loop):**

```python
async def get_user_segment(request):
    # ❌ Sync ORM blocks the event loop for the duration of the query
    profile = UserProfile.objects.select_related("segment").get(user=request.user)
    return JsonResponse({"segment": profile.segment.name})
```

**Correct (Django 4.1+ async ORM):**

```python
async def get_user_segment(request):
    profile = await UserProfile.objects.select_related("segment").aget(user=request.user)
    return JsonResponse({"segment": profile.segment.name})
```

**Async equivalents (Django 4.1+):**

| Sync method | Async method |
|-------------|--------------|
| `.get(...)` | `.aget(...)` |
| `.filter(...).first()` | `.filter(...).afirst()` |
| `.filter(...).last()` | `.filter(...).alast()` |
| `.create(...)` | `.acreate(...)` |
| `.save()` | `.asave()` |
| `.delete()` | `.adelete()` |
| `.count()` | `.acount()` |
| `.exists()` | `.aexists()` |
| `.update_or_create(...)` | `.aupdate_or_create(...)` |
| `.bulk_create([...])` | `.abulk_create([...])` |
| iteration: `for x in qs:` | `async for x in qs:` |

**For older Django or sync libraries (boto3, etc.) — sync_to_async with care:**

```python
from asgiref.sync import sync_to_async

# Correct usage — thread_sensitive=True keeps DB connection reuse working
get_profile = sync_to_async(
    lambda user_id: UserProfile.objects.select_related("segment").get(user_id=user_id),
    thread_sensitive=True,
)

async def get_user_segment(request):
    profile = await get_profile(request.user.id)
    return JsonResponse({"segment": profile.segment.name})
```

**The `thread_sensitive` flag matters:**

| Setting | Behavior |
|---------|----------|
| `thread_sensitive=True` (default) | All wrapped calls share a single thread; DB connections reused; safe with Django ORM |
| `thread_sensitive=False` | Calls spawn fresh threads; better parallelism BUT each thread opens its own DB connection — exhausts connection pool fast |

For Django ORM, almost always use the default (`True`). For independent CPU-bound work (parsing, compression), `False` allows true parallelism in the thread pool.

**Wrapping boto3 (sync) for AWS calls in async views:**

```python
import asyncio

# boto3 client is sync — wrap calls in to_thread
_personalize = boto3.client("personalize-runtime", ...)

async def get_personalize_recommendations(user_id: str):
    return await asyncio.to_thread(
        _personalize.get_recommendations,
        campaignArn=settings.PERSONALIZE_CAMPAIGN_ARN,
        userId=user_id,
        numResults=20,
    )
```

`asyncio.to_thread` (Python 3.9+) is the modern equivalent of `loop.run_in_executor` — clean and idiomatic for one-shot calls.

**Avoid mixing sync and async DB operations in one request:**

```python
# ❌ One sync_to_async + one direct async — coordinates via thread_sensitive sharing
# This works but is confusing; pick one style per request
async def my_view(request):
    profile = await sync_to_async(UserProfile.objects.get, thread_sensitive=True)(user=request.user)
    posts = await Post.objects.filter(author=profile).acount()
    # works but the sync_to_async and async-ORM use different code paths internally

# ✅ Pure async — clearer
async def my_view(request):
    profile = await UserProfile.objects.aget(user=request.user)
    posts = await Post.objects.filter(author=profile).acount()
```

**Database connection pool sizing for async:**

Async views can have many in-flight queries concurrently per worker. Default Django uses 1 connection per thread. For async workloads, configure persistent connections + sufficient max connections at the database:

```python
# settings.py
DATABASES = {
    "default": {
        ...
        "CONN_MAX_AGE": 60,           # reuse connections for 60s
        "CONN_HEALTH_CHECKS": True,   # validate before reuse
        "OPTIONS": {
            "connect_timeout": 5,
            # PgBouncer in transaction-pooling mode helps multiplex
        },
    }
}
```

Pair with PgBouncer (or similar) in front of Postgres to multiplex many Django async connections onto fewer Postgres backend connections.

**Don't fan out per-row queries in async loops:**

```python
# ❌ N+1 — N database round-trips even with async
async def with_authors(post_ids: list[str]):
    posts = []
    async for post in Post.objects.filter(id__in=post_ids):
        author = await User.objects.aget(id=post.author_id)  # ← per-iteration query
        posts.append({"post": post, "author": author})
    return posts

# ✅ Use select_related/prefetch_related — one query, eager join
async def with_authors(post_ids: list[str]):
    return [
        {"post": p, "author": p.author}
        async for p in Post.objects.filter(id__in=post_ids).select_related("author")
    ]
```

**Symptom of missing async ORM:**
- "Async view but throughput same as sync view" — likely blocking on ORM
- Connection pool exhausted under load
- p99 spikes correlating with DB query latency rather than fan-out

Reference: [Django — Async support](https://docs.djangoproject.com/en/5.0/topics/async/) | [Django — Asynchronous queries](https://docs.djangoproject.com/en/5.0/topics/db/queries/#asynchronous-queries) | [asgiref — sync_to_async](https://docs.djangoproject.com/en/5.0/topics/async/#asgiref.sync.sync_to_async)
