#!/usr/bin/env bun
/**
 * Generate a browser-based review UI for an RFC markdown file.
 *
 * Supports three modes:
 *   - Server mode (default): starts an HTTP server on localhost, auto-saves
 *     feedback to a workspace directory, supports iteration with previous feedback.
 *   - Live mode (--live): opens UI with section skeleton, agent pushes sections
 *     one at a time via HTTP, user reviews each section in real-time via SSE.
 *   - Static mode (--static): writes a standalone HTML file, feedback downloads
 *     as a Blob to ~/Downloads (legacy behavior).
 */

import { parseArgs } from "node:util";
import { execSync } from "node:child_process";
import path from "node:path";
import fs from "node:fs";

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function killPort(port: number): void {
  let killed = false;
  // Try lsof (macOS, some Linux)
  try {
    const result = execSync(`lsof -ti :${port}`, { timeout: 5000 })
      .toString()
      .trim();
    for (const pidStr of result.split("\n")) {
      const pid = parseInt(pidStr.trim(), 10);
      if (!isNaN(pid)) {
        try {
          process.kill(pid, "SIGTERM");
          killed = true;
        } catch {
          // Process already gone
        }
      }
    }
  } catch {
    // lsof not found or no process on port
  }

  if (killed) {
    // Give the process a moment to release the port
    Bun.sleepSync(500);
    return;
  }

  // Fallback: fuser (Linux)
  try {
    execSync(`fuser -k ${port}/tcp`, { timeout: 5000 });
    Bun.sleepSync(500);
  } catch {
    // fuser not found or no process on port
  }
}

function slugify(heading: string): string {
  let s = heading.toLowerCase().trim();
  s = s.replace(/[^a-z0-9\s-]/g, "");
  s = s.replace(/[\s]+/g, "-");
  s = s.replace(/-+/g, "-");
  return s.replace(/^-|-$/g, "");
}

// ---------------------------------------------------------------------------
// LiveSession — manages real-time authoring state
// ---------------------------------------------------------------------------

interface SectionData {
  heading: string;
  order: number;
  markdown: string;
  status: "pending" | "review" | "approved" | "changes_requested";
  feedback: FeedbackData | null;
  history: Array<{ markdown: string; feedback: FeedbackData | null }>;
}

interface FeedbackData {
  action: string;
  text: string;
  inline_comments: Array<{ selected_text: string; comment: string }>;
}

interface SSEEvent {
  type: string;
  data: Record<string, unknown>;
}

type SSEController = ReadableStreamDefaultController<string>;

class LiveSession {
  title: string;
  sectionsPlan: string[];
  sections: Map<string, SectionData> = new Map();
  currentSection: string | null = null;
  overallStatus = "in_progress";
  workspace: string | null;
  private feedbackResolvers: Map<
    string,
    { resolve: (value: FeedbackData | { timeout: true } | { error: string }) => void }
  > = new Map();
  private sseClients: Set<SSEController> = new Set();

  constructor(
    title: string,
    sectionsPlan: string[],
    workspace: string | null = null,
  ) {
    this.title = title;
    this.sectionsPlan = sectionsPlan;
    this.workspace = workspace;

    for (let i = 0; i < sectionsPlan.length; i++) {
      const heading = sectionsPlan[i];
      const sid = slugify(heading);
      this.sections.set(sid, {
        heading,
        order: i + 1,
        markdown: "",
        status: "pending",
        feedback: null,
        history: [],
      });
    }
  }

  addSection(sectionId: string, heading: string, markdown: string): void {
    const existing = this.sections.get(sectionId);
    if (existing) {
      existing.markdown = markdown;
      existing.status = "review";
      existing.heading = heading;
    } else {
      this.sections.set(sectionId, {
        heading,
        order: this.sections.size + 1,
        markdown,
        status: "review",
        feedback: null,
        history: [],
      });
    }
    this.currentSection = sectionId;
    const sec = this.sections.get(sectionId)!;
    this.broadcast("section-added", {
      id: sectionId,
      heading,
      markdown,
      status: "review",
      order: sec.order,
    });
    this.saveState();
  }

