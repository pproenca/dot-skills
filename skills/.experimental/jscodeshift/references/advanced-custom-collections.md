---
title: Create Custom Collection Methods
impact: LOW
impactDescription: reduces query code by 50-80% through reuse
tags: advanced, collections, custom-methods, reusability
---

## Create Custom Collection Methods

jscodeshift allows registering custom collection methods for frequently used query patterns. This improves code reuse and readability.

**Incorrect (repeating complex queries):**

```javascript
// Same complex query repeated in multiple transforms
root.find(j.CallExpression)
  .filter(path => {
    const callee = path.node.callee;
    return callee.type === 'MemberExpression' &&
           callee.object.name === 'React' &&
           callee.property.name === 'createElement';
  });

// Copy-pasted to every transform that needs it
```

**Correct (custom collection method):**

```javascript
// Register once at module load
const jscodeshift = require('jscodeshift');

// Add custom method to collections
jscodeshift.registerMethods({
  findReactCreateElement: function() {
    return this.find(jscodeshift.CallExpression).filter(path => {
      const callee = path.node.callee;
      return callee.type === 'MemberExpression' &&
             callee.object?.name === 'React' &&
             callee.property?.name === 'createElement';
    });
  },

  findHooks: function(hookName) {
    return this.find(jscodeshift.CallExpression, {
      callee: { name: hookName || /^use[A-Z]/ }
    });
  },

  findComponentDefinitions: function() {
    // Finds both function and arrow function components
    return this.find(jscodeshift.FunctionDeclaration)
      .filter(path => /^[A-Z]/.test(path.node.id?.name))
      .concat(
        this.find(jscodeshift.VariableDeclarator)
          .filter(path =>
            /^[A-Z]/.test(path.node.id?.name) &&
            (path.node.init?.type === 'ArrowFunctionExpression' ||
             path.node.init?.type === 'FunctionExpression')
          )
      );
  }
});

// Usage in transforms
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);

  // Clean, readable queries
  root.findReactCreateElement()
    .replaceWith(/* ... */);

  root.findHooks('useState')
    .forEach(/* ... */);

  root.findComponentDefinitions()
    .forEach(/* ... */);

  return root.toSource();
};
```

**Note:** Register methods in a shared setup file that all transforms import.

Reference: [jscodeshift - registerMethods](https://jscodeshift.com/build/api-reference/)
