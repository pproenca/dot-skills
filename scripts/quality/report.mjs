#!/usr/bin/env node
// Build quality/REPORT.md (Obsidian-friendly) + quality/dashboard.html
// from snapshot.json, history.json, and calibration/results.json.
//
// Usage: node scripts/quality/report.mjs

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const Q = path.join(ROOT, "quality");
const read = (p) => JSON.parse(fs.readFileSync(path.join(Q, p), "utf8"));

const snap = read("snapshot.json");
const hist = read("history.json");
let calib = { results: [] };
try {
  calib = read("calibration/results.json");
} catch {}

const skills = snap.skills;
const bySqsDesc = [...skills].sort((a, b) => b.sqs - a.sqs);
const top = bySqsDesc.slice(0, 10);
const bottom = [...skills].sort((a, b) => a.sqs - b.sqs).slice(0, 10);

const movers = Object.entries(hist.trajectories)
  .filter(([, v]) => v.versions > 1)
  .map(([k, v]) => ({ skill: k, ...v }));
const improvers = [...movers].sort((a, b) => b.delta - a.delta).slice(0, 8);
const decliners = [...movers].sort((a, b) => a.delta - b.delta).slice(0, 6);

const f1 = (x) => (x === null || x === undefined ? "–" : x.toFixed(1));
const pct = (n, d) => `${((100 * n) / d).toFixed(0)}%`;

// ---------------- REPORT.md ----------------
const s = snap.summary;
const md = [];
md.push("# dot-skills Quality Report");
md.push("");
md.push(
  `_Generated from \`${(snap.generated_from || "").slice(0, 9)}\` · ${s.count} skills · ` +
    `metrics: [METRICS.md](METRICS.md) · credibility: [calibration/correlation.md](calibration/correlation.md)_`
);
md.push("");
md.push("## TL;DR");
md.push("");
md.push(
  `- **Current mean SQS ${f1(s.mean_sqs)}** (median ${f1(s.median_sqs)}). ` +
    `Verdicts: ${Object.entries(s.verdicts).map(([k, v]) => `${v} ${k}`).join(", ")}.`
);
md.push(
  `- **The corpus is structurally mature and improving slowly.** Monthly mean SQS: ` +
    hist.monthly.map((m) => `${m.month.slice(2)} ${f1(m.mean_sqs)}`).join(" → ") +
    ". A dip in Mar–Apr coincides with bulk experimental additions; May recovers."
);
md.push(
  "- **SQS measures structure, NOT usefulness.** Calibration found SQS↔functional-lift " +
    "≈ −0.5: the highest-SQS sampled skill (`react`, 95.7) added **0%** over a no-skill " +
    "baseline, while two low-SQS prose skills added **+50–75%**. Read SQS as an authoring/" +
    "regression signal only — see [calibration](calibration/correlation.md)."
);
md.push(
  "- **Content bugs are common even in high-SQS skills** — the rubric review found a real, " +
    "fixable defect in ~8 of 12 sampled skills (e.g. a `jq --slurpfile` crash, a `Justfile` " +
    "detection bug, an API misname). Static scoring cannot see these."
);
md.push("");
md.push("## What we measure (and why no single number suffices)");
md.push("");
md.push("| Question | Instrument | Cost | Coverage |");
md.push("|----------|-----------|------|----------|");
md.push("| Follows authoring best practices? Structure regressed? | **SQS** (deterministic) | $0, instant | every skill, every commit |");
md.push("| Content correct / current / non-contradictory? | **Rubric review** | moderate | periodic sample |");
md.push("| Actually beats a no-skill baseline? | **FQD** (baseline-differential) | high | the skills that matter most |");
md.push("");
md.push(
  "SQS is a weighted composite over **Discoverability, Context economy, Structural integrity, " +
    "Instructional calibration** (universal) plus a **discipline** dimension (distillation / " +
    "composition / investigation / extraction / guidance). Full definitions and source " +
    "citations in [METRICS.md](METRICS.md)."
);
md.push("");
md.push("## Current state (HEAD)");
md.push("");
md.push("### By tier");
md.push("");
md.push("| Tier | Count | Mean SQS |");
md.push("|------|------:|---------:|");
for (const [k, v] of Object.entries(s.by_tier)) md.push(`| ${k} | ${v.count} | ${f1(v.mean_sqs)} |`);
md.push("");
md.push("### By discipline");
md.push("");
md.push("| Discipline | Count | Mean SQS |");
md.push("|------------|------:|---------:|");
for (const [k, v] of Object.entries(s.by_discipline)) md.push(`| ${k} | ${v.count} | ${f1(v.mean_sqs)} |`);
md.push("");
md.push("### Top 10 by SQS");
md.push("");
md.push("| SQS | Skill | Discipline | Tier |");
md.push("|----:|-------|-----------|------|");
for (const x of top) md.push(`| ${f1(x.sqs)} | ${x.skill} | ${x.discipline} | ${x.tier} |`);
md.push("");
md.push("### Bottom 10 by SQS (where to focus)");
md.push("");
md.push("| SQS | Verdict | Skill | Discipline | Tier |");
md.push("|----:|---------|-------|-----------|------|");
for (const x of bottom) md.push(`| ${f1(x.sqs)} | ${x.verdict} | ${x.skill} | ${x.discipline} | ${x.tier} |`);
md.push("");
md.push("## Quality over time (longitudinal)");
md.push("");
md.push("Scored against the actual tree at each month-end (skills later removed still count).");
md.push("");
md.push("| Month | Skills | Mean SQS | SHIP | NEEDS-WORK | REJECT |");
md.push("|-------|------:|---------:|----:|----------:|------:|");
for (const m of hist.monthly)
  md.push(
    `| ${m.month} | ${m.skill_count} | ${f1(m.mean_sqs)} | ${m.verdicts.SHIP || 0} | ${
      m.verdicts["NEEDS-WORK"] || 0
    } | ${m.verdicts.REJECT || 0} |`
  );
