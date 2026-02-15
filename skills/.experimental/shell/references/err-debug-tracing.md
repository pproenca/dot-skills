---
title: Use Debug Tracing with set -x and PS4
impact: HIGH
impactDescription: reduces debugging time by 5-10× with source-file:line context on every command
tags: err, debug, tracing, xtrace, PS4
---

## Use Debug Tracing with set -x and PS4

Without tracing, debugging shell scripts means adding temporary `echo` statements. `set -x` prints every command before execution, and a custom `PS4` adds file name and line numbers automatically.

**Incorrect (echo-based debugging):**

```bash
#!/bin/bash
deploy_service() {
  echo "DEBUG: Starting deploy"
  local image_tag
  image_tag=$(get_latest_tag "$service_name")
  echo "DEBUG: Got tag $image_tag"
  docker pull "registry.example.com/${service_name}:${image_tag}"
  echo "DEBUG: Pull done, status=$?"
  # Must remove all echo lines before committing
}
```

**Correct (set -x with custom PS4):**

```bash
#!/bin/bash
# PS4 shows source file, line number, and function name
export PS4='+ ${BASH_SOURCE[0]}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x

deploy_service() {
  local image_tag
  image_tag=$(get_latest_tag "$service_name")
  docker pull "registry.example.com/${service_name}:${image_tag}"
}

# Output: + deploy.sh:8:deploy_service(): get_latest_tag myapp
# Output: + deploy.sh:9:deploy_service(): docker pull registry.example.com/myapp:v2.3.1
```

**Enable tracing selectively:**

```bash
#!/bin/bash
export PS4='+ ${BASH_SOURCE[0]}:${LINENO}: '

# Trace only the problematic section
deploy_service() {
  local image_tag
  image_tag=$(get_latest_tag "$service_name")

  set -x  # Enable tracing
  docker pull "registry.example.com/${service_name}:${image_tag}"
  docker tag "${service_name}:${image_tag}" "${service_name}:latest"
  set +x  # Disable tracing

  notify_deployment "$image_tag"
}
```

**Debug via environment variable:**

```bash
#!/bin/bash
# Allow callers to enable tracing: DEBUG=1 ./deploy.sh
export PS4='+ ${BASH_SOURCE[0]}:${LINENO}: '
[[ "${DEBUG:-0}" == "1" ]] && set -x

# Script runs normally without DEBUG, traces with DEBUG=1
```

**Redirect trace output to file:**

```bash
#!/bin/bash
# Send trace to file, keep stdout/stderr clean
exec 4>debug_trace.log
BASH_XTRACEFD=4
export PS4='+ $(date +%T) ${BASH_SOURCE[0]}:${LINENO}: '
set -x

# Trace goes to debug_trace.log, not stderr
deploy_service "$@"
```

Reference: [Bash Manual - The Set Builtin](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
