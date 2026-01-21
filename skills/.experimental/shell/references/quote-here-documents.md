---
title: Use Here Documents for Multi-line Strings
impact: MEDIUM-HIGH
impactDescription: avoids quoting complexity in long strings
tags: quote, heredoc, multiline, strings
---

## Use Here Documents for Multi-line Strings

Building multi-line strings with quotes and escapes is error-prone. Here documents provide clean multi-line text with clear variable expansion control.

**Incorrect (escaped multi-line strings):**

```bash
#!/bin/bash
# Messy escaping and concatenation
message="Line 1\n\
Line 2 with \"quotes\"\n\
Line 3 with \$variable"

# Hard to read SQL
query="SELECT * FROM users \
WHERE name = '$name' \
AND status = 'active' \
ORDER BY created_at"
```

**Correct (here documents):**

```bash
#!/bin/bash
# Clean multi-line text (variables expand)
cat << EOF
Line 1
Line 2 with "quotes"
Line 3 with $variable
EOF

# SQL query
read -r -d '' query << EOF
SELECT *
FROM users
WHERE name = '$name'
AND status = 'active'
ORDER BY created_at
EOF

# Assign to variable
message=$(cat << EOF
Hello $user,

Your order #$order_id has shipped.
Tracking: $tracking_number
EOF
)
```

**Quoted delimiter prevents expansion:**

```bash
#!/bin/bash
# 'EOF' or "EOF" prevents variable expansion
cat << 'EOF'
This $variable is literal
Backslashes are literal: \n \t
$(commands) are not executed
EOF

# Useful for generating scripts
cat << 'SCRIPT' > /tmp/generated.sh
#!/bin/bash
echo "Arguments: $@"
echo "PID: $$"
SCRIPT
```

**Indented here documents:**

```bash
#!/bin/bash
# <<- strips leading TABS (not spaces!)
main() {
	cat <<- EOF
		This text can be indented with tabs
		The tabs before each line are stripped
		But the delimiter must also be indented with tabs
	EOF
}

# Note: Only tabs work, not spaces
# Most editors need configuration to insert tabs
```

**Here strings for single lines:**

```bash
#!/bin/bash
# <<< for single-line input
grep "pattern" <<< "$variable"

# Instead of echo | pipe
echo "$variable" | grep "pattern"  # Works but spawns subshell
grep "pattern" <<< "$variable"      # More efficient

# Read into variable
read -r first rest <<< "$line"
```

**Common patterns:**

```bash
#!/bin/bash
# Generate config files
cat << EOF > /etc/myapp.conf
[database]
host = $DB_HOST
port = $DB_PORT
name = $DB_NAME
EOF

# Multi-line usage message
usage() {
  cat << EOF
Usage: $0 [options] <file>

Options:
  -h, --help     Show this help
  -v, --verbose  Verbose output
  -o FILE        Output file

Examples:
  $0 input.txt
  $0 -v -o output.txt input.txt
EOF
}
```

Reference: [Bash Manual - Here Documents](https://www.gnu.org/software/bash/manual/html_node/Redirections.html)
