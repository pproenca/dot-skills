# Threat Model Transcript: dev-rfc Review UI

**Date:** 2026-03-28
**Target:** `skills/.experimental/dev-rfc/` (review UI subsystem)
**Skill:** `skills/.experimental/threat-model/`
**Model:** claude-opus-4-6

## What I Understood

The task was to perform a full security threat model of the dev-rfc skill's review UI subsystem, following the threat-model skill's 10-phase methodology and producing a 6-section output document. The review UI renders user-submitted RFC markdown in a browser via a local HTTP server and collects structured feedback.

## Steps Taken (mapped to the 10-phase methodology)

### Phase 0: Diff Analysis
Skipped -- no git range provided; this is a full codebase analysis.

### Phase 1: Codebase Survey

**Tools used:**
- `Read` on `skills/.experimental/dev-rfc/SKILL.md`
- `Glob` on `skills/.experimental/dev-rfc/**/*` to enumerate all files
- `Read` on `package.json` to check dependencies

**Findings:**
- Two server implementations: TypeScript (Bun) and Python (stdlib http.server)
- Three modes: batch server, live server (SSE), static HTML
- Key dependencies: `marked@15` (CDN + local), `mermaid@11` (CDN + local), `shiki@3` (CDN only), `open` (npm)
- HTML template at `assets/review_template.html` (~1820 lines) is the core rendering surface

### Phase 2: Component Mapping

**Components identified:**
1. **CLI entry point** (`generate_review.ts` / `.py`) -- parses args, sets up server
2. **HTTP server** -- serves HTML, handles API endpoints, SSE for live mode
3. **HTML builder** (`buildHtml()`) -- performs template placeholder replacement
4. **Client-side renderer** (`review_template.html` JavaScript) -- `marked.parse()`, mermaid, shiki
5. **LiveSession** state manager -- tracks sections, feedback, SSE clients
6. **Filesystem layer** -- writes feedback.json, session.json, archives

**Data flows:**
- Markdown file -> `fs.readFileSync` -> `JSON.stringify` -> template placeholder -> JS variable -> `marked.parse()` -> `innerHTML`
- Live mode: `POST /api/section/add` body -> LiveSession -> SSE broadcast -> client `fillSectionContent()` -> `marked.parse()` -> `innerHTML`
- `--title` argument -> `buildHtml()` -> template placeholder (only `"` escaped) -> `<title>` and `<span>` in HTML
- Feedback: browser textarea -> `POST /api/feedback` -> `fs.writeFileSync` to workspace

### Phase 3: Asset & Security Goal Identification

Identified 4 primary assets:
1. Host integrity (server runs with user privileges)
2. Browser session integrity (XSS could exfiltrate or manipulate)
3. Feedback data integrity
4. Developer environment confidentiality (localhost services)

### Phase 4: Trust Boundaries + Entry Point Mapping

**Tools used:**
- `Grep` for `innerHTML`, `marked.parse`, `writeFileSync`, `__DOC_TITLE__`, `JSON.stringify`, `/tmp/`
- `Read` on template HTML (in 200-line segments across 8 reads)

**Entry points identified:**
- RFC markdown content (attacker-controlled): `generate_review.ts:312`, `POST /api/section/add`
- Document title (attacker-controlled via CLI): `generate_review.ts:323`
- Previous feedback JSON (operator-controlled): `generate_review.ts:695`
- CLI arguments (operator-controlled): --port, --workspace, --output

### Phase 5: Data Flow Tracing

**Tools used:**
- `Bash` to run `scripts/trace-data-flows.sh` on the dev-rfc directory (the script is at `skills/.experimental/threat-model/scripts/trace-data-flows.sh`)
- `Grep` to trace specific variables through code paths
- `Read` on specific code sections for manual tracing

**Traces completed:**

**TRACE 1: RFC markdown to innerHTML (CRITICAL PATH)**
```
Entry:  fs.readFileSync(mdPath) (generate_review.ts:312)
   |    transform: JSON.stringify(mdContent) (ts:322) -- safe for JS string context
   |    pass-through: template replacement __MARKDOWN_CONTENT__ -> MARKDOWN_CONTENT JS variable (template:880)
   |    transform: marked.parse(stripFrontmatter(MARKDOWN_CONTENT)) (template:917)
   |    NO SANITIZATION between marked.parse() and innerHTML
Sink:   tmp.innerHTML = html (template:919)
        Also: div.innerHTML with sec.html at template:999
        Operation: Rendered as HTML in the DOM
        Impact: XSS -- any raw HTML in markdown executes in browser
Validation: NONE -- marked.parse() passes through raw HTML by default
FINDING: Stored XSS via markdown content [HIGH]
```

