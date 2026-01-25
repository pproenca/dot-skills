---
title: Avoid Stack Traces in User-Facing Errors
impact: HIGH
impactDescription: improves usability for non-developers
tags: error, stack-trace, usability, debugging
---

## Avoid Stack Traces in User-Facing Errors

Stack traces are useful for developers but overwhelming for users. Show clean error messages by default; reserve stack traces for debug mode.

**Incorrect (dumps internal details to users):**

```python
# Python script that vomits internals
if __name__ == "__main__":
    process_file(sys.argv[1])
```

```bash
$ mytool missing.txt
Traceback (most recent call last):
  File "/usr/local/bin/mytool", line 45, in <module>
    process_file(sys.argv[1])
  File "/usr/local/lib/mytool/processor.py", line 123, in process_file
    with open(filename) as f:
FileNotFoundError: [Errno 2] No such file or directory: 'missing.txt'
# User sees internals they don't understand
```

**Correct (clean errors, debug mode for details):**

```python
import sys
import traceback

def main():
    try:
        process_file(sys.argv[1])
    except FileNotFoundError as e:
        print(f"mytool: {e.filename}: {e.strerror}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"mytool: internal error: {e}", file=sys.stderr)
        if os.getenv("DEBUG"):
            traceback.print_exc()
        else:
            print("  Run with DEBUG=1 for details", file=sys.stderr)
        sys.exit(70)  # EX_SOFTWARE
```

```bash
# Clean error for users
$ mytool missing.txt
mytool: missing.txt: No such file or directory

# Developers can get details when needed
$ DEBUG=1 mytool corrupt.dat
mytool: internal error: invalid header checksum
Traceback (most recent call last):
  ...
```

**When to show technical details:**
- `--debug` or `-d` flag is set
- `DEBUG` environment variable is set
- Error is clearly a bug (internal assertion, unexpected exception)

Reference: [Command Line Interface Guidelines](https://clig.dev/)
