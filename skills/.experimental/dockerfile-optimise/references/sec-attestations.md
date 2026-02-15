---
title: Enable SBOM and Provenance Attestations
impact: MEDIUM
impactDescription: reduces CVE audit time from hours of manual inspection to seconds via machine-readable SBOM
tags: sec, sbom, provenance, attestations, supply-chain
---

## Enable SBOM and Provenance Attestations

Without attestations, there is no machine-readable record of what packages are inside an image or how it was built. This makes vulnerability auditing, license compliance, and incident response slow and unreliable -- teams resort to running containers and inspecting them manually. SBOM (Software Bill of Materials) and provenance attestations embed this metadata directly into the image index, enabling automated scanning and verifiable build provenance.

**Incorrect (no attestation metadata):**

```bash
docker build -t registry.example.com/myapp:latest .
docker push registry.example.com/myapp:latest
```

(The pushed image contains no SBOM or provenance data. Vulnerability scanners must pull the image and perform a full filesystem scan to identify packages. There is no cryptographic proof of where or how the image was built.)

**Correct (SBOM and provenance attestations enabled):**

```bash
docker buildx build \
    --sbom=true \
    --provenance=true \
    --push \
    -t registry.example.com/myapp:latest .
```

(The image is pushed with an SBOM listing all OS packages and application dependencies, plus a provenance attestation recording the build source, builder identity, and build parameters. Both are attached to the image index as OCI referrers.)

**Correct (inspecting attestations after push):**

```bash
# View the SBOM for a pushed image
docker buildx imagetools inspect \
    registry.example.com/myapp:latest \
    --format '{{ json .SBOM }}'

# View provenance data
docker buildx imagetools inspect \
    registry.example.com/myapp:latest \
    --format '{{ json .Provenance }}'
```

(Attestation data is stored alongside the image manifest in the registry. It can be queried without pulling the full image layers.)

**Correct (CI pipeline with attestations and Docker Scout scanning):**

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

USER nobody
CMD ["gunicorn", "app.wsgi:application"]
```

```bash
# Build, attest, and push
docker buildx build \
    --sbom=true \
    --provenance=mode=max \
    --push \
    -t registry.example.com/myapp:v1.2.3 .

# Scan the image using the attached SBOM
docker scout cves registry.example.com/myapp:v1.2.3
```

(The `mode=max` provenance option captures the full build definition including the Dockerfile source. Docker Scout uses the SBOM to identify known CVEs without needing to unpack every layer.)

### Key Details

- **Attestations require `--push`**: They are stored as additional manifests in the image index and cannot be attached when using `--load` (which produces a single-platform image without an index).
- **SBOM generators**: BuildKit uses Syft by default to scan the filesystem and generate a CycloneDX or SPDX SBOM.
- **Provenance levels**: `mode=min` records basic build metadata; `mode=max` additionally captures the full build source and reproducibility information.
- **Registry support**: Attestations are stored as OCI artifacts. Most modern registries (Docker Hub, GitHub Container Registry, Amazon ECR, Google Artifact Registry) support them.

Reference: [Build attestations](https://docs.docker.com/build/metadata/attestations/)