md.push("");
md.push("### Biggest improvers (per-skill SQS delta across its own versions)");
md.push("");
md.push("| Δ SQS | Skill | First → Last | Versions |");
md.push("|------:|-------|-------------|---------:|");
for (const x of improvers)
  md.push(`| +${f1(x.delta)} | ${x.skill} | ${f1(x.first_sqs)} → ${f1(x.last_sqs)} | ${x.versions} |`);
md.push("");
md.push(
  "_Pattern: many jumps are description-length fixes lifting a skill off the structural " +
    "hard-fail cap (74) — the #1 authoring failure in this repo._"
);
md.push("");
md.push("### Biggest decliners");
md.push("");
md.push("| Δ SQS | Skill | First → Last | Versions |");
md.push("|------:|-------|-------------|---------:|");
for (const x of decliners)
  md.push(`| ${f1(x.delta)} | ${x.skill} | ${f1(x.first_sqs)} → ${f1(x.last_sqs)} | ${x.versions} |`);
md.push("");
md.push("## Calibration — is SQS trustworthy?");
md.push("");
md.push(
  "12 stratified skills were independently checked with the dev-skill rubric; 3 got a full " +
    "baseline-differential functional eval. Full analysis: " +
    "[calibration/correlation.md](calibration/correlation.md)."
);
md.push("");
md.push("| Skill | SQS | SQS verdict | Rubric | FQD |");
md.push("|-------|----:|------------|--------|----:|");
for (const r of calib.results)
  md.push(
    `| ${r.skill} | ${f1(r.sqs)} | ${r.sqs_verdict} | ${r.rubric_verdict} | ${
      r.fqd === undefined ? "–" : (r.fqd >= 0 ? "+" : "") + (r.fqd * 100).toFixed(0) + "%"
    } |`
  );
md.push("");
md.push("**Conclusion.** SQS is a reliable, reproducible signal for **structural/authoring " +
  "quality and regressions** — and honestly only that. It does not predict whether a skill " +
  "helps (FQD) or whether its content is correct (rubric). Track all three; never read a high " +
  "SQS as proof a skill is good or useful.");
