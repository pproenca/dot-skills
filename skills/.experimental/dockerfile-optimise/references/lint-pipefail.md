---
title: Use pipefail for Piped RUN Commands
impact: MEDIUM
impactDescription: prevents silent failures in piped commands
tags: lint, pipefail, shell, error-handling
---

## Use pipefail for Piped RUN Commands

In a piped command (`cmd1 | cmd2`), the shell only evaluates the exit code of the last command in the pipeline. If an earlier command fails but the final command succeeds, the entire `RUN` instruction is considered successful. This means a failed download, a broken compilation step, or a corrupted data stream can silently pass through the build while producing an image with missing or incomplete content.

**Incorrect (piped command without pipefail -- silent failure):**

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends wget

# If wget fails (DNS error, 404, timeout), bash receives empty input
# but exits 0 because bash itself succeeds -- build continues silently
RUN wget -O - https://example.com/install.sh | bash
```

(If `wget` fails due to a network error or 404, `bash` receives empty input and exits with code 0. The build continues without any indication that the installation script never ran.)

**Correct (pipefail causes the pipeline to fail on any command error):**

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends wget

# set -o pipefail makes the pipeline return the exit code of the
# first command that fails, not just the last command
RUN set -o pipefail && wget -O - https://example.com/install.sh | bash
```

(With `pipefail` enabled, if `wget` exits with a non-zero code, the entire pipeline fails immediately and the build stops with a clear error.)

**Correct (explicit shell form for images where /bin/sh is dash):**

```dockerfile
FROM debian:12-slim

# dash (the default /bin/sh on Debian) does not support pipefail.
# Explicitly invoke bash to ensure the option is available.
RUN ["/bin/bash", "-c", "set -o pipefail && curl -fsSL https://deb.nodesource.com/setup_22.x | bash -"]

RUN apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*
```

(The exec form `["/bin/bash", "-c", "..."]` guarantees bash is the interpreter regardless of what `/bin/sh` points to.)

### Combining with set -e

For maximum safety, combine `pipefail` with `set -e` (exit on error) in multi-line scripts:

```dockerfile
RUN set -euo pipefail && \
    curl -fsSL https://example.com/gpg-key.asc | gpg --dearmor -o /usr/share/keyrings/example.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/example.gpg] https://example.com/repo stable main" \
      > /etc/apt/sources.list.d/example.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends example-package && \
    rm -rf /var/lib/apt/lists/*
```

### Shell Compatibility

`set -o pipefail` is a bash feature. The default `/bin/sh` in Debian-based and Ubuntu-based images is `dash`, which does not support it. If your `RUN` instructions use the shell form (not exec form), they run under `/bin/sh` by default. Either use the exec form with an explicit bash invocation, or set the default shell for subsequent instructions:

```dockerfile
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# All subsequent RUN instructions now use bash with pipefail enabled
RUN curl -fsSL https://example.com/install.sh | bash
```

Reference: [Building best practices](https://docs.docker.com/build/building/best-practices/)
