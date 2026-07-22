---
name: sonarqube-ai-slop-gate
description: Corrects the wrong defaults a model has when standing up self-hosted SonarQube Server as a continuous gate on AI-generated code, verified against docs.sonarsource.com in July 2026 (Server 2026.3, LTA 2026.1). Use when configuring SonarQube, designing a quality gate, or wiring a scan step into CI for AI-assisted work. Covers the setups that run green while measuring almost nothing — the fudge factor skips duplication and coverage conditions below 20 new lines and is on by default; duplication is never measured on test code; no `new_cognitive_complexity` metric exists to gate on; `sonar.host.url` now defaults to sonarcloud.io rather than localhost; a shallow clone degrades new-code attribution to timestamps. Also covers AI Code Assurance — the project flag, gate qualification, the deprecated Copilot autodetection — and that Community Build cannot analyze pull requests at all. NOT for SonarQube Cloud, IDE connected mode, or authoring custom analyzer rules.
---

# SonarQube AI Slop Gate

The decisions self-hosted SonarQube forces when you use it to gate AI-generated code, and how to settle them. Every rule names the wrong default it corrects; there is no rule for what the model already gets right.

**Pinned to a date, not a version.** SonarQube ships a release every two months, so every claim here was verified against docs.sonarsource.com in **July 2026**, against **SonarQube Server 2026.3** (current LTA **2026.1**). 2026.4 had shipped at the time of writing but the documentation still defaulted to 2026.3, so that is what these rules describe — `plat-versions-are-calendar-based` covers the release train itself. Re-verify anything version-shaped before trusting it, and read docs from the **unversioned** path (`/latest/<page>` does not resolve); appending `.md` to any docs URL returns its markdown source.

**The failure this skill exists to prevent** is a gate that passes everything. A SonarQube setup assembled from 2024-vintage knowledge will analyze the wrong branch, upload to the wrong server, exit green on a red gate, and skip the duplication and coverage conditions entirely on the small commits that AI-assisted work produces most of. None of those failures announce themselves; the dashboard looks healthy throughout.

## When to Apply

Use this skill when:

- Standing up self-hosted SonarQube Server, or reviewing an existing instance, with the goal of catching AI-generated defects continuously rather than reporting on them after the fact
- Designing or tightening a quality gate — especially deciding what to measure on new code versus overall code, and discovering which conditions are silently not evaluated
- Wiring a scan step into CI: scanner properties, tokens, branch and pull-request parameters, coverage report import, or making the pipeline actually block a merge
- Setting up AI Code Assurance — flagging projects, qualifying a gate, or working out why a project reports "AI Code Assurance is off"
- A gate passes changes that obviously contain duplicated or untested generated code, and nobody can explain why

This skill is NOT for:

- **SonarQube Cloud** — the edition boundaries, token model, and several AI features differ; the agentic-AI gate in particular is documented for Cloud only
- IDE connected mode, SonarLint, or the SonarQube CLI's local agentic analysis
- Authoring custom analyzer rules or plugins — this covers configuring the rules that ship, not writing new ones
- General code-review judgement about whether code is good; this is about making the tool measure what you think it measures

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Edition & Version Reality | `plat-` | What your licence can do; CalVer and the LTA upgrade path; which AI features need which edition |
| 2 | AI Code Assurance | `aica-` | The project flag, gate qualification, deprecated autodetection, the agentic profile |
| 3 | What the Gate Doesn't Measure | `blind-` | Suppression comments, fudge factor, test-code exemption, missing metrics, PR blind spots |
| 4 | New Code & Blame | `newcode-` | Full-clone requirement; choosing a definition that matches the branching model |
| 5 | Scanner Configuration | `scan-` | The properties whose defaults fail open — host URL, gate wait, test scope, coverage, exclusions |
| 6 | Running the Server | `ops-` | Kernel limits before first boot; database and volumes that survive an upgrade |

## Quick Reference

### 1. Edition & Version Reality

- [`plat-community-build-cannot-see-pull-requests`](references/plat-community-build-cannot-see-pull-requests.md) — **Settle this first.** Community Build is main-branch-only; a PR gate needs Developer Edition
- [`plat-versions-are-calendar-based`](references/plat-versions-are-calendar-based.md) — `YYYY.N.P`, not 10.x; upgrades cannot skip an intermediate LTA
- [`plat-ai-features-are-edition-gated`](references/plat-ai-features-are-edition-gated.md) — AI Code Assurance is Developer; AI CodeFix is Enterprise; Advanced Security is a separate SKU

### 2. AI Code Assurance

