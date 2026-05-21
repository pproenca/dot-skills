#!/usr/bin/env node
// Longitudinal quality replay across the full git history.
//
// Produces quality/history.json with:
//   - trajectories: per current-skill SQS at every commit that touched its dir
//   - monthly: repo-wide aggregates scored against the ACTUAL tree at each
//     month-end commit (so skills that existed then but were later removed
//     still count toward that month's average)
//
// Method: `git archive <commit> -- <path>` into a temp dir, then score with the
// same scoreSkillDir() used at HEAD. No working-tree checkout, no branch switch.
//
// Usage: node scripts/quality/score-history.mjs [--out quality/history.json]

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { scoreSkillDir } from "./lib/score.mjs";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const args = process.argv.slice(2);
const outIdx = args.indexOf("--out");
const OUT = outIdx >= 0 ? args[outIdx + 1] : path.join(ROOT, "quality/history.json");

const TMP = fs.mkdtempSync(path.join(os.tmpdir(), "skillqual-"));
process.on("exit", () => {
  try {
    fs.rmSync(TMP, { recursive: true, force: true });
  } catch {}
});

const git = (a) => execFileSync("git", a, { cwd: ROOT, encoding: "utf8" });

let archiveSeq = 0;
// Extract `pathspec` at `commit` into a fresh temp dir; return its path or null.
function archive(commit, pathspec) {
  const dest = path.join(TMP, `a${archiveSeq++}`);
  const tar = path.join(TMP, `a${archiveSeq}.tar`);
  try {
    execFileSync("git", ["archive", "--format=tar", "-o", tar, commit, "--", pathspec], {
      cwd: ROOT,
      stdio: "ignore",
    });
  } catch {
    return null; // pathspec absent at this commit
  }
  fs.mkdirSync(dest, { recursive: true });
  try {
    execFileSync("tar", ["-xf", tar, "-C", dest], { stdio: "ignore" });
  } catch {
    return null;
  } finally {
    fs.rmSync(tar, { force: true });
  }
  return dest;
}

function cleanup(dir) {
  if (dir) fs.rmSync(dir, { recursive: true, force: true });
}

// ---- current skills ----
function currentSkills() {
  const out = [];
  for (const tier of [".curated", ".experimental"]) {
    const base = path.join(ROOT, "skills", tier);
    if (!fs.existsSync(base)) continue;
    for (const name of fs.readdirSync(base)) {
      if (name.startsWith(".")) continue;
      if (fs.existsSync(path.join(base, name, "SKILL.md")))
        out.push({ name, tier, rel: `skills/${tier}/${name}` });
    }
  }
  return out.sort((a, b) => a.name.localeCompare(b.name));
}

// ---- per-skill trajectories ----
function trajectories(skills) {
  const result = {};
  for (const s of skills) {
    const log = git([
      "log",
      "--reverse",
      "--format=%H%x09%cI",
      "--",
      s.rel,
    ]).trim();
    if (!log) continue;
    const commits = log.split("\n").map((l) => {
      const [sha, date] = l.split("\t");
      return { sha, date };
    });
    const points = [];
    let prevSig = null;
    for (const c of commits) {
      const dir = archive(c.sha, s.rel);
      if (!dir) continue;
      const rootDir = path.join(dir, s.rel);
      if (!fs.existsSync(path.join(rootDir, "SKILL.md"))) {
        cleanup(dir);
        continue;
      }
      let r;
      try {
        r = scoreSkillDir(rootDir, { name: s.name, tier: s.tier });
      } catch {
        cleanup(dir);
        continue;
      }
      cleanup(dir);
      const sig = JSON.stringify([r.sqs, r.dimensions, r.discipline]);
      const changed = sig !== prevSig;
      prevSig = sig;
      points.push({
        sha: c.sha.slice(0, 9),
        date: c.date.slice(0, 10),
        sqs: r.sqs,
        verdict: r.verdict,
        discipline: r.discipline,
        version: r.meta_version,
        rule_count: r.metrics.discipline?.rule_count ?? null,
        dimensions: r.dimensions,
        changed,
      });
    }
    if (points.length) {
      const first = points[0].sqs;
      const last = points[points.length - 1].sqs;
      result[s.name] = {
        tier: s.tier.replace(/^\./, ""),
        discipline: points[points.length - 1].discipline,
        versions: points.length,
        first_sqs: first,
        last_sqs: last,
        delta: Math.round((last - first) * 10) / 10,
        points,
      };
    }
  }
  return result;
}

