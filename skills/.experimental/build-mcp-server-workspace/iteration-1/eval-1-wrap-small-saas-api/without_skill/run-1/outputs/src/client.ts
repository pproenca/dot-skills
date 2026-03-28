// HTTP client for the internal issue tracker REST API.
// Reads base URL and API key from environment variables.

const BASE_URL = process.env.ISSUE_TRACKER_BASE_URL ?? "";
const API_KEY = process.env.ISSUE_TRACKER_API_KEY ?? "";

if (!BASE_URL) {
  throw new Error("ISSUE_TRACKER_BASE_URL environment variable is required");
}
if (!API_KEY) {
  throw new Error("ISSUE_TRACKER_API_KEY environment variable is required");
}

interface RequestOptions {
  method?: string;
  body?: unknown;
  params?: Record<string, string | number | boolean | undefined>;
}

/**
 * Core fetch wrapper. Appends the API key header, serializes JSON bodies,
 * and raises a structured error for non-2xx responses.
 */
export async function apiRequest<T>(
  path: string,
  options: RequestOptions = {}
): Promise<T> {
  const { method = "GET", body, params } = options;

  // Build URL with query params
  const url = new URL(`${BASE_URL}${path}`);
  if (params) {
    for (const [key, value] of Object.entries(params)) {
      if (value !== undefined) {
        url.searchParams.set(key, String(value));
      }
    }
  }

  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    "X-API-Key": API_KEY,
    Accept: "application/json",
  };

  const response = await fetch(url.toString(), {
    method,
    headers,
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });

  const text = await response.text();

  if (!response.ok) {
    // Try to parse structured error from API, fall back to raw text
    let errorMessage: string;
    try {
      const parsed = JSON.parse(text) as { message?: string; error?: string };
      errorMessage =
        parsed.message ?? parsed.error ?? `HTTP ${response.status}: ${text}`;
    } catch {
      errorMessage = `HTTP ${response.status}: ${text}`;
    }
    throw new ApiClientError(errorMessage, response.status);
  }

  if (!text) {
    return {} as T;
  }

  return JSON.parse(text) as T;
}

export class ApiClientError extends Error {
  constructor(
    message: string,
    public readonly statusCode: number
  ) {
    super(message);
    this.name = "ApiClientError";
  }
}
