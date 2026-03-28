import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import express, { Request, Response } from "express";
import { z } from "zod";
import { IssueTrackerClient } from "./client.js";

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const API_KEY = process.env.ISSUE_TRACKER_API_KEY;
const BASE_URL = process.env.ISSUE_TRACKER_BASE_URL;

if (!API_KEY || !BASE_URL) {
  console.error(
    "Missing required env vars: ISSUE_TRACKER_API_KEY, ISSUE_TRACKER_BASE_URL"
  );
  process.exit(1);
}

const client = new IssueTrackerClient({ baseUrl: BASE_URL, apiKey: API_KEY });

// ---------------------------------------------------------------------------
// MCP Server
// ---------------------------------------------------------------------------

const server = new McpServer(
  { name: "issue-tracker", version: "0.1.0" },
  {
    instructions:
      "Use search_issues to discover issues before calling get_issue — issue IDs aren't guessable. " +
      "For mutations (create, update, comment), confirm with the user before executing if there is any ambiguity.",
  }
);

// ── READ TOOLS ──────────────────────────────────────────────────────────────

server.registerTool(
  "search_issues",
  {
    description:
      "Search issues by keyword across title and body. Returns up to `limit` results " +
      "ranked by recency. Does NOT search comments — use get_issue to read a specific " +
      "issue's comments after finding it here.",
    inputSchema: {
      query: z
        .string()
        .describe("Search keywords. Supports quoted phrases for exact match."),
      status: z
        .enum(["open", "closed", "all"])
        .default("open")
        .describe("Filter by status. Use 'all' to include closed issues."),
      assignee: z
        .string()
        .optional()
        .describe("Filter by assignee username. Omit to search all assignees."),
      limit: z
        .number()
        .int()
        .min(1)
        .max(50)
        .default(10)
        .describe("Max results to return. Hard cap at 50."),
    },
    annotations: { readOnlyHint: true },
  },
  async ({ query, status, assignee, limit }) => {
    const results = await client.searchIssues({ query, status, assignee, limit });
    if (results.length === 0) {
      return {
        content: [
          {
            type: "text",
            text: "No issues found matching your query. Try broader keywords or status='all'.",
          },
        ],
      };
    }
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(results, null, 2),
        },
      ],
    };
  }
);

server.registerTool(
  "get_issue",
  {
    description:
      "Fetch a single issue by its ID, including full body and all comments. " +
      "Use search_issues first if you don't already have the issue ID.",
    inputSchema: {
      issue_id: z.string().describe("The issue ID (e.g. 'PROJ-123')."),
    },
    annotations: { readOnlyHint: true },
  },
  async ({ issue_id }) => {
    const issue = await client.getIssue(issue_id);
    if (!issue) {
      return {
        isError: true,
        content: [
          {
            type: "text",
            text: `Issue ${issue_id} not found. Use search_issues to find valid issue IDs.`,
          },
        ],
      };
    }
    return {
      content: [{ type: "text", text: JSON.stringify(issue, null, 2) }],
    };
  }
);

server.registerTool(
  "list_issues",
  {
    description:
      "List issues with optional filters. Returns a paginated list without full bodies. " +
      "Use get_issue to fetch full details for a specific issue. " +
      "For keyword search, use search_issues instead.",
    inputSchema: {
      status: z
        .enum(["open", "closed", "all"])
        .default("open")
        .describe("Filter by status."),
      assignee: z
        .string()
        .optional()
        .describe("Filter by assignee username."),
      label: z
        .string()
        .optional()
        .describe("Filter by label name."),
      page: z
        .number()
        .int()
        .min(1)
        .default(1)
        .describe("Page number for pagination."),
      per_page: z
        .number()
        .int()
        .min(1)
        .max(100)
        .default(20)
        .describe("Results per page. Hard cap at 100."),
    },
    annotations: { readOnlyHint: true },
  },
  async ({ status, assignee, label, page, per_page }) => {
    const result = await client.listIssues({ status, assignee, label, page, per_page });
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  }
);

// ── WRITE TOOLS ─────────────────────────────────────────────────────────────

server.registerTool(
  "create_issue",
  {
    description:
      "Create a new issue in the tracker. Returns the created issue including its assigned ID. " +
      "Do not call this if the issue might already exist — search first.",
    inputSchema: {
      title: z
        .string()
        .min(1)
        .max(256)
        .describe("Short, descriptive title for the issue."),
      body: z
        .string()
        .optional()
        .describe(
          "Full description in Markdown. Include reproduction steps for bugs, acceptance criteria for features."
        ),
      assignee: z
        .string()
        .optional()
        .describe("Username to assign the issue to."),
      labels: z
        .array(z.string())
        .optional()
        .describe("List of label names to apply (e.g. ['bug', 'high-priority'])."),
      priority: z
        .enum(["low", "medium", "high", "critical"])
        .optional()
        .describe("Issue priority. Defaults to 'medium' if omitted."),
    },
    annotations: { openWorldHint: true },
  },
  async ({ title, body, assignee, labels, priority }) => {
    const issue = await client.createIssue({ title, body, assignee, labels, priority });
    return {
      content: [
        {
          type: "text",
          text: `Created issue ${issue.id}: "${issue.title}"\n\n${JSON.stringify(issue, null, 2)}`,
        },
      ],
    };
  }
);