md.push("");
md.push("## Recommended actions");
md.push("");
md.push("1. **Fix the rubric-flagged content bugs** in sampled skills (nuqs `--slurpfile` crash, dx-harness `Justfile` detection, effect-ts API misname, react example contradiction).");
md.push("2. **Triage the bottom-10 SQS skills** for structural gaps (description packing, progressive disclosure, missing rule structure).");
md.push("3. **Run FQD on high-traffic skills** before assuming they add value — `react`-class skills may add little over a strong baseline.");
md.push("4. **Adopt the baseline** (`baseline.json`) and re-run the scorer on every change to catch regressions (see [README.md](README.md)).");
md.push("");
fs.writeFileSync(path.join(Q, "REPORT.md"), md.join("\n") + "\n");

// ---------------- dashboard.html ----------------
const data = {
  generated_from: snap.generated_from,
  summary: snap.summary,
  monthly: hist.monthly,
  top,
  bottom,
  improvers,
  decliners,
  calibration: calib.results,
  all: skills.map((x) => ({ skill: x.skill, sqs: x.sqs, discipline: x.discipline, tier: x.tier, verdict: x.verdict })),
};

const html = `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>dot-skills Quality Dashboard</title>
<style>
  :root{--bg:#0d1117;--card:#161b22;--border:#30363d;--fg:#e6edf3;--muted:#8b949e;--ship:#3fb950;--needs:#d29922;--reject:#f85149;--accent:#58a6ff}
  *{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--fg);font:14px/1.5 -apple-system,BlinkMacSystemFont,"Segoe UI",Helvetica,Arial,sans-serif}
  header{padding:24px 28px;border-bottom:1px solid var(--border)}h1{margin:0 0 4px;font-size:20px}.sub{color:var(--muted);font-size:13px}
  .wrap{padding:20px 28px;max-width:1200px;margin:0 auto}
  .grid{display:grid;gap:16px;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));margin-bottom:20px}
  .card{background:var(--card);border:1px solid var(--border);border-radius:10px;padding:16px}
  .kpi .n{font-size:30px;font-weight:700}.kpi .l{color:var(--muted);font-size:12px;text-transform:uppercase;letter-spacing:.04em}
  .panel{background:var(--card);border:1px solid var(--border);border-radius:10px;padding:18px;margin-bottom:20px}
  h2{font-size:15px;margin:0 0 14px;color:var(--fg)}
  table{width:100%;border-collapse:collapse;font-size:13px}th,td{text-align:left;padding:6px 8px;border-bottom:1px solid var(--border)}
  th{color:var(--muted);font-weight:600}td.n,th.n{text-align:right;font-variant-numeric:tabular-nums}
  .bar{height:10px;border-radius:5px;background:linear-gradient(90deg,var(--accent),#1f6feb)}
  .pill{display:inline-block;padding:1px 8px;border-radius:10px;font-size:11px;font-weight:600}
  .SHIP{background:rgba(63,185,80,.15);color:var(--ship)}.NEEDS-WORK{background:rgba(210,153,34,.15);color:var(--needs)}.REJECT{background:rgba(248,81,73,.15);color:var(--reject)}
  .two{display:grid;gap:20px;grid-template-columns:1fr 1fr}@media(max-width:820px){.two{grid-template-columns:1fr}}
  .note{background:rgba(88,166,255,.08);border:1px solid rgba(88,166,255,.3);border-radius:8px;padding:12px 14px;color:#c9d7ec;font-size:13px;margin-bottom:20px}
  svg{width:100%;height:auto;display:block}.axis{stroke:var(--border)}.gl{stroke:var(--border);stroke-dasharray:2 3;opacity:.5}.lbl{fill:var(--muted);font-size:11px}
  .dot{fill:var(--accent)}.line{fill:none;stroke:var(--accent);stroke-width:2}
</style></head><body>
<header><h1>dot-skills Quality Dashboard</h1>
<div class="sub">commit <code id="sha"></code> · <span id="count"></span> skills · SQS = structural/authoring quality index (0–100). <b>Not</b> a usefulness score — see calibration.</div></header>
<div class="wrap">
<div class="note" id="calibnote"></div>
<div class="grid" id="kpis"></div>
<div class="panel"><h2>Mean SQS over time (scored against the actual tree each month)</h2><div id="trend"></div></div>
<div class="two">
  <div class="panel"><h2>By discipline</h2><div id="disc"></div></div>
  <div class="panel"><h2>Calibration: SQS vs functional lift (FQD)</h2><div id="scatter"></div>
  <div class="sub" style="margin-top:8px">Negative relationship: high SQS ≠ high usefulness.</div></div>
</div>
<div class="two">
  <div class="panel"><h2>Top 10 by SQS</h2><table id="top"></table></div>
  <div class="panel"><h2>Bottom 10 by SQS</h2><table id="bottom"></table></div>
</div>
<div class="two">
  <div class="panel"><h2>Biggest improvers (Δ across versions)</h2><table id="improvers"></table></div>
  <div class="panel"><h2>Biggest decliners</h2><table id="decliners"></table></div>
</div>
<div class="panel"><h2>Calibration sample (SQS vs rubric vs FQD)</h2><table id="calib"></table></div>
</div>
<script id="data" type="application/json">${JSON.stringify(data)}</script>
<script>
const D=JSON.parse(document.getElementById('data').textContent);
const $=id=>document.getElementById(id);
$('sha').textContent=(D.generated_from||'').slice(0,9);$('count').textContent=D.summary.count;
$('calibnote').innerHTML='<b>Calibration finding:</b> SQS↔functional-lift ≈ −0.5 on the anchor. The highest-SQS sampled skill (react 95.7) added <b>0%</b> over baseline; two low-SQS prose skills added <b>+50–75%</b>. Use SQS for authoring quality &amp; regression tracking only.';
const v=D.summary.verdicts||{};
const kpis=[['Mean SQS',D.summary.mean_sqs.toFixed(1)],['Median SQS',D.summary.median_sqs.toFixed(1)],['SHIP',v.SHIP||0],['NEEDS-WORK',v['NEEDS-WORK']||0],['REJECT',v.REJECT||0]];
$('kpis').innerHTML=kpis.map(([l,n])=>'<div class="card kpi"><div class="n">'+n+'</div><div class="l">'+l+'</div></div>').join('');
// trend line
(function(){const m=D.monthly,W=820,H=220,pad=36;const xs=m.map((_,i)=>pad+i*(W-2*pad)/(m.length-1||1));
const lo=Math.min(...m.map(d=>d.mean_sqs))-2,hi=Math.max(...m.map(d=>d.mean_sqs))+2;const y=v=>H-pad-(v-lo)/(hi-lo)*(H-2*pad);
let g='';for(let t=0;t<=4;t++){const val=lo+(hi-lo)*t/4,yy=y(val);g+='<line class="gl" x1="'+pad+'" y1="'+yy+'" x2="'+(W-pad)+'" y2="'+yy+'"/><text class="lbl" x="4" y="'+(yy+3)+'">'+val.toFixed(0)+'</text>';}
const pts=m.map((d,i)=>xs[i]+','+y(d.mean_sqs));
let dots=m.map((d,i)=>'<circle class="dot" cx="'+xs[i]+'" cy="'+y(d.mean_sqs)+'" r="4"><title>'+d.month+': '+d.mean_sqs+'</title></circle><text class="lbl" x="'+xs[i]+'" y="'+(H-pad+16)+'" text-anchor="middle">'+d.month.slice(2)+'</text><text class="lbl" x="'+xs[i]+'" y="'+(y(d.mean_sqs)-9)+'" text-anchor="middle">'+d.mean_sqs.toFixed(1)+'</text>').join('');
$('trend').innerHTML='<svg viewBox="0 0 '+W+' '+H+'">'+g+'<polyline class="line" points="'+pts.join(' ')+'"/>'+dots+'</svg>';})();
// discipline bars
(function(){const d=D.summary.by_discipline,keys=Object.keys(d).sort((a,b)=>d[b].mean_sqs-d[a].mean_sqs);const max=100;
$('disc').innerHTML='<table>'+keys.map(k=>{const w=(d[k].mean_sqs/max*100).toFixed(0);return '<tr><td>'+k+'</td><td class="n">'+d[k].count+'</td><td style="width:55%"><div class="bar" style="width:'+w+'%"></div></td><td class="n">'+d[k].mean_sqs.toFixed(1)+'</td></tr>';}).join('')+'</table>';})();
// scatter SQS vs FQD
(function(){const c=D.calibration.filter(r=>r.fqd!==undefined);if(!c.length){$('scatter').innerHTML='<div class="sub">no FQD points</div>';return;}
const W=420,H=220,pad=40;const x=v=>pad+(v-40)/(100-40)*(W-2*pad);const y=v=>H-pad-(v-0)/(0.8)*(H-2*pad);
let g='';for(let t=0;t<=4;t++){const yy=pad+t*(H-2*pad)/4,val=80-t*20;g+='<line class="gl" x1="'+pad+'" y1="'+yy+'" x2="'+(W-pad)+'" y2="'+yy+'"/><text class="lbl" x="4" y="'+(yy+3)+'">'+val+'%</text>';}
const pts=c.map(r=>'<circle class="dot" cx="'+x(r.sqs)+'" cy="'+y(r.fqd)+'" r="6"><title>'+r.skill+' SQS '+r.sqs+' FQD '+(r.fqd*100)+'%</title></circle><text class="lbl" x="'+(x(r.sqs)+9)+'" y="'+(y(r.fqd)+4)+'">'+r.skill+'</text>').join('');
$('scatter').innerHTML='<svg viewBox="0 0 '+W+' '+H+'">'+g+'<text class="lbl" x="'+(W/2)+'" y="'+(H-6)+'" text-anchor="middle">SQS →</text>'+pts+'</svg>';})();
function tbl(id,rows,head){$(id).innerHTML='<tr>'+head.map(h=>'<th class="'+(h.n?'n':'')+'">'+h.t+'</th>').join('')+'</tr>'+rows;}
tbl('top',D.top.map(x=>'<tr><td class="n">'+x.sqs.toFixed(1)+'</td><td>'+x.skill+'</td><td>'+x.discipline+'</td></tr>').join(''),[{t:'SQS',n:1},{t:'Skill'},{t:'Discipline'}]);
tbl('bottom',D.bottom.map(x=>'<tr><td class="n">'+x.sqs.toFixed(1)+'</td><td><span class="pill '+x.verdict+'">'+x.verdict+'</span></td><td>'+x.skill+'</td></tr>').join(''),[{t:'SQS',n:1},{t:'Verdict'},{t:'Skill'}]);
tbl('improvers',D.improvers.map(x=>'<tr><td class="n" style="color:var(--ship)">+'+x.delta.toFixed(1)+'</td><td>'+x.skill+'</td><td class="n">'+x.first_sqs.toFixed(1)+'→'+x.last_sqs.toFixed(1)+'</td></tr>').join(''),[{t:'Δ',n:1},{t:'Skill'},{t:'First→Last',n:1}]);
tbl('decliners',D.decliners.map(x=>'<tr><td class="n" style="color:var(--reject)">'+x.delta.toFixed(1)+'</td><td>'+x.skill+'</td><td class="n">'+x.first_sqs.toFixed(1)+'→'+x.last_sqs.toFixed(1)+'</td></tr>').join(''),[{t:'Δ',n:1},{t:'Skill'},{t:'First→Last',n:1}]);
tbl('calib',D.calibration.map(r=>'<tr><td>'+r.skill+'</td><td class="n">'+r.sqs.toFixed(1)+'</td><td><span class="pill '+r.sqs_verdict+'">'+r.sqs_verdict+'</span></td><td><span class="pill '+r.rubric_verdict+'">'+r.rubric_verdict+'</span></td><td class="n">'+(r.fqd===undefined?'–':(r.fqd>=0?'+':'')+(r.fqd*100).toFixed(0)+'%')+'</td></tr>').join(''),[{t:'Skill'},{t:'SQS',n:1},{t:'SQS verdict'},{t:'Rubric'},{t:'FQD',n:1}]);
</script></body></html>`;
fs.writeFileSync(path.join(Q, "dashboard.html"), html);
console.log("Wrote quality/REPORT.md and quality/dashboard.html");
