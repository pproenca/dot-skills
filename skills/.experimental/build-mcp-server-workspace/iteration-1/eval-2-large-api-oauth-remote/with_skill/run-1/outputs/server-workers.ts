/**
 * Salesforce MCP Server — Cloudflare Workers deployment
 *
 * Fastest path: two commands to a live HTTPS URL.
 * Uses McpAgent (Cloudflare's wrapper) + @cloudflare/workers-oauth-provider for auth.
 *
 * Bootstrap:
 *   npm create cloudflare@latest -- salesforce-mcp \
 *     --template=cloudflare/ai/demos/remote-mcp-authless
 *   cd salesforce-mcp
 *   npm install @cloudflare/workers-oauth-provider
 *
 * Secrets (set once, never hardcoded):
 *   npx wrangler secret put SALESFORCE_CLIENT_ID
 *   npx wrangler secret put SALESFORCE_CLIENT_SECRET
 *   npx wrangler secret put MCP_CLIENT_SECRET   (random string, used to sign MCP bearer tokens)
 *
 * Run locally:  npx wrangler dev
 * Deploy:       npx wrangler deploy
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { McpAgent } from "agents/mcp";
import { z } from "zod";
import { SALESFORCE_ACTION_CATALOG, rankActions } from "./salesforce-catalog.js";

// ---------------------------------------------------------------------------
// Env bindings (declared in wrangler.jsonc)
// ---------------------------------------------------------------------------
interface Env {
  SALESFORCE_CLIENT_ID: string;
  SALESFORCE_CLIENT_SECRET: string;
  MCP_OBJECT: DurableObjectNamespace;
  // KV namespace for storing per-user Salesforce tokens
  TOKEN_STORE: KVNamespace;
}

// ---------------------------------------------------------------------------
// Per-session Salesforce context
// ---------------------------------------------------------------------------
interface SalesforceSession {
  accessToken: string;
  refreshToken: string;
  instanceUrl: string; // e.g. https://mycompany.my.salesforce.com
}

// ---------------------------------------------------------------------------
// MCP Server class
// ---------------------------------------------------------------------------
export class SalesforceMCP extends McpAgent<Env> {
  server = new McpServer(
    { name: "salesforce", version: "0.1.0" },
    {
      instructions:
        "This server connects to the user's Salesforce org. " +
        "For common operations (SOQL queries, record CRUD, object metadata) use the dedicated tools. " +
        "For bulk, metadata API, reports, flows, or other advanced operations, call search_salesforce_actions first to discover the right action ID, then execute_salesforce_action. " +
        "Always call describe_object before create_record or update_record to confirm required fields.",
    },
  );

  async init() {
    // -------------------------------------------------------------------------
    // Dedicated Tool 1: SOQL Query
    // -------------------------------------------------------------------------
    this.server.registerTool(
      "soql_query",
      {
        description:
          "Execute a SOQL SELECT statement against the user's Salesforce org. " +
          "Returns records as a JSON array. Automatically paginates up to `maxRecords`. " +
          "Does NOT support INSERT/UPDATE/DELETE — use create_record / update_record for mutations.",
        inputSchema: {
          query: z
            .string()
            .describe(
              "Full SOQL SELECT statement, e.g. 'SELECT Id, Name FROM Account WHERE Industry = \\'Technology\\' LIMIT 20'",
            ),
          maxRecords: z
            .number()
            .int()
            .min(1)
            .max(2000)
            .default(200)
            .describe("Maximum total records to return across all pages. Hard cap at 2000."),
        },
        annotations: { readOnlyHint: true, openWorldHint: true },
      },
      async ({ query, maxRecords }, extra) => {
        const session = await this.getSession(extra);
        if (!session) return this.authRequiredError();

        const records: unknown[] = [];
        let url = `${session.instanceUrl}/services/data/v59.0/query?q=${encodeURIComponent(query)}`;

        while (url && records.length < maxRecords) {
          const res = await sfFetch(url, session);
          const page = (await res.json()) as { records: unknown[]; nextRecordsUrl?: string; done: boolean };
          records.push(...page.records.slice(0, maxRecords - records.length));
          url = !page.done && page.nextRecordsUrl
            ? `${session.instanceUrl}${page.nextRecordsUrl}`
            : "";
        }

        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                { totalReturned: records.length, records },
                null,
                2,
              ),
            },
          ],
        };
      },
    );

    // -------------------------------------------------------------------------
    // Dedicated Tool 2: Get Record
    // -------------------------------------------------------------------------
    this.server.registerTool(
      "get_record",
      {
        description:
          "Fetch a single Salesforce record by object type and ID. " +
          "Returns all fields unless `fields` is specified. " +
          "If you only have a name or email (not an ID), use soql_query to find the ID first.",
        inputSchema: {
          objectType: z
            .string()
            .describe("Salesforce API object name, e.g. 'Account', 'Contact', 'Opportunity', 'Case'"),
          id: z
            .string()
            .regex(/^[a-zA-Z0-9]{15,18}$/)
            .describe("Salesforce record ID (15 or 18 characters)"),
          fields: z
            .array(z.string())
            .optional()
            .describe(
              "Specific field API names to return. Omit to return all fields. " +
                "Call describe_object to see available field names.",
            ),
        },
        annotations: { readOnlyHint: true, openWorldHint: true },
      },
      async ({ objectType, id, fields }, extra) => {
        const session = await this.getSession(extra);
        if (!session) return this.authRequiredError();

        const fieldsParam = fields?.length ? `?fields=${fields.join(",")}` : "";
        const url = `${session.instanceUrl}/services/data/v59.0/sobjects/${objectType}/${id}${fieldsParam}`;
        const res = await sfFetch(url, session);

        if (!res.ok) {
          const err = await res.json();
          return {
            isError: true,
            content: [{ type: "text", text: `Salesforce error: ${JSON.stringify(err)}` }],
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
    this.server.registerTool(
      "create_record",
      {
        description:
          "Create a new Salesforce record. Returns the new record's ID on success. " +
          "Call describe_object first to confirm required fields and their API names. " +
          "Do NOT use this for updating existing records — use update_record instead.",
        inputSchema: {
          objectType: z
            .string()
            .describe("Salesforce API object name, e.g. 'Account', 'Lead', 'Case'"),
          fields: z
            .record(z.unknown())
            .describe(
              "Field values as a JSON object. Keys are Salesforce field API names. " +
                "Example: { \"FirstName\": \"Jane\", \"LastName\": \"Doe\", \"Email\": \"jane@example.com\" }",
            ),
        },
        annotations: { openWorldHint: true, idempotentHint: false },
      },
      async ({ objectType, fields }, extra) => {
        const session = await this.getSession(extra);
        if (!session) return this.authRequiredError();

        const url = `${session.instanceUrl}/services/data/v59.0/sobjects/${objectType}`;
        const res = await sfFetch(url, session, {
          method: "POST",
          body: JSON.stringify(fields),
        });

        if (!res.ok) {
          const err = await res.json();
          return {
            isError: true,
            content: [{ type: "text", text: `Failed to create ${objectType}: ${JSON.stringify(err)}` }],
          };
        }

        const result = (await res.json()) as { id: string; success: boolean };
        return {
          content: [
            {
              type: "text",
              text: result.success
                ? `Created ${objectType} with ID ${result.id}`
                : `Creation failed: ${JSON.stringify(result)}`,
            },
          ],
        };
      },
    );

    // -------------------------------------------------------------------------
    // Dedicated Tool 4: Update Record
    // -------------------------------------------------------------------------
    this.server.registerTool(
      "update_record",
      {
        description:
          "Update fields on an existing Salesforce record. Only the specified fields are changed. " +
          "If you don't have the record ID, use soql_query to find it first. " +
          "For creating new records, use create_record.",
        inputSchema: {
          objectType: z.string().describe("Salesforce API object name"),
          id: z
            .string()
            .regex(/^[a-zA-Z0-9]{15,18}$/)
            .describe("Salesforce record ID"),
          fields: z
            .record(z.unknown())
            .describe(
              "Fields to update as a JSON object. Only listed fields are modified. " +
                "Example: { \"Stage\": \"Closed Won\", \"CloseDate\": \"2026-06-30\" }",
            ),
        },
        annotations: { openWorldHint: true, idempotentHint: true },
      },
      async ({ objectType, id, fields }, extra) => {
        const session = await this.getSession(extra);
        if (!session) return this.authRequiredError();

        const url = `${session.instanceUrl}/services/data/v59.0/sobjects/${objectType}/${id}`;
        const res = await sfFetch(url, session, {
          method: "PATCH",
          body: JSON.stringify(fields),
        });

        // Salesforce returns 204 No Content on success for PATCH
        if (res.status === 204) {
          return {
            content: [{ type: "text", text: `Updated ${objectType} ${id} successfully.` }],
          };
        }

        const err = await res.json();
        return {
          isError: true,
          content: [{ type: "text", text: `Failed to update ${objectType} ${id}: ${JSON.stringify(err)}` }],
        };
      },
    );

    // -------------------------------------------------------------------------
    // Dedicated Tool 5: Describe Object
    // -------------------------------------------------------------------------
    this.server.registerTool(
      "describe_object",
      {
        description:
          "Get field metadata for a Salesforce object type: field names, types, labels, and required status. " +
          "Call this before create_record or update_record to confirm field API names and requirements. " +
          "To list all available object types in the org, call search_salesforce_actions with intent 'list all objects'.",
        inputSchema: {
          objectType: z
            .string()
            .describe("Salesforce API object name, e.g. 'Account', 'Opportunity', 'MyCustomObject__c'"),
          includeRelationships: z
            .boolean()
            .default(false)
            .describe("Whether to include relationship/lookup field details. Defaults to false (keep response compact)."),
        },
        annotations: { readOnlyHint: true, openWorldHint: true },
      },
      async ({ objectType, includeRelationships }, extra) => {
        const session = await this.getSession(extra);
        if (!session) return this.authRequiredError();

        const url = `${session.instanceUrl}/services/data/v59.0/sobjects/${objectType}/describe`;
        const res = await sfFetch(url, session);

        if (!res.ok) {
          const err = await res.json();
          return {
            isError: true,
            content: [{ type: "text", text: `Cannot describe ${objectType}: ${JSON.stringify(err)}` }],
          };
        }

        const describe = (await res.json()) as {
          fields: Array<{
            name: string;
            label: string;
            type: string;
            nillable: boolean;
            createable: boolean;
            updateable: boolean;
            referenceTo?: string[];
          }>;
          childRelationships?: unknown[];
        };

        const compactFields = describe.fields.map((f) => ({
          name: f.name,
          label: f.label,
          type: f.type,
          required: !f.nillable && f.createable,
          createable: f.createable,
          updateable: f.updateable,
          ...(includeRelationships && f.referenceTo?.length ? { referenceTo: f.referenceTo } : {}),
        }));

        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                {
                  objectType,
                  fieldCount: compactFields.length,
                  fields: compactFields,
                },
                null,
                2,
              ),
            },
          ],
        };
      },
    );

    // -------------------------------------------------------------------------
    // Search + Execute Tool 1: Search Actions
    // -------------------------------------------------------------------------
    this.server.registerTool(
      "search_salesforce_actions",
      {
        description:
          "Search the catalog of available Salesforce operations by intent. " +
          "Use this to discover bulk operations, metadata API calls, reports, flows, Apex execution, " +
          "and any operation not covered by the dedicated tools. " +
          "Returns action IDs, descriptions, and parameter schemas. " +
          "Then call execute_salesforce_action with the chosen action ID.",
        inputSchema: {
          intent: z
            .string()
            .describe(
              "What you want to do, in plain English. " +
                "Examples: 'run a bulk insert of contacts', 'deploy metadata', 'execute anonymous Apex', 'get report results'",
            ),
          limit: z
            .number()
            .int()
            .min(1)
            .max(20)
            .default(8)
            .describe("Max results to return"),
        },
        annotations: { readOnlyHint: true },
      },
      async ({ intent, limit }) => {
        const matches = rankActions(SALESFORCE_ACTION_CATALOG, intent).slice(0, limit);
        return {
          content: [
            {
              type: "text",
              text:
                matches.length > 0
                  ? JSON.stringify(matches, null, 2)
                  : `No actions matched "${intent}". Try a broader description.`,
            },
          ],
        };
      },
    );

    // -------------------------------------------------------------------------
    // Search + Execute Tool 2: Execute Action
    // -------------------------------------------------------------------------
    this.server.registerTool(
      "execute_salesforce_action",
      {
        description:
          "Execute a Salesforce operation by action ID. " +
          "Call search_salesforce_actions first to get the action ID and parameter schema. " +
          "Params must match the schema returned by search_salesforce_actions.",
        inputSchema: {
          actionId: z
            .string()
            .describe("Action ID from search_salesforce_actions"),
          params: z
            .record(z.unknown())
            .describe("Parameters for the action. Use the paramSchema from search_salesforce_actions."),
        },
        annotations: { openWorldHint: true },
      },
      async ({ actionId, params }, extra) => {
        const session = await this.getSession(extra);
        if (!session) return this.authRequiredError();

        const action = SALESFORCE_ACTION_CATALOG.find((a) => a.id === actionId);
        if (!action) {
          return {
            isError: true,
            content: [
              {
                type: "text",
                text: `Unknown action ID: "${actionId}". Call search_salesforce_actions to find valid IDs.`,
              },
            ],
          };
        }

        try {
          const result = await action.execute(params, session);
          return {
            content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
          };
        } catch (err) {
          return {
            isError: true,
            content: [{ type: "text", text: `Action "${actionId}" failed: ${String(err)}` }],
          };
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  private async getSession(extra: { sessionId?: string }): Promise<SalesforceSession | null> {
    // In a real implementation, look up the session from KV or Durable Object state
    // keyed by the MCP session ID. Return null if not authenticated yet.
    const sessionId = extra.sessionId ?? "anonymous";
    const raw = await this.env.TOKEN_STORE.get(`sf_session:${sessionId}`);
    if (!raw) return null;
    return JSON.parse(raw) as SalesforceSession;
  }

  private authRequiredError() {
    return {
      isError: true,
      content: [
        {
          type: "text" as const,
          text:
            "Not authenticated with Salesforce. " +
            "Please visit the authorization URL provided by the MCP host to connect your Salesforce org.",
        },
      ],
    };
  }
}

// ---------------------------------------------------------------------------
// Salesforce API fetch helper
// ---------------------------------------------------------------------------
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
// Worker entry point
// ---------------------------------------------------------------------------
export default {
  fetch(request: Request, env: Env, ctx: ExecutionContext): Response | Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/mcp") {
      // @cloudflare/workers-oauth-provider wraps this to gate behind OAuth
      // See auth-config.ts for how to wire the OAuth provider around this
      return SalesforceMCP.serve("/mcp").fetch(request, env, ctx);
    }

    if (url.pathname === "/health") {
      return new Response(JSON.stringify({ status: "ok" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    return new Response("Not found", { status: 404 });
  },
};
