---
title: Use Absolute Paths for External Commands
impact: CRITICAL
impactDescription: prevents PATH hijacking attacks
tags: safety, path, security, execution
---

## Use Absolute Paths for External Commands

Relying on `$PATH` for command resolution allows attackers to place malicious executables earlier in the path. Scripts running with elevated privileges are especially vulnerable.

**Incorrect (relies on PATH):**

```bash
#!/bin/bash
# Attacker could create ~/bin/rm that steals data first
rm -rf /tmp/workdir
cp important.txt /backup/
mail -s "Report" admin@example.com < report.txt
```

**Correct (explicit paths for security-critical scripts):**

```bash
#!/bin/bash
# Set a known-safe PATH at script start
PATH=/usr/local/bin:/usr/bin:/bin
export PATH

# Or use absolute paths for critical operations
/bin/rm -rf /tmp/workdir
/bin/cp important.txt /backup/
/usr/bin/mail -s "Report" admin@example.com < report.txt
```

**Alternative (verify command location):**

```bash
#!/bin/bash
# Verify commands are from expected locations
rm_cmd=$(command -v rm)
if [[ "$rm_cmd" != "/bin/rm" ]]; then
  echo "Error: Unexpected rm location: $rm_cmd" >&2
  exit 1
fi

"$rm_cmd" -rf /tmp/workdir
```

**Best practices:**
- Set `PATH` explicitly at script start
- Use absolute paths in cron jobs and setuid contexts
- Verify command locations with `command -v`
- Never trust inherited `PATH` in security-sensitive scripts

Reference: [Apple Shell Script Security](https://developer.apple.com/library/archive/documentation/OpenSource/Conceptual/ShellScripting/ShellScriptSecurity/ShellScriptSecurity.html)
