# Version pins

Every version-sensitive claim in this skill, in one place. When updating the skill, check these first.

| Claim | Where stated | Last verified |
|---|---|---|
| Claude Code >=2.1.76 for elicitation | `elicitation.md:15`, `SKILL.md:43,76` | 2026-03 |
| MCP spec 2025-11-25 CIMD/DCR status | `auth.md:20,24,41` | 2026-03 |
| CF `agents` SDK / `McpAgent` API | `deploy-cloudflare-workers.md` | 2026-03 |
| CF template path `cloudflare/ai/demos/remote-mcp-authless` | `deploy-cloudflare-workers.md` | 2026-03 |

## How to verify

```bash
# CF template still exists
gh api repos/cloudflare/ai/contents/demos/remote-mcp-authless/src/index.ts --jq '.sha'
```
