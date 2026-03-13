import { describe, test, expect, afterAll } from "bun:test";
import { execSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";

const SCRIPT = path.join(import.meta.dir, "generate_review.ts");
const TEMPLATE_MD = path.join(import.meta.dir, "..", "references", "template.md");
const TMP_DIR = `/tmp/dev-rfc-test-${Date.now()}`;

// Track servers to clean up
const servers: Array<{ port: number; proc: ReturnType<typeof Bun.spawn> }> = [];

function startServer(
  args: string[],
  port: number,
): ReturnType<typeof Bun.spawn> {
  const proc = Bun.spawn(
    ["bun", "run", SCRIPT, "--no-open", "--port", String(port), ...args],
    { stdout: "pipe", stderr: "pipe" },
  );
  servers.push({ port, proc });
  return proc;
}

async function waitForServer(port: number, timeoutMs = 5000): Promise<void> {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    try {
      const res = await fetch(`http://localhost:${port}/`);
      if (res.ok) return;
    } catch {
      // Not ready yet
    }
    await Bun.sleep(100);
  }
  throw new Error(`Server on port ${port} did not start within ${timeoutMs}ms`);
}

afterAll(() => {
  for (const { proc } of servers) {
    try {
      proc.kill();
    } catch {}
  }
  // Clean up temp dir
  try {
    fs.rmSync(TMP_DIR, { recursive: true, force: true });
  } catch {}
});

// ---------------------------------------------------------------------------
// Static mode tests
// ---------------------------------------------------------------------------

describe("static mode", () => {
  test("generates HTML file", () => {
    const outPath = path.join(TMP_DIR, "static-test.html");
    fs.mkdirSync(TMP_DIR, { recursive: true });
    execSync(
      `bun run ${SCRIPT} ${TEMPLATE_MD} --title "Static Test" --static --no-open --output ${outPath}`,
    );
    expect(fs.existsSync(outPath)).toBe(true);
    const html = fs.readFileSync(outPath, "utf-8");
    expect(html).toContain("Static Test");
    expect(html).not.toContain("__SERVER_MODE__"); // Should be replaced with false
  });

  test("embeds markdown content", () => {
    const outPath = path.join(TMP_DIR, "static-embed.html");
    execSync(
      `bun run ${SCRIPT} ${TEMPLATE_MD} --title "Embed Test" --static --no-open --output ${outPath}`,
    );
    const html = fs.readFileSync(outPath, "utf-8");
    // Template.md contains "RFC" text which should be embedded
    expect(html).toContain("RFC");
  });
});

// ---------------------------------------------------------------------------
// Batch server mode tests
// ---------------------------------------------------------------------------

describe("batch server mode", () => {
  const PORT = 13200;
  const workspace = path.join(TMP_DIR, "batch-workspace");

  test("serves index and feedback API", async () => {
    fs.mkdirSync(workspace, { recursive: true });
    startServer(
      [TEMPLATE_MD, "--title", "Batch Test", "--workspace", workspace],
      PORT,
    );
    await waitForServer(PORT);

    // GET /
    const indexRes = await fetch(`http://localhost:${PORT}/`);
    expect(indexRes.status).toBe(200);
    const html = await indexRes.text();
    expect(html).toContain("Batch Test");

    // GET /api/feedback (empty initially)
    const fbRes = await fetch(`http://localhost:${PORT}/api/feedback`);
    expect(fbRes.status).toBe(200);
    const fbData = await fbRes.text();
    expect(fbData).toBe("{}");

    // POST /api/feedback
    const postRes = await fetch(`http://localhost:${PORT}/api/feedback`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        status: "draft",
        sections: [{ heading: "Test", feedback: "Good" }],
      }),
    });
    expect(postRes.status).toBe(200);
    const postData = await postRes.json();
    expect(postData).toEqual({ ok: true });

    // Verify feedback persisted
    const saved = JSON.parse(
      fs.readFileSync(path.join(workspace, "feedback.json"), "utf-8"),
    );
    expect(saved.status).toBe("draft");
    expect(saved.sections[0].heading).toBe("Test");
  });

  test("returns 404 for unknown paths", async () => {
    await waitForServer(PORT);
    const res = await fetch(`http://localhost:${PORT}/nonexistent`);
    expect(res.status).toBe(404);
  });

  test("serves assets", async () => {
    await waitForServer(PORT);
    const res = await fetch(`http://localhost:${PORT}/assets/marked.min.js`);
    expect(res.status).toBe(200);
    expect(res.headers.get("Content-Type")).toBe("application/javascript");
  });

  test("blocks path traversal in assets", async () => {
    await waitForServer(PORT);
    // URL with .. gets normalized by fetch, so we test with encoded path
    const res = await fetch(
      `http://localhost:${PORT}/assets/..%2Fscripts%2Fgenerate_review.ts`,
    );
    // Server should reject — either 403 (traversal detected) or 404 (file not found after sanitization)
    expect([403, 404]).toContain(res.status);
  });
});

// ---------------------------------------------------------------------------
// Live server mode tests
// ---------------------------------------------------------------------------

