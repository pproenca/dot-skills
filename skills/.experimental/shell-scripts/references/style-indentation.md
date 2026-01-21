---
title: Use Consistent Indentation
impact: LOW
impactDescription: improves readability and maintenance
tags: style, indentation, formatting, whitespace
---

## Use Consistent Indentation

Inconsistent indentation makes control flow hard to follow. Use 2 spaces (Google style) consistently throughout the script.

**Incorrect (inconsistent indentation):**

```bash
#!/bin/bash
if [[ -f "$file" ]]; then
echo "exists"
   if [[ -r "$file" ]]; then
        echo "readable"
	# Mixed tabs and spaces
    fi
fi

for item in "${items[@]}"; do
process "$item"
done
```

**Correct (consistent 2-space indentation):**

```bash
#!/bin/bash
if [[ -f "$file" ]]; then
  echo "exists"
  if [[ -r "$file" ]]; then
    echo "readable"
  fi
fi

for item in "${items[@]}"; do
  process "$item"
done
```

**Formatting guidelines:**

```bash
#!/bin/bash
# Maximum line length: 80 characters
# Indent: 2 spaces (no tabs except in heredocs)

# If/then on same line
if [[ condition ]]; then
  commands
fi

# For/do on same line
for item in list; do
  commands
done

# While/do on same line
while [[ condition ]]; do
  commands
done

# Case indentation
case "$var" in
  pattern1)
    commands
    ;;
  pattern2)
    commands
    ;;
esac
```

**Long lines:**

```bash
#!/bin/bash
# Break long commands with backslash
command \
  --long-option="value" \
  --another-option="another value" \
  file.txt

# Or use arrays for complex commands
declare -a args=(
  --long-option="value"
  --another-option="another value"
)
command "${args[@]}" file.txt

# Pipelines - one per line
command1 \
  | command2 \
  | command3 \
  | command4
```

**Function formatting:**

```bash
#!/bin/bash
# Opening brace on same line as function name
my_function() {
  local var="$1"

  if [[ -n "$var" ]]; then
    process "$var"
  fi
}

# Not this:
my_function()
{
  # ...
}
```

**Heredoc indentation:**

```bash
#!/bin/bash
# Only tabs work with <<- (not spaces)
my_function() {
	cat <<- EOF
		This text is indented with tabs.
		The tabs are stripped from output.
	EOF
}

# Or don't indent heredoc content
my_function() {
  cat << EOF
This text is not indented.
Output appears at column 0.
EOF
}
```

Reference: [Google Shell Style Guide - Formatting](https://google.github.io/styleguide/shellguide.html)
