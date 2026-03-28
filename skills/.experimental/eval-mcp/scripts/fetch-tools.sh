#!/usr/bin/env bash
# fetch-tools.sh — Fetch tool schemas from a running MCP server via Inspector CLI
set -euo pipefail

command -v npx >/dev/null 2>&1 || {
  echo "npx not found. Install Node.js (>= 18): https://nodejs.org"
  exit 1
}

command -v jq >/dev/null 2>&1 || {
  echo "jq not found. Install jq: https://jqlang.github.io/jq/download/"
  exit 1
}

URL="${1:-}"
TRANSPORT="${2:-http}"
OUTPUT="${3:-}"

if [[ -z "$URL" ]]; then
  echo "Usage: fetch-tools.sh <server-url> [transport] [output-file]"
  echo ""
  echo "  server-url   MCP server endpoint (e.g. http://localhost:3000/mcp)"
  echo "  transport    'http' (default), 'sse', or 'stdio'"
  echo "  output-file  Write JSON to file instead of stdout"
  echo ""
  echo "Fetches tools/list from the server and outputs the tool schemas as JSON."
  exit 1
fi

echo "Fetching tools from $URL (transport: $TRANSPORT)..." >&2

RAW_OUTPUT=$(npx @modelcontextprotocol/inspector --cli "$URL" \
  --transport "$TRANSPORT" --method tools/list 2>/dev/null) || {
  echo "Could not connect to MCP server at $URL." >&2
  echo "Verify the server is running. Try:" >&2
  echo "  npx @modelcontextprotocol/inspector --cli $URL --transport $TRANSPORT --method tools/list" >&2
  exit 1
}

# Extract tools array from the response
# Inspector CLI outputs the JSON-RPC result directly
TOOLS=$(echo "$RAW_OUTPUT" | jq -e '.tools // empty' 2>/dev/null) || {
  # Try extracting from nested result structure
  TOOLS=$(echo "$RAW_OUTPUT" | jq -e '.result.tools // empty' 2>/dev/null) || {
    echo "Could not parse tool schemas from Inspector output." >&2
    echo "Raw output:" >&2
    echo "$RAW_OUTPUT" >&2
    exit 1
  }
}

TOOL_COUNT=$(echo "$TOOLS" | jq 'length')

if [[ "$TOOL_COUNT" -eq 0 ]]; then
  echo "Server returned zero tools. Check that tools are registered in server init." >&2
  exit 2
fi

echo "Found $TOOL_COUNT tool(s)." >&2

# Build output with metadata
RESULT=$(jq -n \
  --argjson tools "$TOOLS" \
  --arg url "$URL" \
  --arg transport "$TRANSPORT" \
  --arg fetched_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{
    server_url: $url,
    transport: $transport,
    fetched_at: $fetched_at,
    tool_count: ($tools | length),
    tools: $tools
  }')

if [[ -n "$OUTPUT" ]]; then
  echo "$RESULT" > "$OUTPUT"
  echo "Saved to $OUTPUT" >&2
else
  echo "$RESULT"
fi
