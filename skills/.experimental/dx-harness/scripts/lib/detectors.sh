#!/usr/bin/env bash
# detectors.sh — primitive checks for what a repo IS
# Source from other scripts:  source "$(dirname "$0")/lib/detectors.sh"
#
# Each detector echoes a single value (or empty) and returns 0. They never fail —
# absence is communicated by empty stdout, so detectors are safe to chain in pipelines.

set -euo pipefail

# ---- Languages ----
# Emits a JSON array string like ["typescript","python"] (empty array if none).
detect_languages() {
  local root="${1:-$PWD}"
  local langs=()
  [[ -f "${root}/package.json" ]] && langs+=("javascript")
  ( [[ -f "${root}/tsconfig.json" ]] || compgen -G "${root}/**/*.ts" >/dev/null 2>&1 ) && langs+=("typescript")
  [[ -f "${root}/Cargo.toml" ]] && langs+=("rust")
  [[ -f "${root}/go.mod" ]] && langs+=("go")
  ( [[ -f "${root}/pyproject.toml" ]] || [[ -f "${root}/requirements.txt" ]] || [[ -f "${root}/setup.py" ]] ) && langs+=("python")
  [[ -f "${root}/Gemfile" ]] && langs+=("ruby")
  [[ -f "${root}/pom.xml" ]] || [[ -f "${root}/build.gradle" ]] || [[ -f "${root}/build.gradle.kts" ]] && langs+=("java")
  if [[ ${#langs[@]} -eq 0 ]]; then
    printf '[]'
  else
    printf '['
    local first=1
    for l in "${langs[@]}"; do
      [[ $first -eq 1 ]] || printf ','
      printf '"%s"' "$l"
      first=0
    done
    printf ']'
  fi
}

# ---- Package manager (JS ecosystem) ----
detect_package_manager() {
  local root="${1:-$PWD}"
  [[ -f "${root}/pnpm-lock.yaml" ]] && { printf 'pnpm'; return; }
  [[ -f "${root}/yarn.lock" ]] && { printf 'yarn'; return; }
  [[ -f "${root}/bun.lockb" ]] && { printf 'bun'; return; }
  [[ -f "${root}/package-lock.json" ]] && { printf 'npm'; return; }
  [[ -f "${root}/package.json" ]] && { printf 'npm'; return; }
  printf ''
}

# ---- Task runner ----
detect_task_runner() {
  local root="${1:-$PWD}"
  [[ -f "${root}/Justfile" ]] || [[ -f "${root}/justfile" ]] && { printf 'just'; return; }
  [[ -f "${root}/Makefile" ]] && { printf 'make'; return; }
  [[ -f "${root}/package.json" ]] && { printf 'npm-scripts'; return; }
  printf 'none'
}

# ---- Test runner ----
detect_test_runner() {
  local root="${1:-$PWD}"
  if [[ -f "${root}/package.json" ]]; then
    if grep -q '"vitest"' "${root}/package.json" 2>/dev/null; then printf 'vitest'; return; fi
    if grep -q '"jest"'   "${root}/package.json" 2>/dev/null; then printf 'jest'; return; fi
    if grep -q '"mocha"'  "${root}/package.json" 2>/dev/null; then printf 'mocha'; return; fi
    if grep -q '"playwright"' "${root}/package.json" 2>/dev/null; then printf 'playwright'; return; fi
    if jq -e '.scripts.test // empty' "${root}/package.json" >/dev/null 2>&1; then printf 'npm-test'; return; fi
  fi
  [[ -f "${root}/pytest.ini" ]] || grep -q '\[tool.pytest' "${root}/pyproject.toml" 2>/dev/null && { printf 'pytest'; return; }
  [[ -f "${root}/Cargo.toml" ]] && { printf 'cargo-test'; return; }
  [[ -f "${root}/go.mod" ]] && { printf 'go-test'; return; }
  printf ''
}

# ---- CI provider ----
detect_ci_provider() {
  local root="${1:-$PWD}"
  if compgen -G "${root}/.github/workflows/*.y*ml" >/dev/null; then printf 'github-actions'; return; fi
  [[ -f "${root}/.circleci/config.yml" ]] && { printf 'circleci'; return; }
  [[ -f "${root}/.gitlab-ci.yml" ]] && { printf 'gitlab-ci'; return; }
  [[ -f "${root}/azure-pipelines.yml" ]] && { printf 'azure-pipelines'; return; }
  printf 'none'
}

# ---- Database presence + kind ----
detect_database_kind() {
  local root="${1:-$PWD}"
  # docker-compose with postgres service
  if [[ -f "${root}/docker-compose.yml" ]] || [[ -f "${root}/compose.yaml" ]] || [[ -f "${root}/compose.yml" ]]; then
    local f
    for f in "${root}/docker-compose.yml" "${root}/compose.yaml" "${root}/compose.yml"; do
      [[ -f "$f" ]] || continue
      grep -qE 'postgres|postgis' "$f" && { printf 'postgres'; return; }
      grep -qE 'mysql|mariadb'    "$f" && { printf 'mysql'; return; }
      grep -qE 'mongo'            "$f" && { printf 'mongodb'; return; }
      grep -qE 'redis'            "$f" && { printf 'redis'; return; }
    done
  fi
  # Env file mentions DATABASE_URL
  for f in "${root}/.env.example" "${root}/.env.sample" "${root}/.env"; do
    [[ -f "$f" ]] || continue
    grep -q 'DATABASE_URL' "$f" && { printf 'unknown-sql'; return; }
  done
  # Prisma / Drizzle / Sequelize hints
  [[ -d "${root}/prisma" ]] && { printf 'prisma'; return; }
  printf ''
}

# ---- Bootstrap command detection ----
detect_bootstrap() {
  local root="${1:-$PWD}"
  for f in bootstrap.sh scripts/bootstrap.sh bin/bootstrap setup.sh scripts/setup.sh; do
    [[ -x "${root}/${f}" ]] && { printf '%s' "$f"; return; }
  done
  if [[ -f "${root}/Justfile" ]] || [[ -f "${root}/justfile" ]]; then
    if grep -qE '^(bootstrap|setup):' "${root}/Justfile" 2>/dev/null || grep -qE '^(bootstrap|setup):' "${root}/justfile" 2>/dev/null; then
      printf 'just bootstrap'; return
    fi
  fi
  if [[ -f "${root}/Makefile" ]] && grep -qE '^(bootstrap|setup):' "${root}/Makefile"; then
    printf 'make bootstrap'; return
  fi
  if [[ -f "${root}/package.json" ]]; then
    if jq -e '.scripts.bootstrap // .scripts.setup // empty' "${root}/package.json" >/dev/null 2>&1; then
      printf 'npm run bootstrap'; return
    fi
  fi
  printf ''
}

# ---- AGENTS.md / CLAUDE.md ----
detect_agents_md() {
  local root="${1:-$PWD}"
  for f in AGENTS.md CLAUDE.md .cursorrules .agents.md; do
    [[ -f "${root}/${f}" ]] && { printf '%s' "$f"; return; }
  done
  printf ''
}

# ---- Lockfile presence (committed?) ----
detect_lockfile_committed() {
  local root="${1:-$PWD}"
  local locks=(package-lock.json pnpm-lock.yaml yarn.lock bun.lockb Cargo.lock poetry.lock uv.lock Gemfile.lock)
  for l in "${locks[@]}"; do
    if [[ -f "${root}/${l}" ]]; then
      if ( cd "$root" && git ls-files --error-unmatch "$l" >/dev/null 2>&1 ); then
        printf 'true'; return
      else
        printf 'untracked'; return
      fi
    fi
  done
  printf 'no-lockfile'
}
