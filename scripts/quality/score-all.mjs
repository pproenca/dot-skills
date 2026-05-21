#!/usr/bin/env node
// Score every skill at HEAD -> quality/snapshot.json
// Maintenance status (STALE/DIRTY/...) is attached as an operational flag only;
// it carries 0 weight in SQS (see quality/METRICS.md §3).
//
// Usage: node scripts/quality/score-all.mjs [--out quality/snapshot.json]

import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { scoreSkillDir } from "./lib/score.mjs";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const args = process.argv.slice(2);
const outIdx = args.indexOf("--out");
const OUT = outIdx >= 0 ? args[outIdx + 1] : path.join(ROOT, "quality/snapshot.json");

function headSha() {
  try {
    return execFileSync("git", ["rev-parse", "HEAD"], { cwd: ROOT, encoding: "utf8" }).trim();
  } catch {
    return null;
  }
}

function maintenance() {
  try {
    const out = execFileSync("node", ["scripts/check-versions.mjs", "--json"], {
      cwd: ROOT,
      encoding: "utf8",
    });
    const rows = JSON.parse(out);
    return Object.fromEntries(rows.map((r) => [r.skill, r.status]));
  } catch {
    return {};
  }
}

function listSkills() {
  const out = [];
  for (const tier of [".curated", ".experimental"]) {
    const base = path.join(ROOT, "skills", tier);
    if (!fs.existsSync(base)) continue;
    for (const name of fs.readdirSync(base)) {
      if (name.startsWith(".")) continue;
      const dir = path.join(base, name);
      if (!fs.existsSync(path.join(dir, "SKILL.md"))) continue;
      out.push({ name, tier, dir });
    }
  }
  return out.sort((a, b) => a.name.localeCompare(b.name));
}

function summarize(skills) {
  const by = (key) => {
    const m = {};
    for (const s of skills) {
      const k = s[key];
      (m[k] ||= []).push(s.sqs);
    }
    return Object.fromEntries(
      Object.entries(m).map(([k, v]) => [
        k,
        { count: v.length, mean_sqs: round(v.reduce((a, b) => a + b, 0) / v.length) },
      ])
    );
  };
  const verdicts = skills.reduce((a, s) => ((a[s.verdict] = (a[s.verdict] || 0) + 1), a), {});
  return {
    count: skills.length,
    mean_sqs: round(skills.reduce((a, s) => a + s.sqs, 0) / skills.length),
    median_sqs: round(median(skills.map((s) => s.sqs))),
    verdicts,
    by_tier: by("tier"),
    by_discipline: by("discipline"),
  };
}
const round = (x) => Math.round(x * 10) / 10;
const median = (xs) => {
  const s = [...xs].sort((a, b) => a - b);
  const m = Math.floor(s.length / 2);
  return s.length % 2 ? s[m] : (s[m - 1] + s[m]) / 2;
};

const maint = maintenance();
const skills = listSkills().map(({ name, tier, dir }) => {
  const r = scoreSkillDir(dir, { name, tier });
  r.maintenance = maint[name] || "UNKNOWN";
  return r;
});

const snapshot = {
  generated_from: headSha(),
  metrics_spec: "quality/METRICS.md",
  summary: summarize(skills),
  skills,
};

fs.mkdirSync(path.dirname(OUT), { recursive: true });
fs.writeFileSync(OUT, JSON.stringify(snapshot, null, 2) + "\n");
console.log(
  `Scored ${skills.length} skills -> ${path.relative(ROOT, OUT)}  ` +
    `(mean SQS ${snapshot.summary.mean_sqs}, ` +
    Object.entries(snapshot.summary.verdicts)
      .map(([k, v]) => `${k}:${v}`)
      .join(" ") +
    ")"
);
