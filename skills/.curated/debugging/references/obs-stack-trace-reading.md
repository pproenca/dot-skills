---
title: Read Stack Traces Bottom to Top
impact: HIGH
impactDescription: 5-10× faster error localization; reveals full call chain context
tags: obs, stack-trace, errors, exceptions, call-chain
---

## Read Stack Traces Bottom to Top

Stack traces show the call chain with the most recent (and usually most relevant) frame at the bottom. Start reading from the bottom where the error occurred, then work up to understand how you got there.

**Incorrect (reading top to bottom):**

```python
Traceback (most recent call last):
  File "main.py", line 5, in <module>      # Start here? No!
    run_app()
  File "app.py", line 23, in run_app
    process_request(request)
  File "handler.py", line 45, in process_request
    data = parse_input(request.body)
  File "parser.py", line 12, in parse_input
    return json.loads(text)
  File "/usr/lib/python3/json/__init__.py", line 346
    raise JSONDecodeError(...)
json.decoder.JSONDecodeError: Expecting value: line 1 column 1

# Developer starts debugging main.py - wrong place!
```

**Correct (reading bottom to top):**

```python
Traceback (most recent call last):
  File "main.py", line 5, in <module>
    run_app()
  File "app.py", line 23, in run_app
    process_request(request)
  File "handler.py", line 45, in process_request
    data = parse_input(request.body)         # 3. Called parse_input
  File "parser.py", line 12, in parse_input  # 2. With what body?
    return json.loads(text)                   # 1. START HERE: json.loads failed
  File "/usr/lib/python3/json/__init__.py", line 346
    raise JSONDecodeError(...)
json.decoder.JSONDecodeError: Expecting value: line 1 column 1

# Reading bottom-to-top:
# 1. BOTTOM: JSONDecodeError on empty/invalid JSON
# 2. UP: In parse_input, calling json.loads(text)
# 3. UP: Called from process_request with request.body
# Question: What was request.body? Likely an empty string.
```

**Stack trace reading strategy:**

```text
BOTTOM (Error Location):
└── What exception? What message?
└── What line threw it?
└── What were the arguments?

MIDDLE (Your Code):
└── Find the topmost frame in YOUR code
└── This is usually where the bug actually is
└── Look at the data being passed

TOP (Entry Point):
└── How did we get here?
└── What triggered this code path?
└── Useful for understanding context
```

**Skip library frames, focus on your code:**

```python
# Look for frames in YOUR code, not libraries:
  File "parser.py", line 12, in parse_input  # <-- YOUR CODE
    return json.loads(text)
  File "/usr/lib/python3/json/__init__.py"   # <-- LIBRARY (skip)
```

**When NOT to use this pattern:**
- Errors in library code due to version bugs
- Stack traces truncated or missing

Reference: [Python Documentation - Traceback](https://docs.python.org/3/library/traceback.html)
