import { z } from "zod";
import { apiRequest } from "../client.js";
import type { Issue, PaginatedResponse } from "../types.js";

export const listIssuesSchema = z.object({
  status: z
    .enum(["open", "in_progress", "closed", "wont_fix"])
    .optional()
    .describe("Filter by status"),
  priority: z
    .enum(["low", "medium", "high", "critical"])
    .optional()
    .describe("Filter by priority"),
  assignee: z.string().optional().describe("Filter by assignee username"),
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

export type ListIssuesInput = z.infer<typeof listIssuesSchema>;

export async function listIssues(input: ListIssuesInput): Promise<string> {
  const result = await apiRequest<PaginatedResponse<Issue>>("/issues", {
    params: {
      status: input.status,
      priority: input.priority,
      assignee: input.assignee,
      page: input.page,
      per_page: input.per_page,
    },
  });

  if (result.items.length === 0) {
    return "No issues found.";
  }

  const lines: string[] = [
    `${result.total} total issue(s) (showing page ${result.page} of ${Math.ceil(result.total / result.per_page)}):`,
    "",
  ];

  for (const issue of result.items) {
    lines.push(
      `#${issue.id} [${issue.status}] [${issue.priority}] ${issue.title}` +
        (issue.assignee ? ` — ${issue.assignee}` : "")
    );
  }

  if (result.has_more) {
    lines.push(`\nUse page=${result.page + 1} to see more.`);
  }

  return lines.join("\n");
}