**TRACE 2: Live mode markdown to innerHTML**
```
Entry:  POST /api/section/add body.markdown (generate_review.ts:498)
   |    pass-through: stored in LiveSession.sections[id].markdown (ts:131)
   |    pass-through: broadcast via SSE "section-added" event (ts:148)
   |    pass-through: client receives in connectSSE() handler (template:1659-1664)
   |    transform: marked.parse(stripLeadingHeading(data.markdown)) (template:1700)
   |    NO SANITIZATION
Sink:   content.innerHTML = `...${rendered}...` (template:1703)
FINDING: XSS via live mode section push [HIGH]
```

**TRACE 3: --title to HTML injection**
```
Entry:  --title CLI argument (generate_review.ts:values.title)
   |    transform: title.replace(/"/g, "&quot;") (ts:323) -- ONLY quotes escaped
   |    pass-through: template replacement __DOC_TITLE__ in two HTML contexts
Sink 1: <title>RFC Review: __DOC_TITLE__</title> (template:6)
Sink 2: <span id="doc-title">__DOC_TITLE__</span> (template:842)
        Operation: Rendered as HTML
        Impact: HTML injection; <script> tags would execute
Validation: INSUFFICIENT -- only " escaped, not < > &
FINDING: HTML injection via title [MEDIUM]
```

**TRACE 4: Static mode predictable tmp path**
```
Entry:  mdPath basename (generate_review.ts:718)
   |    transform: `/tmp/dev-rfc-review-${path.basename(mdPath, ext)}.html`
Sink:   fs.writeFileSync(outPath, html) (ts:719)
        Operation: File write to predictable /tmp path
        Impact: Symlink race -> arbitrary file overwrite
Validation: NONE -- no O_EXCL, no symlink check
FINDING: Predictable tmp file path [LOW]
```

### Phase 6: Attack Surface Enumeration

Documented 9 attack surface areas with specific files, risks, mitigations, and attacker stories. See THREAT-MODEL.md Section 3.

### Phase 7: Pattern Clustering

**Tools used:** Manual analysis of Phase 6 findings.

**Clusters identified:**
1. `XSS_NO_SANITIZE` x 4 (lines 917-919, 996-999, 1510-1511, 1700-1705) -- Root cause: no sanitization between `marked.parse()` and `innerHTML`. Single fix: DOMPurify helper.
2. Incomplete HTML escaping x 2 (TS:323, PY:249) -- Root cause: context-inappropriate escaping for `__DOC_TITLE__`. Single fix: proper HTML entity escaping function.

### Phase 8: Exploit Chain Construction

**Chains identified:**
1. **Markdown XSS -> Feedback Tampering**: XSS (medium) + No auth on API (low) -> auto-approve RFC without human review [High]
2. **Markdown XSS -> Localhost Probing**: XSS (medium) -> probe other localhost services and exfiltrate data [Medium-High]

### Phase 9: Calibration

Applied severity framework:
- Systemic finding 4.1 rated High (4 instances, highly centralizable)
- Chain 1 rated High (terminal impact: review bypass)
- Adjusted for deployment context (localhost-only, typically self-authored RFCs)

### Phase 10: Output

Wrote THREAT-MODEL.md with all 6 sections following the output format template.

## Issues Encountered

1. **`scripts/trace-data-flows.sh` not at project root**: The script is inside the threat-model skill directory, not at the project root. Found it at `skills/.experimental/threat-model/scripts/trace-data-flows.sh`.
2. **Large HTML template**: The review template at 1823 lines exceeded the 10,000-token read limit and required 8 separate `Read` calls with offset/limit to cover completely.
3. **Minified JS noise**: The `trace-data-flows.sh` output included many matches from `mermaid.min.js` (bundled library), which cluttered results. The script's `--glob=!*.min.js` exclusion was part of the EXCLUDE variable but the dev-rfc `assets/` directory contained minified JS files that matched sink patterns.

## Output Produced

- **THREAT-MODEL.md**: `skills/.experimental/threat-model-workspace/iteration-2/eval-1-dev-rfc-review-ui/with_skill/run-1/outputs/THREAT-MODEL.md`
  - 6 sections: Overview, Trust Boundaries, Attack Surfaces (9 subsections + out-of-scope), Systemic Findings (2 clusters), Exploit Chains (2 chains), Criticality Calibration
- **transcript.md**: This file.

## Key Findings Summary

| # | Finding | Severity | Type |
|---|---------|----------|------|
| 1 | `marked.parse()` -> `innerHTML` without sanitization (4 instances) | High | Systemic |
| 2 | Markdown XSS -> auto-approve feedback chain | High | Chain |
| 3 | `--title` HTML injection (incomplete escaping) | Medium | Systemic |
| 4 | No CSRF/auth on API endpoints | Medium | Individual |
| 5 | CDN scripts without SRI hashes | Medium | Individual |
| 6 | Predictable `/tmp/` path in static mode | Low | Individual |
| 7 | `killPort()` kills unrelated processes | Low | Individual |
