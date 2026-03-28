import { z } from "zod";
import { apiRequest } from "../client.js";

export const deleteIssueSchema = z.object({
  id: z.string().describe("Issue ID to delete"),
});

export type DeleteIssueInput = z.infer<typeof deleteIssueSchema>;

export async function deleteIssue(input: DeleteIssueInput): Promise<string> {
  await apiRequest<void>(`/issues/${input.id}`, { method: "DELETE" });
  return `Issue #${input.id} has been deleted.`;
}
