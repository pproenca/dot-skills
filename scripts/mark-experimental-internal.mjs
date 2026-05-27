#!/usr/bin/env node

// Add `metadata.internal: true` to every skills/.experimental/<name>/SKILL.md
// so `npx skills add` hides them from default browse. They remain installable
// by exact name and via INSTALL_INTERNAL_SKILLS=1.
//
// Idempotent: skipped if metadata.internal is already truthy.

import { readdirSync, readFileSync, writeFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import yaml from "js-yaml";

const REPO_ROOT = new URL("..", import.meta.url).pathname;
const EXPERIMENTAL_DIR = join(REPO_ROOT, "skills/.experimental");

const FM = /^---\n([\s\S]*?)\n---\n?/;

function bumpPatchInMetadata(skillDir) {
  const metaPath = join(skillDir, "metadata.json");
  if (!existsSync(metaPath)) return null;
  const meta = JSON.parse(readFileSync(metaPath, "utf-8"));
  if (typeof meta.version !== "string") return null;
  const parts = meta.version.split(".").map((n) => parseInt(n, 10));
  if (parts.length !== 3 || parts.some(isNaN)) return null;
  parts[2] += 1;
  const next = parts.join(".");
  meta.version = next;
  writeFileSync(metaPath, JSON.stringify(meta, null, 2) + "\n");
  return next;
}

function processSkill(skillName) {
  const skillDir = join(EXPERIMENTAL_DIR, skillName);
  const file = join(skillDir, "SKILL.md");
  if (!existsSync(file)) return { skillName, status: "no-skill-md" };

  const original = readFileSync(file, "utf-8");
  const match = original.match(FM);
  if (!match) return { skillName, status: "no-frontmatter" };

  const fmText = match[1];
  const body = original.slice(match[0].length);
  const data = yaml.load(fmText) ?? {};

  if (data.metadata?.internal === true) {
    return { skillName, status: "already-internal" };
  }

  data.metadata = { ...(data.metadata ?? {}), internal: true };

  const newFm = yaml.dump(data, { lineWidth: -1, noRefs: true, quotingType: '"' });
  const next = `---\n${newFm}---\n${body.startsWith("\n") ? body.slice(1) : body}`;
  writeFileSync(file, next);

  const newVersion = bumpPatchInMetadata(skillDir);
  return { skillName, status: "marked", newVersion };
}

const skills = readdirSync(EXPERIMENTAL_DIR, { withFileTypes: true })
  .filter((e) => e.isDirectory() && !e.name.startsWith("."))
  .map((e) => e.name)
  .sort();

const results = skills.map(processSkill);
const counts = results.reduce((acc, r) => {
  acc[r.status] = (acc[r.status] ?? 0) + 1;
  return acc;
}, {});

console.log(`Processed ${skills.length} skills under .experimental/`);
console.log(counts);

const noSkillMd = results.filter((r) => r.status === "no-skill-md");
if (noSkillMd.length > 0) {
  console.log(`\nSkipped ${noSkillMd.length} dirs without SKILL.md (eval workspaces, etc.):`);
  for (const r of noSkillMd) console.log(`  - ${r.skillName}`);
}

const failures = results.filter((r) => r.status === "no-frontmatter");
if (failures.length > 0) {
  console.log("\nNeeds manual attention (no frontmatter):");
  for (const r of failures) console.log(`  - ${r.skillName}`);
  process.exit(1);
}
