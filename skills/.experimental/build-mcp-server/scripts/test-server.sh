#!/usr/bin/env bash
# test-server.sh — Smoke-test an MCP server using the MCP Inspector CLI
set -euo pipefail

command -v npx >/dev/null 2>&1 || {
  echo "npx not found. Install Node.js (>= 18): https://nodejs.org"
  exit 1
}

URL="${1:-}"
TRANSPORT="${2:-http}"

if [[ -z "$URL" ]]; then
  echo "Usage: test-server.sh <server-url> [transport]"
  echo ""
  echo "  server-url   MCP server endpoint (e.g. http://localhost:3000/mcp)"
  echo "  transport    'http' (default) or 'stdio'"
  echo ""
  echo "Runs tools/list and checks the server responds with valid MCP."
  exit 1
fi

echo "Testing MCP server at $URL (transport: $TRANSPORT)..."
echo ""

# Check tools/list
echo "--- tools/list ---"
TOOLS_OUTPUT=$(npx @modelcontextprotocol/inspector --cli "$URL" \
  --transport "$TRANSPORT" --method tools/list 2>&1) || {
  echo "FAIL: tools/list failed"
  echo "$TOOLS_OUTPUT"
  exit 1
}
echo "$TOOLS_OUTPUT"
echo ""

# Count tools
TOOL_COUNT=$(echo "$TOOLS_OUTPUT" | grep -c '"name"' || true)
echo "Found $TOOL_COUNT tool(s)."

if [[ "$TOOL_COUNT" -eq 0 ]]; then
  echo "WARNING: Server returned zero tools. Is init() registering tools?"
  exit 2
fi

echo ""
echo "Server responds correctly."
