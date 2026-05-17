#!/usr/bin/env node
// detect-ast.mjs — Structural detectors via ts-morph AST analysis.
// Part of: react-hook-form-audit
//
// Implements:
//   Rule 1  sub-usewatch-over-watch          watch() in same component as useForm()
//   Rule 2  sub-watch-specific-fields        watch() with no args
//   Rule 3  formcfg-default-values           useForm without defaultValues
//   Rule 4  formcfg-useeffect-dependency     useEffect depending on useForm return
//   Rule 6  ctrl-usecontroller-isolation     <Controller> inlined in useForm parent
//   Rule 7  formstate-async-submit-lifecycle async submit without try/catch
//   Rule 8  valid-resolver-caching           schema defined inside component
//   Rule 9  valid-server-errors              submit fetches but never setError('root.*')
//   Rule 10 next-rhf-useactionstate-mix      RHF + useActionState in same component
//   Rule 12 formcfg-disabled-prop            register({ disabled: <state> }) for visual disable
//   Rule 13 array-use-field-id-as-key        useFieldArray map missing field.id key
//   Rule 15 sub-useformcontext-sparingly     bare useFormContext() usage flagged
//
// Output: JSON array of findings on stdout.

import { resolve, dirname, relative } from 'node:path';
import { fileURLToPath } from 'node:url';
import { readFileSync, existsSync } from 'node:fs';
import { createRequire } from 'node:module';

// Load ts-morph from this script's local node_modules (installed by audit.sh).
const here = dirname(fileURLToPath(import.meta.url));
const require_ = createRequire(import.meta.url);
const tsMorphPath = resolve(here, 'node_modules', 'ts-morph');
if (!existsSync(tsMorphPath)) {
  process.stderr.write(`ts-morph not found at ${tsMorphPath}. Run: cd "${here}" && npm install\n`);
  process.exit(2);
}
const { Project, Node, SyntaxKind } = require_(tsMorphPath);

// --- CLI ---
const args = parseArgs(process.argv.slice(2));
if (!args.project || !args.files) {
  process.stderr.write('Usage: detect-ast.mjs --project <root> --files <files.json>\n');
  process.exit(2);
}
const projectRoot = resolve(args.project);
const filePaths = JSON.parse(readFileSync(args.files, 'utf8'));

function parseArgs(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--project') out.project = argv[++i];
    else if (a === '--files') out.files = argv[++i];
  }
  return out;
}

// --- Project setup ---
const project = new Project({
  useInMemoryFileSystem: false,
  skipAddingFilesFromTsConfig: true,
  skipFileDependencyResolution: true,
  skipLoadingLibFiles: true,
  compilerOptions: { allowJs: true, jsx: 4 /* Preserve */ },
});

for (const relPath of filePaths) {
  const abs = resolve(projectRoot, relPath);
  if (existsSync(abs)) project.addSourceFileAtPath(abs);
}

// --- Findings accumulator ---
const findings = [];
function addFinding({ rule, severity, message, file, node, snippetOverride }) {
  const sf = node.getSourceFile();
  const { line, column } = sf.getLineAndColumnAtPos(node.getStart());
  const lineText = sf.getFullText().split(/\r?\n/)[line - 1] ?? '';
  findings.push({
    rule,
    severity,
    message,
    file: relative(projectRoot, sf.getFilePath()),
    line,
    column,
    snippet: (snippetOverride ?? lineText).trim(),
  });
}

// --- Helpers ---
function getEnclosingComponentFn(node) {
  let n = node.getParent();
  while (n) {
    if (
      Node.isFunctionDeclaration(n) ||
      Node.isArrowFunction(n) ||
      Node.isFunctionExpression(n) ||
      Node.isMethodDeclaration(n)
    ) {
      return n;
    }
    n = n.getParent();
  }
  return null;
}

function getCallCalleeName(call) {
  const expr = call.getExpression();
  if (Node.isIdentifier(expr)) return expr.getText();
  if (Node.isPropertyAccessExpression(expr)) return expr.getName();
  return null;
}

function findCallsByName(scope, name) {
  return scope
    .getDescendantsOfKind(SyntaxKind.CallExpression)
    .filter((c) => getCallCalleeName(c) === name);
}

function functionContainsAwaitOrAsync(fn) {
  if (!fn) return false;
  if (fn.isAsync && fn.isAsync()) return true;
  return fn.getDescendantsOfKind(SyntaxKind.AwaitExpression).length > 0;
}

function functionHasTryCatch(fn) {
  if (!fn) return false;
  return fn.getDescendantsOfKind(SyntaxKind.TryStatement).length > 0;
}

