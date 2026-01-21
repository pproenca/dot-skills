---
title: Use (( )) for Arithmetic Comparisons
impact: MEDIUM
impactDescription: provides clearer syntax and prevents string comparison bugs
tags: test, arithmetic, numeric, comparison
---

## Use (( )) for Arithmetic Comparisons

Using `[ ]` or `[[ ]]` with `-eq`, `-lt` for numbers is error-prone. `(( ))` provides natural math syntax and fails clearly on non-numeric input.

**Incorrect (string-based numeric comparison):**

```bash
#!/bin/bash
count="10"

# Confusing operators
if [ "$count" -gt 5 ]; then
  echo "greater"
fi

# String comparison mistake
if [[ "$count" > "5" ]]; then   # String comparison! "10" < "5"
  echo "greater"  # Not printed! "10" sorts before "5" alphabetically
fi

# Using let (deprecated)
let "count = count + 1"

# Using expr (external command, slow)
count=$(expr $count + 1)

# Using $[ ] (deprecated)
count=$[ count + 1 ]
```

**Correct (arithmetic context):**

```bash
#!/bin/bash
count=10

# Natural comparison syntax
if (( count > 5 )); then
  echo "greater"
fi

# Arithmetic assignment
(( count++ ))
(( count += 5 ))
(( count = count * 2 ))

# Arithmetic in expressions
result=$(( count + 5 ))
result=$(( (count + 5) * 2 ))

# Multiple conditions
if (( count > 5 && count < 20 )); then
  echo "in range"
fi
```

**Arithmetic operators:**

```bash
#!/bin/bash
a=10
b=3

# Arithmetic expression operators
(( sum = a + b ))        # Addition: 13
(( diff = a - b ))       # Subtraction: 7
(( prod = a * b ))       # Multiplication: 30
(( quot = a / b ))       # Division (integer): 3
(( rem = a % b ))        # Modulo: 1
(( pow = a ** 2 ))       # Exponentiation: 100

# Comparison operators (return 0=true, 1=false)
(( a == b ))             # Equal
(( a != b ))             # Not equal
(( a > b ))              # Greater than
(( a >= b ))             # Greater or equal
(( a < b ))              # Less than
(( a <= b ))             # Less or equal

# Increment/decrement
(( a++ ))                # Post-increment
(( ++a ))                # Pre-increment
(( a-- ))                # Post-decrement
(( a += 5 ))             # Add and assign
(( a *= 2 ))             # Multiply and assign

# Ternary operator
(( max = a > b ? a : b ))
```

**Combining with conditionals:**

```bash
#!/bin/bash
# (( )) returns exit status 0 if non-zero, 1 if zero
count=0

if (( count )); then
  echo "count is non-zero"
else
  echo "count is zero"
fi

# Use in while loops
while (( count < 10 )); do
  echo "$count"
  (( count++ ))
done

# C-style for loop
for (( i = 0; i < 10; i++ )); do
  echo "$i"
done
```

**Note: Variables don't need $ inside (( )):**

```bash
#!/bin/bash
x=5
y=10

# $ is optional inside (( ))
(( z = x + y ))          # Works
(( z = $x + $y ))        # Also works, but unnecessary

# But needed for special variables
(( z = ${array[0]} ))    # Array access needs ${}
```

Reference: [Bash Manual - Arithmetic Evaluation](https://www.gnu.org/software/bash/manual/html_node/Shell-Arithmetic.html)
