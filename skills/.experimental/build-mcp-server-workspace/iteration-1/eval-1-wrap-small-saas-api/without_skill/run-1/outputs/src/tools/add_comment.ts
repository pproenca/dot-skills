import { z } from "zod";
import { apiRequest } from "../client.js";
import type { Comment } from "../types.js";

export const addCommentSchema = z.object({
  issue_id: z.string().describe("Issue ID to comment on"),
  body: z.string().min(1).describe("Comment body (markdown supported)"),
});

export type AddCommentInput = z.infer<typeof addCommentSchema>;

export async function addComment(input: AddCommentInput): Promise<string> {
  const comment = await apiRequest<Comment>(
    `/issues/${input.issue_id}/comments`,
    {
      method: "POST",
      body: { body: input.body },
    }
  );

  return [
    `Comment #${comment.id} added to issue #${comment.issue_id}`,
    `Author: ${comment.author}`,
    `Created at: ${comment.created_at}`,
  ].join("\n");
}
