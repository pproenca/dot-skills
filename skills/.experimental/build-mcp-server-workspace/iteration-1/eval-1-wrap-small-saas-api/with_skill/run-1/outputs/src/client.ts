// ---------------------------------------------------------------------------
// IssueTrackerClient
//
// Thin HTTP client that wraps your internal issue tracker REST API.
// Replace the method implementations with your actual API calls.
// All methods throw on network errors — the MCP tool handlers catch them.
// ---------------------------------------------------------------------------

export interface ClientConfig {
  baseUrl: string;
  apiKey: string;
}

export interface Issue {
  id: string;
  title: string;
  body?: string;
  status: "open" | "closed" | "in_progress" | "blocked";
  assignee?: string;
  labels?: string[];
  priority?: "low" | "medium" | "high" | "critical";
  created_at: string;
  updated_at: string;
  comments?: Comment[];
}

export interface Comment {
  id: string;
  issue_id: string;
  body: string;
  author: string;
  created_at: string;
}

export interface IssueList {
  items: Omit<Issue, "body" | "comments">[];
  total: number;
  page: number;
  per_page: number;
}

export class IssueTrackerClient {
  private baseUrl: string;
  private headers: Record<string, string>;

  constructor(config: ClientConfig) {
    this.baseUrl = config.baseUrl.replace(/\/$/, "");
    this.headers = {
      "Content-Type": "application/json",
      // Adjust this header name to match your API's auth scheme:
      //   "Authorization": `Bearer ${config.apiKey}`
      //   "X-API-Key": config.apiKey
      //   "api-key": config.apiKey
      "X-API-Key": config.apiKey,
    };
  }

  private async request<T>(
    method: string,
    path: string,
    body?: unknown
  ): Promise<T> {
    const url = `${this.baseUrl}${path}`;
    const res = await fetch(url, {
      method,
      headers: this.headers,
      body: body !== undefined ? JSON.stringify(body) : undefined,
    });

    if (!res.ok) {
      const text = await res.text().catch(() => "");
      throw new Error(`${method} ${path} → ${res.status}: ${text}`);
    }

    return res.json() as Promise<T>;
  }

  async searchIssues(params: {
    query: string;
    status?: "open" | "closed" | "all";
    assignee?: string;
    limit?: number;
  }): Promise<Issue[]> {
    const qs = new URLSearchParams({
      q: params.query,
      ...(params.status && params.status !== "all" ? { status: params.status } : {}),
      ...(params.assignee ? { assignee: params.assignee } : {}),
      limit: String(params.limit ?? 10),
    });
    // Adjust path to match your API:
    return this.request<Issue[]>("GET", `/issues/search?${qs}`);
  }

  async getIssue(issueId: string): Promise<Issue | null> {
    try {
      return await this.request<Issue>("GET", `/issues/${issueId}`);
    } catch (err) {
      if (err instanceof Error && err.message.includes("404")) return null;
      throw err;
    }
  }

  async listIssues(params: {
    status?: "open" | "closed" | "all";
    assignee?: string;
    label?: string;
    page?: number;
    per_page?: number;
  }): Promise<IssueList> {
    const qs = new URLSearchParams({
      ...(params.status && params.status !== "all" ? { status: params.status } : {}),
      ...(params.assignee ? { assignee: params.assignee } : {}),
      ...(params.label ? { label: params.label } : {}),
      page: String(params.page ?? 1),
      per_page: String(params.per_page ?? 20),
    });
    return this.request<IssueList>("GET", `/issues?${qs}`);
  }

  async createIssue(data: {
    title: string;
    body?: string;
    assignee?: string;
    labels?: string[];
    priority?: string;
  }): Promise<Issue> {
    return this.request<Issue>("POST", "/issues", data);
  }

  async updateIssue(
    issueId: string,
    updates: {
      title?: string;
      body?: string;
      status?: string;
      assignee?: string;
      labels?: string[];
      priority?: string;
    }
  ): Promise<Issue | null> {
    try {
      return await this.request<Issue>("PATCH", `/issues/${issueId}`, updates);
    } catch (err) {
      if (err instanceof Error && err.message.includes("404")) return null;
      throw err;
    }
  }

  async addComment(issueId: string, body: string): Promise<Comment | null> {
    try {
      return await this.request<Comment>("POST", `/issues/${issueId}/comments`, {
        body,
      });
    } catch (err) {
      if (err instanceof Error && err.message.includes("404")) return null;
      throw err;
    }
  }

  async deleteIssue(issueId: string): Promise<boolean> {
    try {
      await this.request("DELETE", `/issues/${issueId}`);
      return true;
    } catch (err) {
      if (err instanceof Error && err.message.includes("404")) return false;
      throw err;
    }
  }
}
