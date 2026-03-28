import { z } from "zod";
import { apiRequest } from "../client.js";
import type { Issue } from "../types.js";

export const updateIssueSchema = z.object({
  id: z.string().describe("Issue ID to update"),
  title: z.string().optional().describe("New title"),
  description: z.string().optional().describe("New description"),
  status: z
    .enum(["open", "in_progress", "closed", "wont_fix"])
    .optional()
    .describe("New status"),
  priority: z
    .enum(["low", "medium", "high", "critical"])
    .optional()
    .describe("New priority"),
  assignee: z.string().optional().describe("New assignee username"),
  labels: z.array(z.string()).optional().describe("Replacement label list"),
});

export type UpdateIssueInput = z.infer<typeof updateIssueSchema>;

export async function updateIssue(input: UpdateIssueInput): Promise<string> {
  const { id, ...updates } = input;

  const issue = await apiRequest<Issue>(`/issues/${id}`, {
    method: "PATCH",
    body: updates,
  });

  return [
    `Updated issue #${issue.id}`,
    `Title: ${issue.title}`,
    `Status: ${issue.status}`,
    `Priority: ${issue.priority}`,
    issue.assignee ? `Assignee: ${issue.assignee}` : null,
    `Updated at: ${issue.updated_at}`,
  ]
    .filter(Boolean)
    .join("\n");
}
