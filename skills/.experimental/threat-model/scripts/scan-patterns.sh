#!/usr/bin/env bash
# scan-patterns.sh — Scan a codebase for security-relevant code patterns
# Gives the threat modeler a head start by surfacing code that commonly
# correlates with security issues. NOT a vulnerability scanner — just
# pattern matching to guide manual analysis.
#
# Usage: scan-patterns.sh <project-root>
# Output: Grouped findings by category, with file:line references

set -euo pipefail

command -v rg >/dev/null 2>&1 || {
  echo "Error: ripgrep (rg) is required but not installed." >&2
  echo "Install via: brew install ripgrep (macOS), apt install ripgrep (Debian/Ubuntu)" >&2
  echo "See: https://github.com/BurntSushi/ripgrep#installation" >&2
  exit 1
}

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <project-root>" >&2
  echo "Scans for security-relevant code patterns to guide threat modeling." >&2
  exit 1
fi

ROOT="$1"
if [[ ! -d "$ROOT" ]]; then
  echo "Error: '$ROOT' is not a directory" >&2
  exit 1
fi

# Exclusions: vendored code, build output, test fixtures, node_modules
EXCLUDE="--glob=!vendor --glob=!node_modules --glob=!.build --glob=!build --glob=!dist --glob=!Pods --glob=!.git --glob=!*.min.js --glob=!package-lock.json --glob=!yarn.lock"

scan() {
  local label="$1"
  local pattern="$2"
  shift 2
  local results
  results=$(rg -n --no-heading $EXCLUDE "$@" "$pattern" "$ROOT" 2>/dev/null || true)
  if [[ -n "$results" ]]; then
    echo "### $label"
    echo "$results" | head -20
    local count
    count=$(echo "$results" | wc -l | tr -d ' ')
    if [[ "$count" -gt 20 ]]; then
      echo "  ... and $((count - 20)) more matches"
    fi
    echo ""
  fi
}

echo "# Security Pattern Scan: $(basename "$ROOT")"
echo "# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

echo "## Predictable Temporary Paths"
scan "Hardcoded /tmp paths" '/tmp/' --glob='!*.md' --glob='!*.txt'

echo "## Path Construction"
scan "Path interpolation" '(appendingPathComponent|path\.join|Path\.Combine|os\.path\.join)' --glob='!*.md'
scan "Potential traversal" '\.\.\/' --glob='!*.md' --glob='!*.lock'

echo "## HTML / Template Injection"
scan "innerHTML usage" 'innerHTML' --glob='!*.md'
scan "Script tag embedding" '(<script|</script)' --glob='*.html' --glob='*.erb' --glob='*.ejs'
scan "Marked/markdown rendering" '(marked\.parse|marked\()' --glob='*.js' --glob='*.ts'
scan "dangerouslySetInnerHTML" 'dangerouslySetInnerHTML'

echo "## Command / Expression Injection"
scan "Process/exec calls" '(Process\(|NSTask|system\(|popen\(|exec\(|child_process)' --glob='!*.md'
scan "eval usage" '(eval\(|Function\()' --glob='*.js' --glob='*.ts' --glob='*.py'
scan "Shell interpolation" '(\$\(|`.*`)' --glob='*.sh'

echo "## Native Code / Unsafe Operations"
scan "Unsafe pointer access" '(withUnsafeBytes|withUnsafePointer|UnsafeRawPointer|UnsafeBufferPointer)' --glob='*.swift'
scan "C memory allocation" '(malloc|calloc|realloc|free\()' --glob='*.c' --glob='*.m' --glob='*.mm' --glob='*.cpp'
scan "dlopen/dlsym" '(dlopen|dlsym|dlclose)' --glob='*.c' --glob='*.m' --glob='*.mm' --glob='*.swift'
scan "fromByteOffset" 'fromByteOffset' --glob='*.swift'
scan "String(cString:)" 'String\(cString' --glob='*.swift'

echo "## Credential / Secret Patterns"
scan "Hardcoded secrets" '(SECRET_KEY|API_KEY|PASSWORD|PRIVATE_KEY|Bearer )' -i --glob='!*.md' --glob='!*.lock'
scan "Hardcoded URLs with auth" '(https?://[^@\s]*:[^@\s]*@)' --glob='!*.md'

echo "## Serialization / Parsing"
scan "JSON parsing" '(JSONSerialization|cJSON_Parse|JSON\.parse|json\.loads)' --glob='!*.md'
scan "Decompression" '(gunzip|inflate|decompress|Compression)' --glob='!*.md'

echo "## Authentication / Authorization"
scan "Auth-related" '(authenticate|authorize|before_action|middleware.*auth)' --glob='!*.md' --glob='!node_modules'
scan "config.hosts.clear" 'config\.hosts\.clear'
scan "CORS permissive" '(Access-Control-Allow-Origin.*\*|cors.*origin.*true)' --glob='!*.md'

echo "## File Operations"
scan "File deletion" '(removeItem|unlink\(|rm -|File\.delete)' --glob='!*.md' --glob='!*.sh'
scan "File permissions" '(chmod|0777|0755|0750|permissions)' --glob='!*.md'
scan "Symlink operations" '(createSymbolicLink|isSymbolicLink|readlink|lstat)' --glob='!*.md'

echo "---"
echo "# Summary"
echo "This scan highlights code patterns that commonly correlate with security"
echo "issues. Each match needs manual review to determine if it represents an"
echo "actual vulnerability in context. Use these results to guide attack surface"
echo "enumeration, not as a findings list."
