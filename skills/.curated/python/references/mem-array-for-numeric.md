---
title: Use array.array for Homogeneous Numeric Data
impact: HIGH
impactDescription: 4-8× memory reduction for numbers
tags: mem, array, numeric, compact-storage
---

## Use array.array for Homogeneous Numeric Data

Lists store pointers to boxed Python objects (~28 bytes per integer). `array.array` stores raw values compactly (4-8 bytes per number).

**Incorrect (boxed integers in list):**

```python
def load_sensor_readings(filepath: str) -> list[int]:
    readings = []
    with open(filepath) as f:
        for line in f:
            readings.append(int(line.strip()))
    return readings
# 1M integers × 28 bytes = ~28MB
```

**Correct (compact array storage):**

```python
from array import array

def load_sensor_readings(filepath: str) -> array:
    readings = array("i")  # 'i' = signed 32-bit integers
    with open(filepath) as f:
        for line in f:
            readings.append(int(line.strip()))
    return readings
# 1M integers × 4 bytes = ~4MB
```

**Common type codes:**
- `'b'` - signed char (1 byte)
- `'i'` - signed int (4 bytes)
- `'l'` - signed long (4-8 bytes)
- `'f'` - float (4 bytes)
- `'d'` - double (8 bytes)

**When NOT to use array.array:**
- When you need mixed types
- When you need NumPy operations
- For small datasets where overhead doesn't matter

Reference: [array documentation](https://docs.python.org/3/library/array.html)
