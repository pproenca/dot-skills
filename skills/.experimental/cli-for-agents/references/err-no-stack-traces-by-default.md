---
title: Reserve Stack Traces for --debug Mode
impact: MEDIUM-HIGH
impactDescription: reduces default error output by 10-50x
tags: err, stack-traces, debug, verbose
---

## Reserve Stack Traces for --debug Mode

A 40-line Python traceback dumped on a simple "file not found" wastes agent context and obscures the actual problem. Default errors should be one-line and actionable; stack traces belong in `--debug` mode or an opt-in `$MYCLI_DEBUG=1` env var. This is not about hiding errors — it's about putting the signal first and the diagnostic detail second.

**Incorrect (uncaught exceptions print full traceback):**

```python
import json
import sys

def load_config(path: str) -> dict:
    with open(path) as f:
        return json.load(f)

if __name__ == '__main__':
    cfg = load_config(sys.argv[1])
    print(cfg)

# Invoking with a missing file produces:
#   Traceback (most recent call last):
#     File "mycli.py", line 8, in <module>
#       cfg = load_config(sys.argv[1])
#     File "mycli.py", line 5, in load_config
#       with open(path) as f:
#   FileNotFoundError: [Errno 2] No such file or directory: 'missing.json'
```

**Correct (one-line error by default, traceback under --debug):**

```python
import json
import os
import sys
import traceback

def load_config(path: str) -> dict:
    with open(path) as f:
        return json.load(f)

def main() -> int:
    try:
        cfg = load_config(sys.argv[1])
        print(cfg)
        return 0
    except FileNotFoundError as e:
        print(f"Error: config file not found: {e.filename}", file=sys.stderr)
        print(f"  mycli --config ./config.json", file=sys.stderr)
        if os.environ.get('MYCLI_DEBUG'):
            traceback.print_exc(file=sys.stderr)
        return 2
    except json.JSONDecodeError as e:
        print(f"Error: invalid JSON in config: {e.msg} (line {e.lineno})", file=sys.stderr)
        if os.environ.get('MYCLI_DEBUG'):
            traceback.print_exc(file=sys.stderr)
        return 2

if __name__ == '__main__':
    sys.exit(main())
```

**When NOT to use this pattern:**
- Unexpected internal errors (not caused by user input) should print a traceback and a bug-report URL — the user cannot fix them and the traceback helps the maintainer

Reference: [clig.dev — Minimize noise in output](https://clig.dev/#output)
