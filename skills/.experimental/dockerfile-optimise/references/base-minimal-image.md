---
title: Use Minimal Base Images
impact: HIGH
impactDescription: 2-18× image size reduction depending on runtime and variant
tags: base, alpine, slim, image-size
---

## Use Minimal Base Images

Full distribution images like `ubuntu` or `debian` bundle hundreds of packages your application never uses -- compilers, man pages, documentation, and system utilities. This bloats the image, increases pull and deploy times, and widens the attack surface with software that is present but never needed.

**Incorrect (full distribution base image):**

```dockerfile
FROM python:3.12

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

CMD ["python", "app.py"]
```

(The `python:3.12` tag is built on full Debian and includes gcc, make, man pages, and hundreds of system packages. The resulting image exceeds 900MB before any application code is added.)

**Correct (slim variant removes non-essential packages):**

```dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

CMD ["python", "app.py"]
```

(The `python:3.12-slim` tag strips compilers, documentation, and rarely-used system packages. The base layer drops from ~900MB to ~150MB with no code changes required.)

**Correct (Alpine variant for maximum size reduction):**

```dockerfile
FROM python:3.12-alpine

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

CMD ["python", "app.py"]
```

(The `python:3.12-alpine` tag uses Alpine Linux with musl libc. The base layer is ~50MB, but some Python packages with C extensions may require additional build dependencies.)

### Approximate Base Image Sizes

| Variant            | Base Size  | Use Case                                |
|--------------------|------------|-----------------------------------------|
| `python:3.12`      | ~900MB     | Development or when full toolchain needed |
| `python:3.12-slim` | ~150MB     | Production default for most applications  |
| `python:3.12-alpine` | ~50MB    | Maximum size reduction for compatible apps |

### When NOT to Use Minimal Images

Alpine uses musl libc instead of glibc. Libraries that depend on glibc-specific behaviour (such as certain scientific computing packages, DNS resolution edge cases, or pre-compiled binary wheels) may fail to build or behave differently on Alpine. In those cases, use the `-slim` variant, which retains glibc compatibility while still removing non-essential packages.

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
