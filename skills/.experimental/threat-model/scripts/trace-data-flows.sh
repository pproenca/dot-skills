#!/usr/bin/env bash
# trace-data-flows.sh — Find entry points and sinks, suggest candidate traces
# Gives the analyst structured data about where untrusted input enters and
# where privileged operations occur. The agent then verifies connections manually.
#
# Usage: trace-data-flows.sh <project-root> [--language <swift|c|js|py|rb|go|rust>]
# Output: Entry points, sinks, and candidate traces by proximity

set -euo pipefail

command -v rg >/dev/null 2>&1 || {
  echo "Error: ripgrep (rg) is required. Install: brew install ripgrep" >&2
  exit 1
}

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <project-root> [--language <swift|c|js|py|rb|go|rust>]" >&2
  exit 1
fi

ROOT="$1"
shift
LANG_FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --language)
      if [[ $# -lt 2 ]]; then
        echo "Error: --language requires a value (swift|c|js|py|rb|go|rust)" >&2
        exit 1
      fi
      LANG_FILTER="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

EXCLUDE="--glob=!vendor --glob=!node_modules --glob=!.build --glob=!build --glob=!dist --glob=!Pods --glob=!.git --glob=!*.min.js --glob=!*lock*"

# Language-specific glob filters
case "$LANG_FILTER" in
  swift)  GLOB="--glob=*.swift" ;;
  c)      GLOB="--glob=*.{c,m,mm,h,cpp}" ;;
  js)     GLOB="--glob=*.{js,ts,jsx,tsx}" ;;
  py)     GLOB="--glob=*.py" ;;
  rb)     GLOB="--glob=*.rb" ;;
  go)     GLOB="--glob=*.go" ;;
  rust)   GLOB="--glob=*.rs" ;;
  "")     GLOB="" ;;
  *)      echo "Warning: unknown language '$LANG_FILTER', scanning all file types" >&2; GLOB="" ;;
esac

scan_entries() {
  local label="$1" pattern="$2"
  local results
  results=$(rg -n --no-heading $EXCLUDE $GLOB "$pattern" "$ROOT" 2>/dev/null || true)
  if [[ -n "$results" ]]; then
    echo "### $label"
    echo "$results" | head -30
    local count
    count=$(echo "$results" | wc -l | tr -d ' ')
    if [[ "$count" -gt 30 ]]; then
      echo "  ... and $((count - 30)) more"
    fi
    echo ""
  fi
}

echo "# Data Flow Analysis: $(basename "$ROOT")"
echo "# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

echo "## Entry Points (where untrusted data enters)"
echo ""

# CLI argument parsing
scan_entries "CLI Arguments (Swift ArgumentParser)" '@(Argument|Option|Flag)\b'
scan_entries "CLI Arguments (Node.js)" '(process\.argv|commander\.|yargs\.|minimist)'
scan_entries "CLI Arguments (Python)" '(argparse|sys\.argv|click\.)'
scan_entries "CLI Arguments (Go)" '(flag\.String|os\.Args|cobra)'
scan_entries "CLI Arguments (Rust)" '(clap::Arg|structopt|std::env::args)'

# HTTP request parameters
scan_entries "HTTP Params (Express/Node)" '(req\.(params|body|query|headers|cookies)\[|req\.get\()'
scan_entries "HTTP Params (Rails)" '(params\[|params\.permit|params\.require|params\.expect)'
scan_entries "HTTP Params (Python)" '(request\.(GET|POST|json|data|args|form)\[)'
scan_entries "HTTP Params (Go)" '(r\.URL\.Query|r\.FormValue|r\.Header\.Get)'

# File content reads (untrusted file data)
scan_entries "File Reads" '(readFileSync|readFile\(|contents\(atPath|contentsOfDirectory|open\(.+["\x27]r)'
scan_entries "JSON/Data Parsing" '(JSON\.parse|JSONDecoder|JSONSerialization|cJSON_Parse|json\.loads|json\.load)'

# Environment variables
scan_entries "Environment Variables" '(ProcessInfo\.processInfo\.environment|process\.env\.|os\.environ|os\.Getenv)'

echo "---"
echo ""
echo "## Sinks (where privileged operations occur)"
echo ""

