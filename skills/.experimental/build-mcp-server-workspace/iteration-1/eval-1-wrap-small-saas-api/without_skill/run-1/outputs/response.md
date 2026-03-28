# MCP Server for Internal Issue Tracker API

## Overview

This guide walks through building a Model Context Protocol (MCP) server that wraps your internal issue tracker REST API. The server exposes your 8 REST endpoints as MCP tools, allowing any MCP-compatible AI client (Claude Desktop, Claude Code, etc.) to interact with your issue tracker directly.

## Design Decisions

### Why TypeScript + `@modelcontextprotocol/sdk`

- The official MCP TypeScript SDK (`@modelcontextprotocol/sdk`) is the most mature option and has first-class support from Anthropic.
- TypeScript gives you type safety for your tool input schemas, which maps naturally to MCP's JSON Schema input validation.
- The SDK handles the stdio transport automatically — no HTTP server required for local team use.

### Transport: stdio (not SSE/HTTP)

For a team of 5 engineers using this locally, stdio transport is the right choice:
- Simpler: no port management, no auth on the transport layer.
- Claude Desktop and Claude Code both invoke MCP servers as child processes over stdio.
- If you later want to share it across the team from a central machine, you can switch to SSE transport with ~10 lines of change.

### API Key Handling

The API key is read from an environment variable (`ISSUE_TRACKER_API_KEY`). Engineers set this in their shell profile or in their Claude Desktop `env` config block. This avoids hardcoding credentials and keeps the key out of version control.

### Tool Design

Each REST endpoint maps to one MCP tool. Tool names use `snake_case` and are descriptive. Input schemas use JSON Schema (Zod is used internally and converted via `zod-to-json-schema`).

## Project Structure

```
issue-tracker-mcp/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts          # Entry point, registers tools, starts server
│   ├── client.ts         # HTTP client wrapper around the REST API
│   ├── tools/
│   │   ├── create_issue.ts
│   │   ├── update_issue.ts
│   │   ├── get_issue.ts
│   │   ├── delete_issue.ts
│   │   ├── search_issues.ts
│   │   ├── add_comment.ts
│   │   ├── list_comments.ts
│   │   └── list_issues.ts
│   └── types.ts          # Shared types/interfaces
└── .env.example
```

## Setup Instructions

### 1. Install dependencies

```bash
npm install
npm run build
```

### 2. Set your API key

```bash
export ISSUE_TRACKER_API_KEY=your_key_here
export ISSUE_TRACKER_BASE_URL=https://your-internal-tracker.example.com/api
```

Or add these to a `.env` file (loaded via `dotenv`).

### 3. Configure Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "issue-tracker": {
      "command": "node",
      "args": ["/absolute/path/to/issue-tracker-mcp/dist/index.js"],
      "env": {
        "ISSUE_TRACKER_API_KEY": "your_key_here",
        "ISSUE_TRACKER_BASE_URL": "https://your-internal-tracker.example.com/api"
      }
    }
  }
}
```

### 4. Configure Claude Code

```bash
# From your project directory
claude mcp add issue-tracker node /absolute/path/to/issue-tracker-mcp/dist/index.js
```

Then set the env vars in your shell before running `claude`.

## Tools Exposed

| Tool Name | REST Endpoint | Description |
|---|---|---|
| `create_issue` | `POST /issues` | Create a new issue |
| `update_issue` | `PATCH /issues/:id` | Update fields on an issue |
| `get_issue` | `GET /issues/:id` | Fetch a single issue by ID |
| `delete_issue` | `DELETE /issues/:id` | Delete an issue |
| `search_issues` | `GET /issues/search` | Full-text/filtered search |
| `list_issues` | `GET /issues` | List issues with pagination |
| `add_comment` | `POST /issues/:id/comments` | Add a comment to an issue |
| `list_comments` | `GET /issues/:id/comments` | List comments on an issue |

## Error Handling

- HTTP 4xx errors are returned as structured error text (not thrown), so the AI can read and explain them.
- HTTP 5xx errors throw, which the MCP SDK surfaces as tool errors.
- Network errors (DNS, timeout) also throw and are surfaced as tool errors.

## Extending

To add a new endpoint:
1. Create `src/tools/your_tool.ts` following the pattern of existing tools.
2. Import and register it in `src/index.ts` with `server.tool(...)`.
3. Rebuild with `npm run build`.