  updateSection(sectionId: string, markdown: string): boolean {
    const sec = this.sections.get(sectionId);
    if (!sec) return false;

    if (sec.markdown) {
      sec.history.push({ markdown: sec.markdown, feedback: sec.feedback });
    }
    sec.markdown = markdown;
    sec.status = "review";
    sec.feedback = null;

    // Reset any pending feedback wait for this section
    const pending = this.feedbackResolvers.get(sectionId);
    if (pending) {
      // Don't resolve — the old waiter will time out or a new wait will be issued
      this.feedbackResolvers.delete(sectionId);
    }

    this.broadcast("section-updated", {
      id: sectionId,
      heading: sec.heading,
      markdown,
      status: "review",
    });
    this.saveState();
    return true;
  }

  setFeedback(
    sectionId: string,
    action: string,
    text: string = "",
    inlineComments: Array<{ selected_text: string; comment: string }> = [],
  ): boolean {
    const sec = this.sections.get(sectionId);
    if (!sec) return false;

    const feedback: FeedbackData = {
      action,
      text,
      inline_comments: inlineComments,
    };
    sec.feedback = feedback;
    sec.status = action === "approve" ? "approved" : "changes_requested";

    this.broadcast("section-status", {
      id: sectionId,
      status: sec.status,
      feedback,
    });
    this.saveState();

    // Resolve any waiter
    const pending = this.feedbackResolvers.get(sectionId);
    if (pending) {
      pending.resolve(feedback);
      this.feedbackResolvers.delete(sectionId);
    }

    return true;
  }

  waitForFeedback(
    sectionId: string,
    timeout: number = 300_000,
  ): Promise<FeedbackData | { timeout: true } | { error: string }> {
    if (!this.sections.has(sectionId)) {
      return Promise.resolve({ error: "unknown section" });
    }

    // Check if feedback already exists
    const sec = this.sections.get(sectionId)!;
    if (sec.feedback) {
      return Promise.resolve(sec.feedback);
    }

    return new Promise((resolve) => {
      this.feedbackResolvers.set(sectionId, { resolve });
      setTimeout(() => {
        if (this.feedbackResolvers.has(sectionId)) {
          this.feedbackResolvers.delete(sectionId);
          resolve({ timeout: true });
        }
      }, timeout);
    });
  }

  getState(): Record<string, unknown> {
    const sections: Record<string, SectionData> = {};
    for (const [k, v] of this.sections) {
      sections[k] = { ...v };
    }
    return {
      mode: "live",
      title: this.title,
      sections_plan: [...this.sectionsPlan],
      sections,
      current_section: this.currentSection,
      overall_status: this.overallStatus,
    };
  }

  registerSSEClient(controller: SSEController): void {
    this.sseClients.add(controller);
  }

  unregisterSSEClient(controller: SSEController): void {
    this.sseClients.delete(controller);
  }

  private broadcast(eventType: string, data: Record<string, unknown>): void {
    const msg = `event: ${eventType}\ndata: ${JSON.stringify(data)}\n\n`;
    for (const controller of this.sseClients) {
      try {
        controller.enqueue(msg);
      } catch {
        // Client disconnected
      }
    }
  }

  private saveState(): void {
    if (!this.workspace) return;
    try {
      const state = {
        mode: "live",
        title: this.title,
        sections_plan: this.sectionsPlan,
        sections: Object.fromEntries(this.sections),
        current_section: this.currentSection,
        overall_status: this.overallStatus,
      };
      const filePath = path.join(this.workspace, "session.json");
      fs.writeFileSync(filePath, JSON.stringify(state, null, 2) + "\n", "utf-8");
    } catch {
      // Silently ignore write errors
    }
  }
}

// ---------------------------------------------------------------------------
// HTML builder
// ---------------------------------------------------------------------------

