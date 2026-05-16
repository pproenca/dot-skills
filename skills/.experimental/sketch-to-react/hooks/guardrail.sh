#!/usr/bin/env bash
# guardrail.sh — Block destructive Bash commands while sketch-to-react is loaded.
# Receives the PreToolUse payload on stdin as JSON:
#   {"tool_name":"Bash","tool_input":{"command":"..."}}
# Returns exit 0 to allow, exit 2 to block with a message printed to stderr.
set -euo pipefail

# Extract the command without depending on jq. Falls back to raw stdin if the
# payload isn't JSON (e.g. when the hook is invoked manually).
PAYLOAD="$(cat || true)"
CMD="$(
  printf '%s' "$PAYLOAD" | \
  python3 -c "import sys,json
try:
    d=json.loads(sys.stdin.read())
    print(d.get('tool_input',{}).get('command',''))
except Exception:
    pass" 2>/dev/null || true
)"

# If we couldn't parse JSON, treat the raw payload as the command (defensive).
[[ -z "$CMD" ]] && CMD="$PAYLOAD"

if echo "$CMD" | grep -qE '\brm[[:space:]]+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)\b'; then
  echo "Blocked by sketch-to-react guardrail: rm -rf is disallowed while this skill is loaded." >&2
  echo "If you need to remove generated output, use git clean or remove files individually." >&2
  exit 2
fi

if echo "$CMD" | grep -qE '\bgit[[:space:]]+push[[:space:]]+(--force|--force-with-lease|-f\b)'; then
  echo "Blocked by sketch-to-react guardrail: force-push is disallowed while this skill is loaded." >&2
  exit 2
fi

exit 0
