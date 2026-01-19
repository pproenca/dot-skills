---
title: Review Third-Party Codemods Before Running
impact: LOW-MEDIUM
impactDescription: prevents malicious code execution from untrusted sources
tags: security, review, third-party, trust
---

## Review Third-Party Codemods Before Running

Inspect third-party codemod source code before running. Codemods with capabilities can execute arbitrary operations on your system.

**Incorrect (running without review):**

```bash
# Running random codemod from registry
npx codemod @unknown-author/mysterious-migration
# What does it do? What permissions does it have?
# Could be mining crypto, stealing credentials, etc.
```

**Correct (review first):**

```bash
# 1. Search and inspect metadata
npx codemod search "react upgrade"
# Review: author, downloads, last update, capabilities

# 2. Check requested capabilities
cat node_modules/@org/codemod/codemod.yaml
# capabilities:
#   - fs          # Why does it need filesystem?
#   - fetch       # Why network access?
#   - child_process  # RED FLAG - why shell access?

# 3. Read the source code
cat node_modules/@org/codemod/scripts/transform.ts
# Look for suspicious:
# - eval(), Function()
# - fetch() to unknown URLs
# - execSync() with dynamic input
# - fs.writeFile() outside project

# 4. Run only after review
npx codemod @trusted-org/reviewed-migration
```

**Warning signs in codemods:**
- Requests `child_process` capability
- Fetches from non-official URLs
- Writes files outside project directory
- Obfuscated or minified source
- No test suite or documentation

**Trusted sources:**
- Official framework maintainers
- Well-known organizations
- Codemods with visible source and tests
- High download counts and recent updates

Reference: [JSSG Security](https://docs.codemod.com/jssg/security)
