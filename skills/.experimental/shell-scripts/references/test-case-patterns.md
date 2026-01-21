---
title: Use case for Pattern Matching
impact: MEDIUM
impactDescription: cleaner than chained if/elif for multiple patterns
tags: test, case, patterns, conditionals
---

## Use case for Pattern Matching

Multiple if/elif chains for pattern matching are verbose and error-prone. `case` is cleaner, supports glob patterns natively, and is POSIX-compliant.

**Incorrect (if/elif chains):**

```bash
#!/bin/bash
# Verbose and repetitive
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
elif [[ "$1" == "-v" || "$1" == "--version" ]]; then
  show_version
elif [[ "$1" == "-q" || "$1" == "--quiet" ]]; then
  quiet=true
elif [[ "$1" == "-"* ]]; then
  echo "Unknown option: $1"
  exit 1
fi

# File type detection
if [[ "$file" == *.tar.gz || "$file" == *.tgz ]]; then
  tar -xzf "$file"
elif [[ "$file" == *.tar.bz2 || "$file" == *.tbz2 ]]; then
  tar -xjf "$file"
elif [[ "$file" == *.zip ]]; then
  unzip "$file"
fi
```

**Correct (case statement):**

```bash
#!/bin/bash
# Clean pattern matching
case "$1" in
  -h|--help)
    show_help
    ;;
  -v|--version)
    show_version
    ;;
  -q|--quiet)
    quiet=true
    ;;
  -*)
    echo "Unknown option: $1" >&2
    exit 1
    ;;
esac

# File type detection
case "$file" in
  *.tar.gz|*.tgz)
    tar -xzf "$file"
    ;;
  *.tar.bz2|*.tbz2)
    tar -xjf "$file"
    ;;
  *.tar.xz|*.txz)
    tar -xJf "$file"
    ;;
  *.zip)
    unzip "$file"
    ;;
  *)
    echo "Unknown format: $file" >&2
    return 1
    ;;
esac
```

**Case pattern features:**

```bash
#!/bin/bash
input="$1"

case "$input" in
  # Exact match
  start|stop|restart)
    handle_command "$input"
    ;;

  # Glob patterns
  *.txt)
    echo "Text file"
    ;;

  # Character classes
  [0-9]*)
    echo "Starts with digit"
    ;;

  [a-zA-Z]*)
    echo "Starts with letter"
    ;;

  # Negation (bash extended)
  !(*.bak|*.tmp))
    echo "Not a backup or temp file"
    ;;

  # Default case (always put last)
  *)
    echo "No match"
    ;;
esac
```

**Fall-through with ;&:**

```bash
#!/bin/bash
# Bash 4+ feature: fall-through
level="$1"

case "$level" in
  debug)
    enable_debug=true
    ;&  # Fall through
  verbose)
    enable_verbose=true
    ;&  # Fall through
  normal)
    enable_logging=true
    ;;
esac

# Continue matching with ;;&
case "$option" in
  --all)
    all=true
    ;;&  # Continue checking
  --verbose|--all)
    verbose=true
    ;;&  # Continue checking
  --debug|--all)
    debug=true
    ;;
esac
```

**Option parsing with case:**

```bash
#!/bin/bash
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      -v|--verbose)
        VERBOSE=true
        shift
        ;;
      -o|--output)
        OUTPUT="$2"
        shift 2
        ;;
      --)
        shift
        break
        ;;
      -*)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
      *)
        break
        ;;
    esac
  done
  ARGS=("$@")
}
```

Reference: [Bash Manual - Case Statement](https://www.gnu.org/software/bash/manual/html_node/Conditional-Constructs.html)
