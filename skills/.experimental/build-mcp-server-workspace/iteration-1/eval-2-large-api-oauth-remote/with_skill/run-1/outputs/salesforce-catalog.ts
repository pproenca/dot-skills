/**
 * Salesforce Action Catalog — the long tail behind search_salesforce_actions
 *
 * Each entry has:
 *   id          — stable, kebab-case identifier
 *   description — what it does (lands in Claude's context via search results)
 *   keywords    — for keyword-matching in rankActions()
 *   paramSchema — JSON Schema describing expected params (returned with search results)
 *   execute     — async function that calls the Salesforce API and returns a result
 *
 * Add entries here as you expand coverage. The dedicated tools (soql_query,
 * get_record, create_record, update_record, describe_object) are NOT in this
 * catalog — they live as registered MCP tools with full schemas.
 */

export interface SalesforceSession {
  accessToken: string;
  refreshToken: string;
  instanceUrl: string;
}

export interface CatalogEntry {
  id: string;
  description: string;
  keywords: string[];
  paramSchema: Record<string, unknown>;
  execute: (params: Record<string, unknown>, session: SalesforceSession) => Promise<unknown>;
}

export const SALESFORCE_ACTION_CATALOG: CatalogEntry[] = [
  // -------------------------------------------------------------------------
  // Object metadata
  // -------------------------------------------------------------------------
  {
    id: "list-all-objects",
    description: "List all SObject types available in the org (standard + custom).",
    keywords: ["list", "objects", "sobjects", "all", "types", "available"],
    paramSchema: { type: "object", properties: {}, required: [] },
    async execute(_params, session) {
      const res = await sfFetch(`${session.instanceUrl}/services/data/v59.0/sobjects`, session);
      const data = (await res.json()) as { sobjects: Array<{ name: string; label: string }> };
      return data.sobjects.map((o) => ({ name: o.name, label: o.label }));
    },
  },

  // -------------------------------------------------------------------------
  // Bulk API 2.0
  // -------------------------------------------------------------------------
  {
    id: "bulk-insert",
    description: "Bulk insert records using Salesforce Bulk API 2.0. Accepts a CSV string.",
    keywords: ["bulk", "insert", "mass", "import", "csv", "batch", "load"],
    paramSchema: {
      type: "object",
      properties: {
        objectType: { type: "string", description: "API name of the object to insert into" },
        csvData: { type: "string", description: "CSV data string with a header row" },
      },
      required: ["objectType", "csvData"],
    },
    async execute({ objectType, csvData }, session) {
      // Create bulk job
      const createRes = await sfFetch(
        `${session.instanceUrl}/services/data/v59.0/jobs/ingest`,
        session,
        {
          method: "POST",
          body: JSON.stringify({ object: objectType, operation: "insert", contentType: "CSV" }),
        },
      );
      const job = (await createRes.json()) as { id: string };

      // Upload CSV
      await sfFetch(
        `${session.instanceUrl}/services/data/v59.0/jobs/ingest/${job.id}/batches`,
        session,
        { method: "PUT", body: csvData as string, headers: { "Content-Type": "text/csv" } },
      );

      // Close job
      await sfFetch(
        `${session.instanceUrl}/services/data/v59.0/jobs/ingest/${job.id}`,
        session,
        { method: "PATCH", body: JSON.stringify({ state: "UploadComplete" }) },
      );

      return { jobId: job.id, status: "UploadComplete — poll job status to track progress" };
    },
  },
  {
    id: "bulk-job-status",
    description: "Check the status of a Bulk API 2.0 ingest or query job.",
    keywords: ["bulk", "job", "status", "progress", "check", "poll"],
    paramSchema: {
      type: "object",
      properties: {
        jobId: { type: "string", description: "Bulk API job ID" },
        jobType: { type: "string", enum: ["ingest", "query"], description: "Type of bulk job" },
      },
      required: ["jobId", "jobType"],
    },
    async execute({ jobId, jobType }, session) {
      const endpoint = jobType === "query" ? "query" : "ingest";
      const res = await sfFetch(
        `${session.instanceUrl}/services/data/v59.0/jobs/${endpoint}/${jobId as string}`,
        session,
      );
      return res.json();
    },
  },

  // -------------------------------------------------------------------------
  // Reports
  // -------------------------------------------------------------------------
  {
    id: "run-report",
    description: "Run a Salesforce report and return the results. Pass the report ID.",
    keywords: ["report", "run", "analytics", "dashboard", "results"],
    paramSchema: {
      type: "object",
      properties: {
        reportId: { type: "string", description: "Salesforce report ID (starts with '00O')" },
        includeDetails: {
          type: "boolean",
          default: true,
          description: "Whether to include detail rows. False returns only summary.",
        },
      },
      required: ["reportId"],
    },
    async execute({ reportId, includeDetails = true }, session) {
      const url =
        `${session.instanceUrl}/services/data/v59.0/analytics/reports/${reportId as string}` +
        `?includeDetails=${String(includeDetails)}`;
      const res = await sfFetch(url, session, { method: "POST" });
      return res.json();
    },
  },
  {
    id: "list-reports",
    description: "List available Salesforce reports in the org.",
    keywords: ["list", "reports", "analytics", "available"],
    paramSchema: { type: "object", properties: {}, required: [] },
    async execute(_params, session) {
      const res = await sfFetch(
        `${session.instanceUrl}/services/data/v59.0/analytics/reports`,
        session,
      );
      return res.json();
    },
  },

  // -------------------------------------------------------------------------
  // Apex
  // -------------------------------------------------------------------------
  {
    id: "execute-apex",
    description:
      "Execute anonymous Apex code in the user's org. Returns logs and output. " +
      "Use with caution — Apex can mutate data.",
    keywords: ["apex", "anonymous", "execute", "code", "script", "developer"],
    paramSchema: {
      type: "object",
      properties: {
        apexCode: { type: "string", description: "Apex code to execute anonymously" },
      },
      required: ["apexCode"],
    },
    async execute({ apexCode }, session) {
      const res = await sfFetch(
        `${session.instanceUrl}/services/data/v59.0/tooling/executeAnonymous?anonymousBody=${encodeURIComponent(apexCode as string)}`,
        session,
      );
      return res.json();
    },
  },

  // -------------------------------------------------------------------------
  // Flows / Process Automation
  // -------------------------------------------------------------------------
  {
    id: "invoke-flow",
    description: "Invoke a Salesforce Flow by API name, passing input variables.",
    keywords: ["flow", "invoke", "trigger", "automation", "process builder", "run flow"],
    paramSchema: {
      type: "object",
      properties: {
        flowApiName: { type: "string", description: "API name of the Flow" },
        inputs: {
          type: "array",
          description: "Array of { name, type, value } input variable objects",
          items: { type: "object" },
        },
      },
      required: ["flowApiName"],
    },
    async execute({ flowApiName, inputs = [] }, session) {
      const res = await sfFetch(
        `${session.instanceUrl}/services/data/v59.0/actions/custom/flow/${flowApiName as string}`,
        session,
        { method: "POST", body: JSON.stringify({ inputs }) },
      );
      return res.json();
    },
  },

  // -------------------------------------------------------------------------
  // Metadata API
  // -------------------------------------------------------------------------
  {
    id: "list-metadata-types",
    description:
      "List all metadata types available in the org (CustomObject, ApexClass, Flow, etc.).",
    keywords: ["metadata", "types", "list", "components", "deployment"],
    paramSchema: { type: "object", properties: {}, required: [] },
    async execute(_params, session) {
      const res = await sfFetch(
        `${session.instanceUrl}/services/data/v59.0/tooling/query?q=${encodeURIComponent("SELECT DurableId, QualifiedApiName FROM EntityDefinition LIMIT 500")}`,
        session,
      );
      return res.json();
    },
  },

  // -------------------------------------------------------------------------
  // Delete Record (intentionally NOT a dedicated tool — destructive op)
  // -------------------------------------------------------------------------
  {
    id: "delete-record",
    description:
      "Permanently delete a Salesforce record by object type and ID. This is irreversible. " +
      "Use soql_query to confirm the record ID before calling this.",
    keywords: ["delete", "remove", "destroy", "record", "permanent"],
    paramSchema: {
      type: "object",
      properties: {
        objectType: { type: "string", description: "Salesforce API object name" },
        id: { type: "string", description: "Record ID (15 or 18 characters)" },
      },
      required: ["objectType", "id"],
    },
    async execute({ objectType, id }, session) {
      const res = await sfFetch(
        `${session.instanceUrl}/services/data/v59.0/sobjects/${objectType as string}/${id as string}`,
        session,
        { method: "DELETE" },
      );
      if (res.status === 204) {
        return { deleted: true, id, objectType };
      }
      return { deleted: false, error: await res.json() };
    },
  },

  // -------------------------------------------------------------------------
  // Search (SOSL)
  // -------------------------------------------------------------------------
  {
    id: "sosl-search",
    description:
      "Execute a SOSL (Salesforce Object Search Language) full-text search across multiple objects. " +
      "Better than SOQL for finding a record when you only know part of a name or email across all object types.",
    keywords: ["sosl", "search", "full text", "find", "cross-object", "global search"],
    paramSchema: {
      type: "object",
      properties: {
        searchString: {
          type: "string",
          description: "SOSL search string, e.g. 'FIND {jane doe} IN ALL FIELDS RETURNING Account(Name), Contact(Name, Email)'",
        },
      },
      required: ["searchString"],
    },
    async execute({ searchString }, session) {
      const res = await sfFetch(
        `${session.instanceUrl}/services/data/v59.0/search?q=${encodeURIComponent(searchString as string)}`,
        session,
      );
      return res.json();
    },
  },
];

// ---------------------------------------------------------------------------
// Simple keyword ranker — upgrade to embeddings if precision matters
// ---------------------------------------------------------------------------
export function rankActions(
  catalog: CatalogEntry[],
  intent: string,
): Array<Pick<CatalogEntry, "id" | "description" | "paramSchema">> {
  const terms = intent.toLowerCase().split(/\s+/);

  const scored = catalog.map((entry) => {
    const haystack = [
      entry.id,
      entry.description.toLowerCase(),
      ...entry.keywords,
    ].join(" ");

    const score = terms.reduce((acc, term) => {
      return acc + (haystack.includes(term) ? 1 : 0);
    }, 0);

    return { entry, score };
  });

  return scored
    .filter((s) => s.score > 0)
    .sort((a, b) => b.score - a.score)
    .map((s) => ({
      id: s.entry.id,
      description: s.entry.description,
      paramSchema: s.entry.paramSchema,
    }));
}

// ---------------------------------------------------------------------------
// Internal fetch helper (mirrors the one in server-workers.ts)
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
