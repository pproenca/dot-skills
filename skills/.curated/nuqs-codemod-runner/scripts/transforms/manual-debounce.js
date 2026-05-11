/**
 * manual-debounce.js — Replace hand-rolled setTimeout/useState debounce around a nuqs setter.
 *
 * Recognised shape (the version produced by Copilot/ChatGPT before nuqs v2.5 debounce existed):
 *
 *   const [inputValue, setInputValue] = useState(query)
 *   useEffect(() => { setInputValue(query) }, [query])
 *   useEffect(() => {
 *     const t = setTimeout(() => { if (inputValue !== query) setQuery(inputValue || null) }, 300)
 *     return () => clearTimeout(t)
 *   }, [inputValue, query, setQuery])
 *
 * Rewrites to: add `limitUrlUpdates: debounce(<ms>)` to the existing `withOptions(...)` (or
 * insert one) on the matching `useQueryState` call. Removes the mirror state and both
 * effects. Adds `debounce` to the `nuqs` import.
 *
 * This transform is intentionally conservative: it skips any file where the mirror/effects
 * don't match exactly. Skipped files remain in scan.json so the user can review and adjust by hand.
 */
module.exports = function (file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);
  let touched = false;
  let needDebounce = false;

  // For each useQueryState call we find, look at the surrounding scope for the debounce pattern.
  root
    .find(j.CallExpression, { callee: { name: 'useQueryState' } })
    .forEach((useQSPath) => {
      const fnPath = findEnclosingFunctionBody(useQSPath);
      if (!fnPath) return;
      const body = fnPath.node.body;
      if (!body || !Array.isArray(body)) return;

      // Find the destructured setter name from `const [x, setX] = useQueryState(...)`
      const varDecl = useQSPath.parent.parent.node; // VariableDeclarator → VariableDeclaration
      if (varDecl.type !== 'VariableDeclaration') return;
      const declarator = varDecl.declarations.find(
        (d) => d.init === useQSPath.node
      );
      if (!declarator || declarator.id.type !== 'ArrayPattern') return;
      const setterEl = declarator.id.elements[1];
      const stateEl = declarator.id.elements[0];
      if (!setterEl || !stateEl || setterEl.type !== 'Identifier') return;
      const setterName = setterEl.name;
      const stateName = stateEl.type === 'Identifier' ? stateEl.name : null;
      if (!stateName) return;

      // Locate the debounce trio in the same block.
      const trio = matchDebounceTrio(j, body, setterName, stateName);
      if (!trio) return;

      // Splice the trio out of the body.
      const indices = new Set([trio.mirrorIdx, trio.syncEffectIdx, trio.timerEffectIdx]);
      fnPath.node.body = body.filter((_, i) => !indices.has(i));

      // Add `limitUrlUpdates: debounce(<ms>)` to the parser chain.
      addDebounceOption(j, useQSPath, trio.delayMs);
      needDebounce = true;
      touched = true;
    });

  if (!touched) return null;

  // Ensure `debounce` is imported from nuqs.
  root
    .find(j.ImportDeclaration, { source: { value: 'nuqs' } })
    .forEach((p) => {
      const already = p.node.specifiers.some(
        (s) => s.type === 'ImportSpecifier' && s.imported.name === 'debounce'
      );
      if (!already && needDebounce) {
        p.node.specifiers.push(j.importSpecifier(j.identifier('debounce')));
      }
    });

  return root.toSource({ quote: 'single' });
};

function findEnclosingFunctionBody(path) {
  let cur = path;
  while (cur) {
    const t = cur.node && cur.node.type;
    if (
      t === 'FunctionDeclaration' ||
      t === 'FunctionExpression' ||
      t === 'ArrowFunctionExpression'
    ) {
      if (cur.node.body && cur.node.body.type === 'BlockStatement') {
        return { node: cur.node.body };
      }
      return null;
    }
    cur = cur.parent;
  }
  return null;
}

