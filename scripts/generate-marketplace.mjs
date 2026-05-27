#!/usr/bin/env node

/**
 * Generate .claude-plugin/marketplace.json so `npx skills add` groups
 * curated skills under the 4 dev-skill disciplines.
 *
 * Discipline detection mirrors dev-skill's validator.js:detectDiscipline:
 *   1. scripts/                              → composition
 *   2. references/*-tree.md or references/queries/ → investigation
 *   3. assets/templates/*.template           → extraction
 *   4. otherwise                             → distillation
 *
 * Plugin names map to user-facing labels via npx skills' kebab→Title-case
 * (add.ts:1205): `references` → "References", etc.
 */

import { readdirSync, existsSync, statSync, writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";

const REPO_ROOT = new URL("..", import.meta.url).pathname;
const CURATED_DIR = join(REPO_ROOT, "skills/.curated");
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

const skills = listSkills(CURATED_DIR);
const groups = { references: [], workflows: [], runbooks: [], extractors: [] };

for (const name of skills) {
  const discipline = detectDiscipline(join(CURATED_DIR, name));
  const plugin = DISCIPLINE_TO_PLUGIN[discipline];
  groups[plugin].push(`./${name}`);
}

const manifest = {
  metadata: { pluginRoot: "./skills/.curated" },
  plugins: Object.entries(groups)
    .filter(([, paths]) => paths.length > 0)
    .map(([name, paths]) => ({ name, source: ".", skills: paths })),
};

mkdirSync(OUT_DIR, { recursive: true });
writeFileSync(OUT_FILE, JSON.stringify(manifest, null, 2) + "\n");

const counts = Object.fromEntries(
  Object.entries(groups).map(([k, v]) => [k, v.length])
);
console.log(`Wrote ${OUT_FILE}`);
console.log(`Skills: ${skills.length} total — ${JSON.stringify(counts)}`);
