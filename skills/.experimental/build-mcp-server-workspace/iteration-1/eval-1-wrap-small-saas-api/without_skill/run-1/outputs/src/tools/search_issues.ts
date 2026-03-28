import { z } from "zod";
import { apiRequest } from "../client.js";
import type { Issue, PaginatedResponse } from "../types.js";

export const searchIssuesSchema = z.object({
  query: z.string().describe("Full-text search query"),
  status: z
    .enum(["open", "in_progress", "closed", "wont_fix"])
    .optional()
    .describe("Filter by status"),
  priority: z
    .enum(["low", "medium", "high", "critical"])
    .optional()
    .describe("Filter by priority"),
  assignee: z.string().optional().describe("Filter by assignee username"),
  label: z.string().optional().describe("Filter by label"),
  page: z.number().int().min(1).optional().default(1).describe("Page number"),
  per_page: z
    .number()
    .int()
    .min(1)
    .max(100)
    .optional()
    .default(20)
    .describe("Results per page"),
});

export type SearchIssuesInput = z.infer<typeof searchIssuesSchema>;

export async function searchIssues(input: SearchIssuesInput): Promise<string> {
  const result = await apiRequest<PaginatedResponse<Issue>>("/issues/search", {
    params: {
      q: input.query,
      status: input.status,
      priority: input.priority,
      assignee: input.assignee,
      label: input.label,
      page: input.page,
      per_page: input.per_page,
    },
  });

  if (result.items.length === 0) {
    return "No issues found matching your search.";
  }

  const lines: string[] = [
    `Found ${result.total} issue(s) (showing ${result.items.length}, page ${result.page}):`,
    "",
  ];

  for (const issue of result.items) {
    lines.push(
      `#${issue.id} [${issue.status}] [${issue.priority}] ${issue.title}` +
        (issue.assignee ? ` — ${issue.assignee}` : "")
    );
  }

  if (result.has_more) {
    lines.push(`\nMore results available. Use page=${result.page + 1} to continue.`);
  }

  return lines.join("\n");
}
