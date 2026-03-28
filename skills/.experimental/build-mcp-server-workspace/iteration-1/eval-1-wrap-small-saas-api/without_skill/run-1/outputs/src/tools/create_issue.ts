import { z } from "zod";
import { apiRequest } from "../client.js";
import type { Issue } from "../types.js";

export const createIssueSchema = z.object({
  title: z.string().min(1).describe("Short title for the issue"),
  description: z
    .string()
    .optional()
    .describe("Full description (markdown supported)"),
  priority: z
    .enum(["low", "medium", "high", "critical"])
    .optional()
    .default("medium")
    .describe("Issue priority"),
  assignee: z
    .string()
    .optional()
    .describe("Username to assign the issue to"),
  labels: z
    .array(z.string())
    .optional()
    .describe("List of label strings to apply"),
});

export type CreateIssueInput = z.infer<typeof createIssueSchema>;

export async function createIssue(input: CreateIssueInput): Promise<string> {
  const issue = await apiRequest<Issue>("/issues", {
    method: "POST",
    body: input,
  });

  return [
    `Created issue #${issue.id}`,
    `Title: ${issue.title}`,
    `Status: ${issue.status}`,
    `Priority: ${issue.priority}`,
    issue.assignee ? `Assignee: ${issue.assignee}` : null,
    `Created at: ${issue.created_at}`,
  ]
    .filter(Boolean)
    .join("\n");
}