function buildHtml(
  mdPath: string | null,
  title: string,
  previousFeedback: Record<string, unknown> | null,
  iteration: number,
  serverMode: boolean,
  liveMode: boolean = false,
): string {
  let mdContent = "";
  if (mdPath && fs.existsSync(mdPath)) {
    mdContent = fs.readFileSync(mdPath, "utf-8");
  }

  const templatePath = path.join(
    path.dirname(import.meta.dir),
    "assets",
    "review_template.html",
  );
  let html = fs.readFileSync(templatePath, "utf-8");

  html = html.replace("__MARKDOWN_CONTENT__", JSON.stringify(mdContent));
  html = html.replace("__DOC_TITLE__", title.replace(/"/g, "&quot;"));
  html = html.replace(
    "__PREVIOUS_FEEDBACK__",
    JSON.stringify(previousFeedback || {}),
  );
  html = html.replace("__ITERATION__", String(iteration));
  html = html.replace("__SERVER_MODE__", serverMode ? "true" : "false");
  html = html.replace("__LIVE_MODE__", liveMode ? "true" : "false");

  return html;
}

// ---------------------------------------------------------------------------
// HTTP Server
// ---------------------------------------------------------------------------

interface ServerContext {
  mdPath: string | null;
  title: string;
  feedbackPath: string | null;
  previousFeedback: Record<string, unknown> | null;
  iteration: number;
  liveSession: LiveSession | null;
}

const NO_CACHE_HEADERS: Record<string, string> = {
  "Cache-Control": "no-cache, no-store, must-revalidate",
  Pragma: "no-cache",
  Expires: "0",
};

function jsonResponse(
  code: number,
  data: Record<string, unknown>,
): Response {
  return new Response(JSON.stringify(data), {
    status: code,
    headers: {
      "Content-Type": "application/json",
      ...NO_CACHE_HEADERS,
    },
  });
}

function handleGet(url: URL, ctx: ServerContext): Response | null {
  const pathname = url.pathname;

  // --- Serve index ---
  if (pathname === "/" || pathname === "/index.html") {
    const liveMode = ctx.liveSession !== null;
    const html = buildHtml(
      ctx.mdPath,
      ctx.title,
      ctx.previousFeedback,
      ctx.iteration,
      true, // serverMode
      liveMode,
    );
    return new Response(html, {
      headers: {
        "Content-Type": "text/html; charset=utf-8",
        ...NO_CACHE_HEADERS,
      },
    });
  }

  // --- GET /api/feedback ---
  if (pathname === "/api/feedback") {
    let data = "{}";
    if (ctx.feedbackPath && fs.existsSync(ctx.feedbackPath)) {
      data = fs.readFileSync(ctx.feedbackPath, "utf-8");
    }
    return new Response(data, {
      headers: {
        "Content-Type": "application/json",
        ...NO_CACHE_HEADERS,
      },
    });
  }

  // --- GET /api/session ---
  if (pathname === "/api/session" && ctx.liveSession) {
    return jsonResponse(200, ctx.liveSession.getState());
  }

  // --- GET /api/wait-feedback ---
  if (pathname.startsWith("/api/wait-feedback") && ctx.liveSession) {
    const sectionId = url.searchParams.get("section");
    if (!sectionId) {
      return jsonResponse(400, { error: "missing section parameter" });
    }
    // Return null here — handled async in the fetch handler
    return null;
  }

  // --- GET /events (SSE) ---
  if (pathname === "/events" && ctx.liveSession) {
    return null; // Handled specially in fetch handler
  }

  // --- GET /assets/* ---
  if (pathname.startsWith("/assets/")) {
    return serveAsset(pathname);
  }

  return new Response("Not Found", { status: 404 });
}

function serveAsset(pathname: string): Response {
  const filename = pathname.split("/assets/")[1] || "";
  // Block path traversal
  if (filename.includes("/") || filename.includes("\\") || filename.includes("..")) {
    return new Response("Forbidden", { status: 403 });
  }

  const assetsDir = path.join(path.dirname(import.meta.dir), "assets");
  const assetPath = path.join(assetsDir, filename);

  if (!fs.existsSync(assetPath) || !fs.statSync(assetPath).isFile()) {
    return new Response("Not Found", { status: 404 });
  }

  const contentTypes: Record<string, string> = {
    ".js": "application/javascript",
    ".css": "text/css",
    ".html": "text/html",
  };
  const ext = path.extname(assetPath);
  const ct = contentTypes[ext] || "application/octet-stream";
  const data = fs.readFileSync(assetPath);

  return new Response(data, {
    headers: {
      "Content-Type": ct,
      "Cache-Control": "public, max-age=86400",
    },
  });
}

async function handlePost(
  url: URL,
  req: Request,
  ctx: ServerContext,
): Promise<Response> {
  const pathname = url.pathname;

  // --- POST /api/feedback ---
  if (pathname === "/api/feedback") {
    try {
      const data = await req.json();
      if (typeof data !== "object" || data === null || Array.isArray(data)) {
        return jsonResponse(400, { error: "Expected JSON object" });
      }
      if (ctx.feedbackPath) {
        fs.writeFileSync(
          ctx.feedbackPath,
          JSON.stringify(data, null, 2) + "\n",
          "utf-8",
        );
      }
      return jsonResponse(200, { ok: true });
    } catch (e: unknown) {
      return jsonResponse(500, {
        error: e instanceof Error ? e.message : String(e),
      });
    }
  }

  // --- POST /api/section/add ---
  if (pathname === "/api/section/add" && ctx.liveSession) {
    try {
      const data = await req.json();
      const heading = data.heading || "";
      const sectionId = data.id || slugify(heading);
      const markdown = data.markdown || "";
      if (!sectionId || !heading) {
        return jsonResponse(400, { error: "id and heading required" });
      }
      ctx.liveSession.addSection(sectionId, heading, markdown);
      return jsonResponse(200, { ok: true, section: sectionId });
    } catch (e: unknown) {
      return jsonResponse(400, {
        error: e instanceof Error ? e.message : String(e),
      });
    }
  }

  // --- POST /api/section/update ---
  if (pathname === "/api/section/update" && ctx.liveSession) {
    try {
      const data = await req.json();
      const sectionId = data.id || data.section || "";
      const markdown = data.markdown || "";
      if (!sectionId) {
        return jsonResponse(400, { error: "id/section required" });
      }
      const ok = ctx.liveSession.updateSection(sectionId, markdown);
      if (ok) {
        return jsonResponse(200, { ok: true });
      }
      return jsonResponse(404, { error: "section not found" });
    } catch (e: unknown) {
      return jsonResponse(400, {
        error: e instanceof Error ? e.message : String(e),
      });
    }
  }

  // --- POST /api/section/feedback ---
  if (pathname === "/api/section/feedback" && ctx.liveSession) {
    try {
      const data = await req.json();
      const sectionId = data.section || "";
      const action = data.action || "";
      const text = data.text || "";
      const inlineComments = data.inline_comments || [];
      if (!sectionId || !action) {
        return jsonResponse(400, {
          error: "section and action required",
        });
      }
      const ok = ctx.liveSession.setFeedback(
        sectionId,
        action,
        text,
        inlineComments,
      );
      if (ok) {
        return jsonResponse(200, { ok: true });
      }
      return jsonResponse(404, { error: "section not found" });
    } catch (e: unknown) {
      return jsonResponse(400, {
        error: e instanceof Error ? e.message : String(e),
      });
    }
  }

  return new Response("Not Found", { status: 404 });
}

function handleSSE(ctx: ServerContext): Response {
  const liveSession = ctx.liveSession!;

  const stream = new ReadableStream<string>({
    start(controller) {
      liveSession.registerSSEClient(controller);

      // Send current state as catch-up events
      const state = liveSession.getState();
      const sections = state.sections as Record<string, SectionData>;
      for (const [sectionId, sec] of Object.entries(sections)) {
        if (sec.status !== "pending") {
          const msg = `event: section-added\ndata: ${JSON.stringify({
            id: sectionId,
            heading: sec.heading,
            markdown: sec.markdown,
            status: sec.status,
            order: sec.order,
          })}\n\n`;
          controller.enqueue(msg);
        }
      }

      // Keep-alive pings every 15 seconds
      const pingInterval = setInterval(() => {
        try {
          controller.enqueue(`event: ping\ndata: {}\n\n`);
        } catch {
          clearInterval(pingInterval);
        }
      }, 15_000);

      // Clean up on cancel
      controller.enqueue(""); // Trigger the stream
    },
    cancel(controller) {
      liveSession.unregisterSSEClient(controller as SSEController);
    },
  });

  return new Response(stream, {
    headers: {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      Connection: "keep-alive",
    },
  });
}

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------

function printUsage(): void {
  console.log(`Usage: bun run scripts/generate_review.ts [options] [markdown_path]

Open an RFC review UI in the browser.

Arguments:
  markdown_path              Path to the markdown file (not required in --live mode)

Options:
  --title <title>            Document title for the header (default: "Untitled")
  --workspace <dir>          Workspace directory (default: <doc-dir>/.rfc-review/)
  --previous-feedback <path> Path to previous iteration's feedback.json
  --iteration <n>            Iteration/round number (default: 1)
  --port <port>              Server port (default: 3118)
  --static                   Write standalone HTML instead of starting a server
  --output <path>            Output HTML path (only used with --static)
  --live                     Start in live authoring mode (sections added via API)
  --sections <json>          JSON array of section headings (for --live mode)
  --no-open                  Don't open browser automatically
  --help                     Show this help message`);
}

async function main(): Promise<void> {
  const { values, positionals } = parseArgs({
    args: Bun.argv.slice(2),
    options: {
      title: { type: "string", default: "Untitled" },
      workspace: { type: "string" },
      "previous-feedback": { type: "string" },
      iteration: { type: "string", default: "1" },
      port: { type: "string", default: "3118" },
      static: { type: "boolean", default: false },
      output: { type: "string" },
      live: { type: "boolean", default: false },
      sections: { type: "string" },
      "no-open": { type: "boolean", default: false },
      help: { type: "boolean", default: false },
    },
    allowPositionals: true,
    strict: true,
  });

  if (values.help) {
    printUsage();
    process.exit(0);
  }

  const title = values.title!;
  const iteration = parseInt(values.iteration!, 10);
  const port = parseInt(values.port!, 10);
  const isStatic = values.static!;
  const isLive = values.live!;
  const noOpen = values["no-open"]!;
  const markdownPathArg = positionals[0] || null;

  // Validate args
  if (!isLive && !markdownPathArg) {
    console.error(
      "Error: markdown_path is required unless --live is specified",
    );
    process.exit(1);
  }

  let mdPath: string | null = null;
  if (markdownPathArg) {
    mdPath = path.resolve(markdownPathArg);
    if (!fs.existsSync(mdPath)) {
      console.error(`Error: file not found: ${mdPath}`);
      process.exit(1);
    }
  }

  // Load previous feedback if provided
  let previousFeedback: Record<string, unknown> | null = null;
  if (values["previous-feedback"]) {
    const pfPath = path.resolve(values["previous-feedback"]);
    if (fs.existsSync(pfPath)) {
      try {
        previousFeedback = JSON.parse(fs.readFileSync(pfPath, "utf-8"));
      } catch (e: unknown) {
        console.error(
          `Warning: could not read previous feedback: ${e instanceof Error ? e.message : e}`,
        );
      }
    }
  }

  // --- Static mode (legacy) ---
  if (isStatic) {
    if (!mdPath) {
      console.error("Error: markdown_path is required for --static mode");
      process.exit(1);
    }
    const html = buildHtml(
      mdPath,
      title,
      previousFeedback,
      iteration,
      false,
    );
    const outPath =
      values.output || `/tmp/dev-rfc-review-${path.basename(mdPath, path.extname(mdPath))}.html`;
    fs.writeFileSync(outPath, html, "utf-8");
    if (!noOpen) {
      const open = (await import("open")).default;
      await open(`file://${path.resolve(outPath)}`);
    }
    console.log(`Review UI: ${outPath}`);
    return;
  }

  // --- Server mode (batch or live) ---
  let workspace: string;
  if (values.workspace) {
    workspace = path.resolve(values.workspace);
  } else if (mdPath) {
    workspace = path.resolve(path.dirname(mdPath), ".rfc-review");
  } else {
    workspace = path.resolve(process.cwd(), ".rfc-review");
  }
  fs.mkdirSync(workspace, { recursive: true });

  const feedbackPath = path.join(workspace, "feedback.json");
  const historyDir = path.join(workspace, "feedback-history");
  fs.mkdirSync(historyDir, { recursive: true });

  // Archive existing feedback.json before starting a new round
  if (fs.existsSync(feedbackPath) && iteration > 1) {
    const prevRound = iteration - 1;
    const archiveDest = path.join(
      historyDir,
      `feedback-round-${prevRound}.json`,
    );
    if (!fs.existsSync(archiveDest)) {
      fs.writeFileSync(
        archiveDest,
        fs.readFileSync(feedbackPath, "utf-8"),
        "utf-8",
      );
    }
  }

  killPort(port);

  // Set up live session if in live mode
  let liveSession: LiveSession | null = null;
  if (isLive) {
    let sectionsPlan: string[] = [];
    if (values.sections) {
      try {
        sectionsPlan = JSON.parse(values.sections);
        if (!Array.isArray(sectionsPlan)) {
          throw new Error("--sections must be a JSON array");
        }
      } catch (e: unknown) {
        console.error(
          `Error parsing --sections: ${e instanceof Error ? e.message : e}`,
        );
        process.exit(1);
      }
    }
    liveSession = new LiveSession(title, sectionsPlan, workspace);
  }

  const ctx: ServerContext = {
    mdPath,
    title,
    feedbackPath,
    previousFeedback,
    iteration,
    liveSession,
  };

  const server = Bun.serve({
    hostname: "127.0.0.1",
    port,
    async fetch(req) {
      const url = new URL(req.url);

      if (req.method === "GET") {
        // Handle SSE
        if (url.pathname === "/events" && ctx.liveSession) {
          return handleSSE(ctx);
        }

        // Handle wait-feedback (async/blocking)
        if (
          url.pathname.startsWith("/api/wait-feedback") &&
          ctx.liveSession
        ) {
          const sectionId = url.searchParams.get("section");
          if (!sectionId) {
            return jsonResponse(400, {
              error: "missing section parameter",
            });
          }
          const result = await ctx.liveSession.waitForFeedback(sectionId);
          return jsonResponse(200, result as Record<string, unknown>);
        }

        const response = handleGet(url, ctx);
        return response || new Response("Not Found", { status: 404 });
      }

      if (req.method === "POST") {
        return handlePost(url, req, ctx);
      }

      return new Response("Method Not Allowed", { status: 405 });
    },
  });

  const serverUrl = `http://localhost:${server.port}`;

  if (!noOpen) {
    try {
      const open = (await import("open")).default;
      await open(serverUrl);
    } catch {
      console.error(
        `Could not open browser automatically. Visit: ${serverUrl}`,
      );
    }
  }

  if (isLive) {
    console.log(`RFC live authoring server running at ${serverUrl}`);
    console.log(`Workspace: ${workspace}`);
    if (values.sections && liveSession) {
      console.log(`Planned sections: ${liveSession.sections.size}`);
    }
    console.log("Agent can now push sections via POST /api/section/add");
  } else {
    console.log(`RFC review server running at ${serverUrl}`);
    console.log(`Workspace: ${workspace}`);
    console.log(`Feedback will be saved to: ${feedbackPath}`);
    if (previousFeedback) {
      console.log(
        `Showing previous feedback from: ${values["previous-feedback"]}`,
      );
    }
  }

  console.log("Press Ctrl+C to stop the server.");

  // Handle graceful shutdown
  process.on("SIGINT", () => {
    console.log("\nServer stopped.");
    server.stop();
    process.exit(0);
  });

  process.on("SIGTERM", () => {
    server.stop();
    process.exit(0);
  });
}

main();