server.registerTool(
  "update_issue",
  {
    description:
      "Update fields on an existing issue. Only the fields you provide will change — " +
      "omitted fields keep their current values. To close an issue, set status='closed'.",
    inputSchema: {
      issue_id: z.string().describe("The issue ID to update (e.g. 'PROJ-123')."),
      title: z.string().min(1).max(256).optional().describe("New title."),
      body: z.string().optional().describe("New body (replaces existing body)."),
      status: z
        .enum(["open", "closed", "in_progress", "blocked"])
        .optional()
        .describe("New status."),
      assignee: z
        .string()
        .optional()
        .describe("New assignee username. Pass empty string to unassign."),
      labels: z
        .array(z.string())
        .optional()
        .describe("Replace the full label set with this list."),
      priority: z
        .enum(["low", "medium", "high", "critical"])
        .optional()
        .describe("New priority."),
    },
    annotations: { openWorldHint: true, idempotentHint: true },
  },
  async ({ issue_id, ...updates }) => {
    const issue = await client.updateIssue(issue_id, updates);
    if (!issue) {
      return {
        isError: true,
        content: [
          {
            type: "text",
            text: `Issue ${issue_id} not found. Use search_issues to find valid issue IDs.`,
          },
        ],
      };
    }
    return {
      content: [
        {
          type: "text",
          text: `Updated issue ${issue.id}.\n\n${JSON.stringify(issue, null, 2)}`,
        },
      ],
    };
  }
);

server.registerTool(
  "add_comment",
  {
    description:
      "Add a comment to an existing issue. Use get_issue first to read existing comments " +
      "and avoid duplicating information.",
    inputSchema: {
      issue_id: z
        .string()
        .describe("The issue ID to comment on (e.g. 'PROJ-123')."),
      body: z
        .string()
        .min(1)
        .describe("Comment text in Markdown."),
    },
    annotations: { openWorldHint: true },
  },
  async ({ issue_id, body }) => {
    const comment = await client.addComment(issue_id, body);
    if (!comment) {
      return {
        isError: true,
        content: [
          {
            type: "text",
            text: `Issue ${issue_id} not found. Use search_issues to find valid issue IDs.`,
          },
        ],
      };
    }
    return {
      content: [
        {
          type: "text",
          text: `Added comment ${comment.id} to issue ${issue_id}.`,
        },
      ],
    };
  }
);

server.registerTool(
  "delete_issue",
  {
    description:
      "Permanently delete an issue and all its comments. THIS CANNOT BE UNDONE. " +
      "Prefer closing the issue (update_issue with status='closed') instead of deleting.",
    inputSchema: {
      issue_id: z.string().describe("The issue ID to delete (e.g. 'PROJ-123')."),
    },
    annotations: { destructiveHint: true, openWorldHint: true },
  },
  async ({ issue_id }) => {
    const ok = await client.deleteIssue(issue_id);
    if (!ok) {
      return {
        isError: true,
        content: [
          {
            type: "text",
            text: `Issue ${issue_id} not found or could not be deleted.`,
          },
        ],
      };
    }
    return {
      content: [{ type: "text", text: `Deleted issue ${issue_id}.` }],
    };
  }
);

// ---------------------------------------------------------------------------
// Express app + Streamable HTTP transport
// ---------------------------------------------------------------------------

const app = express();
app.use(express.json());

// Validate Origin header — required by MCP spec to prevent DNS rebinding.
// For an internal tool on a closed network, you can relax this to a specific
// set of allowed origins rather than rejecting all non-matching requests.
const ALLOWED_ORIGINS = (process.env.ALLOWED_ORIGINS ?? "").split(",").filter(Boolean);

function isOriginAllowed(origin: string | undefined): boolean {
  // Allow requests with no Origin header (e.g. CLI tools, curl)
  if (!origin) return true;
  // Allow localhost for development
  if (origin.startsWith("http://localhost") || origin.startsWith("http://127.0.0.1")) {
    return true;
  }
  // Allow explicitly configured origins
  return ALLOWED_ORIGINS.includes(origin);
}

app.post("/mcp", async (req: Request, res: Response) => {
  const origin = req.headers["origin"];
  if (!isOriginAllowed(origin)) {
    res.status(403).json({ error: "Origin not allowed" });
    return;
  }

  const transport = new StreamableHTTPServerTransport({
    sessionIdGenerator: undefined, // stateless — simplest for an API-wrapping server
  });

  res.on("close", () => transport.close());

  await server.connect(transport);
  await transport.handleRequest(req, res, req.body);
});

// Health check — separate from /mcp so hosts can poll it without triggering MCP logic
app.get("/health", (_req: Request, res: Response) => {
  res.json({ status: "ok", server: "issue-tracker", version: "0.1.0" });
});

const PORT = process.env.PORT ?? 3000;
app.listen(PORT, () => {
  console.log(`issue-tracker MCP server listening on port ${PORT}`);
  console.log(`MCP endpoint: http://localhost:${PORT}/mcp`);
});
