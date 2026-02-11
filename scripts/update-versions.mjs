#!/usr/bin/env node

/**
 * Derives skill versions from git history using conventional commits.
 *
 * Logic:
 *   - First commit for a skill = 1.0.0
 *   - Each subsequent "feat:" commit = minor bump
 *   - Each subsequent "fix:" / "refactor:" / "chore:" / other commit = patch bump
 *
 * Usage: node scripts/update-versions.mjs [--dry-run]
 */

import { execSync } from "node:child_process";
import { readFileSync, writeFileSync, existsSync, readdirSync } from "node:fs";
import { join, basename } from "node:path";

const ROOT = new URL("..", import.meta.url).pathname.replace(/\/$/, "");
const DRY_RUN = process.argv.includes("--dry-run");

function getSkillDirs() {
  const dirs = [];
  for (const tier of [".curated", ".experimental"]) {
    const tierPath = join(ROOT, "skills", tier);
    if (!existsSync(tierPath)) continue;
    for (const name of readdirSync(tierPath, { withFileTypes: true })) {
      if (name.isDirectory()) {
        dirs.push(join(tierPath, name.name));
      }
    }
  }
  return dirs;
}

function getGitLog(skillDir) {
  const rel = skillDir.replace(ROOT + "/", "");
  try {
    const out = execSync(
      `git log --oneline --reverse --format="%s" -- "${rel}"`,
      { cwd: ROOT, encoding: "utf-8" }
    );
    return out
      .trim()
      .split("\n")
      .filter((l) => l.length > 0);
  } catch {
    return [];
  }
}

function deriveVersion(commits) {
  if (commits.length === 0) return "1.0.0";

  let major = 1;
  let minor = 0;
  let patch = 0;

  // First commit is always 1.0.0, process remaining
  for (let i = 1; i < commits.length; i++) {
    const msg = commits[i];
    if (/^feat(\(.*?\))?[!]?:/.test(msg)) {
      minor++;
      patch = 0;
    } else {
      // fix, refactor, chore, docs, style, perf, build, ci, test, etc.
      patch++;
    }
  }

  return `${major}.${minor}.${patch}`;
}

function run() {
  const skillDirs = getSkillDirs();
  const changes = [];

  for (const dir of skillDirs) {
    const metaPath = join(dir, "metadata.json");
    if (!existsSync(metaPath)) continue;

    const meta = JSON.parse(readFileSync(metaPath, "utf-8"));
    const currentVersion = meta.version || "0.0.0";
    const commits = getGitLog(dir);
    const newVersion = deriveVersion(commits);
    const skillName = basename(dir);

    if (currentVersion !== newVersion) {
      changes.push({ skillName, currentVersion, newVersion, metaPath, meta });
    }
  }

  if (changes.length === 0) {
    console.log("All versions are up to date.");
    return;
  }

  console.log(`Found ${changes.length} version update(s):\n`);
  const pad = Math.max(...changes.map((c) => c.skillName.length));

  for (const { skillName, currentVersion, newVersion, metaPath, meta } of changes) {
    const arrow = `${currentVersion} → ${newVersion}`;
    console.log(`  ${skillName.padEnd(pad)}  ${arrow}`);

    if (!DRY_RUN) {
      meta.version = newVersion;
      writeFileSync(metaPath, JSON.stringify(meta, null, 2) + "\n");
    }
  }

  if (DRY_RUN) {
    console.log("\n(dry run — no files were modified)");
  } else {
    console.log(`\nUpdated ${changes.length} metadata.json file(s).`);
  }
}

run();