function matchDebounceTrio(j, statements, setterName, stateName) {
  // Find the mirror useState declaration: const [inputValue, setInputValue] = useState(<state>)
  let mirrorIdx = -1;
  let mirrorVarName = null;
  let mirrorSetterName = null;

  for (let i = 0; i < statements.length; i++) {
    const stmt = statements[i];
    if (stmt.type !== 'VariableDeclaration') continue;
    const d = stmt.declarations[0];
    if (!d || d.id.type !== 'ArrayPattern' || !d.init) continue;
    if (
      d.init.type !== 'CallExpression' ||
      d.init.callee.name !== 'useState'
    )
      continue;
    const initArg = d.init.arguments[0];
    if (!initArg || initArg.type !== 'Identifier' || initArg.name !== stateName)
      continue;
    mirrorIdx = i;
    mirrorVarName = d.id.elements[0].name;
    mirrorSetterName = d.id.elements[1].name;
    break;
  }
  if (mirrorIdx < 0) return null;

  // Find the sync useEffect: useEffect(() => { setInputValue(<state>) }, [<state>])
  let syncEffectIdx = -1;
  for (let i = 0; i < statements.length; i++) {
    if (i === mirrorIdx) continue;
    const stmt = statements[i];
    if (
      stmt.type !== 'ExpressionStatement' ||
      stmt.expression.type !== 'CallExpression' ||
      stmt.expression.callee.name !== 'useEffect'
    )
      continue;
    const [cb, deps] = stmt.expression.arguments;
    if (!cb || cb.type !== 'ArrowFunctionExpression') continue;
    const cbBody = cb.body.type === 'BlockStatement' ? cb.body.body : [];
    const ok = cbBody.some(
      (s) =>
        s.type === 'ExpressionStatement' &&
        s.expression.type === 'CallExpression' &&
        s.expression.callee.name === mirrorSetterName &&
        s.expression.arguments[0] &&
        s.expression.arguments[0].type === 'Identifier' &&
        s.expression.arguments[0].name === stateName
    );
    if (ok) {
      syncEffectIdx = i;
      break;
    }
  }

  // Find the timer useEffect: contains setTimeout(() => ..setterName(<mirrorVar>)..)
  let timerEffectIdx = -1;
  let delayMs = 300;
  for (let i = 0; i < statements.length; i++) {
    if (i === mirrorIdx || i === syncEffectIdx) continue;
    const stmt = statements[i];
    if (
      stmt.type !== 'ExpressionStatement' ||
      stmt.expression.type !== 'CallExpression' ||
      stmt.expression.callee.name !== 'useEffect'
    )
      continue;

    const cb = stmt.expression.arguments[0];
    if (!cb || cb.type !== 'ArrowFunctionExpression') continue;
    const cbBody = cb.body.type === 'BlockStatement' ? cb.body.body : [];

    let foundSetTimeout = false;
    cbBody.forEach((s) => {
      if (
        s.type === 'VariableDeclaration' &&
        s.declarations[0] &&
        s.declarations[0].init &&
        s.declarations[0].init.type === 'CallExpression' &&
        s.declarations[0].init.callee.name === 'setTimeout'
      ) {
        const stArgs = s.declarations[0].init.arguments;
        const stCb = stArgs[0];
        const delayArg = stArgs[1];
        if (delayArg && delayArg.type === 'Literal' && typeof delayArg.value === 'number') {
          delayMs = delayArg.value;
        }
        // Verify the callback inside setTimeout calls the nuqs setter
        if (stCb && stCb.body) {
          const inner = stCb.body.type === 'BlockStatement' ? stCb.body.body : [stCb.body];
          const calls = j(inner).find(j.CallExpression, {
            callee: { name: setterName },
          });
          if (calls.size() > 0) foundSetTimeout = true;
        }
      }
    });
    if (foundSetTimeout) {
      timerEffectIdx = i;
      break;
    }
  }

  if (syncEffectIdx < 0 || timerEffectIdx < 0) return null;

  return { mirrorIdx, syncEffectIdx, timerEffectIdx, delayMs };
}

function addDebounceOption(j, useQSPath, ms) {
  // useQueryState('q', parser.withOptions({ ... }))
  // We want to add { limitUrlUpdates: debounce(ms) } to the existing withOptions object,
  // or wrap the second arg with a fresh .withOptions({...}) if absent.
  const args = useQSPath.node.arguments;
  if (args.length < 2) return;

  const parserArg = args[1];
  if (
    parserArg.type === 'CallExpression' &&
    parserArg.callee.type === 'MemberExpression' &&
    parserArg.callee.property.name === 'withOptions' &&
    parserArg.arguments[0] &&
    parserArg.arguments[0].type === 'ObjectExpression'
  ) {
    parserArg.arguments[0].properties.push(
      j.property(
        'init',
        j.identifier('limitUrlUpdates'),
        j.callExpression(j.identifier('debounce'), [j.literal(ms)])
      )
    );
  } else {
    args[1] = j.callExpression(
      j.memberExpression(parserArg, j.identifier('withOptions')),
      [
        j.objectExpression([
          j.property(
            'init',
            j.identifier('limitUrlUpdates'),
            j.callExpression(j.identifier('debounce'), [j.literal(ms)])
          ),
        ]),
      ]
    );
  }
}

module.exports.parser = 'tsx';
