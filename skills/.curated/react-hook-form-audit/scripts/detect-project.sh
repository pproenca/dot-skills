#!/usr/bin/env bash
# detect-project.sh — Verify project is a Next.js codebase using react-hook-form.
# Part of: react-hook-form-audit

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <project-root>" >&2
  exit 2
fi
PROJECT_ROOT="$1"

PKG_JSON="$PROJECT_ROOT/package.json"
if [[ ! -f "$PKG_JSON" ]]; then
  echo "  ERROR: $PKG_JSON not found. Is this a Node.js project root?" >&2
  exit 2
fi

# Check for Next.js
if ! jq -e '
  (.dependencies // {}) + (.devDependencies // {})
  | has("next")
' "$PKG_JSON" >/dev/null; then
  echo "  ERROR: 'next' not found in package.json dependencies." >&2
  echo "         This skill audits Next.js App Router projects specifically." >&2
  echo "         For non-Next.js React projects, run the detectors against your source manually." >&2
  exit 2
fi

# Check for react-hook-form
if ! jq -e '
  (.dependencies // {}) + (.devDependencies // {})
  | has("react-hook-form")
' "$PKG_JSON" >/dev/null; then
  echo "  ERROR: 'react-hook-form' not found in package.json dependencies." >&2
  echo "         Install with: npm install react-hook-form" >&2
  exit 2
fi

NEXT_VER="$(jq -r '(.dependencies.next // .devDependencies.next // "unknown")' "$PKG_JSON")"
RHF_VER="$(jq -r '(.dependencies."react-hook-form" // .devDependencies."react-hook-form" // "unknown")' "$PKG_JSON")"
echo "  Next.js: $NEXT_VER"
echo "  react-hook-form: $RHF_VER"

# Detect App Router vs Pages Router
HAS_APP_DIR=0
[[ -d "$PROJECT_ROOT/app" || -d "$PROJECT_ROOT/src/app" ]] && HAS_APP_DIR=1
HAS_PAGES_DIR=0
[[ -d "$PROJECT_ROOT/pages" || -d "$PROJECT_ROOT/src/pages" ]] && HAS_PAGES_DIR=1

if [[ "$HAS_APP_DIR" -eq 1 ]]; then
  echo "  Router: App Router detected (use-client checks active)"
elif [[ "$HAS_PAGES_DIR" -eq 1 ]]; then
  echo "  Router: Pages Router detected (use-client checks will be skipped)"
else
  echo "  Router: unknown (no app/ or pages/ directory found at root or src/)"
fi
