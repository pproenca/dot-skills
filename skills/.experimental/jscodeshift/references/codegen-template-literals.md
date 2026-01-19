---
title: Use Template Literals for Complex Node Creation
impact: MEDIUM
impactDescription: reduces node creation code by 70-90%
tags: codegen, template, literals, readability
---

## Use Template Literals for Complex Node Creation

jscodeshift's template feature parses code strings into AST nodes. This is more readable than nested builder calls for complex structures.

**Incorrect (deeply nested builders):**

```javascript
// Creating: export const handler = async (req, res) => { return res.json(data); }
const node = j.exportNamedDeclaration(
  j.variableDeclaration('const', [
    j.variableDeclarator(
      j.identifier('handler'),
      j.arrowFunctionExpression(
        [j.identifier('req'), j.identifier('res')],
        j.blockStatement([
          j.returnStatement(
            j.callExpression(
              j.memberExpression(j.identifier('res'), j.identifier('json')),
              [j.identifier('data')]
            )
          )
        ]),
        true // async
      )
    )
  ])
);
```

**Correct (template literal):**

```javascript
// Same result, much more readable
const node = j.template.statement`
  export const handler = async (req, res) => {
    return res.json(data);
  }
`;
```

**Template with interpolation:**

```javascript
// Insert existing nodes into templates
const functionName = j.identifier('processUser');
const paramName = j.identifier('userId');

const node = j.template.statement`
  export function ${functionName}(${paramName}) {
    return fetchUser(${paramName});
  }
`;
```

**Available template methods:**

```javascript
j.template.statement`...`     // Single statement
j.template.statements`...`    // Multiple statements
j.template.expression`...`    // Expression
```

**Note:** Templates are parsed at runtime. Complex templates add parsing overhead - use builders for simple nodes.

Reference: [jscodeshift - Templates](https://jscodeshift.com/build/api-reference/#templates)
