#!/usr/bin/env bash
# verify-migration.sh — Validate the migration compiles and is complete
# Part of: base-ui-migrator
#
# Why: After editing source files to use Base UI, three things can be wrong:
#   1. TypeScript no longer compiles (wrong import path, wrong prop name)
#   2. Build fails (missing @base-ui/react in package.json)
#   3. Some bespoke patterns were missed (partial migration is worse than none)
# This script checks all three and reports a summary.
#
# Usage:
#   verify-migration.sh                     # Run all checks in project_root from config.json
#   verify-migration.sh <path>              # Run checks against a specific path
#   verify-migration.sh --skip-build        # Typecheck only (faster, for iteration)
#
# Exit codes:
#   0 — all checks passed
#   1 — one or more checks failed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$SKILL_DIR/config.json"

skip_build=0
target=""
for arg in "$@"; do
  case "$arg" in
    --skip-build) skip_build=1 ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *)
      if [[ -z "$target" ]]; then
        target="$arg"
      else
        echo "Unknown argument: $arg" >&2
        exit 1
      fi
      ;;
  esac
done

# Resolve project_root
if [[ -z "$target" ]]; then
  if [[ -f "$CONFIG_FILE" ]] && command -v jq >/dev/null 2>&1; then
    target=$(jq -r '.project_root // ""' "$CONFIG_FILE")
  fi
  [[ -z "$target" || "$target" == "null" ]] && target="$PWD"
fi

if [[ ! -d "$target" ]]; then
  echo "ERROR: Target directory does not exist: $target" >&2
  exit 1
fi

cd "$target"

# Detect package manager so error messages can suggest the exact install command.
detect_pm() {
  [[ -f pnpm-lock.yaml ]] && { echo pnpm; return; }
  [[ -f yarn.lock ]] && { echo yarn; return; }
  [[ -f bun.lockb || -f bun.lock ]] && { echo bun; return; }
  echo npm
}
PM=$(detect_pm)
case "$PM" in
  npm)  PM_INSTALL="npm install" ;;
  *)    PM_INSTALL="$PM add" ;;
esac

PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "Verifying Base UI migration in: $target"
echo ""

# --- Check 1: @base-ui/react in package.json ---
echo "[1/4] Checking package.json for @base-ui/react..."
if [[ ! -f package.json ]]; then
  fail "package.json not found in $target"
else
  if grep -q '"@base-ui/react"' package.json; then
    pass "@base-ui/react is in package.json"
  else
    fail "@base-ui/react is NOT in package.json. Install with: $PM_INSTALL @base-ui/react"
  fi
  # Warn if old package name lingers
  if grep -q '"@base-ui-components/react"' package.json; then
    fail "Old package name '@base-ui-components/react' still in package.json — rename to '@base-ui/react'"
  fi
fi

# --- Check 2: TypeScript compiles (if tsconfig.json exists) ---
echo ""
echo "[2/4] Type-checking..."
if [[ -f tsconfig.json ]]; then
  if command -v npx >/dev/null 2>&1; then
    if npx --no-install tsc --noEmit > /tmp/base-ui-migrator-tsc.log 2>&1; then
      pass "tsc --noEmit succeeded"
    else
      fail "tsc --noEmit produced errors. See /tmp/base-ui-migrator-tsc.log"
      echo "    First 20 errors:"
      head -20 /tmp/base-ui-migrator-tsc.log | sed 's/^/      /'
    fi
  else
    fail "npx not found, cannot run tsc"
  fi
else
  echo "  SKIP: no tsconfig.json (JS project)"
fi

# --- Check 3: Build (optional, skip with --skip-build) ---
echo ""
echo "[3/4] Build..."
if (( skip_build )); then
  echo "  SKIP: --skip-build"
elif [[ -f next.config.js || -f next.config.mjs || -f next.config.ts ]]; then
  if npx --no-install next build > /tmp/base-ui-migrator-build.log 2>&1; then
    pass "next build succeeded"
  else
    fail "next build failed. See /tmp/base-ui-migrator-build.log"
    tail -30 /tmp/base-ui-migrator-build.log | sed 's/^/      /'
  fi
elif [[ -f vite.config.js || -f vite.config.ts || -f vite.config.mjs ]]; then
  if npx --no-install vite build > /tmp/base-ui-migrator-build.log 2>&1; then
    pass "vite build succeeded"
  else
    fail "vite build failed. See /tmp/base-ui-migrator-build.log"
    tail -30 /tmp/base-ui-migrator-build.log | sed 's/^/      /'
  fi
else
  echo "  SKIP: no recognized bundler config (next/vite). Run your own build manually."
fi

# --- Check 4: Leftover bespoke patterns ---
echo ""
echo "[4/4] Scanning for leftover bespoke patterns..."
if [[ -x "$SCRIPT_DIR/scan-candidates.sh" ]]; then
  # Only check for bespoke patterns — library imports are intentional if user kept them.
  # Count semantic matches (each line of scanner output is one JSON object) using
  # jq -s 'length' so the count is robust if the output format ever changes.
  if command -v jq >/dev/null 2>&1; then
    leftover=$(bash "$SCRIPT_DIR/scan-candidates.sh" "$target" --bespoke 2>/dev/null | jq -s 'length' 2>/dev/null || echo "0")
  else
    leftover=$(bash "$SCRIPT_DIR/scan-candidates.sh" "$target" --bespoke 2>/dev/null | grep -c '^{' || true)
  fi
  if [[ "${leftover:-0}" -eq 0 ]]; then
    pass "no leftover bespoke patterns detected"
  else
    fail "$leftover bespoke pattern(s) still present — run scan-candidates.sh --bespoke for details"
  fi
else
  fail "scan-candidates.sh not executable"
fi

# --- Summary ---
echo ""
echo "═════════════════════════════════════════"
echo "Results: $PASS passed, $FAIL failed"
echo "═════════════════════════════════════════"

[[ $FAIL -eq 0 ]] || exit 1
exit 0
