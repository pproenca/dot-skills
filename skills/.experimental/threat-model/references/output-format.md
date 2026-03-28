# Output Format

The threat model document follows a four-section structure. Use the templates below, replacing placeholders with analysis results.

## Document Structure

```
## 1. Overview
## 2. Threat model, Trust boundaries and assumptions
## 3. Attack surface, mitigations and attacker stories
## 4. Systemic findings (root cause clusters)
## 5. Exploit chains (multi-step attack paths)
## 6. Criticality calibration
```

---

## Section 1: Overview

A concise description of the system. Cover: what it does, key components, runtime architecture, deployment model, and primary security goals.

**Template**:

```markdown
## 1. Overview
{project-name} is a {type: CLI/web service/mobile app/library} for {purpose}. It {key capabilities, 2-3 sentences covering architecture and major components}. {Describe the layers/modules and their roles}. Low-level {operations/access} is implemented through {specific mechanisms}. Output is {what the system produces and where}.

The tool/service runs {deployment context: locally/in cloud/on device}, {network posture: without network endpoints/with public endpoints/behind a VPN}, and is typically invoked by {who uses it}. The primary security goals are: {goal 1}, {goal 2}, and {goal 3}.
```

**Guidelines**:
- Name specific source directories, modules, and frameworks
- State the deployment model explicitly (local, networked, multi-tenant)
- End with 2-3 concrete security goals that frame the rest of the analysis

---

## Section 2: Threat Model, Trust Boundaries and Assumptions

Three subsections: assets, trust boundaries, and assumptions.

**Template**:

```markdown
## 2. Threat model, Trust boundaries and assumptions
### Assets / security goals
- {Asset 1} ({specific examples}).
- {Asset 2} ({specific examples}).
- {Asset 3} ({specific examples}).
- {Asset 4} ({specific examples}).

### Trust boundaries & input classes
**Attacker-controlled inputs**
- {Input class 1}: {specific examples with parenthetical detail about where they enter the system}.
- {Input class 2}: {specific examples}.
- {Input class 3}: {specific examples}.

**Operator-controlled inputs**
- {Input class 1}: {specific config files, env vars, paths}.
- {Input class 2}: {specific examples}.

**Developer-controlled inputs**
- {Input class 1}: {packaged assets, scripts, templates}.
- {Input class 2}: {build and test paths}.

### Assumptions & scope
- {Assumption 1 about deployment context and its security implication}.
- {Assumption 2 about what is/isn't in scope}.
- {Assumption 3 about trust relationships}.
- {Explicit scope boundary: what web/network/multi-tenant threats are out of scope and why}.
```

**Guidelines**:
- Assets should be concrete, not abstract. "Host macOS integrity and user files" not "system security"
- Trust boundary entries should name specific code locations where the input enters
- Assumptions should state security implications, not just facts

---

## Section 3: Attack Surface, Mitigations and Attacker Stories

One subsection per attack surface area. Number subsections (3.1, 3.2, etc.). Group by component/functional area.

**Template for each subsection**:

```markdown
### 3.N {Component/Area Name} ({key files or modules})
**Surface:** {What code area and what inputs are involved. Name specific files, functions, or modules.}

**Risks:**
- {Risk 1: Specific vulnerability pattern with concrete detail about what goes wrong and why}.
- {Risk 2: Another risk with specific code-level detail}.

**Mitigations/controls:**
- {Existing mitigation 1: What the code already does to prevent this}.
- {Existing mitigation 2: Incidental or intentional protection}.
- {Gap or suggestion if applicable}.

**Attacker story:** {A concrete scenario: "[Actor] [does action] which causes [impact] because [code behavior]." Include preconditions (e.g., "when the tool is invoked by untrusted automation") and scope qualifiers (e.g., "in typical local usage, severity is lower").}
```

**Guidelines**:
- Name specific source files in the subsection heading parenthetical
- Risks should describe the mechanism, not just the category. Not "path traversal is possible" but "bundleID is interpolated into `/tmp/agent-sim-extract/\(bundleID)` without sanitization"
- Mitigations include what IS there, not just what's missing
- Attacker stories must have realistic preconditions — don't assume the attacker has root if the threat model is for a local CLI
- Include an "Out-of-scope / not applicable" subsection at the end listing inapplicable threat classes

