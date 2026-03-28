# Execution Transcript: Security Analysis of dev-rfc Review UI

## Task Understanding

Perform a security analysis (threat model) of the `skills/.experimental/dev-rfc/` skill, which generates an HTML review page for RFC documents. The review template at `assets/review_template.html` renders user-submitted RFC markdown and displays it in the browser via a local HTTP server. The goal is to identify what could go wrong from a security perspective.

Output: A `THREAT-MODEL.md` file saved to the specified outputs directory.

## Steps Taken

### Step 1: Explore the Skill Structure

**Tool:** Glob, Bash (ls)

Explored the directory structure of `skills/.experimental/dev-rfc/`. Found the following key components:
- `SKILL.md` -- Skill instructions for the AI agent (276 lines)
- `assets/review_template.html` -- The client-side HTML/JS review interface (1823 lines, ~56KB)
- `assets/marked.min.js` -- Bundled markdown parser (~40KB)
- `assets/mermaid.min.js` -- Bundled diagram renderer (~3MB)
- `scripts/generate_review.ts` -- Bun-based HTTP server (875 lines)
- `scripts/generate_review.py` -- Python equivalent HTTP server (642 lines)
- `scripts/generate_review.test.ts` -- Test suite (341 lines)
- `references/template.md` -- RFC template
- `package.json` -- Dependencies: `open` (browser opener)

### Step 2: Analyze the Server-Side Code

**Tool:** Read

Read `scripts/generate_review.ts` in full (875 lines). Key findings:
- Server binds to `127.0.0.1` (localhost only) -- good.
- `buildHtml()` function uses string replacement to inject markdown content via `JSON.stringify()` into the `__MARKDOWN_CONTENT__` placeholder.
- Title injection uses only `"` -> `&quot;` replacement, missing `<`, `>`, `&`, `'`.
- `killPort()` function kills processes on the configured port before starting.
- No CORS headers are set on any response.
- No request body size limits.
- No CSRF protection on API endpoints.
- Asset serving has path traversal protection (checks for `/`, `\\`, `..` in filename).

Read `scripts/generate_review.py` in full (642 lines). Same architecture and same issues as the TypeScript version.

### Step 3: Analyze the Client-Side HTML Template

**Tool:** Read (multiple chunks due to file size)

Read `assets/review_template.html` across 7 reading operations (1823 lines total). Key findings:

**Critical finding -- no HTML sanitization:**
- Line 917: `const html = marked.parse(stripFrontmatter(MARKDOWN_CONTENT));` -- raw markdown parsed to HTML
- Line 919: `tmp.innerHTML = html;` -- unsanitized HTML inserted into DOM
- Lines 1510, 1700: Same pattern in live mode and SSE update paths
- No DOMPurify, no CSP, no `marked` sanitizer configuration

**Other findings:**
- CDN scripts loaded without Subresource Integrity hashes (marked, mermaid, shiki)
- Local fallbacks exist for marked and mermaid but not shiki
- Mermaid initialized without `securityLevel: 'strict'`
- Section IDs in live mode can bypass `slugify()` when provided directly via API
- `escapeHtml()` function exists and is used for user feedback text, heading text, and previous feedback -- but NOT for the main markdown rendering path
- Live mode `onclick` attributes interpolate section IDs without escaping

### Step 4: Analyze the Test Suite

**Tool:** Read

Read `scripts/generate_review.test.ts` (341 lines). Found:
- Tests exist for path traversal blocking in assets (good)
- Tests cover basic server functionality (batch and live modes)
- No security-specific tests for XSS, CSRF, or injection

### Step 5: Search for Specific Security Patterns

**Tool:** Grep

Searched for:
- `innerHTML|outerHTML|insertAdjacentHTML|document.write` -- found 15 instances of innerHTML usage
- `escapeHtml|sanitize|DOMPurify|xss|encode` -- confirmed escapeHtml exists but is only used for feedback/heading text, not for markdown rendering
- `CORS|Access-Control|origin|cors` -- confirmed no CORS headers anywhere
- `marked.parse` -- found 3 call sites, none with sanitization
- All template placeholders (`__MARKDOWN_CONTENT__`, `__DOC_TITLE__`, etc.) -- confirmed injection points

### Step 6: Synthesize Threat Model

**Tool:** Write

Composed the THREAT-MODEL.md document with 10 identified threats, sorted by severity:
- 1 Critical (stored XSS via markdown)
- 1 High (Mermaid diagram injection)
- 4 Medium (title injection, file write, CSRF, process killing)
- 4 Low (JSON validation, CDN integrity, section ID injection, static mode)

Included architecture overview, detailed attack vectors with specific line numbers, impact assessments, existing mitigations, and prioritized remediation recommendations.

## Tools Used

| Tool | Usage Count | Purpose |
|------|-------------|---------|
| Glob | 1 | Discover all files in the skill directory |
| Bash (ls) | 3 | List directory contents for assets, scripts, root |
| Read | 12 | Read all source files (template in 7 chunks, both server scripts, test file, SKILL.md, package.json, template.md) |
| Grep | 5 | Search for innerHTML patterns, sanitization functions, CORS headers, marked.parse calls, template placeholders |
| Write | 2 | Create THREAT-MODEL.md and this transcript |

## Issues Encountered

1. **Large HTML file:** The review template at 1823 lines exceeded the 10,000 token read limit, requiring 7 chunked reads with offset/limit parameters. Resolved by reading in ~200-300 line segments.

2. **No issues with file access or directory creation.** All paths were accessible and the output directory was created successfully.

## Output Produced

- **`outputs/THREAT-MODEL.md`** -- Complete threat model with 10 identified threats, architecture overview, risk summary table, and prioritized remediation plan. The most critical finding is the complete absence of HTML sanitization on markdown content rendered via `marked.parse()` + `innerHTML`, which enables trivial stored XSS attacks.
