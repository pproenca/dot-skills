---
title: Prevent Command Injection from User Input
impact: CRITICAL
impactDescription: prevents arbitrary code execution
tags: safety, injection, security, input-validation
---

## Prevent Command Injection from User Input

User input passed to shell commands without validation enables arbitrary code execution. Attackers can inject shell metacharacters like `;`, `|`, `$()`, or backticks to run malicious commands.

**Incorrect (direct user input in command):**

```bash
#!/bin/bash
# User provides filename
filename="$1"

# DANGEROUS: User could pass "; rm -rf /" as filename
cat $filename
grep "pattern" $filename
```

**Correct (validate and quote input):**

```bash
#!/bin/bash
filename="$1"

# Validate input against whitelist pattern
if [[ ! "$filename" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  echo "Error: Invalid filename" >&2
  exit 1
fi

# Always quote variables
cat -- "$filename"
grep "pattern" -- "$filename"
```

**Alternative (use printf %q for dynamic commands):**

```bash
#!/bin/bash
# When you must build commands dynamically
user_arg="$1"
safe_arg=$(printf '%q' "$user_arg")

# Still prefer arrays over eval
declare -a cmd=(grep -r "$user_arg" .)
"${cmd[@]}"
```

**Key protections:**
- Validate input with whitelist regex
- Always quote variables: `"$var"` not `$var`
- Use `--` to end option parsing
- Prefer arrays over string concatenation for commands
- Never use `eval` with user data

Reference: [Apple Shell Script Security](https://developer.apple.com/library/archive/documentation/OpenSource/Conceptual/ShellScripting/ShellScriptSecurity/ShellScriptSecurity.html)
