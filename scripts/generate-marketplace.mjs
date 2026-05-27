#!/usr/bin/env node

// Generate .claude-plugin/marketplace.json so `npx skills add` groups skills
// into two sections in the picker: "Curated" (38 skills) then "Experimental"
// (137 skills). Picker sort is alphabetical by raw plugin slug
// (vercel-labs/skills add.ts:1192-1196), so 'curated' < 'experimental' gives
// the desired order without further tricks.

import { readdirSync, existsSync, writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";

const REPO_ROOT = new URL("..", import.meta.url).pathname;
const CURATED_DIR = join(REPO_ROOT, "skills/.curated");
const EXPERIMENTAL_DIR = join(REPO_ROOT, "skills/.experimental");
const OUT_DIR = join(REPO_ROOT, ".claude-plugin");
const OUT_FILE = join(OUT_DIR, "marketplace.json");

function listSkills(dir) {
  return readdirSync(dir, { withFileTypes: true })
    .filter((e) => e.isDirectory() && !e.name.startsWith("."))
    .map((e) => e.name)
    .filter((name) => existsSync(join(dir, name, "SKILL.md")))
    .sort();
}

const curated = listSkills(CURATED_DIR);
const experimental = listSkills(EXPERIMENTAL_DIR);

const plugins = [];
if (curated.length > 0) {
  plugins.push({
    name: "curated",
    source: "./skills/.curated",
    skills: curated.map((n) => `./${n}`),
  });
}
if (experimental.length > 0) {
  plugins.push({
    name: "experimental",
    source: "./skills/.experimental",
    skills: experimental.map((n) => `./${n}`),
  });
}

mkdirSync(OUT_DIR, { recursive: true });
writeFileSync(OUT_FILE, JSON.stringify({ plugins }, null, 2) + "\n");

console.log(`Wrote ${OUT_FILE}`);
console.log(`Skills: ${curated.length + experimental.length} total — curated: ${curated.length}, experimental: ${experimental.length}`);
