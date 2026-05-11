/**
 * parser-builder-type.js — Rename ParserBuilder<T> imports/refs to SingleParserBuilder<T>.
 *
 * Detects:
 *   import { ParserBuilder, type ParserBuilder } from 'nuqs'
 *   const p: ParserBuilder<number> = ...
 *   function make(): ParserBuilder<T> { ... }
 *
 * Rewrites to SingleParserBuilder in all positions. Only touches identifiers that came
 * from a 'nuqs' import (we ignore unrelated ParserBuilder names elsewhere).
 */
module.exports = function (file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);

  // 1. Find the 'nuqs' import and check whether it brings in ParserBuilder.
  const nuqsImports = root.find(j.ImportDeclaration, {
    source: { value: 'nuqs' },
  });

  let importedAs = null; // local name (handles `import { ParserBuilder as PB } from 'nuqs'`)
  nuqsImports.forEach((path) => {
    path.node.specifiers.forEach((spec) => {
      if (
        spec.type === 'ImportSpecifier' &&
        spec.imported.name === 'ParserBuilder'
      ) {
        importedAs = spec.local ? spec.local.name : spec.imported.name;
        // Rename the imported name itself
        spec.imported = j.identifier('SingleParserBuilder');
        if (spec.local && spec.local.name === 'ParserBuilder') {
          spec.local = j.identifier('SingleParserBuilder');
        }
      }
    });
  });

  if (!importedAs) return null;

  // 2. Rename every TS reference to the imported local name within this file.
  const localName = importedAs;
  const targetName =
    localName === 'ParserBuilder' ? 'SingleParserBuilder' : localName;
  if (localName === 'ParserBuilder') {
    // Identifier rename — covers TSTypeReference, generic args, etc.
    root.find(j.Identifier, { name: 'ParserBuilder' }).forEach((path) => {
      // Skip the ImportSpecifier we already rewrote above
      if (
        path.parent.node.type === 'ImportSpecifier' &&
        path.parent.node.imported &&
        path.parent.node.imported.name === 'SingleParserBuilder'
      )
        return;
      path.node.name = 'SingleParserBuilder';
    });
  }
  // If it was aliased (`import { ParserBuilder as PB } from 'nuqs'`), the local
  // name PB is already correct in the rest of the file — no further rename needed.

  return root.toSource({ quote: 'single' });
};

module.exports.parser = 'tsx';