describe("live server mode", () => {
  const PORT = 13201;
  const workspace = path.join(TMP_DIR, "live-workspace");

  test("initializes with planned sections", async () => {
    fs.mkdirSync(workspace, { recursive: true });
    startServer(
      [
        "--live",
        "--title",
        "Live Test",
        "--workspace",
        workspace,
        "--sections",
        '["Abstract","Motivation","Design"]',
      ],
      PORT,
    );
    await waitForServer(PORT);

    const res = await fetch(`http://localhost:${PORT}/api/session`);
    expect(res.status).toBe(200);
    const session = (await res.json()) as Record<string, unknown>;
    expect(session.mode).toBe("live");
    expect(session.title).toBe("Live Test");
    expect(session.sections_plan).toEqual([
      "Abstract",
      "Motivation",
      "Design",
    ]);
  });

  test("section add → feedback → wait cycle", async () => {
    await waitForServer(PORT);

    // Add a section
    const addRes = await fetch(`http://localhost:${PORT}/api/section/add`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        id: "abstract",
        heading: "Abstract",
        markdown: "## Abstract\n\nThis is the abstract.",
      }),
    });
    expect(addRes.status).toBe(200);
    const addData = (await addRes.json()) as Record<string, unknown>;
    expect(addData.section).toBe("abstract");

    // Submit approve feedback
    const fbRes = await fetch(
      `http://localhost:${PORT}/api/section/feedback`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          section: "abstract",
          action: "approve",
          text: "LGTM",
        }),
      },
    );
    expect(fbRes.status).toBe(200);

    // Wait for feedback should return immediately
    const waitRes = await fetch(
      `http://localhost:${PORT}/api/wait-feedback?section=abstract`,
    );
    expect(waitRes.status).toBe(200);
    const waitData = (await waitRes.json()) as Record<string, unknown>;
    expect(waitData.action).toBe("approve");
    expect(waitData.text).toBe("LGTM");
  });

  test("section update resets feedback", async () => {
    await waitForServer(PORT);

    // First add and approve
    await fetch(`http://localhost:${PORT}/api/section/add`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        id: "motivation",
        heading: "Motivation",
        markdown: "## Motivation\n\nV1",
      }),
    });
    await fetch(`http://localhost:${PORT}/api/section/feedback`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        section: "motivation",
        action: "request_changes",
        text: "Needs work",
      }),
    });

    // Update the section — should reset to review
    const updateRes = await fetch(
      `http://localhost:${PORT}/api/section/update`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          id: "motivation",
          markdown: "## Motivation\n\nV2 updated",
        }),
      },
    );
    expect(updateRes.status).toBe(200);

    // Check state — section should be in review with no feedback
    const sessionRes = await fetch(`http://localhost:${PORT}/api/session`);
    const session = (await sessionRes.json()) as Record<string, unknown>;
    const sections = session.sections as Record<
      string,
      { status: string; feedback: unknown; history: unknown[] }
    >;
    expect(sections.motivation.status).toBe("review");
    expect(sections.motivation.feedback).toBeNull();
    expect(sections.motivation.history.length).toBeGreaterThan(0);
  });

  test("wait-feedback returns error for unknown section", async () => {
    await waitForServer(PORT);
    const res = await fetch(
      `http://localhost:${PORT}/api/wait-feedback?section=nonexistent`,
    );
    expect(res.status).toBe(200);
    const data = (await res.json()) as Record<string, unknown>;
    expect(data.error).toBe("unknown section");
  });

  test("saves session.json to workspace", async () => {
    await waitForServer(PORT);
    const sessionPath = path.join(workspace, "session.json");
    expect(fs.existsSync(sessionPath)).toBe(true);
    const session = JSON.parse(fs.readFileSync(sessionPath, "utf-8"));
    expect(session.mode).toBe("live");
    expect(session.title).toBe("Live Test");
  });
});

// ---------------------------------------------------------------------------
// Feedback archiving test
// ---------------------------------------------------------------------------

describe("feedback archiving", () => {
  const PORT = 13202;
  const workspace = path.join(TMP_DIR, "archive-workspace");

  test("archives previous feedback on iteration > 1", async () => {
    fs.mkdirSync(path.join(workspace, "feedback-history"), { recursive: true });

    // Create a fake feedback.json from round 1
    const feedbackPath = path.join(workspace, "feedback.json");
    fs.writeFileSync(
      feedbackPath,
      JSON.stringify({ iteration: 1, status: "needs_revision" }),
    );

    startServer(
      [
        TEMPLATE_MD,
        "--title",
        "Archive Test",
        "--workspace",
        workspace,
        "--iteration",
        "2",
      ],
      PORT,
    );
    await waitForServer(PORT);

    // Check that round 1 feedback was archived
    const archivePath = path.join(
      workspace,
      "feedback-history",
      "feedback-round-1.json",
    );
    expect(fs.existsSync(archivePath)).toBe(true);
    const archived = JSON.parse(fs.readFileSync(archivePath, "utf-8"));
    expect(archived.iteration).toBe(1);
  });
});
