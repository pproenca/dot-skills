import { CallToolResult } from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";
import { getSalesforceConnection, AuthRequiredError } from "../salesforce/client.js";
import { buildAuthUrl } from "../auth/oauth.js";
import { config } from "../config.js";

type TextContent = { type: "text"; text: string };

function text(content: string): CallToolResult {
  return { content: [{ type: "text", text: content } as TextContent] };
}

function errorResult(message: string): CallToolResult {
  return { isError: true, content: [{ type: "text", text: message } as TextContent] };
}

function formatSalesforceError(err: unknown): string {
  if (Array.isArray(err) && err.length > 0) {
    return err.map((e: { errorCode?: string; message?: string }) =>
      `${e.errorCode ?? "ERROR"}: ${e.message ?? String(e)}`
    ).join("\n");
  }
  if (err instanceof Error) return err.message;
  return String(err);
}

// Wrap tool handlers to catch auth errors and other SF errors uniformly
async function withSalesforce(
  sessionId: string,
  fn: (conn: Awaited<ReturnType<typeof getSalesforceConnection>>) => Promise<CallToolResult>
): Promise<CallToolResult> {
  try {
    const conn = await getSalesforceConnection(sessionId);
    return await fn(conn);
  } catch (err) {
    if (err instanceof AuthRequiredError) {
      const authUrl = buildAuthUrl(sessionId);
      return errorResult(
        `Not connected to Salesforce. Please authorize at:\n${authUrl}\n\nFor sandbox orgs, reconnect with loginUrl=https://test.salesforce.com`
      );
    }
    return errorResult(`Salesforce error: ${formatSalesforceError(err)}`);
  }
}

// ─── Tool Handlers ────────────────────────────────────────────────────────────

export async function handleListObjects(
  sessionId: string,
  args: unknown
): Promise<CallToolResult> {
  const { include_custom = true, include_standard = true } = z
    .object({
      include_custom: z.boolean().optional().default(true),
      include_standard: z.boolean().optional().default(true),
    })
    .parse(args ?? {});

  return withSalesforce(sessionId, async (conn) => {
    const result = await conn.describeGlobal();
    let objects = result.sobjects;

    if (!include_custom) objects = objects.filter((o) => !o.name.endsWith("__c"));
    if (!include_standard) objects = objects.filter((o) => o.name.endsWith("__c"));

    const summary = objects
      .filter((o) => o.queryable)
      .map((o) => `${o.name} (${o.label})${o.custom ? " [custom]" : ""}`)
      .join("\n");

    return text(`Found ${objects.length} queryable objects:\n\n${summary}`);
  });
}

export async function handleDescribe(
  sessionId: string,
  args: unknown
): Promise<CallToolResult> {
  const { object_name } = z
    .object({ object_name: z.string().min(1) })
    .parse(args);

  return withSalesforce(sessionId, async (conn) => {
    const meta = await conn.describe(object_name);

    const fields = meta.fields.map((f) => {
      let info = `  ${f.name} (${f.type})`;
      if (!f.nillable) info += " [required]";
      if (f.label !== f.name) info += ` — "${f.label}"`;
      if (f.type === "picklist" && f.picklistValues) {
        const values = f.picklistValues.map((v) => v.value).join(", ");
        info += `\n    values: ${values}`;
      }
      if (f.referenceTo && f.referenceTo.length > 0) {
        info += ` → ${f.referenceTo.join(", ")}`;
      }
      return info;
    });

    const relationships = meta.childRelationships
      .filter((r) => r.relationshipName)
      .map((r) => `  ${r.relationshipName}: ${r.childSObject}`)
      .join("\n");

    return text(
      `Object: ${meta.name} (${meta.label})\n` +
      `Createable: ${meta.createable}, Updateable: ${meta.updateable}, Deletable: ${meta.deletable}\n\n` +
      `Fields:\n${fields.join("\n")}\n\n` +
      `Child Relationships:\n${relationships || "  (none)"}`
    );
  });
}

export async function handleQuery(
  sessionId: string,
  args: unknown
): Promise<CallToolResult> {
  const { soql, next_page_token } = z
    .object({
      soql: z.string().min(1),
      next_page_token: z.string().optional(),
    })
    .parse(args);

  return withSalesforce(sessionId, async (conn) => {
    let result;
    if (next_page_token) {
      result = await conn.queryMore(next_page_token);
    } else {
      result = await conn.query(soql);
    }

    const output: Record<string, unknown> = {
      totalSize: result.totalSize,
      fetched: result.records.length,
      done: result.done,
      records: result.records,
    };

    if (!result.done && result.nextRecordsUrl) {
      output.next_page_token = result.nextRecordsUrl;
      output.message = `Showing ${result.records.length} of ${result.totalSize} records. Pass next_page_token to get more.`;
    }

    return text(JSON.stringify(output, null, 2));
  });
}

