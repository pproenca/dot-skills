#!/usr/bin/env node
// render-report.mjs — Render the JSON findings as a markdown audit report.
// Part of: react-hook-form-audit

import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const args = parseArgs(process.argv.slice(2));
if (!args.findings || !args.project) {
  process.stderr.write('Usage: render-report.mjs --findings <findings.json> --project <root> [--rule-link-base <url-or-path>]\n');
  process.exit(2);
}

function parseArgs(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--findings') out.findings = argv[++i];
    else if (a === '--project') out.project = argv[++i];
    else if (a === '--rule-link-base') out.ruleLinkBase = argv[++i];
  }
  return out;
}

const findings = JSON.parse(readFileSync(resolve(args.findings), 'utf8'));

const SEVERITY_ORDER = { CRITICAL: 0, HIGH: 1, MEDIUM: 2, LOW: 3 };

// Map audit rule IDs back to the distillation skill's rule filenames.
const RULE_TO_FILE = {
  'rhf-audit-01-watch-at-form-root': 'sub-usewatch-over-watch',
  'rhf-audit-02-watch-all-fields': 'sub-watch-specific-fields',
  'rhf-audit-03-missing-default-values': 'formcfg-default-values',
  'rhf-audit-04-useeffect-depends-useform': 'formcfg-useeffect-dependency',
  'rhf-audit-05-non-use-client': null, // Next.js-specific; no companion rule
  'rhf-audit-06-controller-inlined': 'ctrl-usecontroller-isolation',
  'rhf-audit-07-async-submit-no-trycatch': 'formstate-async-submit-lifecycle',
  'rhf-audit-08-schema-inside-component': 'valid-resolver-caching',
  'rhf-audit-09-no-server-error-setError': 'valid-server-errors',
  'rhf-audit-10-rhf-with-useactionstate': null, // Next.js-specific
  'rhf-audit-11-onchange-mode': 'formcfg-validation-mode',
  'rhf-audit-12-disabled-visual': 'formcfg-disabled-prop',
  'rhf-audit-13-fieldarray-no-field-id': 'array-use-field-id-as-key',
  'rhf-audit-14-revalidate-onblur': 'formcfg-revalidate-mode',
  'rhf-audit-15-useformcontext': 'sub-useformcontext-sparingly',
};

function ruleLink(ruleId) {
  const fileSlug = RULE_TO_FILE[ruleId];
  if (!fileSlug) return null;
  const base = args.ruleLinkBase ?? '';
  if (!base) return null;
  return `${base.replace(/\/$/, '')}/${fileSlug}.md`;
}

// --- Sort + group ---
findings.sort((a, b) => {
  const s = SEVERITY_ORDER[a.severity] - SEVERITY_ORDER[b.severity];
  if (s !== 0) return s;
  const f = a.file.localeCompare(b.file);
  if (f !== 0) return f;
  return a.line - b.line;
});

const bySeverity = { CRITICAL: [], HIGH: [], MEDIUM: [], LOW: [] };
for (const f of findings) {
  (bySeverity[f.severity] ?? bySeverity.LOW).push(f);
}

// --- Counts by rule, for the summary table ---
const ruleCounts = new Map();
for (const f of findings) {
  ruleCounts.set(f.rule, (ruleCounts.get(f.rule) ?? 0) + 1);
}

// --- Render ---
const now = new Date().toISOString().slice(0, 19).replace('T', ' ');
const total = findings.length;

let out = '';
out += `# React Hook Form Audit Report\n\n`;
out += `**Project:** \`${args.project}\`  \n`;
out += `**Generated:** ${now}  \n`;
out += `**Total findings:** ${total}\n\n`;

out += `## Summary\n\n`;
out += `| Severity | Count |\n|----------|-------|\n`;
for (const sev of ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']) {
  out += `| ${sev} | ${bySeverity[sev].length} |\n`;
}
out += '\n';

if (ruleCounts.size > 0) {
  out += `### By Rule\n\n`;
  out += `| Rule | Count | Companion rule |\n|------|-------|----------------|\n`;
  const sortedRules = [...ruleCounts.entries()].sort((a, b) => b[1] - a[1]);
  for (const [rule, count] of sortedRules) {
    const link = ruleLink(rule);
    const companion = link ? `[${RULE_TO_FILE[rule]}](${link})` : '—';
    out += `| \`${rule}\` | ${count} | ${companion} |\n`;
  }
  out += '\n';
}

for (const sev of ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']) {
  const items = bySeverity[sev];
  if (items.length === 0) continue;
  out += `## ${sev} (${items.length})\n\n`;
  for (const f of items) {
    const loc = `\`${f.file}:${f.line}:${f.column}\``;
    out += `### ${loc}\n\n`;
    out += `**Rule:** \`${f.rule}\``;
    const link = ruleLink(f.rule);
    if (link) {
      out += ` — see [${RULE_TO_FILE[f.rule]}](${link})`;
    }
    out += `\n\n`;
    out += `${f.message}\n\n`;
    if (f.snippet) {
      out += '```\n' + f.snippet + '\n```\n\n';
    }
  }
}

if (total === 0) {
  out += `_No React Hook Form anti-patterns detected._\n`;
}

process.stdout.write(out);
