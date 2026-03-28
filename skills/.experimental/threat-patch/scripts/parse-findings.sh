#!/usr/bin/env bash
# parse-findings.sh — Parse Codex security findings CSV into structured output
# Extracts key fields per finding, sorted by severity, for use by the patching workflow.
#
# Usage: parse-findings.sh <csv-path> [--repo <repo-filter>] [--severity <level>]
# Output: Structured findings grouped by repository and severity

set -euo pipefail

command -v python3 >/dev/null 2>&1 || {
  echo "Error: python3 is required for CSV parsing but not found." >&2
  exit 1
}

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <csv-path> [--repo <owner/repo>] [--severity <critical|high|medium|low>]" >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "  $0 findings.csv                          # All findings" >&2
  echo "  $0 findings.csv --repo pproenca/agent-sim # Filter by repository" >&2
  echo "  $0 findings.csv --severity high           # Filter by severity" >&2
  exit 1
fi

CSV_PATH="$1"
shift

if [[ ! -f "$CSV_PATH" ]]; then
  echo "Error: '$CSV_PATH' is not a file" >&2
  exit 1
fi

REPO_FILTER=""
SEVERITY_FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO_FILTER="$2"
      shift 2
      ;;
    --severity)
      SEVERITY_FILTER="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

python3 - "$CSV_PATH" "$REPO_FILTER" "$SEVERITY_FILTER" << 'PYEOF'
import csv
import sys
from collections import Counter
from datetime import datetime, timezone

csv_path = sys.argv[1]
repo_filter = sys.argv[2] if len(sys.argv) > 2 else ""
severity_filter = sys.argv[3] if len(sys.argv) > 3 else ""

severity_order = {"critical": 1, "high": 2, "medium": 3, "low": 4}

print(f"# Security Findings: {csv_path.split('/')[-1]}")
print(f"# Parsed: {datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')}")
if repo_filter:
    print(f"# Repository filter: {repo_filter}")
if severity_filter:
    print(f"# Severity filter: {severity_filter}")
print()

findings = []
with open(csv_path, newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        repo = row.get("repository", "")
        severity = row.get("severity", "")
        if repo_filter and repo != repo_filter:
            continue
        if severity_filter and severity != severity_filter:
            continue
        findings.append(row)

# Sort by severity
findings.sort(key=lambda r: severity_order.get(r.get("severity", ""), 5))

repo_counts = Counter()
severity_counts = Counter()

for row in findings:
    repo = row.get("repository", "")
    severity = row.get("severity", "")
    title = row.get("title", "")
    status = row.get("status", "")
    commit = row.get("commit_hash", "")[:12]
    paths = row.get("relevant_paths", "")
    has_patch = row.get("has_patch", "false")

    repo_counts[repo] += 1
    severity_counts[severity] += 1

    patch_marker = " [has patch]" if has_patch == "true" else ""
    print(f"## [{severity}] {title}{patch_marker}")
    print(f"- **Repository**: {repo}")
    print(f"- **Status**: {status}")
    print(f"- **Commit**: `{commit}`")
    print(f"- **Files**: {paths}")
    print()

print("---")
print("## Summary")
print(f"- **Total findings**: {len(findings)}")
for sev in ["critical", "high", "medium", "low"]:
    count = severity_counts.get(sev, 0)
    if count > 0:
        print(f"- **{sev}**: {count}")

print()
print("## By Repository")
for repo, count in repo_counts.most_common():
    print(f"- **{repo}**: {count}")
PYEOF
