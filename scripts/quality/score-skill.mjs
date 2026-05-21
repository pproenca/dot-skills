#!/usr/bin/env node
// Score a single skill directory and print its quality JSON.
// Usage: node scripts/quality/score-skill.mjs <skill-dir> [--pretty]

import path from "node:path";
import fs from "node:fs";
import { scoreSkillDir } from "./lib/score.mjs";

const args = process.argv.slice(2);
const pretty = args.includes("--pretty");
const dir = args.find((a) => !a.startsWith("--"));

if (!dir) {
  console.error("Usage: node scripts/quality/score-skill.mjs <skill-dir> [--pretty]");
  process.exit(1);
}
const abs = path.resolve(dir);
if (!fs.existsSync(path.join(abs, "SKILL.md"))) {
  console.error(`No SKILL.md in ${abs}`);
  process.exit(1);
}
const name = path.basename(abs);
const tier = "." + path.basename(path.dirname(abs)).replace(/^\./, "");
const result = scoreSkillDir(abs, { name, tier });
console.log(JSON.stringify(result, null, pretty ? 2 : 0));
