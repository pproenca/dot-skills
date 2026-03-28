# findings.json Schema

The structured output format that connects the threat-model → threat-patch pipeline. This is the source of truth; THREAT-MODEL.md is a human-readable view generated from it.

## Why Machine-Readable Output

A Markdown threat model gets read once and filed. A structured findings file:
- Feeds directly into `threat-patch` for automated remediation
- Tracks state across runs (open → patched → verified → closed)
- Enables incremental analysis (diff mode updates the same file)
- Calibrates future runs against historical severity ratings

## Schema (v1)

```json
{
  "schema_version": "1.0",
  "metadata": {
    "project": "project-name",
    "analyzed_at": "2026-03-28T12:00:00Z",
    "git_ref": "abc123def456",
    "scope": "full | diff:HEAD~10..HEAD",
    "tool_version": "threat-model 0.2.0"
  },
  "findings": [
    {
      "id": "TM-001",
      "title": "Short descriptive title",
      "severity": "critical | high | medium | low",
      "category": "CATEGORY_TAG",
      "status": "open | patched | verified | closed | wont_fix",
      "description": "1-3 sentence explanation of the vulnerability",
      "trace": {
        "entry": {
          "file": "path/to/file.swift",
          "line": 19,
          "type": "cli_arg | http_param | file_content | env_var | ipc | deserialization",
          "variable": "pid"
        },
        "steps": [
          {
            "file": "path/to/file.swift",
            "line": 37,
            "function": "functionName",
            "operation": "pass-through | transform | partial-validation",
            "detail": "What happens at this step"
          }
        ],
        "sink": {
          "file": "path/to/file.swift",
          "line": 42,
          "operation": "file_write | exec | allocation | html_render | sql_query | network_request",
          "impact": "What the attacker achieves"
        }
      },
      "mitigations": ["Existing control 1", "Existing control 2"],
      "attacker_story": "Concrete exploitation scenario",
      "recommended_fix": "What to do about it",
      "relevant_paths": ["path/to/affected/file1.swift", "path/to/affected/file2.swift"],
      "systemic_parent": "SYS-001 or null",
      "chain_memberships": ["CHAIN-001"],
      "detected_at": "2026-03-28T12:00:00Z",
      "resolved_at": null,
      "resolved_by": null
    }
  ],
  "systemic": [
    {
      "id": "SYS-001",
      "title": "Root cause description",
      "severity": "high",
      "category": "CATEGORY_TAG",
      "instance_count": 8,
      "root_cause": "What abstraction, policy, or helper is missing",
      "recommended_fix": "Single change that resolves all instances",
      "finding_ids": ["TM-001", "TM-003", "TM-005"],
      "affected_files": ["file1.swift", "file2.swift"]
    }
  ],
  "chains": [
    {
      "id": "CHAIN-001",
      "title": "Descriptive chain name",
      "severity": "critical",
      "steps": [
        {
          "finding_id": "TM-001",
          "provides": "What this step gives the attacker",
          "requires": "What preconditions this step needs"
        },
        {
          "finding_id": "TM-003",
          "provides": "What the chain ultimately achieves",
          "requires": "What it uses from the previous step"
        }
      ],
      "terminal_impact": "The final outcome of the full chain",
      "preconditions": "What must be true for the chain to work",
      "chain_breaking_fix": "Which single finding to fix to break this chain"
    }
  ]
}
```

## Field Reference

### Finding Categories

Use consistent tags for clustering:

| Category | Pattern |
|----------|---------|
| `PATH_TRAVERSAL` | Unsanitized input in path construction |
| `PREDICTABLE_TMP` | Fixed paths under /tmp without unique naming |
| `SYMLINK_RACE` | File ops at predictable paths without link checks |
| `XSS_NO_SANITIZE` | Untrusted data in HTML without escaping |
| `INJECTION` | Input interpolated into commands/queries/expressions |
| `UNBOUNDED_ALLOC` | Allocation sized by untrusted value without cap |
| `LIFETIME_RACE` | Resource used after owning scope ends |
| `MISSING_AUTH` | Mutation endpoint without authentication |
| `INFO_DISCLOSURE` | Internal data exposed without access control |
| `PROMPT_INJECTION` | Untrusted content injected into LLM context |
| `SUPPLY_CHAIN` | Unpinned dependency or unverified asset |
| `DEFAULT_CREDS` | Hardcoded passwords or API keys |

### Finding Status Lifecycle

```
open → patched (fix applied, not verified)
     → verified (fix confirmed by re-analysis)
     → closed (verified + merged)
     → wont_fix (accepted risk, documented reason)
```

Status transitions happen when:
- `threat-patch` applies a fix → status moves to `patched`, `resolved_by` set to commit hash
- `threat-model --diff` re-analyzes and confirms the fix → status moves to `verified`
- Manual review closes the finding → status moves to `closed` or `wont_fix`

### Trace Entry Types

| Type | When to Use |
|------|------------|
| `cli_arg` | CLI argument or flag value |
| `http_param` | HTTP request parameter, header, cookie, body field |
| `file_content` | Data read from a file (including config, JSON, CSV) |
| `env_var` | Environment variable value |
| `ipc` | Inter-process communication (Redis, sockets, notifications) |
| `deserialization` | Parsed data (JSON, YAML, protobuf, pickle) |

### Sink Operations

| Operation | Impact Class |
|-----------|-------------|
| `file_write` | File overwrite, creation, deletion |
| `exec` | Command execution, process spawning, LLDB expressions |
| `allocation` | Memory allocation sized by untrusted value |
| `html_render` | DOM injection, innerHTML, template rendering |
| `sql_query` | Database query with untrusted input |
| `network_request` | Outbound HTTP/network request (SSRF surface) |
| `llm_context` | Data injected into LLM prompt/context (prompt injection) |

## Compatibility with Codex CSV

The findings.json format is a superset of the Codex CSV format. The `threat-patch` skill can consume either:

| Codex CSV Field | findings.json Equivalent |
|----------------|------------------------|
| `title` | `finding.title` |
| `description` | `finding.description` |
| `severity` | `finding.severity` |
| `relevant_paths` | `finding.relevant_paths` |
| `commit_hash` | `metadata.git_ref` |
| `status` | `finding.status` |
| (not in CSV) | `finding.trace` — data flow evidence |
| (not in CSV) | `finding.systemic_parent` — root cause link |
| (not in CSV) | `finding.chain_memberships` — exploit chain links |
| (not in CSV) | `systemic[]` — clustered root causes |
| (not in CSV) | `chains[]` — multi-step attack paths |

The additional fields are what make threat-model output richer than a scanner's CSV — they encode analytical work (traces, clusters, chains) that a scanner doesn't perform.
