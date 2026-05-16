#!/usr/bin/env python3
"""Regression tests for analyze_complexity.py — pins the false-positive fixes.

Run with: python3 scripts/test_analyze_complexity.py
Exits 0 on success, 1 on any failure.
"""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from textwrap import dedent

HERE = Path(__file__).resolve().parent
SCANNER = HERE / "analyze_complexity.py"


def run(args: list[str], cwd: Path | None = None) -> tuple[int, str, str]:
    proc = subprocess.run(
        [sys.executable, str(SCANNER), *args],
        capture_output=True,
        text=True,
        cwd=cwd,
    )
    return proc.returncode, proc.stdout, proc.stderr


def write(root: Path, rel: str, content: str) -> Path:
    path = root / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(dedent(content).lstrip("\n"))
    return path


def findings_of(stdout: str) -> list[dict]:
    data = json.loads(stdout)
    return data["findings"] if isinstance(data, dict) else data


class TestCase:
    def __init__(self, name: str, fn):
        self.name = name
        self.fn = fn

    def run(self) -> tuple[bool, str]:
        try:
            self.fn()
            return True, ""
        except AssertionError as exc:
            return False, str(exc) or "assertion failed"
        except Exception as exc:
            return False, f"{exc.__class__.__name__}: {exc}"


CASES: list[TestCase] = []


def case(name: str):
    def wrap(fn):
        CASES.append(TestCase(name, fn))
        return fn

    return wrap


@case("real nested for-loop in Python IS flagged")
def _():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        write(root, "real.py", """
            def find_dupes(items):
                dupes = []
                for a in items:
                    for b in items:
                        if a != b and a.name == b.name:
                            dupes.append(a)
                return dupes
            """)
        code, out, _ = run([str(root), "--format", "json"])
        assert code == 0
        kinds = [f["kind"] for f in findings_of(out)]
        assert "nested-loop" in kinds, f"expected nested-loop, got: {kinds}"


@case("benign React component with .find() + .map() is NOT flagged as nested")
def _():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        write(root, "Component.tsx", """
            const MAX_RETRIES = 5;

            export function UserList({ users, selectedId }) {
              const selected = users.find(u => u.id === selectedId);
              return (
                <ul>
                  {users.map(u => <li key={u.id}>{u.name}</li>)}
                </ul>
              );
            }
            """)
        code, out, _ = run([str(root), "--format", "json"])
        assert code == 0
        kinds = [f["kind"] for f in findings_of(out)]
        assert "nested-or-callback-loop" not in kinds, f"false positive: {kinds}"
        assert "membership-in-loop" not in kinds, f"false positive: {kinds}"


@case("two unrelated top-level fns do NOT cross-pollinate loop_stack")
def _():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        write(root, "utils.ts", """
            export function findById(arr, id) {
              return arr.find(u => u.id === id);
            }

            export function getNames(arr) {
              return arr.map(u => u.name);
            }
            """)
        code, out, _ = run([str(root), "--format", "json"])
        assert code == 0
        assert findings_of(out) == [], f"expected no findings, got: {findings_of(out)}"


@case("SCREAMING_SNAKE const does NOT trigger render-path mode")
def _():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        write(root, "constants.ts", """
            const MAX_RETRIES = 5;
            const API_URL = 'https://api.example.com';

            export function pickActive(items) {
              return items.filter(i => i.active).map(i => i.id);
            }
            """)
        code, out, _ = run([str(root), "--format", "json"])
        assert code == 0
        kinds = [f["kind"] for f in findings_of(out)]
        assert "render-derived-work" not in kinds, f"false positive: {kinds}"


@case("bad path exits 2 with actionable error")
def _():
    code, out, err = run(["/this/does/not/exist"])
    assert code == 2, f"expected exit 2, got {code}"
    assert "does not exist" in err, f"missing actionable error, got: {err!r}"


@case("file as root exits 2 with hint")
def _():
    with tempfile.TemporaryDirectory() as tmp:
        f = Path(tmp) / "lonely.py"
        f.write_text("x = 1\n")
        code, _, err = run([str(f)])
        assert code == 2
        assert "must be a directory" in err, f"missing hint, got: {err!r}"


@case("zero files matched exits 3")
def _():
    with tempfile.TemporaryDirectory() as tmp:
        Path(tmp, "README.md").write_text("# nope\n")  # unsupported ext
        code, _, err = run([str(tmp)])
        assert code == 3, f"expected exit 3, got {code}"
        assert "Scanned 0 files" in err or "scanned 0 files" in err


