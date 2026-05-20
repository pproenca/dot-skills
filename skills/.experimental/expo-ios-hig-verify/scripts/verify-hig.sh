#!/usr/bin/env bash
# verify-hig.sh — Static HIG / native-feel checks for an Expo (React Native) iOS app.
# Part of: expo-ios-hig-verify
#
# Scans a project's source for patterns that violate the expo-ios-hig rules and
# prints a grouped report. Read-only: it never modifies the target project.
#
# Usage:
#   verify-hig.sh [project-dir] [--strict] [--json]
#     project-dir  Directory to scan (default: current directory)
#     --strict     Exit non-zero on advisories too (default: only errors fail)
#     --json       Emit findings as a JSON array instead of the text report
#
# Exit codes: 0 = clean, 1 = violations found (or bad usage)

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat >&2 <<'EOF'
Usage: verify-hig.sh [project-dir] [--strict] [--json]
  project-dir   Directory to scan (default: current directory)
  --strict      Exit non-zero on advisories as well as errors
  --json        Emit findings as a JSON array
EOF
}

# --- Parse arguments ---
TARGET="."
STRICT=0
JSON=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict) STRICT=1; shift ;;
    --json) JSON=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --*) echo "Error: unknown option '$1'." >&2; usage; exit 1 ;;
    *) TARGET="$1"; shift ;;
  esac
done

# --- Validate input ---
if [[ ! -d "$TARGET" ]]; then
  echo "Error: '$TARGET' is not a directory." >&2
  echo "Point verify-hig.sh at the root of your Expo project, e.g.: verify-hig.sh ./my-app" >&2
  exit 1
fi

# --- Configuration (optional, via config.json + jq) ---
CONFIG="${SKILL_DIR}/config.json"
SEARCH_ROOTS="app src components"
RULES_LINK="../expo-ios-hig/references"
if command -v jq >/dev/null 2>&1 && [[ -f "$CONFIG" ]]; then
  cfg_roots="$(jq -r '.search_roots // empty' "$CONFIG" 2>/dev/null || true)"
  cfg_link="$(jq -r '.skill_rules_dir // empty' "$CONFIG" 2>/dev/null || true)"
  [[ -n "$cfg_roots" ]] && SEARCH_ROOTS="$cfg_roots"
  [[ -n "$cfg_link" ]] && RULES_LINK="$cfg_link"
fi

