---
title: Use Rest Parameters Instead of arguments Object
impact: MEDIUM
impactDescription: eliminates Array.prototype.slice.call boilerplate
tags: func, rest-parameters, arguments, variadic
---

## Use Rest Parameters Instead of arguments Object

Use rest parameters (`...args`) instead of the `arguments` object. Rest parameters are real arrays with proper methods and work with arrow functions.

**Incorrect (arguments object limitations):**

```javascript
function sum() {
  // arguments is not a real array
  const total = Array.prototype.reduce.call(arguments, (acc, val) => acc + val, 0);
  return total;
}

function logWithPrefix() {
  const prefix = arguments[0];
  // Slicing arguments is awkward
  const messages = Array.prototype.slice.call(arguments, 1);
  messages.forEach(msg => console.log(`${prefix}: ${msg}`));
}

// arguments doesn't work in arrow functions
const multiply = () => {
  return arguments[0] * arguments[1];  // ReferenceError in arrow function
};
```

**Correct (rest parameters):**

```javascript
function sum(...numbers) {
  // numbers is a real array
  return numbers.reduce((acc, val) => acc + val, 0);
}

function logWithPrefix(prefix, ...messages) {
  // Clean separation of named and rest params
  messages.forEach(msg => console.log(`${prefix}: ${msg}`));
}

// Works in arrow functions
const multiply = (...numbers) => {
  return numbers.reduce((acc, val) => acc * val, 1);
};
```

**JSDoc for rest parameters:**

```javascript
/**
 * Joins strings with a separator.
 * @param {string} separator The separator.
 * @param {...string} parts The parts to join.
 * @return {string} The joined string.
 */
function join(separator, ...parts) {
  return parts.join(separator);
}
```

Reference: [Google JavaScript Style Guide - Rest parameters](https://google.github.io/styleguide/jsguide.html#features-rest-parameters)