**Out-of-scope template**:

```markdown
### Out-of-scope / not applicable
- {Threat class 1} {are not applicable because reason}.
- {Threat class 2} {is not a goal; if condition changes, these concerns become in scope}.
```

---

## Section 4: Systemic Findings

Present when pattern clustering (Phase 7) identifies 3+ findings sharing a root cause. If no systemic patterns are found, omit this section.

**Template**:

```markdown
## 4. Systemic findings

### 4.1 {Root cause description}

**Pattern:** {vulnerability class} — {count} instances
**Root cause:** {what's missing — the abstraction, policy, or helper that would prevent all instances}
**Affected files:** {list of files with instances}
**Individual findings:** {references to Section 3 subsections}
**Recommended fix:** {single change that resolves all instances}
**Systemic severity:** {severity with justification: individual severity × count × centralizability}

### 4.2 {Another root cause}
...
```

**Guidelines**:
- Only include clusters with 3+ instances — 2 findings is coincidence, not a pattern
- The recommended fix should be a single abstraction or policy, not N individual patches
- Reference the individual findings in Section 3 by their subsection numbers
- Rate systemic severity higher than any individual instance — systemic findings fix more with one change

---

## Section 5: Exploit Chains

Present when chain construction (Phase 8) identifies multi-step attack paths. If no chains are found, omit this section.

**Template**:

```markdown
## 5. Exploit chains

### Chain 1: {descriptive name}
**Path:**
1. [{Finding title}] ({individual severity}) — Attacker {action}. Gains: {what this provides}.
2. [{Finding title}] ({individual severity}) — Uses {output from step 1}. Gains: {what this provides}.
3. **Terminal impact:** {concrete outcome}

**Chain severity:** {rated by terminal impact, not weakest link}
**Preconditions:** {what must be true for the full chain}
**Chain-breaking fix:** {which single finding to fix to break this chain, and why}
```

**Guidelines**:
- Maximum 4 steps per chain — longer chains are theoretical, not practical
- Each step must reference an actual finding from Section 3
- Rate by terminal impact: a chain of mediums reaching critical impact is critical
- Identify the single fix that breaks the chain — this guides remediation priority
- Include preconditions — some chains require specific deployment contexts

---

## Section 6: Criticality Calibration

Group findings by severity level. Each bullet describes a specific risk with enough context to understand what it is without reading the full attack surface section.

**Template**:

```markdown
## 6. Criticality calibration (critical, high, medium, low)

### Exploit chains
- {Chain name}: {Step 1} → {Step 2} → {terminal impact} [{chain severity}]

### Systemic findings
- {Root cause}: {count} instances, recommended fix: {single change} [{systemic severity}]

### Individual findings
**Critical**
- {Risk description with code-level specificity and data flow evidence}.

**High**
- {Risk description}. Part of systemic finding: {reference if applicable}.

**Medium**
- {Risk description}.

**Low**
- {Risk description}.
```

**Guidelines**:
- **Order**: Chains first (highest combined impact), then systemic findings, then individual findings
- Each bullet should be self-contained — a reader should understand the risk without reading other sections
- Reference specific code areas and data flow traces where available
- Individual findings that belong to a cluster should reference their systemic parent
- Include scope qualifiers: "Critical if network-exposed; medium in internal deployments"
- End with a scope note:

```markdown
**Scope note**: Findings that require {specific access condition} are {severity} only if {condition holds}. In {alternative context}, they may be downgraded to {lower severity} because {reason}.
```

---

## Formatting Conventions

- Use `##` for the four main sections, `###` for subsections
- Use `**Bold:**` for field labels within subsections (Surface, Risks, Mitigations/controls, Attacker story)
- Reference code with backticks: `` `Sources/AgentSim/Service/ExtractionReport.swift` ``
- Use parentheticals in subsection headings for file references: `### 3.1 CLI inputs (Sources/App/UI/, Sources/App/Service/)`
- Keep bullets concise — one risk per bullet, one mitigation per bullet
- Use scope qualifiers liberally: "in typical local usage", "if exposed via a service wrapper", "on shared CI machines"
