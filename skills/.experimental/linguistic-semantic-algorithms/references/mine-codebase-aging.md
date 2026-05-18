---
title: Plot Per-File Age Distribution to Separate Stable Code from Forgotten Code
impact: MEDIUM
impactDescription: eliminates dead-code candidates that static analysis alone cannot confirm
tags: mine, code-age, last-modified, dead-code, stability
---

## Plot Per-File Age Distribution to Separate Stable Code from Forgotten Code

A file untouched for 3 years is either (a) load-bearing code so solid nobody needs to change it, or (b) dead code nobody knows about. The age signal alone can't distinguish them — you also need to know whether the file is *reached* by current code. The combination is decisive: high-age + reachable = stable foundation (leave it alone, document it); high-age + unreachable = dead code (delete it). Tracking the per-file age distribution as a single metric over time also reveals when "stable code" suddenly starts changing, which is often the first sign of an upcoming refactor or incident.

**Incorrect (just delete files unchanged for N years — risks deleting load-bearing code):**

```bash
# A hasty "spring cleaning". Deletes anything not touched in 2 years.
# Easily nukes the rock-solid CLI argument parser that hasn't needed
# changes since 2022 but is loaded by every script.
find src -name "*.py" -mtime +730 -delete   # NO. Do not.
```

**Correct (combine last-modified age with reachability from entry points):**

```python
import subprocess, ast, pathlib
from datetime import datetime, timezone

# 1. Last-modified date per file
def last_commit_date(path: str) -> datetime:
    out = subprocess.check_output(
        ["git", "log", "-1", "--format=%cI", "--", path],
    ).decode().strip()
    return datetime.fromisoformat(out) if out else datetime(2000, 1, 1, tzinfo=timezone.utc)

# 2. Build static reachability from declared entry points
ENTRY_POINTS = [
    "src/cli/main.py", "src/api/wsgi.py", "src/workers/queue_runner.py",
]

import networkx as nx
G = nx.DiGraph()
files = list(pathlib.Path("src").rglob("*.py"))
mod_map = {".".join(p.relative_to("src").with_suffix("").parts): str(p) for p in files}
for p in files:
    G.add_node(str(p))
    try: tree = ast.parse(p.read_text(errors="ignore"))
    except SyntaxError: continue
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module in mod_map:
            G.add_edge(str(p), mod_map[node.module])

reachable = set()
for ep in ENTRY_POINTS:
    if ep in G:
        reachable.update(nx.descendants(G, ep) | {ep})

# 3. Classify files
now = datetime.now(timezone.utc)
report = {"stable": [], "dead_candidate": [], "young": []}
for p in files:
    age_days = (now - last_commit_date(str(p))).days
    if age_days > 365 * 2:                       # >2 years untouched
        bucket = "stable" if str(p) in reachable else "dead_candidate"
        report[bucket].append((age_days, str(p)))
    elif age_days < 90:
        report["young"].append((age_days, str(p)))

print(f"Load-bearing stable: {len(report['stable'])}")
print(f"Dead-code candidates: {len(report['dead_candidate'])}")
print()
print("=== Dead code candidates (>2y old AND unreachable from entry points): ===")
for age_days, path in sorted(report["dead_candidate"], reverse=True)[:20]:
    print(f"  {age_days/365:.1f}y  {path}")
```

**Reachability must include dynamic mechanisms.** Plugin systems, entry-point dispatch via `getattr(module, name)`, Django URL routing, Celery `@task` decorators — all defeat static analysis. Add runtime tracing (sys.settrace / coverage.py over a representative test run) for a "true reachable" set, then take the union.

**For dead-code confirmation, run [vulture](https://github.com/jendrikseipp/vulture) or [coverage.py over CI tests]** before deleting. Static reachability finds dead files; vulture finds dead symbols inside live files.

**Pair with `mine-bus-factor`:** old + bus-factor-1 + reachable is the "Maintainer Hit by Bus" risk — load-bearing code only one person understands. Distinct from "dead but feared to delete" — same age signal, very different action.

**Combine with `concept-tfidf-rare-terms`:** old files that contain high-IDF *domain* terms are stable domain code (the kind to preserve); old files containing only generic terms (string utils, hash helpers) are the safer deletion candidates.

**When NOT to apply:**
- Repos where `git log` is heavily rewritten (rebases, squashes) — last-modified date is misleading; use the `committer-date` of the *first* introduction of each line via `git log -L`
- Codebases with build-time-generated files in tree — exclude generated paths from the analysis entirely

Reference: [Eick et al., Does code decay? (TSE 2001)](https://ieeexplore.ieee.org/document/895984), [vulture — find dead Python code](https://github.com/jendrikseipp/vulture)
