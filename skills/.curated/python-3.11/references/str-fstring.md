---
title: Use f-strings for Simple String Formatting
impact: MEDIUM
impactDescription: 20-30% faster than .format()
tags: str, fstring, formatting, performance
---

## Use f-strings for Simple String Formatting

f-strings (formatted string literals) are the fastest option for simple string formatting, outperforming `%` formatting and `.format()`.

**Incorrect (slower formatting methods):**

```python
def format_user_greeting(name: str, age: int) -> str:
    # Old-style % formatting
    return "Hello, %s! You are %d years old." % (name, age)

def format_user_greeting_v2(name: str, age: int) -> str:
    # .format() method
    return "Hello, {}! You are {} years old.".format(name, age)
```

**Correct (f-string):**

```python
def format_user_greeting(name: str, age: int) -> str:
    return f"Hello, {name}! You are {age} years old."
```

**f-string features:**

```python
# Expressions
total = f"Total: ${price * quantity:.2f}"

# Alignment and padding
header = f"{'Name':<20} {'Age':>5} {'Score':^10}"

# Debug format (Python 3.8+)
debug = f"{user_id=}, {status=}"  # Outputs: "user_id=42, status='active'"

# Multiline
message = f"""
Dear {name},
Your order #{order_id} has been shipped.
"""
```

Reference: [PEP 498 - Literal String Interpolation](https://peps.python.org/pep-0498/)
