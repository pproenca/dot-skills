---
title: Use Explicit PATH for External Commands
impact: CRITICAL
impactDescription: prevents PATH hijacking attacks in privileged scripts
tags: safety, path, security, execution
---

## Use Explicit PATH for External Commands

Relying on inherited `$PATH` for command resolution allows attackers to place malicious executables earlier in the path. Scripts running with elevated privileges are especially vulnerable.

**Incorrect (relies on inherited PATH):**

```bash
#!/bin/bash
# Attacker could create ~/bin/rm that exfiltrates data first
rm -rf /var/cache/deploy
cp release.tar.gz /opt/releases/
mail -s "Deploy Complete" ops@example.com < deploy.log
```

**Correct (set a known-safe PATH at script start):**

```bash
#!/bin/bash
# Primary defense: reset PATH to known-safe directories
PATH=/usr/local/bin:/usr/bin:/bin
export PATH

# Commands now resolve from safe locations only
rm -rf /var/cache/deploy
cp release.tar.gz /opt/releases/
```

**Alternative (verify command locations dynamically):**

```bash
#!/bin/bash
# Useful when expected paths vary across platforms
# (macOS vs Linux, UsrMerge systems)
verify_command() {
  local cmd_name="$1"
  local cmd_path
  cmd_path=$(command -v "$cmd_name") || {
    echo "Error: $cmd_name not found in PATH" >&2
    return 1
  }
  case "$cmd_path" in
    /usr/local/bin/*|/usr/bin/*|/bin/*) ;;
    *) echo "Error: $cmd_name at untrusted location: $cmd_path" >&2; return 1 ;;
  esac
}

verify_command rm
verify_command cp
```

**Key practices:**
- Set `PATH` explicitly at script start — this is the primary defense
- Avoid hardcoding paths like `/bin/rm` — locations differ across platforms (`/bin` vs `/usr/bin` on macOS vs Linux, UsrMerge systems)
- Use `command -v` to verify locations when platform portability is needed
- Never trust inherited `PATH` in cron jobs or privileged scripts

Reference: [Apple Shell Script Security](https://developer.apple.com/library/archive/documentation/OpenSource/Conceptual/ShellScripting/ShellScriptSecurity/ShellScriptSecurity.html)