- [`aica-flag-projects-through-the-api`](references/aica-flag-projects-through-the-api.md) — No `sonar.*` property exists; it is server state set via UI or `set_contains_ai_code`
- [`aica-qualify-the-gate-explicitly`](references/aica-qualify-the-gate-explicitly.md) — Strict conditions grant nothing; plain "Sonar way" is not qualified, and 10.7 upgrades drop assurance
- [`aica-do-not-rely-on-autodetection`](references/aica-do-not-rely-on-autodetection.md) — Copilot-only and deprecated in 2026.1; label deliberately instead
- [`aica-the-builtin-ai-gate-is-lenient`](references/aica-the-builtin-ai-gate-is-lenient.md) — Seven conditions, Reliability rating **C**, and no overall-code coverage floor
- [`aica-use-the-agentic-profile`](references/aica-use-the-agentic-profile.md) — 2026.3's "Sonar agentic AI" profile for Java, JS/TS, Python; Sonar way elsewhere

### 3. What the Gate Doesn't Measure

- [`blind-suppression-comments-turn-the-gate-green`](references/blind-suppression-comments-turn-the-gate-green.md) — **The adversarial one.** `NOSONAR` deletes the issue, and the rules that track it ship inactive
- [`blind-fudge-factor-skips-small-changes`](references/blind-fudge-factor-skips-small-changes.md) — **The costliest accidental default.** Duplication and coverage conditions skipped below 20 new lines, on by default
- [`blind-test-code-escapes-duplication`](references/blind-test-code-escapes-duplication.md) — Duplication is not measured on test code at all — where generated copy-paste concentrates
- [`blind-no-new-code-complexity-metric`](references/blind-no-new-code-complexity-metric.md) — `new_cognitive_complexity` does not exist; gate through rule `S3776` into `new_violations`
- [`blind-java-duplication-threshold-is-fixed`](references/blind-java-duplication-threshold-is-fixed.md) — `sonar.cpd.java.minimumTokens` is a no-op; IaC and CSS get no duplication detection at all
- [`blind-pull-requests-hide-file-level-issues`](references/blind-pull-requests-hide-file-level-issues.md) — Overall-code conditions never run on a PR, so main can go red right after a green merge

### 4. New Code & Blame

- [`newcode-shallow-clones-break-blame`](references/newcode-shallow-clones-break-blame.md) — `fetch-depth: 0`, or new code silently falls back to analysis timestamps
- [`newcode-pick-the-definition-deliberately`](references/newcode-pick-the-definition-deliberately.md) — Reference branch for a PR gate; days capped at 90; specific analysis is API-only

### 5. Scanner Configuration

- [`scan-host-url-defaults-to-the-cloud`](references/scan-host-url-defaults-to-the-cloud.md) — Modern scanners default to `https://sonarcloud.io`, not localhost
- [`scan-use-project-analysis-tokens`](references/scan-use-project-analysis-tokens.md) — `sonar.login` is deprecated; scope CI to a project analysis token
- [`scan-wait-for-the-quality-gate`](references/scan-wait-for-the-quality-gate.md) — Defaults to `false`, so the pipeline passes on a red gate
- [`scan-declare-test-sources`](references/scan-declare-test-sources.md) — `sonar.tests` has no default; unset means tests are measured as production code
- [`scan-import-coverage-reports`](references/scan-import-coverage-reports.md) — Coverage is never computed by SonarQube; no import means the condition evaluates nothing
- [`scan-exclude-narrowly`](references/scan-exclude-narrowly.md) — `sonar.exclusions` moves the denominator of every metric; prefer `sonar.cpd.exclusions`
- [`scan-name-the-branch`](references/scan-name-the-branch.md) — Missing branch parameters publish every analysis onto main

### 6. Running the Server

- [`ops-set-host-limits-before-first-boot`](references/ops-set-host-limits-before-first-boot.md) — `vm.max_map_count=524288`, double the value older guides cite
- [`ops-persist-data-and-skip-h2`](references/ops-persist-data-and-skip-h2.md) — H2 has no upgrade path, and losing history resets every new-code baseline

## Suggested Order

Categories are listed by **importance** — a mistake in category 1 invalidates the whole plan, a mistake in category 6 fails loudly at boot. That is not the order you execute in. For a fresh setup, work through them as:

**1 → 6 → 5 → 4 → 2 → 3.** Confirm the licence can do what you need, stand up the server, configure the scanner, define what "new" means, apply the AI Code Assurance machinery, and read category 3 last — before declaring the gate finished, because it is the list of reasons a green verdict may be meaningless.

## How to Use

Read a reference file when its decision comes up. Each rule names the wrong default it corrects, then shows the canonical configuration.

- [Section definitions](references/_sections.md) — category structure and ordering rationale
- [Rule template](assets/templates/_template.md) — for adding new rules
- [AGENTS.md](AGENTS.md) — auto-built table of contents across all rules
