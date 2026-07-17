---
title: Use pathlib for filesystem paths
tags: std, pathlib, filesystem, os-path
---

## Use pathlib for filesystem paths

`os.path` treats paths as strings, so every operation is a free function over
string surgery — `os.path.join(os.path.dirname(...), ...)` pyramids,
`splitext()[0]` index tricks — and reading/writing a file takes a separate
`open` dance. `pathlib.Path` has been the stdlib's object-oriented path API
since 3.4 and composes: `/` joins, `.stem`/`.suffix`/`.parent` decompose,
`.read_text()`/`.write_bytes()` do whole-file I/O, `.glob()` walks. New code
reaching for `os.path` is training-data inertia, and mixing the two dialects in
one codebase makes every path variable's type a guess.

**Incorrect (string surgery across three calls):**

```python
report_dir = os.path.join(os.path.dirname(config_file), "reports")
report_name = os.path.splitext(os.path.basename(source))[0] + ".pdf"
with open(os.path.join(report_dir, report_name), "wb") as fh:
    fh.write(rendered)
```

**Correct (paths compose as objects):**

```python
report_dir = Path(config_file).parent / "reports"
report_path = report_dir / Path(source).with_suffix(".pdf").name
report_path.write_bytes(rendered)
```

**Evidence of violation:** calls to `os.path.join`, `os.path.dirname`,
`os.path.basename`, `os.path.splitext`, `os.path.exists`, or path assembly via
string concatenation/f-strings with separators, in code the target adds or
modifies. PASS: paths travel as `pathlib.Path` and operations use its methods.
Carve-out (cite it): the value crosses into an API that requires `str` —
convert at that edge with `str(path)` or `os.fspath`, which is a PASS; a
whole-function `os.*` low-level sequence (fd-based I/O, `os.replace`
atomicity on an open fd) where pathlib has no equivalent, cited per call. N/A:
no filesystem path handling in the target.

Reference: [pathlib — Python documentation](https://docs.python.org/3/library/pathlib.html)
