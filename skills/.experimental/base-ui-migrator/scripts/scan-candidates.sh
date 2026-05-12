#!/usr/bin/env bash
# scan-candidates.sh — Find Base UI migration candidates in a path
# Part of: base-ui-migrator
#
# Why: Manual scanning misses things. This script greps for the patterns
# referenced in references/catalog.md and outputs structured JSON the agent
# can present to the user for triage.
#
# Usage:
#   scan-candidates.sh <path>              # Scan a file or directory
#   scan-candidates.sh <path> --library    # Scan only for known-library imports (radix/headlessui)
#   scan-candidates.sh <path> --bespoke    # Scan only for bespoke patterns
#
# Output: JSON to stdout, one object per match:
#   {"file":"...", "line":42, "match":"<dialog>", "suggested":"Dialog", "reason":"..."}
#
# Exit codes:
#   0 — scan completed (matches may or may not exist; check output)
#   1 — invalid arguments or scan failed

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <path> [--library | --bespoke]" >&2
  echo "  <path>   File or directory to scan" >&2
  exit 1
fi

target="$1"
mode="all"
shift || true
for arg in "$@"; do
  case "$arg" in
    --library) mode="library" ;;
    --bespoke) mode="bespoke" ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

if [[ ! -e "$target" ]]; then
  echo "ERROR: Path does not exist: $target" >&2
  exit 1
fi

# --- Pick a grepper ---
# -H/--with-filename ensures consistent FILE:LINE:CONTENT output for both file
# and directory targets (rg omits the filename when given a single file by default).
if command -v rg >/dev/null 2>&1; then
  GREP=(rg --no-heading --with-filename --line-number --color=never --type-add 'react:*.{tsx,jsx,ts,js}' --type react)
else
  echo "WARN: ripgrep (rg) not found, falling back to grep (slower)" >&2
  GREP=(grep -Hrn --include='*.tsx' --include='*.jsx' --include='*.ts' --include='*.js')
fi

# --- Patterns ---
# Each entry: regex|suggested_component|reason
# Note: bash arrays of pipe-delimited strings. Component name maps to references/catalog.md.

declare -a library_patterns=(
  "from ['\"]@radix-ui/react-dialog['\"]|Dialog|Radix Dialog → Base UI Dialog (1:1)"
  "from ['\"]@radix-ui/react-alert-dialog['\"]|AlertDialog|Radix AlertDialog → Base UI AlertDialog"
  "from ['\"]@radix-ui/react-popover['\"]|Popover|Radix Popover → Base UI Popover"
  "from ['\"]@radix-ui/react-dropdown-menu['\"]|Menu|Radix DropdownMenu → Base UI Menu"
  "from ['\"]@radix-ui/react-context-menu['\"]|ContextMenu|Radix ContextMenu → Base UI ContextMenu"
  "from ['\"]@radix-ui/react-menubar['\"]|Menubar|Radix Menubar → Base UI Menubar"
  "from ['\"]@radix-ui/react-navigation-menu['\"]|NavigationMenu|Radix NavigationMenu → Base UI NavigationMenu"
  "from ['\"]@radix-ui/react-select['\"]|Select|Radix Select → Base UI Select"
  "from ['\"]@radix-ui/react-tabs['\"]|Tabs|Radix Tabs → Base UI Tabs"
  "from ['\"]@radix-ui/react-tooltip['\"]|Tooltip|Radix Tooltip → Base UI Tooltip"
  "from ['\"]@radix-ui/react-toast['\"]|Toast|Radix Toast → Base UI Toast"
  "from ['\"]@radix-ui/react-toggle['\"]|Toggle|Radix Toggle → Base UI Toggle"
  "from ['\"]@radix-ui/react-toggle-group['\"]|ToggleGroup|Radix ToggleGroup → Base UI ToggleGroup"
  "from ['\"]@radix-ui/react-switch['\"]|Switch|Radix Switch → Base UI Switch"
  "from ['\"]@radix-ui/react-checkbox['\"]|Checkbox|Radix Checkbox → Base UI Checkbox"
  "from ['\"]@radix-ui/react-radio-group['\"]|Radio|Radix RadioGroup → Base UI Radio + RadioGroup (TWO imports: @base-ui/react/radio and @base-ui/react/radio-group)"
  "from ['\"]@radix-ui/react-slider['\"]|Slider|Radix Slider → Base UI Slider"
  "from ['\"]@radix-ui/react-progress['\"]|Progress|Radix Progress → Base UI Progress"
  "from ['\"]@radix-ui/react-separator['\"]|Separator|Radix Separator → Base UI Separator"
  "from ['\"]@radix-ui/react-accordion['\"]|Accordion|Radix Accordion → Base UI Accordion"
  "from ['\"]@radix-ui/react-collapsible['\"]|Collapsible|Radix Collapsible → Base UI Collapsible"
  "from ['\"]@radix-ui/react-scroll-area['\"]|ScrollArea|Radix ScrollArea → Base UI ScrollArea"
  "from ['\"]@radix-ui/react-avatar['\"]|Avatar|Radix Avatar → Base UI Avatar"
  "from ['\"]@radix-ui/react-toolbar['\"]|Toolbar|Radix Toolbar → Base UI Toolbar"
  "from ['\"]@radix-ui/react-hover-card['\"]|PreviewCard|Radix HoverCard → Base UI PreviewCard"
  "from ['\"]@radix-ui/react-form['\"]|Form|Radix Form → Base UI Form"
  "from ['\"]@headlessui/react['\"]|*|HeadlessUI imports — review each one against references/catalog.md"
  "from ['\"]@reach/dialog['\"]|Dialog|Reach Dialog → Base UI Dialog"
  "from ['\"]@reach/menu-button['\"]|Menu|Reach MenuButton → Base UI Menu"
  "from ['\"]@reach/tabs['\"]|Tabs|Reach Tabs → Base UI Tabs"
  "from ['\"]react-aria-components['\"]|*|react-aria-components imports — review each one against references/catalog.md"
)

