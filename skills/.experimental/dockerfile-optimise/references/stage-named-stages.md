---
title: Use Named Build Stages
impact: HIGH
impactDescription: improves maintainability and enables targeted builds
tags: stage, named-stages, as, maintainability
---

## Use Named Build Stages

Using numeric stage references like `COPY --from=0` is fragile because inserting, removing, or reordering stages silently breaks all downstream references. Named stages make the Dockerfile self-documenting and resilient to structural changes.

**Incorrect (numeric stage reference breaks when stages change):**

```dockerfile
FROM node:22-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:1.27-alpine
# If a new stage is inserted above, "0" now points to the wrong stage
COPY --from=0 /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Correct (named stage is explicit and stable):**

```dockerfile
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:1.27-alpine
# "build" always refers to the correct stage regardless of ordering
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Reference: [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
