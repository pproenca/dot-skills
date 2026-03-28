import "dotenv/config";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { ApiClientError } from "./client.js";

import { createIssueSchema, createIssue } from "./tools/create_issue.js";
import { updateIssueSchema, updateIssue } from "./tools/update_issue.js";
import { getIssueSchema, getIssue } from "./tools/get_issue.js";
import { deleteIssueSchema, deleteIssue } from "./tools/delete_issue.js";
import { searchIssuesSchema, searchIssues } from "./tools/search_issues.js";
import { listIssuesSchema, listIssues } from "./tools/list_issues.js";
import { addCommentSchema, addComment } from "./tools/add_comment.js";
import { listCommentsSchema, listComments } from "./tools/list_comments.js";

const server = new McpServer({
  name: "issue-tracker",
  version: "1.0.0",
});

// Helper: wraps async tool handlers so API errors come back as readable text
// rather than crashing the server. 5xx / network errors still throw (MCP SDK
// will surface them as tool errors to the client).
function wrapHandler<T>(
  fn: (input: T) => Promise<string>
): (input: T) => Promise<{ content: Array<{ type: "text"; text: string }> }> {
  return async (input: T) => {
    try {
      const text = await fn(input);
      return { content: [{ type: "text" as const, text }] };
    } catch (err) {
      if (err instanceof ApiClientError && err.statusCode < 500) {
        // 4xx — return as informative text so the AI can explain it
        return {
          content: [
            {
              type: "text" as const,
              text: `API error (${err.statusCode}): ${err.message}`,
            },
          ],
        };
      }
      throw err; // 5xx / network errors bubble up as tool errors
    }
  };
}

// Register all tools

server.tool(
  "create_issue",
  "Create a new issue in the issue tracker",
  createIssueSchema.shape,
  wrapHandler(createIssue)
);

server.tool(
  "update_issue",
  "Update fields on an existing issue (title, description, status, priority, assignee, labels)",
  updateIssueSchema.shape,
  wrapHandler(updateIssue)
);

server.tool(
  "get_issue",
  "Fetch a single issue by its ID",
  getIssueSchema.shape,
  wrapHandler(getIssue)
);

server.tool(
  "delete_issue",
  "Permanently delete an issue by its ID",
  deleteIssueSchema.shape,
  wrapHandler(deleteIssue)
);

server.tool(
  "search_issues",
  "Full-text search across issues with optional filters for status, priority, assignee, and labels",
  searchIssuesSchema.shape,
  wrapHandler(searchIssues)
);

server.tool(
  "list_issues",
  "List issues with optional filtering by status, priority, or assignee, with pagination",
  listIssuesSchema.shape,
  wrapHandler(listIssues)
);

server.tool(
  "add_comment",
  "Add a comment to an issue",
  addCommentSchema.shape,
  wrapHandler(addComment)
);

server.tool(
  "list_comments",
  "List all comments on a specific issue",
  listCommentsSchema.shape,
  wrapHandler(listComments)
);

// Start the server using stdio transport
const transport = new StdioServerTransport();
await server.connect(transport);

// Log to stderr only (stdout is reserved for MCP protocol messages)
process.stderr.write("Issue tracker MCP server running on stdio\n");