function functionCallsSetErrorRoot(fn) {
  if (!fn) return false;
  const calls = findCallsByName(fn, 'setError');
  return calls.some((call) => {
    const arg0 = call.getArguments()[0];
    if (!arg0) return false;
    if (Node.isStringLiteral(arg0) || Node.isNoSubstitutionTemplateLiteral(arg0)) {
      return arg0.getLiteralText().startsWith('root');
    }
    return false;
  });
}

function functionCallsNetworkApi(fn) {
  if (!fn) return false;
  for (const call of fn.getDescendantsOfKind(SyntaxKind.CallExpression)) {
    const name = getCallCalleeName(call);
    if (name === 'fetch') return true;
    if (call.getExpression().getText().match(/^(axios|api|http)(\.|$)/)) return true;
  }
  return false;
}

// --- Detectors per source file ---
for (const sf of project.getSourceFiles()) {
  const useFormCalls = findCallsByName(sf, 'useForm');
  if (useFormCalls.length === 0) continue;

  for (const useFormCall of useFormCalls) {
    const componentFn = getEnclosingComponentFn(useFormCall);
    if (!componentFn) continue;

    // --- Rule 3: useForm called without defaultValues option ---
    const arg0 = useFormCall.getArguments()[0];
    let hasDefaultValues = false;
    if (arg0 && Node.isObjectLiteralExpression(arg0)) {
      hasDefaultValues = arg0.getProperties().some((p) => {
        if (Node.isPropertyAssignment(p) || Node.isShorthandPropertyAssignment(p)) {
          return p.getName() === 'defaultValues';
        }
        return false;
      });
    }
    if (!hasDefaultValues) {
      addFinding({
        rule: 'rhf-audit-03-missing-default-values',
        severity: 'CRITICAL',
        message: 'useForm() called without `defaultValues`. Uncontrolled fields become undefined, and reset() has nothing to reset to.',
        node: useFormCall,
      });
    }

    // --- Identifiers destructured from useForm (e.g. const { register, watch } = useForm()) ---
    const destructuredNames = new Set();
    const variableDecl = useFormCall.getFirstAncestorByKind(SyntaxKind.VariableDeclaration);
    if (variableDecl) {
      const nameNode = variableDecl.getNameNode();
      if (Node.isObjectBindingPattern(nameNode)) {
        for (const el of nameNode.getElements()) {
          destructuredNames.add(el.getName());
        }
      }
    }

    // --- Rule 1 / 2: watch() in same component as useForm() ---
    const watchCalls = findCallsByName(componentFn, 'watch');
    for (const watchCall of watchCalls) {
      const watchArgs = watchCall.getArguments();
      if (watchArgs.length === 0) {
        addFinding({
          rule: 'rhf-audit-02-watch-all-fields',
          severity: 'CRITICAL',
          message: 'watch() called with no arguments — subscribes to every field. Re-renders the component on every keystroke anywhere in the form.',
          node: watchCall,
        });
      } else {
        addFinding({
          rule: 'rhf-audit-01-watch-at-form-root',
          severity: 'CRITICAL',
          message: 'watch() called in the same component as useForm() — re-renders the entire form on every change. Use useWatch() in a child component instead.',
          node: watchCall,
        });
      }
    }

    // --- Rule 6: <Controller> inlined inside the useForm parent component ---
    const controllerEls = componentFn.getDescendantsOfKind(SyntaxKind.JsxOpeningElement)
      .concat(componentFn.getDescendantsOfKind(SyntaxKind.JsxSelfClosingElement));
    for (const el of controllerEls) {
      const tag = el.getTagNameNode();
      if (tag && tag.getText() === 'Controller') {
        addFinding({
          rule: 'rhf-audit-06-controller-inlined',
          severity: 'HIGH',
          message: '<Controller> rendered directly inside the component that calls useForm(). Move it into a child component so parent re-renders do not propagate to every controlled input.',
          node: el,
        });
      }
    }

    // --- Rule 10: RHF + useActionState in the same component ---
    const useActionStateCalls = findCallsByName(componentFn, 'useActionState');
    for (const call of useActionStateCalls) {
      addFinding({
        rule: 'rhf-audit-10-rhf-with-useactionstate',
        severity: 'HIGH',
        message: 'useActionState() and useForm() in the same component. Pick one: react-hook-form for client-side validation OR useActionState for Server Action submission. Mixing leads to duplicated state and race conditions.',
        node: call,
      });
    }

    // --- Rule 8: schema defined inside the component ---
    for (const call of componentFn.getDescendantsOfKind(SyntaxKind.CallExpression)) {
      const exprText = call.getExpression().getText();
      if (/^(z\.object|yup\.object|Joi\.object|valibot\.object|object)$/.test(exprText)) {
        // Skip if the call is at module top level (we want only inside-component).
        // Also skip if the call is a direct property of useForm's options.
        if (call.getFirstAncestor((a) => a === componentFn)) {
          addFinding({
            rule: 'rhf-audit-08-schema-inside-component',
            severity: 'HIGH',
            message: 'Validation schema defined inside the component body — recreated on every render. Hoist it to module scope so the resolver caches it.',
            node: call,
          });
        }
      }
    }

    // --- Rule 4: useEffect depending on useForm return ---
    const useEffectCalls = findCallsByName(componentFn, 'useEffect');
    for (const eff of useEffectCalls) {
      const depsArg = eff.getArguments()[1];
      if (!depsArg || !Node.isArrayLiteralExpression(depsArg)) continue;
      for (const dep of depsArg.getElements()) {
        if (Node.isIdentifier(dep) && destructuredNames.has(dep.getText())) {
          // Whitelisted: these are stable refs and meant to be deps.
          if (['register', 'control', 'setValue', 'setError', 'clearErrors', 'reset', 'subscribe', 'trigger', 'unregister'].includes(dep.getText())) {
            continue;
          }
        }
        if (Node.isIdentifier(dep)) {
          // Detect a dep that is literally the useForm return variable.
          const declVarStmt = useFormCall.getFirstAncestorByKind(SyntaxKind.VariableStatement);
          if (declVarStmt) {
            const decls = declVarStmt.getDeclarations();
            for (const d of decls) {
              const nameNode = d.getNameNode();
              if (Node.isIdentifier(nameNode) && nameNode.getText() === dep.getText()) {
                addFinding({
                  rule: 'rhf-audit-04-useeffect-depends-useform',
                  severity: 'CRITICAL',
                  message: `useEffect lists '${dep.getText()}' (the useForm return) as a dependency. The form object is a new reference every render — this causes infinite re-runs. Destructure stable callbacks instead.`,
                  node: eff,
                });
              }
            }
          }
        }
      }
    }

    // --- Rule 7 / 9: async submit handler analysis ---
    // Find handleSubmit(fn) calls — the inner fn is the user's submit handler.
    const handleSubmitCalls = findCallsByName(componentFn, 'handleSubmit');
    for (const hs of handleSubmitCalls) {
      const submitFn = hs.getArguments()[0];
      if (!submitFn) continue;
      const isFnLike = Node.isArrowFunction(submitFn) || Node.isFunctionExpression(submitFn);
      // Also handle the case where it's an identifier referring to a fn defined in the component.
      let fnToInspect = isFnLike ? submitFn : null;
      if (!fnToInspect && Node.isIdentifier(submitFn)) {
        const name = submitFn.getText();
        // Look for variable declaration with the same name inside componentFn.
        for (const vd of componentFn.getDescendantsOfKind(SyntaxKind.VariableDeclaration)) {
          if (vd.getNameNode().getText() === name) {
            const init = vd.getInitializer();
            if (init && (Node.isArrowFunction(init) || Node.isFunctionExpression(init))) {
              fnToInspect = init;
              break;
            }
          }
        }
        if (!fnToInspect) {
          for (const fd of componentFn.getDescendantsOfKind(SyntaxKind.FunctionDeclaration)) {
            if (fd.getName && fd.getName() === name) {
              fnToInspect = fd;
              break;
            }
          }
        }
      }
      if (!fnToInspect) continue;

      const isAsync = functionContainsAwaitOrAsync(fnToInspect);
      const hasTryCatch = functionHasTryCatch(fnToInspect);
      const callsNetwork = functionCallsNetworkApi(fnToInspect);
      const callsSetErrorRoot = functionCallsSetErrorRoot(fnToInspect);

      if (isAsync && !hasTryCatch) {
        addFinding({
          rule: 'rhf-audit-07-async-submit-no-trycatch',
          severity: 'HIGH',
          message: 'Async submit handler has no try/catch. If it throws, isSubmitting stays true and the form becomes unrecoverable. Wrap in try/catch and surface errors via setError().',
          node: fnToInspect,
        });
      }
      if (callsNetwork && !callsSetErrorRoot) {
        addFinding({
          rule: 'rhf-audit-09-no-server-error-setError',
          severity: 'HIGH',
          message: "Submit handler calls fetch/axios but never setError('root.serverError', ...). Server failures will be silently dropped. Route API errors through setError so they render.",
          node: fnToInspect,
        });
      }
    }

    // --- Rule 12: register('name', { disabled: <state> }) — likely visual disable ---
    const registerCalls = findCallsByName(componentFn, 'register');
    for (const reg of registerCalls) {
      const opts = reg.getArguments()[1];
      if (!opts || !Node.isObjectLiteralExpression(opts)) continue;
      const disabledProp = opts.getProperties().find((p) => {
        if (!(Node.isPropertyAssignment(p) || Node.isShorthandPropertyAssignment(p))) return false;
        return p.getName() === 'disabled';
      });
      if (!disabledProp) continue;
      if (Node.isPropertyAssignment(disabledProp)) {
        const initVal = disabledProp.getInitializer();
        // Flag when the value isn't a literal true (intentional exclusion) but a reactive state.
        // Heuristic: an Identifier, PropertyAccess, PrefixUnary on identifier, or BinaryExpression.
        const kind = initVal?.getKind();
        if (
          kind === SyntaxKind.Identifier ||
          kind === SyntaxKind.PropertyAccessExpression ||
          kind === SyntaxKind.PrefixUnaryExpression ||
          kind === SyntaxKind.BinaryExpression
        ) {
          addFinding({
            rule: 'rhf-audit-12-disabled-visual',
            severity: 'MEDIUM',
            message: "register({ disabled: <state> }) clears the field's value and skips validation. If you only want it greyed out, use the HTML `disabled` attribute on the input instead.",
            node: disabledProp,
          });
        }
      }
    }

    // --- Rule 13: useFieldArray map missing field.id key ---
    const useFieldArrayCalls = findCallsByName(componentFn, 'useFieldArray');
    for (const ufa of useFieldArrayCalls) {
      // Find the `fields` identifier destructured from this call.
      const vd = ufa.getFirstAncestorByKind(SyntaxKind.VariableDeclaration);
      if (!vd) continue;
      const nameNode = vd.getNameNode();
      if (!Node.isObjectBindingPattern(nameNode)) continue;
      const fieldsBinding = nameNode.getElements().find((el) => el.getName() === 'fields' || el.getPropertyNameNode()?.getText() === 'fields');
      if (!fieldsBinding) continue;
      const fieldsVar = fieldsBinding.getName();

      // Find map() calls on the fields variable.
      for (const callExpr of componentFn.getDescendantsOfKind(SyntaxKind.CallExpression)) {
        const expr = callExpr.getExpression();
        if (!Node.isPropertyAccessExpression(expr)) continue;
        if (expr.getName() !== 'map') continue;
        if (expr.getExpression().getText() !== fieldsVar) continue;

        const mapCallback = callExpr.getArguments()[0];
        if (!mapCallback || !(Node.isArrowFunction(mapCallback) || Node.isFunctionExpression(mapCallback))) continue;

        // Inspect the returned JSX for a `key=` attribute.
        const jsxOpenings = mapCallback.getDescendantsOfKind(SyntaxKind.JsxOpeningElement)
          .concat(mapCallback.getDescendantsOfKind(SyntaxKind.JsxSelfClosingElement));
        if (jsxOpenings.length === 0) continue;
        const first = jsxOpenings[0];
        const keyAttr = first.getAttributes().find((a) => {
          if (a.getKind() !== SyntaxKind.JsxAttribute) return false;
          const nameNode = a.getNameNode();
          return nameNode && nameNode.getText() === 'key';
        });
        if (!keyAttr) {
          addFinding({
            rule: 'rhf-audit-13-fieldarray-no-field-id',
            severity: 'MEDIUM',
            message: `${fieldsVar}.map() renders JSX without a 'key' attribute. Use field.id as key — array index causes state corruption when items are added or reordered.`,
            node: first,
          });
        } else {
          const keyExpr = keyAttr.getInitializer();
          if (keyExpr && Node.isJsxExpression(keyExpr)) {
            const inner = keyExpr.getExpression();
            const text = inner?.getText() ?? '';
            if (!/\.id\b/.test(text)) {
              addFinding({
                rule: 'rhf-audit-13-fieldarray-no-field-id',
                severity: 'MEDIUM',
                message: `${fieldsVar}.map() uses key={${text}} instead of field.id. Array index keys cause state corruption when items are added or reordered.`,
                node: keyAttr,
              });
            }
          }
        }
      }
    }
  }

  // --- Rule 15: useFormContext() usage flag (LOW — informational) ---
  for (const call of findCallsByName(sf, 'useFormContext')) {
    addFinding({
      rule: 'rhf-audit-15-useformcontext',
      severity: 'LOW',
      message: 'useFormContext() found. Verify the consuming component is genuinely deep enough that prop drilling would be worse. Shallow uses add implicit coupling without payoff.',
      node: call,
    });
  }
}

process.stdout.write(JSON.stringify(findings, null, 2));
