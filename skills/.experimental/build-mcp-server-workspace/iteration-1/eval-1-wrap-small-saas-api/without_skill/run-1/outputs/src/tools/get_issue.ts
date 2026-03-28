import { z } from "zod";
import { apiRequest } from "../client.js";
import type { Issue } from "../types.js";

export const getIssueSchema = z.object({
  id: z.string().describe("Issue ID to fetch"),
});

export type GetIssueInput = z.infer<typeof getIssueSchema>;

export async function getIssue(input: GetIssueInput): Promise<string> {
  const issue = await apiRequest<Issue>(`/issues/${input.id}`);

  return [
    `Issue #${issue.id}: ${issue.title}`,
    `Status: ${issue.status}`,
    `Priority: ${issue.priority}`,
    issue.assignee ? `Assignee: ${issue.assignee}` : "Assignee: unassigned",
    issue.labels?.length
      ? `Labels: ${issue.labels.join(", ")}`
      : "Labels: none",
    "",
    issue.description ?? "(no description)",
    "",
    `Created: ${issue.created_at}`,
    `Updated: ${issue.updated_at}`,
  ].join("\n");
}
