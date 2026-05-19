---
title: Compress Responses and Shape Payloads
impact: MEDIUM
impactDescription: reduces 60-80% of API egress bandwidth
tags: api, compression, gzip, brotli, payload, response-size
---

## Compress Responses and Shape Payloads

A 50KB JSON response compresses to ~6KB with gzip and ~5KB with brotli — that's bandwidth, CDN cost, and time-to-first-byte cut by 8-10×. For an API serving millions of requests/day, compression alone is one of the largest cost levers. Pair with payload shaping: drop optional fields, use shorter keys for hot paths, and consider binary formats (msgpack, protobuf) for high-volume internal traffic.

Compression is mostly free CPU-wise on modern servers (~1-5% overhead) and the bandwidth savings dwarf it. Make sure it's enabled at the right layer.

**Incorrect (no compression — sending uncompressed JSON):**

```python
# settings.py — no compression middleware
MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    ...
]

# Response: 50KB sent on the wire for every request
```

**Correct (enable Django's GZip middleware):**

```python
# settings.py — put GZipMiddleware near the top, AFTER security
MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.middleware.gzip.GZipMiddleware",   # ✅ compress responses
    "django.contrib.sessions.middleware.SessionMiddleware",
    ...
]

# Response: 6KB sent on the wire (~10× smaller)
# Django auto-detects Accept-Encoding and only compresses when client supports it
```

**Better: compress at the reverse proxy (nginx) — frees Django CPU:**

```nginx
# nginx.conf
gzip on;
gzip_vary on;
gzip_min_length 256;
gzip_types
    application/json
    application/javascript
    text/css text/plain text/xml
    application/xml application/xml+rss
    image/svg+xml;
gzip_comp_level 5;  # 1-9; higher = more CPU, more compression. 5-6 is the sweet spot.

# Or brotli (better compression, requires the brotli nginx module):
brotli on;
brotli_types application/json application/javascript text/css text/plain;
brotli_comp_level 5;
brotli_static on;
```

When the reverse proxy compresses, Django doesn't need its own middleware. Pick one — not both.

**Shape payloads — drop fields the client doesn't render:**

```python
# ❌ Returning the full Product model in every list response
class ProductSerializer(ModelSerializer):
    class Meta:
        model = Product
        fields = "__all__"  # 30 fields, even when the UI shows 5

# ✅ Shape per use case
class ProductListSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    title = serializers.CharField()
    price = serializers.DecimalField(max_digits=10, decimal_places=2)
    thumbnail_url = serializers.URLField()
    in_stock = serializers.BooleanField()
# 5 fields × N items, 6× smaller than __all__
```

**Conditional fields via `fields` query param (sparse fieldsets):**

```python
class FlexibleSerializer(serializers.ModelSerializer):
    """Client passes ?fields=id,title to limit serialization."""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        request = self.context.get("request")
        if request is None:
            return
        fields_param = request.query_params.get("fields")
        if fields_param:
            allowed = set(fields_param.split(","))
            existing = set(self.fields)
            for field in existing - allowed:
                self.fields.pop(field)

class ProductSerializer(FlexibleSerializer):
    class Meta:
        model = Product
        fields = "__all__"

# Client requests:
# GET /products?fields=id,title,price
# Response: only id, title, price for each — ~50% smaller
```

**For high-volume internal APIs, consider msgpack:**

```python
import msgpack

class MsgPackRenderer(renderers.BaseRenderer):
    media_type = "application/msgpack"
    format = "msgpack"

    def render(self, data, accepted_media_type=None, renderer_context=None):
        return msgpack.packb(data, use_bin_type=True)

class MyView(APIView):
    renderer_classes = [JSONRenderer, MsgPackRenderer]

# Internal consumers request: Accept: application/msgpack
# Response is binary — typically 30-50% smaller than JSON before compression
```

**Drop nulls — JSON nulls are visual noise and bytes:**

```python
class CompactSerializer(serializers.Serializer):
    def to_representation(self, instance):
        data = super().to_representation(instance)
        return {k: v for k, v in data.items() if v is not None}
# {"id": 1, "title": "...", "discount": null} → {"id": 1, "title": "..."}
```

Be careful with this — some clients expect explicit `null` to distinguish "missing from response" from "present but null."

**Use shorter keys for high-volume responses:**

```python
# ❌ Verbose keys multiplied across thousands of items
{
    "product_identifier": 42,
    "product_display_title": "...",
    "current_market_price": 19.99,
}

# ✅ For internal feeds where size matters more than readability
{
    "id": 42,
    "title": "...",
    "price": 19.99,
}
```

For *public* APIs, prefer readability. For *internal* high-volume APIs (mobile app payloads), every byte counts.

**Pre-compress static-ish responses (e.g., catalog data):**

```python
# Compute and cache the gzipped response in Redis
import gzip

async def get_compressed_catalog(segment: str) -> bytes:
    cached = await redis.get(f"catalog:gzip:{segment}")
    if cached:
        return cached

    items = await get_catalog(segment)
    raw = json.dumps(items).encode()
    compressed = gzip.compress(raw, compresslevel=6)
    await redis.setex(f"catalog:gzip:{segment}", 3600, compressed)
    return compressed

# Return pre-compressed bytes directly
async def catalog_view(request):
    body = await get_compressed_catalog(_segment(request))
    response = HttpResponse(body, content_type="application/json")
    response["Content-Encoding"] = "gzip"
    response["Vary"] = "Accept-Encoding"
    return response
```

**Verify compression is working:**

```bash
curl -i -H "Accept-Encoding: gzip, deflate, br" https://api.example.com/recommendations
# Look for: Content-Encoding: gzip (or br)
# Look at: Content-Length — should be much smaller than the uncompressed size
```

**Don't compress already-compressed content:**

Images, videos, gzipped archives. Compressing them again costs CPU for ~0 benefit. Nginx's `gzip_types` directive restricts to text formats by default — good.

**Symptom of missing compression:**
- Egress bandwidth costs disproportionate to RPS
- Mobile users complain about data usage
- TTFB high on responses > 10KB

Reference: [Django — GZipMiddleware](https://docs.djangoproject.com/en/5.0/ref/middleware/#django.middleware.gzip.GZipMiddleware) | [nginx — gzip module](https://nginx.org/en/docs/http/ngx_http_gzip_module.html) | [msgpack](https://msgpack.org/)
