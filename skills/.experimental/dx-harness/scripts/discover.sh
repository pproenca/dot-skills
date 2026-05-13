#!/usr/bin/env bash
# discover.sh — fingerprint the repo
# Part of: dx-harness
#
# Emits a JSON object describing the repo's languages, toolchain, task runner,
# CI, database, existing harness, and AGENTS.md presence. Every downstream
# script reads this fingerprint — detection should not happen anywhere else.
#
# Usage:
#   bash discover.sh                       # writes JSON to stdout
#   bash discover.sh > /tmp/fingerprint.json

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/detectors.sh"

require_jq

ROOT=$(repo_root)
[[ -d "$ROOT" ]] || die "repo_root resolves to non-directory: $ROOT"

LANGS=$(detect_languages "$ROOT")
PKG_MGR=$(detect_package_manager "$ROOT")
TASK_RUNNER=$(detect_task_runner "$ROOT")
TEST_RUNNER=$(detect_test_runner "$ROOT")
CI=$(detect_ci_provider "$ROOT")
DB=$(detect_database_kind "$ROOT")
BOOTSTRAP=$(detect_bootstrap "$ROOT")
AGENTS=$(detect_agents_md "$ROOT")
LOCK=$(detect_lockfile_committed "$ROOT")

# Existing harness scripts the repo already has
EXISTING_SCRIPTS=()
for f in bootstrap.sh reset.sh seed.sh setup.sh; do
  [[ -e "${ROOT}/${f}" ]] && EXISTING_SCRIPTS+=("$f")
  [[ -e "${ROOT}/scripts/${f}" ]] && EXISTING_SCRIPTS+=("scripts/${f}")
done

# Recent commit count for history-window sizing
COMMIT_COUNT=$( ( cd "$ROOT" && git rev-list --count HEAD 2>/dev/null ) || printf '0')

# Build JSON via jq for safety
jq -n \
  --arg repo_root "$ROOT" \
  --arg repo_hash "$(repo_hash)" \
  --argjson languages "${LANGS:-[]}" \
  --arg package_manager "$PKG_MGR" \
  --arg task_runner "$TASK_RUNNER" \
  --arg test_runner "$TEST_RUNNER" \
  --arg ci_provider "$CI" \
  --arg db_kind "$DB" \
  --arg bootstrap_command "$BOOTSTRAP" \
  --arg agents_md "$AGENTS" \
  --arg lockfile_status "$LOCK" \
  --argjson existing_scripts "$(printf '%s\n' "${EXISTING_SCRIPTS[@]:-}" | jq -R . | jq -s 'map(select(length>0))')" \
  --argjson commit_count "$COMMIT_COUNT" \
  --arg generated_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{
    schema_version: 1,
    generated_at: $generated_at,
    repo_root: $repo_root,
    repo_hash: $repo_hash,
    languages: $languages,
    package_manager: $package_manager,
    task_runner: $task_runner,
    test_runner: $test_runner,
    ci_provider: $ci_provider,
    has_database: ($db_kind != ""),
    db_kind: $db_kind,
    bootstrap_command: $bootstrap_command,
    agents_md_present: ($agents_md != ""),
    agents_md_path: $agents_md,
    lockfile_status: $lockfile_status,
    existing_scripts: $existing_scripts,
    commit_count: $commit_count
  }'
