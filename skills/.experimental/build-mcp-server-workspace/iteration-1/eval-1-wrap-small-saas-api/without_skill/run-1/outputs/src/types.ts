// Shared types for the issue tracker MCP server

export interface Issue {
  id: string;
  title: string;
  description?: string;
  status: "open" | "in_progress" | "closed" | "wont_fix";
  priority: "low" | "medium" | "high" | "critical";
  assignee?: string;
  labels?: string[];
  created_at: string;
  updated_at: string;
}

export interface Comment {
  id: string;
  issue_id: string;
  author: string;
  body: string;
  created_at: string;
  updated_at: string;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  per_page: number;
  has_more: boolean;
}

export interface ApiError {
  error: string;
  message: string;
  status_code: number;
}
