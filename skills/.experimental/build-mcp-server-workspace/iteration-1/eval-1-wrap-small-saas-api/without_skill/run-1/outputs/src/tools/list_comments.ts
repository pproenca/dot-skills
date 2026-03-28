import { z } from "zod";
import { apiRequest } from "../client.js";
import type { Comment } from "../types.js";

export const listCommentsSchema = z.object({
  issue_id: z.string().describe("Issue ID to list comments for"),
});

export type ListCommentsInput = z.infer<typeof listCommentsSchema>;

export async function listComments(input: ListCommentsInput): Promise<string> {
  const comments = await apiRequest<Comment[]>(
    `/issues/${input.issue_id}/comments`
  );

  if (comments.length === 0) {
    return `No comments on issue #${input.issue_id}.`;
  }

  const lines: string[] = [
    `${comments.length} comment(s) on issue #${input.issue_id}:`,
    "",
  ];

  for (const comment of comments) {
    lines.push(`--- Comment #${comment.id} by ${comment.author} (${comment.created_at}) ---`);
    lines.push(comment.body);
    lines.push("");
  }

  return lines.join("\n");
}
