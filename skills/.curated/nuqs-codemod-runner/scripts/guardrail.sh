#!/usr/bin/env bash
# guardrail.sh — PreToolUse hook for nuqs-codemod-runner.
# Blocks direct jscodeshift invocations against transforms/ that bypass apply.sh.
#
# Reads $TOOL_INPUT (the bash command being run). Exits 0 to allow, non-zero with a
# message on stderr to block.

set -euo pipefail

CMD="${TOOL_INPUT:-}"

# Allow apply.sh and scan.sh to run jscodeshift internally
if [[ "$CMD" == *"scripts/apply.sh"* ]] || [[ "$CMD" == *"scripts/scan.sh"* ]]; then
  exit 0
fi

# Block bare `jscodeshift ... transforms/*.js` invocations
if [[ "$CMD" == *"jscodeshift"* ]] && [[ "$CMD" == *"transforms/"* ]]; then
  echo "Blocked: run codemods via scripts/apply.sh, not jscodeshift directly." >&2
  echo "  apply.sh enforces the pre-flight checks (clean tree, fresh scan, matching git HEAD)" >&2
  echo "  that protect you from losing work." >&2
  exit 2
fi

exit 0
