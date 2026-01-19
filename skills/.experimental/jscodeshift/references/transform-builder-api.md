---
title: Use Builder API for Creating AST Nodes
impact: HIGH
impactDescription: prevents malformed AST nodes that crash toSource()
tags: transform, builder, api, node-creation
---

## Use Builder API for Creating AST Nodes

Manually constructing AST node objects is error-prone. Use jscodeshift's builder methods which validate required properties.

**Incorrect (manual object construction):**

```javascript
// Missing required properties, incorrect structure
const newNode = {
  type: 'CallExpression',
  callee: { type: 'Identifier', name: 'newFunc' },
  arguments: args
  // Missing: optional, typeParameters, etc.
};

path.replace(newNode);
// May crash toSource() or produce invalid code
```

**Correct (builder API):**

```javascript
// Builder validates structure and sets defaults
const newNode = j.callExpression(
  j.identifier('newFunc'),
  args
);

path.replace(newNode);
```

**Common builder methods:**

```javascript
// Identifiers and literals
j.identifier('name')
j.literal('string')
j.literal(42)

// Expressions
j.callExpression(callee, arguments)
j.memberExpression(object, property)
j.arrowFunctionExpression(params, body, expression)

// Statements
j.variableDeclaration('const', [declarator])
j.variableDeclarator(id, init)
j.returnStatement(argument)
j.expressionStatement(expression)

// Import/Export
j.importDeclaration(specifiers, source)
j.importSpecifier(imported, local)
j.importDefaultSpecifier(local)
```

**Note:** Builder method names match AST node types with camelCase. `CallExpression` → `j.callExpression()`.

Reference: [ast-types Builders](https://github.com/benjamn/ast-types#builders)
