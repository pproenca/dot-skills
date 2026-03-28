# Transcript: Security Analysis of dev-rfc Review UI

**Run:** without_skill / run-1
**Date:** 2026-03-28
**Model:** Claude Opus 4.6 (1M context)

---

## Understanding

The task was to perform a security analysis (threat model) of the `skills/.experimental/dev-rfc/` skill, focusing on the review UI that renders user-submitted RFC markdown in the browser. The constraint was to use only default knowledge (no threat-model skill).

The skill is a browser-based RFC review system with:
- A server (`generate_review.ts` / `generate_review.py`) that serves an HTML review page
- A client-side SPA (`review_template.html`) that renders markdown via `marked.js` and supports inline commenting
- Three modes: batch server, live server (SSE), and static HTML
- Feedback auto-save to JSON files on disk

---

## Steps Taken

### 1. Discovery and enumeration

- **Tool:** Bash `ls`, Glob -- Listed the `dev-rfc/` directory structure to identify all components
- **Findings:** 5 key areas: `SKILL.md` (skill definition), `assets/` (HTML template + vendored JS), `scripts/` (server code + tests), `references/` (RFC templates), `package.json`

### 2. Read SKILL.md

- **Tool:** Read
- **Findings:** Understood the full skill workflow -- agent generates RFC, opens review UI on localhost:3118, user reviews in browser, feedback saved to JSON, agent reads feedback for revision. Identified server mode, static mode, and live authoring mode. Noted the skill instructs the agent to read feedback.json via `cat`.

### 3. Read server code (generate_review.ts)

- **Tool:** Read (full file, 876 lines)
- **Findings:**
  - `killPort()` function uses `lsof`/`fuser` to kill processes on port 3118
  - `buildHtml()` does template placeholder replacement with minimal escaping (only `"` -> `&quot;` for title)
  - `__MARKDOWN_CONTENT__` is JSON-serialized before injection (safe at injection point)
  - Server binds to `127.0.0.1` with no authentication, CORS, or CSRF protection
  - `/api/feedback` POST writes arbitrary JSON to disk
  - Live mode API endpoints (`/api/section/add`, `/api/section/update`, `/api/section/feedback`) are all unauthenticated
  - Asset serving has path traversal check (blocks `/`, `\`, `..`)

### 4. Read server code (generate_review.py)

- **Tool:** Read (full file, 643 lines)
- **Findings:** Python implementation mirrors the TS version. Same security properties. Uses `ThreadingHTTPServer`. Same `killPort()` pattern. Same minimal title escaping.

### 5. Read review_template.html (client-side SPA)

- **Tool:** Read (multiple offset/limit passes, ~1824 lines total)
- **Findings:** This was the most critical file for security analysis.
  - Line 917: `tmp.innerHTML = html` where `html = marked.parse(stripFrontmatter(MARKDOWN_CONTENT))` -- **XSS vector**. `marked.parse()` output is raw HTML inserted via innerHTML with no sanitization.
  - Line 998: `${sec.html}` in template literal -- unescaped marked output
  - Line 1510: Live mode skeleton uses `${rendered}` (from `marked.parse()`) in innerHTML
  - Line 1700: SSE update path: `marked.parse()` -> innerHTML
  - `escapeHtml()` function exists and is used for feedback text, previous comments, headings in live mode -- but NOT for the main markdown content
  - CDN loads: `marked@15` (major range), `mermaid@11` (major range), `shiki@3` via esm.sh -- no SRI hashes
  - Local fallbacks for marked and mermaid but not shiki
  - `mermaid.initialize()` does not set `securityLevel`
  - No CSP header set by the server

### 6. Checked template injection points

- **Tool:** Grep for all `__*__` placeholders
- **Findings:** 6 placeholders. `__DOC_TITLE__` appears in two HTML contexts (title tag and span) with only `"` escaping. `__MARKDOWN_CONTENT__` is JSON-serialized (safe at injection point but becomes XSS when parsed by marked).

### 7. Read package.json and test file

- **Tool:** Read
- **Findings:** Dependency on `open@10`. Tests use Bun test runner. No security-related dependencies (no sanitizer library).

---

## Issues Encountered

- The HTML template file exceeded the 10,000 token read limit, requiring multiple offset/limit reads to cover the full file. Four read passes were needed.
- No issues with tool execution.

---

## Output Produced

**File:** `outputs/THREAT-MODEL.md`

The threat model contains:
- **System overview** with component inventory, data flow description, and mode documentation
- **Trust boundary analysis** (5 boundaries identified)
- **10 threats** cataloged with severity ratings, STRIDE classification, affected code paths (with line numbers), attack vectors, impact assessment, and mitigation recommendations
- **Summary matrix** with severity, likelihood, and impact ratings
- **Prioritized recommendations** organized into immediate, short-term, and long-term categories

### Key findings:

1. **THREAT-01 (HIGH):** The most significant finding -- `marked.parse()` output is injected via `innerHTML` with zero sanitization across all rendering paths (batch, live, SSE updates). Any HTML in the markdown executes in the browser.

2. **THREAT-02 (MEDIUM):** The `__DOC_TITLE__` placeholder only escapes `"` characters, allowing `<script>` injection via the title parameter.

3. **THREAT-03 (MEDIUM):** The localhost API has no authentication or CSRF protection, allowing any process or web page on the machine to manipulate feedback, inject sections, or approve/reject content.

4. **THREAT-10 (MEDIUM):** Feedback poisoning combined with prompt injection -- an attacker who can write to feedback.json can manipulate the agent's behavior in subsequent revision rounds.

The single highest-impact fix is adding HTML sanitization (e.g., DOMPurify) after `marked.parse()`, which would close the primary XSS vector and is referenced as recommendation #1.