// ---- monthly repo aggregates (actual tree at each month-end) ----
function monthEnds() {
  // first..last commit dates
  const first = git(["log", "--reverse", "--format=%cI"]).trim().split("\n")[0].slice(0, 7);
  const last = git(["log", "-1", "--format=%cI"]).trim().slice(0, 7);
  const [fy, fm] = first.split("-").map(Number);
  const [ly, lm] = last.split("-").map(Number);
  const months = [];
  let y = fy,
    m = fm;
  while (y < ly || (y === ly && m <= lm)) {
    months.push(`${y}-${String(m).padStart(2, "0")}`);
    m++;
    if (m > 12) {
      m = 1;
      y++;
    }
  }
  return months.map((ym) => {
    const [yy, mm] = ym.split("-").map(Number);
    const nextY = mm === 12 ? yy + 1 : yy;
    const nextM = mm === 12 ? 1 : mm + 1;
    const until = `${nextY}-${String(nextM).padStart(2, "0")}-01T00:00:00`;
    const sha = git(["rev-list", "-1", `--until=${until}`, "HEAD"]).trim();
    return { month: ym, sha };
  });
}

function scoreTreeAt(sha) {
  const dir = archive(sha, "skills");
  if (!dir) return [];
  const skillsDir = path.join(dir, "skills");
  const rows = [];
  for (const tier of [".curated", ".experimental"]) {
    const base = path.join(skillsDir, tier);
    if (!fs.existsSync(base)) continue;
    for (const name of fs.readdirSync(base)) {
      if (name.startsWith(".")) continue;
      const sk = path.join(base, name);
      if (!fs.existsSync(path.join(sk, "SKILL.md"))) continue;
      try {
        const r = scoreSkillDir(sk, { name, tier });
        rows.push(r);
      } catch {}
    }
  }
  cleanup(dir);
  return rows;
}

const round = (x) => (x === null ? null : Math.round(x * 10) / 10);
const avg = (xs) => (xs.length ? xs.reduce((a, b) => a + b, 0) / xs.length : null);

function monthly() {
  const out = [];
  for (const { month, sha } of monthEnds()) {
    if (!sha) continue;
    const rows = scoreTreeAt(sha);
    if (!rows.length) continue;
    const sqs = rows.map((r) => r.sqs);
    const byTier = {};
    const byDisc = {};
    for (const r of rows) {
      (byTier[r.tier] ||= []).push(r.sqs);
      (byDisc[r.discipline] ||= []).push(r.sqs);
    }
    const verdicts = rows.reduce((a, r) => ((a[r.verdict] = (a[r.verdict] || 0) + 1), a), {});
    out.push({
      month,
      sha: sha.slice(0, 9),
      skill_count: rows.length,
      mean_sqs: round(avg(sqs)),
      verdicts,
      by_tier: Object.fromEntries(
        Object.entries(byTier).map(([k, v]) => [
          k.replace(/^\./, ""),
          { count: v.length, mean_sqs: round(avg(v)) },
        ])
      ),
      by_discipline: Object.fromEntries(
        Object.entries(byDisc).map(([k, v]) => [k, { count: v.length, mean_sqs: round(avg(v)) }])
      ),
    });
  }
  return out;
}

console.error("Replaying per-skill trajectories…");
const skills = currentSkills();
const traj = trajectories(skills);
console.error(`  ${Object.keys(traj).length} skills with history`);
console.error("Replaying monthly repo aggregates…");
const months = monthly();
console.error(`  ${months.length} month-end snapshots`);

const history = {
  generated_from: git(["rev-parse", "HEAD"]).trim(),
  metrics_spec: "quality/METRICS.md",
  monthly: months,
  trajectories: traj,
};
fs.mkdirSync(path.dirname(OUT), { recursive: true });
fs.writeFileSync(OUT, JSON.stringify(history, null, 2) + "\n");
console.error(`Wrote ${path.relative(ROOT, OUT)}`);
