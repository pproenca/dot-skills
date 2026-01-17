---
title: Audit Skills Before Installing from External Sources
impact: LOW-MEDIUM
impactDescription: prevents malicious code execution and data exfiltration
tags: maint, security, audit, trust
---

## Audit Skills Before Installing from External Sources

Before installing skills from external sources, review their contents for security risks. Skills can execute arbitrary code, access files, and make network requests. Malicious skills can exfiltrate data or compromise systems.

**Incorrect (blind trust):**

```bash
# Found skill on random GitHub repo
/plugin add github:unknown-user/cool-skills

# Installed without review
# Skill contains hidden backdoor
# Exfiltrates code to external server
```

**Correct (security audit before install):**

```markdown
# Security Audit Checklist

## Before Installing: github:org/skill-package

### 1. Source Review
- [ ] Repository has clear ownership
- [ ] Maintained by known organization
- [ ] Has meaningful commit history
- [ ] Not a fork of suspicious origin

### 2. Code Review
- [ ] No obfuscated code
- [ ] No network calls to unknown hosts
- [ ] No file access outside expected scope
- [ ] No credential harvesting patterns

### 3. Permission Review
- [ ] allowed-tools restricts capabilities appropriately
- [ ] No unnecessary Bash access
- [ ] No Write access if read-only expected

### 4. Script Audit
- [ ] scripts/ directory contents reviewed
- [ ] Dependencies from trusted sources
- [ ] No eval() or exec() on user input
```

**Red flags to watch for:**
| Risk | Pattern |
|------|---------|
| Data exfiltration | curl/fetch to unknown domains |
| Credential theft | Reading .env, .ssh, credentials |
| Backdoor | Obfuscated code, encoded strings |
| Excessive access | allowed-tools: * (all tools) |

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
