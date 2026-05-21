#!/usr/bin/env node
// Track quality drift against the frozen baseline.
// Re-scores HEAD (or reads quality/snapshot.json) and compares to quality/baseline.json:
// per-skill SQS deltas, new/removed skills, verdict downgrades, and regressions.
//
// Usage:
//   node scripts/quality/track.mjs            # uses existing snapshot.json
//   node scripts/quality/track.mjs --rescore  # re-run score-all first
//   node scripts/quality/track.mjs --json
//
// Exits 1 if any regression beyond --threshold (default 2.0 SQS) is found.

import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const Q = path.join(ROOT, "quality");
const args = process.argv.slice(2);
const JSON_OUT = args.includes("--json");
const tIdx = args.indexOf("--threshold");
const THRESH = tIdx >= 0 ? parseFloat(args[tIdx + 1]) : 2.0;

if (args.includes("--rescore")) {
  execFileSync("node", ["scripts/quality/score-all.mjs"], { cwd: ROOT, stdio: "ignore" });
}

const load = (p) => JSON.parse(fs.readFileSync(path.join(Q, p), "utf8"));
let baseline, current;
try {
  baseline = load("baseline.json");
} catch {
  console.error("No quality/baseline.json. Freeze one: cp quality/snapshot.json quality/baseline.json");
  process.exit(2);
}
current = load("snapshot.json");

const bMap = new Map(baseline.skills.map((s) => [s.skill, s]));
const cMap = new Map(current.skills.map((s) => [s.skill, s]));

const downRank = { SHIP: 2, "NEEDS-WORK": 1, REJECT: 0 };
const changes = [];
for (const [name, c] of cMap) {
  const b = bMap.get(name);
  if (!b) {
    changes.push({ skill: name, kind: "new", sqs: c.sqs, verdict: c.verdict });
    continue;
  }
  const delta = Math.round((c.sqs - b.sqs) * 10) / 10;
  const verdictDown = downRank[c.verdict] < downRank[b.verdict];
  const regression = delta <= -THRESH || verdictDown;
  if (delta !== 0 || verdictDown)
    changes.push({
      skill: name,
      kind: regression ? "regression" : delta > 0 ? "improved" : "changed",
      delta,
      from: b.sqs,
      to: c.sqs,
      verdict_from: b.verdict,
      verdict_to: c.verdict,
    });
}
const removed = [...bMap.keys()].filter((k) => !cMap.has(k));

const regressions = changes.filter((c) => c.kind === "regression");
const out = {
  baseline_from: (baseline.generated_from || "").slice(0, 9),
  current_from: (current.generated_from || "").slice(0, 9),
  mean_delta: Math.round((current.summary.mean_sqs - baseline.summary.mean_sqs) * 10) / 10,
  regressions,
  improved: changes.filter((c) => c.kind === "improved"),
  new: changes.filter((c) => c.kind === "new"),
  removed,
};

if (JSON_OUT) {
  console.log(JSON.stringify(out, null, 2));
} else {
  console.log(`\nQuality tracking — baseline ${out.baseline_from} → current ${out.current_from}`);
  console.log(`Mean SQS delta: ${out.mean_delta >= 0 ? "+" : ""}${out.mean_delta}\n`);
  if (regressions.length) {
    console.log("⚠ Regressions:");
    for (const r of regressions)
      console.log(`  ${r.skill}: ${r.from} → ${r.to} (${r.delta}) ${r.verdict_from}→${r.verdict_to}`);
  } else console.log("✓ No regressions beyond threshold " + THRESH);
  if (out.new.length) console.log(`\nNew skills: ${out.new.map((n) => n.skill).join(", ")}`);
  if (removed.length) console.log(`Removed skills: ${removed.join(", ")}`);
}
process.exit(regressions.length ? 1 : 0);
