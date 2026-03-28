import express from "express";
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { SSEServerTransport } from "@modelcontextprotocol/sdk/server/sse.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { createOAuthRouter } from "./auth/oauth.js";
import { config, validateConfig } from "./config.js";
import { SALESFORCE_TOOLS } from "./tools/index.js";
import {
  handleListObjects,
  handleDescribe,
  handleQuery,
  handleSearch,
  handleGet,
  handleCreate,
  handleUpdate,
  handleDelete,
  handleBulkCreate,
  handleGetLimits,
} from "./tools/handlers.js";

validateConfig();

const app = express();
app.use(express.json());

// OAuth callback routes
app.use(createOAuthRouter());

// Health check
app.get("/health", (_req, res) => {
  res.json({ status: "ok", version: "0.1.0" });
});

// MCP Server factory — one server instance per connection
function createMCPServer(): Server {
  const server = new Server(
    { name: "salesforce-mcp", version: "0.1.0" },
    { capabilities: { tools: {} } }
  );

  server.setRequestHandler(ListToolsRequestSchema, async () => ({
    tools: SALESFORCE_TOOLS,
  }));

  server.setRequestHandler(CallToolRequestSchema, async (request, extra) => {
    // Session ID is derived from the SSE connection context
    // In production, use the actual session identifier from the transport
    const sessionId = (extra as { sessionId?: string }).sessionId ?? "default";
    const { name, arguments: args } = request.params;

    switch (name) {
      case "salesforce_list_objects":
        return handleListObjects(sessionId, args);
      case "salesforce_describe":
        return handleDescribe(sessionId, args);
      case "salesforce_query":
        return handleQuery(sessionId, args);
      case "salesforce_search":
        return handleSearch(sessionId, args);
      case "salesforce_get":
        return handleGet(sessionId, args);
      case "salesforce_create":
        return handleCreate(sessionId, args);
      case "salesforce_update":
        return handleUpdate(sessionId, args);
      case "salesforce_delete":
        return handleDelete(sessionId, args);
      case "salesforce_bulk_create":
        return handleBulkCreate(sessionId, args);
      case "salesforce_get_limits":
        return handleGetLimits(sessionId, args);
      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  });

  return server;
}

// SSE endpoint — each GET creates a new MCP server instance bound to this connection
const activeTransports = new Map<string, SSEServerTransport>();

app.get("/mcp/sse", async (req, res) => {
  const sessionId = (req.query.session as string) ?? crypto.randomUUID();

  const transport = new SSEServerTransport(`/mcp/messages?session=${sessionId}`, res);
  activeTransports.set(sessionId, transport);

  res.on("close", () => {
    activeTransports.delete(sessionId);
  });

  const server = createMCPServer();
  await server.connect(transport);
});

// POST endpoint for MCP messages
app.post("/mcp/messages", async (req, res) => {
  const sessionId = (req.query.session as string) ?? "";
  const transport = activeTransports.get(sessionId);
  if (!transport) {
    res.status(404).json({ error: "Session not found" });
    return;
  }
  await transport.handlePostMessage(req, res);
});

app.listen(config.port, () => {
  console.log(`Salesforce MCP server running on port ${config.port}`);
  console.log(`OAuth callback: ${config.salesforce.redirectUri}`);
  console.log(`MCP SSE endpoint: http://localhost:${config.port}/mcp/sse`);
});
