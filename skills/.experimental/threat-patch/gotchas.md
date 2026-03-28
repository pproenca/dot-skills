# Gotchas

### parse-findings.sh requires python3
The CSV parser script uses Python's `csv` module for correct handling of quoted fields with embedded commas. If `python3` is not available, read the CSV directly with the Read tool instead.
Added: 2026-03-28

### Confirm the finding's commit hash matches the current codebase
Findings reference specific commit hashes. If the codebase has been significantly refactored since the finding was detected, the vulnerable code may have moved, been renamed, or been removed. Always grep for the vulnerable pattern rather than assuming the exact file:line from the finding.
Added: 2026-03-28

### Grouped fixes need careful testing of all affected call sites
When extracting a shared helper to fix multiple duplicate vulnerabilities, test every call site — not just the first one. The helper's interface may not fit all callers identically, especially if they handle errors differently.
Added: 2026-03-28
