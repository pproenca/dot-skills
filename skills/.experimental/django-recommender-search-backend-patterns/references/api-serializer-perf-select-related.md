---
title: Use select_related, prefetch_related, and only in DRF Serializers
impact: MEDIUM
impactDescription: reduces N+1 queries from serialization
tags: api, drf, serializer, n-plus-one, orm
---

## Use select_related, prefetch_related, and only in DRF Serializers

A DRF `ModelSerializer` with a nested `UserSerializer` field will issue one query *per row* to fetch the user — the N+1 problem. For a 20-item recommendations response, that's 21 database queries instead of 1. DRF doesn't auto-detect related fields you serialize; you have to specify what to join via `select_related`/`prefetch_related` on the queryset.

`only(...)` further bounds the work: by default, every column is fetched. For a Product with 30 columns where the serializer renders 5, `only("id", "title", "price", "thumbnail_url", "in_stock")` cuts row size 6× and eliminates expensive column fetches (e.g., serialized JSON, large text fields).

**Incorrect (N+1 serialization, full-row fetch):**

```python
# serializers.py
class RecommendationSerializer(serializers.ModelSerializer):
    product = ProductSerializer()    # nested
    user = UserSerializer()           # nested

    class Meta:
        model = Recommendation
        fields = ["id", "user", "product", "score", "created_at"]

# views.py
class RecommendationsList(ListAPIView):
    serializer_class = RecommendationSerializer
    queryset = Recommendation.objects.all()   # ❌ no joins, full columns

# For 20 results:
#   1 query: SELECT * FROM recommendations LIMIT 20
#  20 queries: SELECT * FROM products WHERE id = ?  (per row!)
#  20 queries: SELECT * FROM users WHERE id = ?
# Total: 41 queries
```

**Correct (eager joins + column projection):**

```python
class RecommendationsList(ListAPIView):
    serializer_class = RecommendationSerializer

    def get_queryset(self):
        return (
            Recommendation.objects
            .select_related("product", "user")           # ✅ join in 1 query
            .only(
                "id", "score", "created_at",
                "product__id", "product__title", "product__price", "product__thumbnail_url",
                "user__id", "user__name", "user__avatar_url",
            )                                             # ✅ project only needed columns
        )

# 1 query total: SELECT recommendations.*, products.*, users.* FROM ... JOIN ... JOIN ...
# 4× faster, smaller transfer, less DB load
```

**select_related vs prefetch_related:**

| Method | Use for | Generates |
|--------|---------|-----------|
| `select_related` | ForeignKey, OneToOne (single related row) | SQL JOIN |
| `prefetch_related` | ManyToMany, reverse ForeignKey (many related rows) | Second query with `WHERE id IN (...)` |

```python
# For many-to-one (one product belongs to one category):
qs = Product.objects.select_related("category")

# For many-to-many (one product has many tags):
qs = Product.objects.prefetch_related("tags")

# Combined:
qs = (
    Product.objects
    .select_related("category", "brand")           # 1:1 / many:1 → joins
    .prefetch_related("tags", "variants")          # 1:many / m:m → in-clauses
    .only("id", "title", "price", "category__name", "brand__name")
)
```

**For reverse relations with constraints, use Prefetch:**

```python
from django.db.models import Prefetch

# Fetch only active variants for each product
qs = Product.objects.prefetch_related(
    Prefetch(
        "variants",
        queryset=Variant.objects.filter(is_active=True).only("id", "name", "stock"),
        to_attr="active_variants",
    )
)
# Each product now has product.active_variants
# Without the to_attr, it would shadow product.variants (the manager)
```

**Use `values_list` for trivial responses (skip serializer overhead):**

For endpoints that just return a list of IDs or simple tuples:

```python
# Slow: full ORM + serializer
ids = list(Product.objects.filter(...).values("id"))
# Fast: direct values_list (no model instantiation)
ids = list(Product.objects.filter(...).values_list("id", flat=True))
# Faster still on huge lists: queryset.iterator(chunk_size=1000)
```

**Detect N+1 in development:**

```python
# requirements-dev.txt
django-debug-toolbar

# settings.py (dev only)
INSTALLED_APPS += ["debug_toolbar"]
MIDDLEWARE += ["debug_toolbar.middleware.DebugToolbarMiddleware"]

# Or use nplusone for automated detection
INSTALLED_APPS += ["nplusone.ext.django"]
MIDDLEWARE += ["nplusone.ext.django.NPlusOneMiddleware"]
NPLUSONE_RAISE = True   # fails tests on N+1
```

`nplusone` raises an exception on every detected N+1, surfacing them in CI before they reach production.

**Avoid `to_representation` overrides that re-query:**

```python
# ❌ Subtle N+1: to_representation calls .first() on a related queryset
class ProductSerializer(serializers.ModelSerializer):
    primary_image = serializers.SerializerMethodField()

    def get_primary_image(self, obj):
        return obj.images.first().url   # ← one query per product

# ✅ Use Prefetch + first item in Python
class ProductSerializer(serializers.ModelSerializer):
    primary_image = serializers.SerializerMethodField()

    def get_primary_image(self, obj):
        # Relies on Prefetch having already loaded obj.images
        images = list(obj.images.all())  # uses prefetched data
        return images[0].url if images else None
```

**For large nested responses, consider flat serialization:**

When the nested object is heavy (lots of fields, deep nesting), flatten it:

```python
# Heavy nested
{"user": {"id": ..., "name": ..., "email": ..., "preferences": {...}}}

# Flat with just the fields needed
{"user_id": ..., "user_name": ...}

# Implement with SerializerMethodField:
class RecommendationSerializer(serializers.Serializer):
    user_id = serializers.IntegerField(source="user.id")
    user_name = serializers.CharField(source="user.name")
    # ... no nested UserSerializer
```

**Symptom of N+1 in serialization:**
- Endpoint latency scales linearly with `page_size`
- Database query count > 5 per simple list endpoint
- "Single row fast, list slow" mismatch

Reference: [Django — Database access optimization](https://docs.djangoproject.com/en/5.0/topics/db/optimization/) | [DRF — Optimizing serialization](https://www.django-rest-framework.org/api-guide/serializers/) | [nplusone](https://github.com/jmcarp/nplusone)