# --- Search helper (prefers ripgrep, falls back to grep) ---
do_search() {
  # $1 = extended regex. Prints "path:line:content" for matching .ts/.tsx/.js/.jsx files.
  local pattern="$1"
  local -a roots=()
  local r
  for r in $SEARCH_ROOTS; do
    [[ -d "$TARGET/$r" ]] && roots+=("$TARGET/$r")
  done
  [[ ${#roots[@]} -eq 0 ]] && roots=("$TARGET")
  if command -v rg >/dev/null 2>&1; then
    rg --no-heading --line-number --color never \
       -g '*.ts' -g '*.tsx' -g '*.js' -g '*.jsx' -g '!node_modules' \
       -e "$pattern" "${roots[@]}" 2>/dev/null || true
  else
    grep -rEn --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
       --exclude-dir=node_modules -e "$pattern" "${roots[@]}" 2>/dev/null || true
  fi
}

# --- Findings accumulation ---
ERRORS=0
ADVISORIES=0
declare -a FINDINGS=()

record() {
  # $1 severity  $2 rule  $3 message  $4 location
  FINDINGS+=("$1"$'\t'"$2"$'\t'"$3"$'\t'"$4")
  if [[ "$1" == "ERROR" ]]; then ERRORS=$((ERRORS + 1)); else ADVISORIES=$((ADVISORIES + 1)); fi
}

check() {
  # $1 severity  $2 rule  $3 message  $4 pattern
  local severity="$1" rule="$2" message="$3" pattern="$4" matches line
  matches="$(do_search "$pattern")"
  [[ -z "$matches" ]] && return 0
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    record "$severity" "$rule" "$message" "$line"
  done <<< "$matches"
}

check_scrollview_map() {
  # Advisory: a file that uses <ScrollView> and .map( probably renders an unvirtualized list.
  local files file loc
  files="$(do_search '<ScrollView' | cut -d: -f1 | sort -u)"
  [[ -z "$files" ]] && return 0
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    if grep -Eq '\.map\(' "$file" 2>/dev/null; then
      loc="$(grep -En '<ScrollView' "$file" | head -1 | cut -d: -f1)"
      record "ADVISORY" "motion-virtualized-lists" \
        "ScrollView combined with .map() — use FlashList for long lists" "$file:$loc"
    fi
  done <<< "$files"
}

# --- Checks (ERROR = high precision, ADVISORY = heuristic) ---
run_checks() {
  check ERROR native-avoid-material-ui "Material Design component kit imported on iOS" \
    "from ['\"](react-native-paper|@react-native-material/|@rneui/|react-native-elements)"
  check ERROR nav-native-stack "JavaScript stack navigator instead of the native stack" \
    "(@react-navigation/stack|createStackNavigator)"
  check ERROR touch-gesture-handler-thread "PanResponder runs gestures on the JS thread" \
    "PanResponder"
  check ERROR touch-pressable-feedback "TouchableWithoutFeedback gives no press feedback" \
    "TouchableWithoutFeedback"
  check ERROR acc-dynamic-type "allowFontScaling disabled — breaks Dynamic Type" \
    "allowFontScaling(\s*=\s*\{\s*false\s*\}|\s*:\s*false)"
  check ERROR motion-ui-thread-animation "useNativeDriver:false keeps the animation on the JS thread" \
    "useNativeDriver\s*:\s*false"

  check ADVISORY nav-native-tabs "createBottomTabNavigator is a JS tab bar — prefer native tabs" \
    "createBottomTabNavigator"
  check ADVISORY visual-semantic-colors "Hardcoded hex color — prefer PlatformColor semantic colors" \
    "(color|backgroundColor|borderColor|tintColor)\s*:\s*['\"]#[0-9a-fA-F]{3,8}"
  check ADVISORY visual-system-font "Custom fontFamily on interface text — prefer the system font" \
    "fontFamily\s*:"
  check ADVISORY system-status-bar "Hardcoded StatusBar style — prefer style=\"auto\"" \
    "StatusBar[^\n]*style=['\"](dark|light)['\"]"
  check_scrollview_map
}

# --- Output ---
print_text() {
  echo "HIG verification report for: $TARGET"
  echo "============================================================"
  if [[ ${#FINDINGS[@]} -eq 0 ]]; then
    echo "No HIG violations found."
    echo "============================================================"
    echo "Summary: 0 errors, 0 advisories"
    return 0
  fi
  local sev label printed entry s rule msg loc
  for sev in ERROR ADVISORY; do
    printed=0
    if [[ "$sev" == "ERROR" ]]; then label="ERRORS"; else label="ADVISORIES"; fi
    for entry in "${FINDINGS[@]}"; do
      IFS=$'\t' read -r s rule msg loc <<< "$entry"
      [[ "$s" == "$sev" ]] || continue
      if [[ $printed -eq 0 ]]; then echo ""; echo "$label:"; printed=1; fi
      echo "  [$rule] $msg"
      echo "    $loc"
      echo "    -> $RULES_LINK/$rule.md"
    done
  done
  echo ""
  echo "============================================================"
  echo "Summary: $ERRORS errors, $ADVISORIES advisories"
}

json_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

print_json() {
  local first=1 entry s rule msg loc
  printf '['
  if [[ ${#FINDINGS[@]} -gt 0 ]]; then
    for entry in "${FINDINGS[@]}"; do
      IFS=$'\t' read -r s rule msg loc <<< "$entry"
      if [[ $first -eq 1 ]]; then first=0; else printf ','; fi
      printf '{"severity":"%s","rule":"%s","message":"%s","location":"%s"}' \
        "$s" "$rule" "$(json_escape "$msg")" "$(json_escape "$loc")"
    done
  fi
  printf ']\n'
}

run_checks
if [[ $JSON -eq 1 ]]; then print_json; else print_text; fi

# --- Exit status ---
if [[ $ERRORS -gt 0 ]]; then exit 1; fi
if [[ $STRICT -eq 1 && $ADVISORIES -gt 0 ]]; then exit 1; fi
exit 0