export async function handleSearch(
  sessionId: string,
  args: unknown
): Promise<CallToolResult> {
  const { sosl } = z.object({ sosl: z.string().min(1) }).parse(args);

  return withSalesforce(sessionId, async (conn) => {
    const result = await conn.search(sosl);
    return text(JSON.stringify(result, null, 2));
  });
}

export async function handleGet(
  sessionId: string,
  args: unknown
): Promise<CallToolResult> {
  const { object_name, record_id, fields } = z
    .object({
      object_name: z.string().min(1),
      record_id: z.string().min(1),
      fields: z.array(z.string()).optional(),
    })
    .parse(args);

  return withSalesforce(sessionId, async (conn) => {
    let record;
    if (fields && fields.length > 0) {
      record = await conn.sobject(object_name).retrieve(record_id, { fields });
    } else {
      record = await conn.sobject(object_name).retrieve(record_id);
    }
    return text(JSON.stringify(record, null, 2));
  });
}

export async function handleCreate(
  sessionId: string,
  args: unknown
): Promise<CallToolResult> {
  const { object_name, fields } = z
    .object({
      object_name: z.string().min(1),
      fields: z.record(z.unknown()),
    })
    .parse(args);

  return withSalesforce(sessionId, async (conn) => {
    const result = await conn.sobject(object_name).create(fields as object);
    if (result.success) {
      return text(`Record created successfully. Id: ${result.id}`);
    }
    return errorResult(`Create failed: ${formatSalesforceError(result.errors)}`);
  });
}

export async function handleUpdate(
  sessionId: string,
  args: unknown
): Promise<CallToolResult> {
  const { object_name, record_id, fields } = z
    .object({
      object_name: z.string().min(1),
      record_id: z.string().min(1),
      fields: z.record(z.unknown()),
    })
    .parse(args);

  return withSalesforce(sessionId, async (conn) => {
    const result = await conn.sobject(object_name).update({
      Id: record_id,
      ...fields,
    } as object);
    if (result.success) {
      return text(`Record ${record_id} updated successfully.`);
    }
    return errorResult(`Update failed: ${formatSalesforceError(result.errors)}`);
  });
}

export async function handleDelete(
  sessionId: string,
  args: unknown
): Promise<CallToolResult> {
  const { object_name, record_id } = z
    .object({
      object_name: z.string().min(1),
      record_id: z.string().min(1),
    })
    .parse(args);

  return withSalesforce(sessionId, async (conn) => {
    const result = await conn.sobject(object_name).delete(record_id);
    if (result.success) {
      return text(`Record ${record_id} deleted successfully (moved to Recycle Bin).`);
    }
    return errorResult(`Delete failed: ${formatSalesforceError(result.errors)}`);
  });
}

export async function handleBulkCreate(
  sessionId: string,
  args: unknown
): Promise<CallToolResult> {
  const { object_name, records } = z
    .object({
      object_name: z.string().min(1),
      records: z.array(z.record(z.unknown())).min(1),
    })
    .parse(args);

  return withSalesforce(sessionId, async (conn) => {
    // Use jsforce bulk API
    const results = await conn.bulk.load(object_name, "insert", records as object[]);
    const succeeded = results.filter((r) => r.success).length;
    const failed = results.filter((r) => !r.success).length;
    const errors = results
      .filter((r) => !r.success)
      .map((r, i) => `Record ${i}: ${r.errors?.join(", ")}`)
      .join("\n");

    return text(
      `Bulk create complete: ${succeeded} succeeded, ${failed} failed.\n` +
      (errors ? `\nErrors:\n${errors}` : "")
    );
  });
}

export async function handleGetLimits(
  sessionId: string,
  _args: unknown
): Promise<CallToolResult> {
  return withSalesforce(sessionId, async (conn) => {
    const limits = await conn.limits();
    const formatted = Object.entries(limits)
      .map(([key, val]) => {
        const v = val as { Remaining: number; Max: number };
        return `${key}: ${v.Remaining} / ${v.Max} remaining`;
      })
      .join("\n");
    return text(`Salesforce API Limits:\n\n${formatted}`);
  });
}
