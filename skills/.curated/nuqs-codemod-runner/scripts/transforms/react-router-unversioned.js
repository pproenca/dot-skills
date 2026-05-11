/**
 * react-router-unversioned.js — Pin nuqs/adapters/react-router to /v6.
 *
 * Detects:
 *   import { NuqsAdapter } from 'nuqs/adapters/react-router'
 *
 * Rewrites to:
 *   import { NuqsAdapter } from 'nuqs/adapters/react-router/v6'
 *
 * Rationale: the unversioned alias historically pointed at v6 and is removed in nuqs v3.
 * If the project is actually on React Router v7, the typecheck will catch the wrong adapter
 * and we'll re-run with /v7 by hand.
 */
module.exports = function (file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);
  let touched = false;

  root
    .find(j.ImportDeclaration, {
      source: { value: 'nuqs/adapters/react-router' },
    })
    .forEach((path) => {
      path.node.source = j.literal('nuqs/adapters/react-router/v6');
      touched = true;
    });

  return touched ? root.toSource({ quote: 'single' }) : null;
};

module.exports.parser = 'tsx';
