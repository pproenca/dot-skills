/**
 * throttle-ms.js — Replace deprecated `throttleMs: N` with `limitUrlUpdates: throttle(N)`.
 *
 * Detects:
 *   .withOptions({ throttleMs: 300 })
 *   useQueryState('q', parser.withOptions({ throttleMs: 100 }))
 *   setQuery('v', { throttleMs: 0 })           // per-call override
 *
 * Rewrites to:
 *   .withOptions({ limitUrlUpdates: throttle(300) })
 *   setQuery('v', { limitUrlUpdates: defaultRateLimit })  // when throttleMs was 0
 *
 * Also ensures `throttle` (or `defaultRateLimit`) is imported from `nuqs`.
 *
 * Intentionally skipped:
 *   - throttleMs keys outside of an object passed to withOptions/setter call
 *     (validated via parent-shape check)
 */
module.exports = function (file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);

  let touched = false;
  let needThrottle = false;
  let needDefaultRateLimit = false;

  // --- Find Property nodes with key.name === 'throttleMs' inside an ObjectExpression
  //     that is itself an argument to .withOptions(...) or to a setter call.
  root
    .find(j.Property, { key: { name: 'throttleMs' } })
    .forEach((path) => {
      const objExpr = path.parent.node;
      if (objExpr.type !== 'ObjectExpression') return;

      const objExprPath = path.parent;
      const callExpr = objExprPath.parent.node;
      if (!callExpr || callExpr.type !== 'CallExpression') return;

      // Accept: foo.withOptions({...}) OR setX('v', { throttleMs: 0 })
      const isWithOptions =
        callExpr.callee &&
        callExpr.callee.type === 'MemberExpression' &&
        callExpr.callee.property &&
        callExpr.callee.property.name === 'withOptions';

      const isSetterCall =
        callExpr.callee &&
        callExpr.callee.type === 'Identifier' &&
        /^set[A-Z]/.test(callExpr.callee.name) &&
        callExpr.arguments.length >= 2 &&
        callExpr.arguments[callExpr.arguments.length - 1] === objExpr;

      if (!isWithOptions && !isSetterCall) return;

      const valueNode = path.node.value;
      const isZero =
        valueNode.type === 'Literal' && valueNode.value === 0;

      path.node.key = j.identifier('limitUrlUpdates');
      if (isZero) {
        path.node.value = j.identifier('defaultRateLimit');
        needDefaultRateLimit = true;
      } else {
        path.node.value = j.callExpression(j.identifier('throttle'), [valueNode]);
        needThrottle = true;
      }
      touched = true;
    });

  if (!touched) return null;

  // --- Ensure imports from 'nuqs' include the new helpers.
  const nuqsImport = root.find(j.ImportDeclaration, {
    source: { value: 'nuqs' },
  });

  const addSpecifier = (decl, name) => {
    const already = decl.specifiers.some(
      (s) => s.type === 'ImportSpecifier' && s.imported.name === name
    );
    if (!already) {
      decl.specifiers.push(j.importSpecifier(j.identifier(name)));
    }
  };

  if (nuqsImport.size() > 0) {
    nuqsImport.forEach((p) => {
      if (needThrottle) addSpecifier(p.node, 'throttle');
      if (needDefaultRateLimit) addSpecifier(p.node, 'defaultRateLimit');
    });
  } else {
    // No existing 'nuqs' import — bail rather than guess where to insert.
    // The user's lint/typecheck will flag this clearly.
    console.warn(
      `[throttle-ms] ${file.path}: rewrote throttleMs but found no 'nuqs' import to extend. Add: import { throttle } from 'nuqs'`
    );
  }

  return root.toSource({ quote: 'single' });
};

module.exports.parser = 'tsx';