@case(".vue and .svelte files ARE scanned")
def _():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        write(root, "App.vue", """
            <script setup>
            for (const a of items) {
              for (const b of items) {
                if (a === b) continue;
              }
            }
            </script>
            """)
        write(root, "App.svelte", """
            <script>
            export let items;
            for (const a of items) {
              for (const b of items) {
                console.log(a, b);
              }
            }
            </script>
            """)
        code, out, _ = run([str(root), "--format", "json"])
        assert code == 0
        data = json.loads(out)
        assert data["files_scanned"] == 2, f"expected 2 scanned, got {data}"
        kinds = [f["kind"] for f in data["findings"]]
        assert "nested-or-callback-loop" in kinds, f"vue/svelte not analyzed: {kinds}"


@case("Redux-style selectFoo call is NOT flagged as io-or-query-in-loop")
def _():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        write(root, "selectors.ts", """
            export function makeRows(state, ids) {
              return ids.map(id => selectUserById(state, id));
            }
            """)
        code, out, _ = run([str(root), "--format", "json"])
        assert code == 0
        kinds = [f["kind"] for f in findings_of(out)]
        assert "io-or-query-in-loop" not in kinds, f"selectUserById misflagged: {kinds}"


@case("Prisma findMany inside loop IS flagged")
def _():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        write(root, "n_plus_one.ts", """
            export async function loadComments(posts) {
              const out = [];
              for (const p of posts) {
                out.push(await prisma.comment.findMany({ where: { postId: p.id } }));
              }
              return out;
            }
            """)
        code, out, _ = run([str(root), "--format", "json"])
        assert code == 0
        kinds = [f["kind"] for f in findings_of(out)]
        assert "io-or-query-in-loop" in kinds, f"prisma N+1 not flagged: {kinds}"


@case("JSON output includes files_scanned + files_failed counts")
def _():
    with tempfile.TemporaryDirectory() as tmp:
        write(Path(tmp), "x.py", "x = 1\n")
        write(Path(tmp), "y.ts", "const y = 1;\n")
        code, out, _ = run([str(tmp), "--format", "json"])
        assert code == 0
        data = json.loads(out)
        assert data["files_scanned"] == 2
        assert data["files_failed"] == 0
        assert isinstance(data["findings"], list)


@case("--changed-only requires a git repo, fails gracefully without one")
def _():
    with tempfile.TemporaryDirectory() as tmp:
        write(Path(tmp), "a.ts", "const a = 1;\n")
        code, _, err = run([str(tmp), "--changed-only"])
        assert code == 2, f"expected exit 2 on non-git dir, got {code}"
        assert "git diff failed" in err or "git" in err, f"missing git error, got: {err!r}"


@case("--changed-only scopes to files in git diff")
def _():
    if shutil.which("git") is None:
        return  # skip
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        subprocess.run(["git", "init", "-q"], cwd=root, check=True)
        subprocess.run(["git", "-C", str(root), "config", "user.email", "t@t.t"], check=True)
        subprocess.run(["git", "-C", str(root), "config", "user.name", "t"], check=True)
        write(root, "untouched.py", "x = 1\n")
        write(root, "touched.py", "x = 1\n")
        subprocess.run(["git", "-C", str(root), "add", "."], check=True)
        subprocess.run(
            ["git", "-C", str(root), "commit", "-q", "-m", "init"],
            check=True,
            env={**__import__("os").environ, "GIT_AUTHOR_NAME": "t", "GIT_COMMITTER_NAME": "t",
                 "GIT_AUTHOR_EMAIL": "t@t.t", "GIT_COMMITTER_EMAIL": "t@t.t"},
        )
        write(root, "touched.py", """
            def f(items):
                for a in items:
                    for b in items:
                        pass
            """)
        subprocess.run(["git", "-C", str(root), "add", "touched.py"], check=True)
        subprocess.run(
            ["git", "-C", str(root), "commit", "-q", "-m", "edit"],
            check=True,
            env={**__import__("os").environ, "GIT_AUTHOR_NAME": "t", "GIT_COMMITTER_NAME": "t",
                 "GIT_AUTHOR_EMAIL": "t@t.t", "GIT_COMMITTER_EMAIL": "t@t.t"},
        )
        code, out, _ = run([str(root), "--changed-only", "--base", "HEAD~1", "--format", "json"])
        assert code == 0, f"expected exit 0, got {code}"
        data = json.loads(out)
        assert data["files_scanned"] == 1, f"expected 1 changed file scanned, got {data}"
        paths = {f["path"] for f in data["findings"]}
        assert all("touched" in p for p in paths), f"untouched file leaked: {paths}"


def main() -> int:
    failed = 0
    for c in CASES:
        ok, msg = c.run()
        marker = "✓" if ok else "✗"
        print(f"  {marker} {c.name}")
        if not ok:
            print(f"      {msg}")
            failed += 1
    total = len(CASES)
    print(f"\n{total - failed}/{total} passed")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