# File system writes
scan_entries "File Writes" '(write\(toFile|writeFileSync|writeFile\(|createDirectory|removeItem|copyItem|moveItem|fs\.unlink|fs\.rm)'
scan_entries "File Path Construction" '(appendingPathComponent|path\.join|Path\.Combine|os\.path\.join)'

# Command/code execution
scan_entries "Command Execution" '(Process\(|NSTask|system\(|popen\(|exec\(|child_process|spawn\()'
scan_entries "Dynamic Evaluation" '(eval\(|Function\(|expression\s+--|dlopen|dlsym)'

# Memory allocation from untrusted sizes
scan_entries "Sized Allocation" '(malloc\(|calloc\(|realloc\(|\[UInt8\]\(repeating|Buffer\.alloc|new ArrayBuffer)'

# HTML/template rendering
scan_entries "HTML Rendering" '(innerHTML|outerHTML|document\.write|marked\.parse|dangerouslySetInnerHTML)'
scan_entries "Template Interpolation" '(render\(|erb|ejs|pug|handlebars|mustache)'

# SQL/database
scan_entries "SQL Queries" '(SELECT.*FROM|INSERT.*INTO|UPDATE.*SET|DELETE.*FROM|\.execute\(|\.query\()' -i

# Network requests (SSRF surface)
scan_entries "Outbound HTTP" '(URLSession|fetch\(|Net::HTTP|requests\.(get|post)|http\.Get|curl)'

echo "---"
echo ""
echo "## Candidate Traces"
echo ""
echo "The following entry-sink pairs appear in the same source directory or module."
echo "Each candidate needs manual verification: read the code between entry and sink"
echo "to determine if the untrusted value actually flows to the privileged operation."
echo ""

# Collect entry-point files and sink files, find overlaps
ENTRY_FILES=$(mktemp)
SINK_FILES=$(mktemp)
trap 'rm -f "$ENTRY_FILES" "$SINK_FILES"' EXIT

# Collect unique directories containing entry points
rg -l $EXCLUDE $GLOB '@(Argument|Option)|process\.argv|argparse|params\[|req\.(params|body|query)|request\.(GET|POST)|readFileSync|contents\(atPath|JSON\.parse|JSONDecoder|cJSON_Parse' "$ROOT" 2>/dev/null | while read -r f; do
  dirname "$f"
done | sort -u > "$ENTRY_FILES"

# Collect unique directories containing sinks
rg -l $EXCLUDE $GLOB 'write\(toFile|writeFileSync|removeItem|copyItem|Process\(|system\(|popen\(|exec\(|dlopen|malloc\(|realloc\(|innerHTML|\.execute\(' "$ROOT" 2>/dev/null | while read -r f; do
  dirname "$f"
done | sort -u > "$SINK_FILES"

# Find directories that contain BOTH entries and sinks
OVERLAPS=$(comm -12 "$ENTRY_FILES" "$SINK_FILES")
if [[ -n "$OVERLAPS" ]]; then
  echo "### Directories with both entry points and sinks"
  echo ""
  echo "$OVERLAPS" | while read -r dir; do
    rel=$(python3 -c "import os.path; print(os.path.relpath('$dir', '$ROOT'))" 2>/dev/null || echo "$dir")
    entries=$(rg -c $EXCLUDE $GLOB '@(Argument|Option)|process\.argv|argparse|params\[|req\.(params|body|query)|request\.(GET|POST)|readFileSync|contents\(atPath|JSON\.parse|JSONDecoder|cJSON_Parse' "$dir" 2>/dev/null | wc -l | tr -d ' ')
    sinks=$(rg -c $EXCLUDE $GLOB 'write\(toFile|writeFileSync|removeItem|copyItem|Process\(|system\(|popen\(|exec\(|dlopen|malloc\(|realloc\(|innerHTML|\.execute\(' "$dir" 2>/dev/null | wc -l | tr -d ' ')
    echo "- **$rel** — $entries entry-point files, $sinks sink files"
  done
  echo ""
  echo "Start tracing in these directories: they have the highest probability of"
  echo "untrusted data reaching privileged operations."
else
  echo "No directory overlaps found. Entry points and sinks are in separate modules."
  echo "Trace data flow across module boundaries by following function call chains."
fi