declare -a bespoke_patterns=(
  "<dialog[ >]|Dialog|Native <dialog> element — replace with Base UI Dialog for portaling + focus trap"
  "role=['\"]dialog['\"]|Dialog|ARIA dialog role — likely a bespoke modal, use Base UI Dialog"
  "role=['\"]alertdialog['\"]|AlertDialog|ARIA alertdialog role — use Base UI AlertDialog"
  "role=['\"]menu['\"]|Menu|ARIA menu role — likely a bespoke dropdown, use Base UI Menu"
  "role=['\"]listbox['\"]|Select|ARIA listbox — bespoke select, use Base UI Select or Combobox"
  "role=['\"]combobox['\"]|Combobox|ARIA combobox — use Base UI Combobox or Autocomplete"
  "role=['\"]tab['\"]|Tabs|ARIA tab role — use Base UI Tabs"
  "role=['\"]tooltip['\"]|Tooltip|ARIA tooltip role — use Base UI Tooltip"
  "role=['\"]switch['\"]|Switch|ARIA switch role — use Base UI Switch"
  "role=['\"]progressbar['\"]|Progress|ARIA progressbar — use Base UI Progress"
  "role=['\"]slider['\"]|Slider|ARIA slider — use Base UI Slider"
  "useFloating|Popover|Floating UI usage — Base UI Popover/Tooltip wrap this"
  "FocusTrap|Dialog|Manual focus trap — Base UI Dialog/AlertDialog handles this"
  "react-focus-lock|Dialog|react-focus-lock library — Base UI handles focus management natively"
  "<input[^>]+type=['\"]checkbox['\"]|Checkbox|Raw checkbox input — use Base UI Checkbox for indeterminate state + a11y"
  "<input[^>]+type=['\"]radio['\"]|Radio|Raw radio input — use Base UI Radio + Radio.Group"
  "<input[^>]+type=['\"]range['\"]|Slider|Raw range input — use Base UI Slider for keyboard + a11y"
  "<input[^>]+type=['\"]number['\"]|NumberField|Raw number input — use Base UI NumberField for increment/decrement + format"
  "<select[ >]|Select|Native <select> — use Base UI Select for custom styling + a11y"
  "<progress[ >]|Progress|Native <progress> — use Base UI Progress for styling consistency"
  "<meter[ >]|Meter|Native <meter> — use Base UI Meter for styling consistency"
)

# --- Build pattern set based on mode ---
patterns=()
case "$mode" in
  library) patterns=("${library_patterns[@]}") ;;
  bespoke) patterns=("${bespoke_patterns[@]}") ;;
  all)     patterns=("${library_patterns[@]}" "${bespoke_patterns[@]}") ;;
esac

# --- Scan ---
emit_json() {
  local file="$1" line="$2" snippet="$3" suggested="$4" reason="$5"
  # Escape for JSON (basic — relies on jq -R if available, fallback to sed)
  if command -v jq >/dev/null 2>&1; then
    jq -nc --arg file "$file" --argjson line "$line" --arg match "$snippet" \
           --arg suggested "$suggested" --arg reason "$reason" \
           '{file: $file, line: $line, match: $match, suggested: $suggested, reason: $reason}'
  else
    # Minimal escape for fallback
    snippet=$(echo "$snippet" | sed 's/\\/\\\\/g; s/"/\\"/g')
    file=$(echo "$file" | sed 's/\\/\\\\/g; s/"/\\"/g')
    reason=$(echo "$reason" | sed 's/\\/\\\\/g; s/"/\\"/g')
    echo "{\"file\":\"$file\",\"line\":$line,\"match\":\"$snippet\",\"suggested\":\"$suggested\",\"reason\":\"$reason\"}"
  fi
}

match_count=0
# Greedy `.+` matches from the LEFT but bash regex engines prefer the longest
# overall match, so the rightmost `:LINE:` anchors correctly even when the
# file path itself contains colons.
LINE_RE='^(.+):([0-9]+):(.*)$'
for entry in "${patterns[@]}"; do
  IFS='|' read -r regex suggested reason <<<"$entry"
  # rg/grep outputs FILE:LINE:CONTENT (with -H/-with-filename always set)
  while IFS= read -r hit; do
    [[ -z "$hit" ]] && continue
    if [[ ! "$hit" =~ $LINE_RE ]]; then
      # Unexpected output format — skip rather than crash jq below
      continue
    fi
    file="${BASH_REMATCH[1]}"
    line="${BASH_REMATCH[2]}"
    snippet="${BASH_REMATCH[3]}"
    # Truncate snippet to keep JSON readable
    snippet="${snippet:0:200}"
    emit_json "$file" "$line" "$snippet" "$suggested" "$reason"
    match_count=$((match_count + 1))
  done < <("${GREP[@]}" -e "$regex" "$target" 2>/dev/null || true)
done

echo "" >&2
echo "Scan complete: $match_count match(es) in $target" >&2
exit 0
