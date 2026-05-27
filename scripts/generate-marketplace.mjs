#!/usr/bin/env node

// Generate .claude-plugin/marketplace.json so `npx skills add` groups skills
// in the picker. Curated skills go under 4 discipline-based plugins
// (References / Workflows / Runbooks / Extractors). Experimental skills go
// under a single `experimental` plugin so the picker renders an
// "Experimental" section header that visually flags their status.
//
// Discipline detection mirrors dev-skill's validator.js:detectDiscipline:
//   1. scripts/                              -> composition
//   2. references/<name>-tree.md or references/queries/ -> investigation
//   3. assets/templates/<name>.template      -> extraction
//   4. otherwise                             -> distillation
//
// Plugin names map to user-facing labels via npx skills' kebab->Title-case
// (vercel-labs/skills add.ts:1205): `references` -> "References", etc.

import { readdirSync, existsSync, writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";

const REPO_ROOT = new URL("..", import.meta.url).pathname;
const CURATED_DIR = join(REPO_ROOT, "skills/.curated");
const EXPERIMENTAL_DIR = join(REPO_ROOT, "skills/.experimental");
const OUT_DIR = join(REPO_ROOT, ".claude-plugin");
const OUT_FILE = join(OUT_DIR, "marketplace.json");

const DISCIPLINE_TO_PLUGIN = {
  distillation: "references",
  composition: "workflows",
  investigation: "runbooks",
  extraction: "extractors",
};

function detectDiscipline(skillDir) {
  if (existsSync(join(skillDir, "scripts"))) return "composition";

  const refsDir = join(skillDir, "references");
  if (existsSync(refsDir)) {
    const refs = readdirSync(refsDir);
    if (refs.some((f) => f.endsWith("-tree.md"))) return "investigation";
    if (existsSync(join(refsDir, "queries"))) return "investigation";
  }

  const templatesDir = join(skillDir, "assets/templates");
  if (existsSync(templatesDir)) {
    const tpls = readdirSync(templatesDir);
    if (tpls.some((f) => f.endsWith(".template"))) return "extraction";
  }

  return "distillation";
}

function listSkills(dir) {
  return readdirSync(dir, { withFileTypes: true })
    .filter((e) => e.isDirectory() && !e.name.startsWith("."))
    .map((e) => e.name)
    .filter((name) => existsSync(join(dir, name, "SKILL.md")))
    .sort();
}

const curated = listSkills(CURATED_DIR);
const experimental = listSkills(EXPERIMENTAL_DIR);

const curatedGroups = { references: [], workflows: [], runbooks: [], extractors: [] };
for (const name of curated) {
  const plugin = DISCIPLINE_TO_PLUGIN[detectDiscipline(join(CURATED_DIR, name))];
  curatedGroups[plugin].push(`./${name}`);
}

const plugins = [
  ...Object.entries(curatedGroups)
    .filter(([, paths]) => paths.length > 0)
    .map(([name, paths]) => ({ name, source: "./skills/.curated", skills: paths })),
];

if (experimental.length > 0) {
  plugins.push({
    name: "experimental",
    source: "./skills/.experimental",
    skills: experimental.map((n) => `./${n}`),
  });
}

mkdirSync(OUT_DIR, { recursive: true });
writeFileSync(OUT_FILE, JSON.stringify({ plugins }, null, 2) + "\n");

const counts = {
  ...Object.fromEntries(Object.entries(curatedGroups).map(([k, v]) => [k, v.length])),
  experimental: experimental.length,
};
console.log(`Wrote ${OUT_FILE}`);
console.log(`Skills: ${curated.length + experimental.length} total — ${JSON.stringify(counts)}`);
