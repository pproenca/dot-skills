/**
 * Salesforce MCP Server — Portable Express deployment
 *
 * Use this if you need to run on Render, Railway, Fly.io, a VPS, or any
 * Node host that isn't Cloudflare Workers. Identical tool logic — just a
 * different transport setup.
 *
 * Install:
 *   npm install @modelcontextprotocol/sdk zod express express-session connect-redis ioredis
 *   npm install -D typescript @types/express @types/node tsx
 *
 * Run:
 *   npx tsx src/server.ts
 *
 * Test:
 *   npx @modelcontextprotocol/inspector --cli http://localhost:3000/mcp \
 *     --transport http --method tools/list
 *
 * Environment variables:
 *   PORT                      (default: 3000)
 *   SALESFORCE_CLIENT_ID
 *   SALESFORCE_CLIENT_SECRET
 *   SALESFORCE_CALLBACK_URL   (e.g. https://your-app.render.com/oauth/callback)
 *   SESSION_SECRET            (random string for signing session cookies)
 *   REDIS_URL                 (for token storage; defaults to in-memory Map if unset)
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import express, { Request, Response } from "express";
import { z } from "zod";
import { SALESFORCE_ACTION_CATALOG, rankActions, type SalesforceSession } from "./salesforce-catalog.js";

// ---------------------------------------------------------------------------
// Simple in-process token store (swap for Redis in production)
// ---------------------------------------------------------------------------
const tokenStore = new Map<string, SalesforceSession>();

function getSession(sessionId: string): SalesforceSession | null {
  return tokenStore.get(sessionId) ?? null;
}

function setSession(sessionId: string, session: SalesforceSession): void {
  tokenStore.set(sessionId, session);
}

// ---------------------------------------------------------------------------
// Build the MCP server (tool definitions identical to Workers version)
// ---------------------------------------------------------------------------
function buildMcpServer(): McpServer {
  const server = new McpServer(
    { name: "salesforce", version: "0.1.0" },
    {
      instructions:
        "This server connects to the user's Salesforce org. " +
        "For common operations (SOQL queries, record CRUD, object metadata) use the dedicated tools. " +
        "For bulk, metadata API, reports, flows, or other advanced operations, call search_salesforce_actions first to discover the right action ID, then execute_salesforce_action. " +
        "Always call describe_object before create_record or update_record to confirm required fields.",
    },
  );

  // -------------------------------------------------------------------------
  // Dedicated Tool 1: SOQL Query
  // -------------------------------------------------------------------------
  server.registerTool(
    "soql_query",
    {
      description:
        "Execute a SOQL SELECT statement against the user's Salesforce org. " +
        "Returns records as a JSON array. Automatically paginates up to `maxRecords`. " +
        "Does NOT support INSERT/UPDATE/DELETE — use create_record / update_record for mutations.",
      inputSchema: {
        query: z
          .string()
          .describe("Full SOQL SELECT statement"),
        maxRecords: z
          .number()
          .int()
          .min(1)
          .max(2000)
          .default(200)
          .describe("Maximum total records to return. Hard cap at 2000."),
        sessionId: z.string().describe("MCP session ID for auth lookup"),
      },
      annotations: { readOnlyHint: true, openWorldHint: true },
    },
    async ({ query, maxRecords, sessionId }) => {
      const session = getSession(sessionId);
      if (!session) return authRequiredError();

      const records: unknown[] = [];
      let url = `${session.instanceUrl}/services/data/v59.0/query?q=${encodeURIComponent(query)}`;

      while (url && records.length < maxRecords) {
        const res = await sfFetch(url, session);
        const page = (await res.json()) as {
          records: unknown[];
          nextRecordsUrl?: string;
          done: boolean;
        };
        records.push(...page.records.slice(0, maxRecords - records.length));
        url = !page.done && page.nextRecordsUrl
          ? `${session.instanceUrl}${page.nextRecordsUrl}`
          : "";
      }

      return {
        content: [
          {
            type: "text",
            text: JSON.stringify({ totalReturned: records.length, records }, null, 2),
          },
        ],
      };
    },
  );

  // -------------------------------------------------------------------------
  // Dedicated Tool 2: Get Record
  // -------------------------------------------------------------------------
  server.registerTool(
    "get_record",
    {
      description:
        "Fetch a single Salesforce record by object type and ID. " +
        "Returns all fields unless `fields` is specified. " +
        "If you only have a name or email (not an ID), use soql_query to find the ID first.",
      inputSchema: {
        objectType: z.string().describe("Salesforce API object name"),
        id: z.string().regex(/^[a-zA-Z0-9]{15,18}$/).describe("Salesforce record ID"),
        fields: z.array(z.string()).optional().describe("Specific fields to return"),
        sessionId: z.string().describe("MCP session ID"),
      },
      annotations: { readOnlyHint: true, openWorldHint: true },
    },
    async ({ objectType, id, fields, sessionId }) => {
      const session = getSession(sessionId);
      if (!session) return authRequiredError();

      const fieldsParam = fields?.length ? `?fields=${fields.join(",")}` : "";
      const url = `${session.instanceUrl}/services/data/v59.0/sobjects/${objectType}/${id}${fieldsParam}`;
      const res = await sfFetch(url, session);

      if (!res.ok) {
        return {
          isError: true,
          content: [{ type: "text", text: `Salesforce error: ${JSON.stringify(await res.json())}` }],
        };
      }

      return {
        content: [{ type: "text", text: JSON.stringify(await res.json(), null, 2) }],
      };
    },
  );

  // -------------------------------------------------------------------------
  // Dedicated Tool 3: Create Record
  // -------------------------------------------------------------------------
  server.registerTool(
    "create_record",
    {
      description:
        "Create a new Salesforce record. Returns the new record's ID on success. " +
        "Call describe_object first to confirm required fields.",
      inputSchema: {
        objectType: z.string().describe("Salesforce API object name"),
        fields: z.record(z.unknown()).describe("Field values as a JSON object"),
        sessionId: z.string().describe("MCP session ID"),
      },
      annotations: { openWorldHint: true, idempotentHint: false },
    },
    async ({ objectType, fields, sessionId }) => {
      const session = getSession(sessionId);
      if (!session) return authRequiredError();

      const res = await sfFetch(
        `${session.instanceUrl}/services/data/v59.0/sobjects/${objectType}`,
        session,
        { method: "POST", body: JSON.stringify(fields) },
      );

      if (!res.ok) {
        return {
          isError: true,
          content: [{ type: "text", text: `Failed to create ${objectType}: ${JSON.stringify(await res.json())}` }],
        };
      }

      const result = (await res.json()) as { id: string; success: boolean };
      return {
        content: [{
          type: "text",
          text: result.success
            ? `Created ${objectType} with ID ${result.id}`
            : `Creation failed: ${JSON.stringify(result)}`,
        }],
      };
    },
  );

  // -------------------------------------------------------------------------
  // Dedicated Tool 4: Update Record
  // -------------------------------------------------------------------------
  server.registerTool(
    "update_record",
    {
      description:
        "Update fields on an existing Salesforce record. Only specified fields are changed.",
      inputSchema: {
        objectType: z.string().describe("Salesforce API object name"),
        id: z.string().regex(/^[a-zA-Z0-9]{15,18}$/).describe("Salesforce record ID"),
        fields: z.record(z.unknown()).describe("Fields to update"),
        sessionId: z.string().describe("MCP session ID"),
      },
      annotations: { openWorldHint: true, idempotentHint: true },
    },
    async ({ objectType, id, fields, sessionId }) => {
      const session = getSession(sessionId);
      if (!session) return authRequiredError();

      const res = await sfFetch(
        `${session.instanceUrl}/services/data/v59.0/sobjects/${objectType}/${id}`,
        session,
        { method: "PATCH", body: JSON.stringify(fields) },
      );

      if (res.status === 204) {
        return { content: [{ type: "text", text: `Updated ${objectType} ${id} successfully.` }] };
      }

      return {
        isError: true,
        content: [{ type: "text", text: `Failed to update: ${JSON.stringify(await res.json())}` }],
      };
    },
  );

  // -------------------------------------------------------------------------
  // Dedicated Tool 5: Describe Object
  // -------------------------------------------------------------------------
  server.registerTool(
    "describe_object",
    {
      description:
        "Get field metadata for a Salesforce object: field names, types, labels, required status.",
      inputSchema: {
        objectType: z.string().describe("Salesforce API object name"),
        includeRelationships: z.boolean().default(false),
        sessionId: z.string().describe("MCP session ID"),
      },
      annotations: { readOnlyHint: true, openWorldHint: true },
    },
    async ({ objectType, includeRelationships, sessionId }) => {
      const session = getSession(sessionId);
      if (!session) return authRequiredError();

      const res = await sfFetch(
        `${session.instanceUrl}/services/data/v59.0/sobjects/${objectType}/describe`,
        session,
      );

      if (!res.ok) {
        return {
          isError: true,
          content: [{ type: "text", text: `Cannot describe ${objectType}: ${JSON.stringify(await res.json())}` }],
        };
      }

      const describe = (await res.json()) as {
        fields: Array<{
          name: string; label: string; type: string;
          nillable: boolean; createable: boolean; updateable: boolean;
          referenceTo?: string[];
        }>;
      };

      const compactFields = describe.fields.map((f) => ({
        name: f.name, label: f.label, type: f.type,
        required: !f.nillable && f.createable,
        createable: f.createable, updateable: f.updateable,
        ...(includeRelationships && f.referenceTo?.length ? { referenceTo: f.referenceTo } : {}),
      }));

      return {
        content: [{
          type: "text",
          text: JSON.stringify({ objectType, fieldCount: compactFields.length, fields: compactFields }, null, 2),
        }],
      };
    },
  );

  // -------------------------------------------------------------------------
  // Search + Execute
  // -------------------------------------------------------------------------
  server.registerTool(
    "search_salesforce_actions",
    {
      description:
        "Search available Salesforce operations by intent. Use for bulk, metadata, reports, flows, Apex. " +
        "Returns action IDs and schemas. Then call execute_salesforce_action.",
      inputSchema: {
        intent: z.string().describe("What you want to do, in plain English"),
        limit: z.number().int().min(1).max(20).default(8),
      },
      annotations: { readOnlyHint: true },
    },
    async ({ intent, limit }) => {
      const matches = rankActions(SALESFORCE_ACTION_CATALOG, intent).slice(0, limit);
      return {
        content: [{
          type: "text",
          text: matches.length > 0
            ? JSON.stringify(matches, null, 2)
            : `No actions matched "${intent}". Try a broader description.`,
        }],
      };
    },
  );

  server.registerTool(
    "execute_salesforce_action",
    {
      description:
        "Execute a Salesforce operation by action ID from search_salesforce_actions.",
      inputSchema: {
        actionId: z.string().describe("Action ID from search_salesforce_actions"),
        params: z.record(z.unknown()).describe("Parameters per the paramSchema"),
        sessionId: z.string().describe("MCP session ID"),
      },
      annotations: { openWorldHint: true },
    },
    async ({ actionId, params, sessionId }) => {
      const session = getSession(sessionId);
      if (!session) return authRequiredError();

      const action = SALESFORCE_ACTION_CATALOG.find((a) => a.id === actionId);
      if (!action) {
        return {
          isError: true,
          content: [{
            type: "text",
            text: `Unknown action ID: "${actionId}". Call search_salesforce_actions to find valid IDs.`,
          }],
        };
      }

      try {
        const result = await action.execute(params, session);
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      } catch (err) {
        return {
          isError: true,
          content: [{ type: "text", text: `Action "${actionId}" failed: ${String(err)}` }],
        };
      }
    },
  );

  return server;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function authRequiredError() {
  return {
    isError: true,
    content: [{
      type: "text" as const,
      text: "Not authenticated with Salesforce. Please complete the OAuth flow first.",
    }],
  };
}

async function sfFetch(
  url: string,
  session: SalesforceSession,
  options: RequestInit = {},
): Promise<Response> {
  return fetch(url, {
    ...options,
    headers: {
      Authorization: `Bearer ${session.accessToken}`,
      "Content-Type": "application/json",
      ...((options.headers as Record<string, string>) ?? {}),
    },
  });
}

// ---------------------------------------------------------------------------
// Express app + Streamable HTTP transport
// ---------------------------------------------------------------------------

const app = express();
app.use(express.json());

const mcpServer = buildMcpServer();

// Validate Origin header (spec MUST — DNS rebinding prevention)
const ALLOWED_ORIGINS = new Set([
  "https://claude.ai",
  "https://claude-code.anthropic.com",
  // Add your own domain in production
]);

app.post("/mcp", async (req: Request, res: Response) => {
  const origin = req.headers.origin;
  if (origin && !ALLOWED_ORIGINS.has(origin)) {
    res.status(403).json({ error: "Origin not allowed" });
    return;
  }

  // Check MCP-Protocol-Version
  const protocolVersion = req.headers["mcp-protocol-version"] as string | undefined;
  if (protocolVersion && protocolVersion !== "2025-11-25") {
    res.status(400).json({ error: `Unsupported MCP-Protocol-Version: ${protocolVersion}` });
    return;
  }

  const transport = new StreamableHTTPServerTransport({
    sessionIdGenerator: undefined, // stateless — fine for API wrapping
  });

  res.on("close", () => transport.close());
  await mcpServer.connect(transport);
  await transport.handleRequest(req, res, req.body);
});

// OAuth callback (simplified — in production use a proper OAuth library)
app.get("/oauth/callback", async (req: Request, res: Response) => {
  const { code, state } = req.query as { code: string; state: string };

  if (!code) {
    res.status(400).send("Missing authorization code");
    return;
  }

  const tokenRes = await fetch("https://login.salesforce.com/services/oauth2/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "authorization_code",
      code,
      client_id: process.env.SALESFORCE_CLIENT_ID ?? "",
      client_secret: process.env.SALESFORCE_CLIENT_SECRET ?? "",
      redirect_uri: process.env.SALESFORCE_CALLBACK_URL ?? "",
    }),
  });

  if (!tokenRes.ok) {
    res.status(500).send("Token exchange failed");
    return;
  }

  const tokens = (await tokenRes.json()) as {
    access_token: string;
    refresh_token: string;
    instance_url: string;
  };

  // Store keyed by state (which should encode the MCP session ID)
  setSession(state, {
    accessToken: tokens.access_token,
    refreshToken: tokens.refresh_token,
    instanceUrl: tokens.instance_url,
  });

  res.send("Authentication successful. You can close this tab and return to Claude.");
});

// Health check (separate from /mcp — hosts poll this)
app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

const port = process.env.PORT ?? 3000;
app.listen(port, () => {
  console.log(`Salesforce MCP server listening on port ${port}`);
  console.log(`MCP endpoint: http://localhost:${port}/mcp`);
});
