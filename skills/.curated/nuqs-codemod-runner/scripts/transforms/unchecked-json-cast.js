/**
 * unchecked-json-cast.js — Flag parseAsJson() calls that lack a real validator.
 *
 * Two forms are unsafe:
 *   (a) parseAsJson<T>()                        — no argument; in nuqs v2 this is a TS error,
 *                                                  but some codebases @ts-ignore it.
 *   (b) parseAsJson((v) => v as T)              — unchecked cast disguised as a validator.
 *
 * This transform doesn't generate a complete validator (we can't know the user's intent),
 * but it inserts a TODO marker and either:
 *   - replaces the body with a `null` placeholder so the file stops compiling cleanly
 *     (forcing the user to write a real guard), OR
 *   - if Zod is detected in the project's package.json (passed via env CODEMOD_HAS_ZOD=1),
 *     inserts a `__TODO_ZodSchema__.parse` placeholder for the user to wire up.
 *
 * Either way, the resulting file fails typecheck, surfacing the change clearly during
 * verify.sh and pinpointing where the user must intervene.
 */
module.exports = function (file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);
  const hasZod = process.env.CODEMOD_HAS_ZOD === '1';
  let touched = false;

  root
    .find(j.CallExpression, { callee: { name: 'parseAsJson' } })
    .forEach((path) => {
      const node = path.node;
      const args = node.arguments;

      // Case (a): no arguments
      if (args.length === 0) {
        node.arguments = [
          hasZod
            ? j.memberExpression(
                j.identifier('__TODO_ZodSchema__'),
                j.identifier('parse')
              )
            : buildTodoGuard(j),
        ];
        addLeadingComment(
          j,
          path,
          ' TODO(nuqs-codemod): parseAsJson requires a runtime validator. Replace this stub.'
        );
        touched = true;
        return;
      }

      // Case (b): a single arrow `(v) => v as T`
      const first = args[0];
      if (
        first &&
        first.type === 'ArrowFunctionExpression' &&
        first.body &&
        first.body.type === 'TSAsExpression'
      ) {
        node.arguments[0] = hasZod
          ? j.memberExpression(
              j.identifier('__TODO_ZodSchema__'),
              j.identifier('parse')
            )
          : buildTodoGuard(j);
        addLeadingComment(
          j,
          path,
          ' TODO(nuqs-codemod): replaced unchecked cast — write a real type guard or Standard Schema.'
        );
        touched = true;
      }
    });

  return touched ? root.toSource({ quote: 'single' }) : null;
};

function buildTodoGuard(j) {
  // (value: unknown) => (null as never)  — placeholder that won't compile, forcing attention.
  return j.arrowFunctionExpression(
    [
      Object.assign(j.identifier('value'), {
        typeAnnotation: j.tsTypeAnnotation(j.tsUnknownKeyword()),
      }),
    ],
    j.tsAsExpression(j.nullLiteral(), j.tsNeverKeyword())
  );
}

function addLeadingComment(j, path, text) {
  const stmt = findEnclosingStatement(path);
  if (!stmt || !stmt.node) return;
  const comment = j.commentLine(text, true, false);
  stmt.node.comments = (stmt.node.comments || []).concat([comment]);
}

function findEnclosingStatement(path) {
  let cur = path;
  while (cur && cur.node && !/Statement$|^Program$/.test(cur.node.type)) {
    cur = cur.parent;
  }
  return cur;
}

module.exports.parser = 'tsx';
