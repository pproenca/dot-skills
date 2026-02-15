---
title: Use Docker Official Images
impact: HIGH
impactDescription: reduces vulnerability exposure and ensures best-practice configuration
tags: base, official-images, security, trust
---

## Use Docker Official Images

Random community images may contain outdated packages, known vulnerabilities, misconfigured defaults, or even intentional malware. Docker Official Images are curated by Docker in partnership with upstream maintainers, regularly scanned for vulnerabilities, and rebuilt when security patches are available.

**Incorrect (unverified community image):**

```dockerfile
FROM random-user/node-custom:latest

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

CMD ["node", "server.js"]
```

(The `random-user/node-custom` image has unverified provenance, unknown update cadence, and no guarantee of security scanning. It may bundle unnecessary tools or contain known CVEs that are never patched.)

**Correct (Docker Official Image):**

```dockerfile
FROM node:22-alpine

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY . .

CMD ["node", "server.js"]
```

(The `node:22-alpine` image is a Docker Official Image maintained by the Node.js Docker team. It receives regular security updates, follows Dockerfile best practices, and is scanned for vulnerabilities on Docker Hub.)

### Docker Hub Trust Tiers

Docker Hub organises images into three trust tiers that indicate the level of curation and verification:

| Tier | Badge | Meaning |
|------|-------|---------|
| **Docker Official Image** | `docker-official-image` | Curated by Docker, reviewed by upstream maintainers, regularly scanned and rebuilt |
| **Verified Publisher** | `verified-publisher` | Published by a verified commercial entity (e.g., Bitnami, Datadog, Nginx Inc.) |
| **Docker-Sponsored Open Source** | `open-source` | Published by an open-source project sponsored through Docker's OSS programme |

When choosing a base image, prefer Docker Official Images first. If an official image is not available for your runtime, look for Verified Publisher images before falling back to community images. Always check the image description, Dockerfile source, and update frequency before trusting any image as a base.

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
