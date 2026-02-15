---
title: Separate Local Declaration from Command Substitution
impact: CRITICAL
impactDescription: prevents masked exit codes in 100% of local+assignment cases
tags: port, export, local, variables, posix, exit-status
---

## Separate Local Declaration from Command Substitution

Combining `local` (or `declare`) with command substitution masks the exit status. The `local` builtin always succeeds, overwriting `$?` from the substituted command. This causes silent failures even with `set -e`.

**Incorrect (combined declaration and assignment):**

```bash
#!/bin/bash
set -euo pipefail

process_config() {
  # local succeeds, masking the failed command's exit status
  local config_data=$(cat /nonexistent/config.yaml)
  echo "Status: $?"  # Always 0 — local succeeded!
  echo "$config_data"
}

process_config  # No error raised despite missing file
```

**Correct (separate declaration and assignment):**

```bash
#!/bin/bash
set -euo pipefail

process_config() {
  local config_data
  config_data=$(cat /nonexistent/config.yaml)  # Exits here with set -e
  echo "Status: $?"  # Shows actual exit status
  echo "$config_data"
}

process_config  # Correctly fails if file is missing
```

**Multiple variables:**

```bash
#!/bin/bash
set -euo pipefail

deploy_service() {
  # Declare all locals first
  local image_tag
  local registry_url
  local deploy_status

  # Then assign — exit status is preserved
  image_tag=$(get_latest_tag "$service_name")
  registry_url=$(resolve_registry "$environment")

  docker pull "${registry_url}/${service_name}:${image_tag}"
}
```

**Applies to both bash and POSIX sh:**

```sh
#!/bin/sh
# POSIX sh has the same issue with local (where supported)
fetch_user() {
  local user_json
  user_json=$(curl -sf "https://api.example.com/users/$1") || return 1
  echo "$user_json"
}
```

**Note on export:** The `export VAR=value` combined syntax is valid POSIX (IEEE Std 1003.1-2001). Unlike `local`, `export VAR=$(cmd)` does preserve exit status in most shells, but separating them is still clearer and avoids confusion.

Reference: [ShellCheck SC2155](https://www.shellcheck.net/wiki/SC2155)
