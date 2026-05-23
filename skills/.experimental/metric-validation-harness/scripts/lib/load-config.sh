# shellcheck shell=bash
# Sourced by the bash check scripts. Resolves SKILL_ROOT + config and defines helpers.
# Precedence for each setting: environment variable > config.json > built-in default.
# NOTE: paths in metric_cmd/skill root must not contain spaces (bash word-splits the command).

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$_LIB_DIR/../.." && pwd)"
CONFIG_FILE="${HARNESS_CONFIG:-$SKILL_ROOT/config.json}"

_cfg() {  # _cfg <json-key>  → value or empty
  [[ -f "$CONFIG_FILE" ]] || { printf ''; return; }
  python3 -c 'import json,sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    d = {}
print(d.get(sys.argv[2], ""))' "$CONFIG_FILE" "$1" 2>/dev/null || printf ''
}

_resolve() { printf '%s' "${1//\{SKILL\}/$SKILL_ROOT}"; }

_setting() {  # _setting <ENV_NAME> <json-key> <default>
  local env_name="$1" key="$2" def="$3" val
  val="${!env_name:-}"
  [[ -n "$val" ]] || val="$(_cfg "$key")"
  [[ -n "$val" ]] || val="$def"
  _resolve "$val"
}

METRIC_CMD="$(_setting METRIC_CMD   metric_cmd   'python3 {SKILL}/scripts/examples/metric_ast_nodes.py')"
BASELINE_CMD="$(_setting BASELINE_CMD baseline_cmd 'python3 {SKILL}/scripts/examples/metric_loc.py')"
CORPUS_DIR="$(_setting CORPUS_DIR   corpus_dir   '{SKILL}/scripts/fixtures/corpus')"
LABELS_CSV="$(_setting LABELS_CSV   labels_csv   '{SKILL}/scripts/fixtures/corpus.csv')"
DECLARED_MIN="$(_setting DECLARED_MIN declared_min '')"
DECLARED_MAX="$(_setting DECLARED_MAX declared_max '')"

case "$SKILL_ROOT" in
  *\ *) echo "warning: the skill path contains a space; the bash checks word-split \$METRIC_CMD and may fail. Move the skill to a space-free path or wrap your metric in a launcher script." >&2 ;;
esac

# metric_of <path> → prints the metric value; returns 1 with an actionable message on failure.
metric_of() {
  local p="$1" out
  out="$($METRIC_CMD "$p" 2>/dev/null)" || {
    echo "metric command failed on '$p'. Check 'metric_cmd' in config.json — it must run and exit 0." >&2
    return 1
  }
  out="$(printf '%s' "$out" | tr -d '[:space:]')"
  [[ "$out" =~ ^-?[0-9]+([.][0-9]+)?$ ]] || {
    echo "metric did not print one number on '$p' (got: '$out'). It must print exactly ONE number to stdout." >&2
    return 1
  }
  printf '%s' "$out"
}

num_eq() { [[ "$1" == "$2" ]]; }                              # exact string equality
num_ge() { awk -v a="$1" -v b="$2" 'BEGIN{exit !(a>=b)}'; }   # a >= b numerically
num_gt() { awk -v a="$1" -v b="$2" 'BEGIN{exit !(a>b)}'; }    # a >  b numerically

list_fixtures() { find "$CORPUS_DIR" -maxdepth 1 -name '*.py' -type f | sort; }
