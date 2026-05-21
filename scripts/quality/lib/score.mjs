// Skill Quality Scorer — deterministic SQS implementation of quality/METRICS.md.
//
// The scorer operates on a plain directory (rootDir) so the SAME code serves
// HEAD scoring and git-history replay (which extracts a past version of a skill
// subtree into a temp dir via `git archive`, then scores it here).
//
// Public API:
//   scoreSkillDir(rootDir, { name, tier }) -> result object (see bottom)
//
// All metric functions return a number in [0,1] or null (null = not applicable,
// excluded from the dimension mean). Determinism: no time, no randomness.

import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const yaml = require("js-yaml");

// ---------- generic fs helpers (null-safe) ----------
const read = (root, rel) => {
  try {
    return fs.readFileSync(path.join(root, rel), "utf8");
  } catch {
    return null;
  }
};
const exists = (root, rel) => fs.existsSync(path.join(root, rel));
const isDir = (root, rel) => {
  try {
    return fs.statSync(path.join(root, rel)).isDirectory();
  } catch {
    return false;
  }
};
const listDir = (root, rel) => {
  try {
    return fs.readdirSync(path.join(root, rel));
  } catch {
    return [];
  }
};
const listFilesRec = (root, rel) => {
  const base = path.join(root, rel);
  const out = [];
  const walk = (d) => {
    let entries = [];
    try {
      entries = fs.readdirSync(d, { withFileTypes: true });
    } catch {
      return;
    }
    for (const e of entries) {
      const p = path.join(d, e.name);
      if (e.isDirectory()) walk(p);
      else out.push(path.relative(base, p));
    }
  };
  if (isDir(root, rel)) walk(base);
  return out;
};

// ---------- math helpers ----------
const clamp01 = (x) => Math.max(0, Math.min(1, x));
const mean = (xs) => {
  const v = xs.filter((x) => x !== null && x !== undefined && !Number.isNaN(x));
  return v.length ? v.reduce((a, b) => a + b, 0) / v.length : null;
};
const wmean = (pairs) => {
  // pairs: [value|null, weight]
  let s = 0,
    w = 0;
  for (const [v, weight] of pairs) {
    if (v === null || v === undefined || Number.isNaN(v)) continue;
    s += v * weight;
    w += weight;
  }
  return w ? s / w : null;
};
const round = (x, n = 3) =>
  x === null || x === undefined ? null : Math.round(x * 10 ** n) / 10 ** n;

// ---------- frontmatter ----------
export function splitFrontmatter(text) {
  if (typeof text !== "string") return { data: {}, body: "" };
  const m = text.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?/);
  if (!m) return { data: {}, body: text };
  let data = {};
  try {
    data = yaml.load(m[1]) || {};
  } catch {
    data = {};
  }
  return { data, body: text.slice(m[0].length) };
}

const wordCount = (s) => (s ? (s.match(/\S+/g) || []).length : 0);

// Count OPENING code fences and whether each declares a language.
// Returns { fences: n, withLang: m, codeText: "..." }.
function scanCodeFences(body) {
  const lines = body.split(/\r?\n/);
  let inFence = false;
  let fences = 0,
    withLang = 0;
  const code = [];
  for (const line of lines) {
    const t = line.trimStart();
    if (t.startsWith("```")) {
      if (!inFence) {
        inFence = true;
        fences++;
        const lang = t.slice(3).trim();
        if (lang) withLang++;
      } else {
        inFence = false;
      }
      continue;
    }
    if (inFence) code.push(line);
  }
  return { fences, withLang, codeText: code.join("\n") };
}

// ---------- discipline detection (mirrors dev-skill eval.md precedence) ----------
// Order, first match wins: metadata.discipline → distillation (impact-frontmatter
// rules) → composition (scripts/) → investigation (trees/queries) → extraction
// (assets/templates/*.template) → distillation (default).
export function detectDiscipline(root, meta) {
  if (meta && typeof meta.discipline === "string" && meta.discipline.trim())
    return meta.discipline.trim();
  const hasImpactRules = getRuleFiles(root).some(
    (r) => splitFrontmatter(r.text).data.impact
  );
  if (hasImpactRules) return "distillation";
  if (isDir(root, "scripts") && listFilesRec(root, "scripts").length)
    return "composition";
  const hasTree =
    listFilesRec(root, "references").some((f) => /-tree\.md$/.test(f)) ||
    isDir(root, "references/queries");
  if (hasTree) return "investigation";
  if (
    isDir(root, "assets/templates") &&
    listFilesRec(root, "assets/templates").some((f) => /\.template$/.test(f))
  )
    return "extraction";
  // No rule pack, no scripts, no trees, no templates → a prose/guidance skill.
  // Grading it as a broken distillation rule-pack is the proxy's worst bias
  // (calibration showed prose skills can have the HIGHEST functional value).
  return "guidance";
}

// ---------- rule-file parsing (distillation) ----------
function getRuleFiles(root) {
  const dir = "references";
  if (!isDir(root, dir)) return [];
  return listDir(root, dir)
    .filter((f) => f.endsWith(".md") && !f.startsWith("_"))
    .sort()
    .map((f) => ({ name: f, text: read(root, path.join(dir, f)) || "" }));
}

const QUANT =
  /\d+\s*[×x%]|\bO\([^)]*\)\s*(to|→|->)|\bO\(|\d+\s*-\s*\d+\s*[×x%]|\d+\s*ms\b|\breduces?\b|\bprevents?\b|\bavoids?\b|\beliminates?\b|\d+\s*(×|x)\b|\bfaster\b|\d+%/i;

// ---------- Layer A ----------
function discoverability(root, name, tier) {
  const skill = read(root, "SKILL.md") || "";
  const { data, body } = splitFrontmatter(skill);
  const desc = typeof data.description === "string" ? data.description : "";
  const declaredName = typeof data.name === "string" ? data.name : "";

  const desc_valid = desc.length > 0 && desc.length <= 1024 ? 1 : 0;
  const L = desc.length;
  const desc_packed =
    L >= 250 ? 1 : L >= 150 ? 0.7 : L >= 80 ? 0.4 : L > 0 ? 0.1 : 0;
  const has_trigger =
    /\buse(d| this skill)?\s+when\b|should be used when|when (writing|building|creating|migrating|optimi|reviewing|auditing|debugging|implementing|designing|using)/i.test(
      desc
    )
      ? 1
      : 0;
  const opensFirstPerson = /^\s*(i|you|we)\b/i.test(desc);
  const third_person =
    !opensFirstPerson && /this skill|use when|patterns|rules|guide/i.test(desc)
      ? 1
      : opensFirstPerson
      ? 0
      : 0.5;
  const negative_scope =
    /does not|doesn't cover|not for|use \w[\w-]* (skill )?instead|rather than|not cover/i.test(
      desc
    )
      ? 1
      : 0;
  const nameOk =
    /^[a-z0-9-]+$/.test(declaredName) &&
    declaredName.length >= 1 &&
    declaredName.length <= 64 &&
    !declaredName.startsWith("-") &&
    !declaredName.endsWith("-") &&
    !declaredName.includes("--") &&
    declaredName === name;
  const name_valid = nameOk ? 1 : 0;

  return {
    score: mean([
      desc_valid,
      desc_packed,
      has_trigger,
      third_person,
      negative_scope,
      name_valid,
    ]),
    metrics: {
      desc_valid,
      desc_packed,
      has_trigger,
      third_person,
      negative_scope,
      name_valid,
      desc_len: L,
    },
  };
}

function contextEconomy(root) {
  const skill = read(root, "SKILL.md") || "";
  const { body } = splitFrontmatter(skill);
  const lines = skill.split(/\r?\n/).length;
  const line_band =
    lines > 500
      ? 0
      : lines >= 350
      ? 0.4
      : lines >= 200
      ? 0.7
      : lines >= 80
      ? 1
      : lines >= 40
      ? 0.5
      : 0.3;
  const ruleFiles = getRuleFiles(root).length;
  const progressive_disclosure =
    ruleFiles >= 3 ||
    (isDir(root, "scripts") && listFilesRec(root, "scripts").length) ||
    isDir(root, "assets/templates")
      ? 1
      : ruleFiles >= 1
      ? 0.5
      : 0;
  const bw = wordCount(body);
  const body_focus = bw <= 1500 ? 1 : bw <= 2500 ? 0.6 : bw <= 4000 ? 0.3 : 0.1;
  return {
    score: mean([line_band, progressive_disclosure, body_focus]),
    metrics: { line_band, progressive_disclosure, body_focus, skill_lines: lines, body_words: bw },
  };
}

function structuralIntegrity(root, name, tier) {
  const skill = read(root, "SKILL.md") || "";
  const { data } = splitFrontmatter(skill);
  const desc = typeof data.description === "string" ? data.description : "";
  const declaredName = typeof data.name === "string" ? data.name : "";
  const lines = skill.split(/\r?\n/).length;

  const hard_fails = [];
  if (!/^[a-z0-9-]+$/.test(declaredName) || declaredName !== name)
    hard_fails.push("name");
  if (!(desc.length > 0 && desc.length <= 1024)) hard_fails.push("description");
  if (lines > 500) hard_fails.push("line-count");
  const skills_ref_pass = hard_fails.length === 0 ? 1 : 0;

  // metadata completeness
  let meta = null;
  try {
    meta = JSON.parse(read(root, "metadata.json") || "null");
  } catch {
    meta = null;
  }
  let metadata_complete = 0;
  if (meta) {
    const have = [
      typeof meta.version === "string",
      typeof meta.discipline === "string" && meta.discipline,
      typeof meta.abstract === "string" && meta.abstract,
      Array.isArray(meta.references) && meta.references.length > 0,
    ];
    metadata_complete = have.filter(Boolean).length / have.length;
  }

  // Quick Reference consistency
  let refs_consistent = null;
  if (isDir(root, "references")) {
    const qrSlugs = extractQuickRefSlugs(skill);
    if (qrSlugs.length) {
      const files = new Set(
        listDir(root, "references")
          .filter((f) => f.endsWith(".md") && !f.startsWith("_"))
          .map((f) => f.replace(/\.md$/, ""))
      );
      const missing = qrSlugs.filter((s) => !files.has(s));
      refs_consistent = missing.length === 0 ? 1 : 0;
    }
  }

  const agentsPresent = exists(root, "AGENTS.md");
  const agents_md =
    tier === ".curated" ? (agentsPresent ? 1 : 0) : agentsPresent ? 1 : 0.5;

  return {
    score: mean([skills_ref_pass, metadata_complete, refs_consistent, agents_md]),
    metrics: { skills_ref_pass, metadata_complete, refs_consistent, agents_md },
    hard_fails,
    meta,
  };
}

function extractQuickRefSlugs(skill) {
  const lines = skill.split(/\r?\n/);
  let inQR = false;
  const slugs = [];
  for (const line of lines) {
    if (/^##\s+Quick Reference\s*$/.test(line)) {
      inQR = true;
      continue;
    }
    if (inQR && /^##\s+/.test(line)) inQR = false;
    if (inQR) {
      const m = line.match(/^-\s+`([a-z]+-[a-z0-9-]+)`/);
      if (m) slugs.push(m[1]);
    }
  }
  return slugs;
}

function instructionalCalibration(root, discipline) {
  const skill = read(root, "SKILL.md") || "";
  const { body } = splitFrontmatter(skill);
  const rules = getRuleFiles(root);
  const allText = body + "\n" + rules.map((r) => r.text).join("\n");
  const words = Math.max(1, wordCount(allText));

  const vagueMatches =
    (allText.match(
      /\b(consider|might(?:\s+want)?|perhaps|maybe|probably|potentially|try to)\b/gi
    ) || []).length;
  const vaguePer1k = (vagueMatches / words) * 1000;
  const low_vagueness = clamp01(1 - vaguePer1k / 6); // ~6 per 1k words → 0

  const fluff =
    (allText.match(
      /\b(amazing|revolutionary|blazing(?:\s*fast)?|seamless(?:ly)?|cutting-edge|game-?changer|magical|effortless)\b/gi
    ) || []).length;
  const no_fluff = fluff === 0 ? 1 : clamp01(1 - fluff / 5);

  // Distillation: measure rationale from rule impactDescription. Other disciplines
  // don't use impact-rule files, so judge "explain the why" from the SKILL.md body.
  let has_rationale = null;
  if (discipline === "distillation" && rules.length) {
    const withDesc = rules.filter((r) => {
      const { data } = splitFrontmatter(r.text);
      return (
        (typeof data.impactDescription === "string" &&
          data.impactDescription.trim().length > 10) ||
        /\*\*(pattern intent|why|rationale)/i.test(r.text)
      );
    }).length;
    has_rationale = withDesc / rules.length;
  } else {
    has_rationale = /\bbecause\b|\bwhy\b|rationale|trade-?off|so that|in order to/i.test(
      body
    )
      ? 1
      : 0.5;
  }

  return {
    score: mean([low_vagueness, no_fluff, has_rationale]),
    metrics: {
      low_vagueness: round(low_vagueness),
      no_fluff: round(no_fluff),
      has_rationale: round(has_rationale),
      vague_count: vagueMatches,
      fluff_count: fluff,
    },
  };
}

// ---------- Layer B: distillation ----------
function distillationB(root) {
  const rules = getRuleFiles(root);
  const n = rules.length;
  const rule_count_band =
    n >= 40 && n <= 60
      ? 1
      : (n >= 30 && n < 40) || (n > 60 && n <= 70)
      ? 0.7
      : n >= 20 && n < 30
      ? 0.4
      : n >= 10
      ? 0.2
      : n > 0
      ? 0.1
      : 0;

  // impact calibration
  const impacts = rules
    .map((r) => splitFrontmatter(r.text).data.impact)
    .filter((x) => typeof x === "string")
    .map((x) => x.toUpperCase().trim());
  const critShare = impacts.length
    ? impacts.filter((i) => i === "CRITICAL").length / impacts.length
    : null;
  let impact_calibration =
    critShare === null
      ? null
      : critShare <= 0.3
      ? 1
      : clamp01(1 - (critShare - 0.3) / 0.4); // 70% crit → 0

  // category coverage: every section prefix has ≥1 rule
  const sections = parseSections(root);
  if (sections.length) {
    const prefixes = new Set(rules.map((r) => r.name.split("-")[0]));
    const empty = sections.filter((s) => s.prefix && !prefixes.has(s.prefix));
    if (impact_calibration === null) impact_calibration = 1;
    impact_calibration *= empty.length === 0 ? 1 : clamp01(1 - empty.length / sections.length);
  }

  // quantified impact
  const descs = rules
    .map((r) => splitFrontmatter(r.text).data.impactDescription)
    .filter((x) => typeof x === "string" && x.trim());
  const quantified_impact = descs.length
    ? descs.filter((d) => QUANT.test(d)).length / descs.length
    : null;

  // pair coverage
  const pair_coverage = n
    ? rules.filter((r) => /\*\*Incorrect/i.test(r.text) && /\*\*Correct/i.test(r.text))
        .length / n
    : null;

  // annotation descriptiveness
  let annTotal = 0,
    annDesc = 0;
  for (const r of rules) {
    const anns = r.text.match(/\*\*(Incorrect|Correct)\b[^*\n]*\*\*/gi) || [];
    for (const a of anns) {
      annTotal++;
      if (/\(/.test(a)) annDesc++;
    }
  }
  const annotation_desc = annTotal ? annDesc / annTotal : null;

  // code-fence language coverage + generic names
  let fences = 0,
    withLang = 0,
    generic = 0;
  for (const r of rules) {
    const s = scanCodeFences(r.text);
    fences += s.fences;
    withLang += s.withLang;
    generic += (s.codeText.match(/\b(foo|bar|baz|qux)\b/g) || []).length;
  }
  const codefence_lang = fences ? withLang / fences : null;
  const generic_name_avoid = generic === 0 ? 1 : clamp01(1 - generic / 10);

  const metrics = {
    rule_count_band: round(rule_count_band),
    impact_calibration: round(impact_calibration),
    quantified_impact: round(quantified_impact),
    pair_coverage: round(pair_coverage),
    annotation_desc: round(annotation_desc),
    codefence_lang: round(codefence_lang),
    generic_name_avoid: round(generic_name_avoid),
    rule_count: n,
    critical_share: round(critShare),
  };
  return {
    score: wmean([
      [rule_count_band, 5],
      [impact_calibration, 8],
      [quantified_impact, 8],
      [pair_coverage, 10],
      [annotation_desc, 6],
      [codefence_lang, 5],
      [generic_name_avoid, 3],
    ]),
    metrics,
  };
}

function parseSections(root) {
  const text = read(root, "references/_sections.md");
  if (!text) return [];
  const out = [];
  const re = /^##\s+\d+\.\s+(.+?)\s*\(([a-z0-9-]+)\)\s*$/gim;
  let m;
  while ((m = re.exec(text))) out.push({ name: m[1], prefix: m[2] });
  return out;
}

// ---------- Layer B: composition ----------
function compositionB(root) {
  const scriptFiles = listFilesRec(root, "scripts").filter((f) =>
    /\.(sh|bash|mjs|js|py)$/.test(f)
  );
  const abs = (f) => path.join(root, "scripts", f);
  let syntaxOk = 0,
    syntaxTot = 0,
    strict = 0,
    shTot = 0,
    validated = 0;
  for (const f of scriptFiles) {
    const p = abs(f);
    const text = fs.readFileSync(p, "utf8");
    // syntax
    syntaxTot++;
    try {
      if (/\.(sh|bash)$/.test(f)) execFileSync("bash", ["-n", p], { stdio: "ignore" });
      else if (/\.(mjs|js)$/.test(f)) execFileSync("node", ["--check", p], { stdio: "ignore" });
      // -B + ast.parse = syntax check with NO bytecode written (no __pycache__).
      else if (/\.py$/.test(f))
        execFileSync("python3", ["-B", "-c", "import ast,sys; ast.parse(open(sys.argv[1]).read())", p], {
          stdio: "ignore",
        });
      syntaxOk++;
    } catch {
      /* fail */
    }
    if (/\.(sh|bash)$/.test(f)) {
      shTot++;
      if (/set\s+-[a-z]*e[a-z]*/.test(text) && /pipefail/.test(text)) strict++;
    }
    if (/\$#|\[\s*-z\s|\busage\b|exit\s+1/i.test(text)) validated++;
  }
  const script_syntax = syntaxTot ? syntaxOk / syntaxTot : null;
  const strict_mode = shTot ? strict / shTot : null;
  const input_validation = syntaxTot ? validated / syntaxTot : null;

  // guardrails: destructive ops guarded
  const allScripts = scriptFiles.map((f) => fs.readFileSync(abs(f), "utf8")).join("\n");
  const destructive = /\brm\s+-rf|git\s+push|curl[^\n]*-X\s*(POST|PUT|DELETE)|DROP\s+(TABLE|DATABASE)|--force\b/i.test(
    allScripts
  );
  const guardword = /confirm|--dry-run|dry_run|read -p|are you sure|--yes|prompt/i.test(
    allScripts
  );
  const guardrails = !destructive ? 1 : guardword ? 1 : 0;

  const skill = read(root, "SKILL.md") || "";
  const dryrun_doc = /dry-?run|preview|--dry-run/i.test(skill + allScripts) ? 1 : 0;

  return {
    score: wmean([
      [script_syntax, 14],
      [strict_mode, 8],
      [input_validation, 8],
      [guardrails, 10],
      [dryrun_doc, 5],
    ]),
    metrics: {
      script_syntax: round(script_syntax),
      strict_mode: round(strict_mode),
      input_validation: round(input_validation),
      guardrails,
      dryrun_doc,
      script_count: scriptFiles.length,
    },
  };
}

// ---------- Layer B: investigation ----------
function investigationB(root) {
  const treeFiles = listFilesRec(root, "references").filter((f) => /-tree\.md$/.test(f));
  const tree_present = treeFiles.length || isDir(root, "references/queries") ? 1 : 0;
  let leaves = 0,
    actionLeaves = 0,
    branchLines = 0,
    measurable = 0;
  for (const f of treeFiles) {
    const t = read(root, path.join("references", f)) || "";
    for (const line of t.split(/\r?\n/)) {
      if (/^\s*[-*]\s|→|->/.test(line)) {
        leaves++;
        if (/\b(fix|escalate|dismiss|restart|roll ?back|check|run|verify|investigate)\b/i.test(line))
          actionLeaves++;
      }
      if (/\bif\b|\?|>|<|=/.test(line)) {
        branchLines++;
        if (/[<>]=?\s*\d|\d+\s*(ms|%|s)\b/.test(line)) measurable++;
      }
    }
  }
  const no_dead_ends = leaves ? actionLeaves / leaves : null;
  const measurable_criteria = branchLines ? measurable / branchLines : null;
  const queryDir = "references/queries";
  const queries = listFilesRec(root, queryDir);
  const query_valid = queries.length
    ? queries.filter((q) => {
        const t = read(root, path.join(queryDir, q)) || "";
        return /^\s*(--|#|\/\/)/.test(t.trimStart());
      }).length / queries.length
    : null;
  return {
    score: wmean([
      [tree_present, 10],
      [no_dead_ends, 12],
      [measurable_criteria, 8],
      [query_valid, 8],
    ]),
    metrics: {
      tree_present,
      no_dead_ends: round(no_dead_ends),
      measurable_criteria: round(measurable_criteria),
      query_valid: round(query_valid),
      tree_count: treeFiles.length,
    },
  };
}

// ---------- Layer B: extraction ----------
function extractionB(root) {
  const templates = listFilesRec(root, "assets/templates");
  const template_present = templates.length ? 1 : 0;
  const allTpl = templates
    .map((f) => read(root, path.join("assets/templates", f)) || "")
    .join("\n");
  const conv =
    read(root, "references/conventions.md") ||
    read(root, "references/_sections.md") ||
    read(root, "SKILL.md") ||
    "";
  const placeholders = (allTpl.match(/\{[a-zA-Z][\w-]*\}/g) || []).length;
  const params_documented = placeholders
    ? clamp01(
        (conv.match(/\{[a-zA-Z][\w-]*\}|\bparameter|\bplaceholder/gi) || []).length /
          Math.max(1, placeholders / 3)
      )
    : null;
  const convention_rationale = /\bwhy\b|because|rationale|trade-?off/i.test(conv) ? 1 : 0.3;
  const literalPaths = (allTpl.match(/\/(src|app|components|pages)\//g) || []).length;
  const no_hardcoded = placeholders
    ? clamp01(placeholders / (placeholders + literalPaths))
    : null;
  return {
    score: wmean([
      [template_present, 10],
      [params_documented, 10],
      [convention_rationale, 8],
      [no_hardcoded, 6],
    ]),
    metrics: {
      template_present,
      params_documented: round(params_documented),
      convention_rationale,
      no_hardcoded: round(no_hardcoded),
      template_count: templates.length,
    },
  };
}

// ---------- Layer B: guidance (prose skills) ----------
// Prose/guidance skills aren't rule packs; judge them as prose: organized,
// actionable, reasoned, and right-sized. (Added in calibration re-tune.)
function guidanceB(root) {
  const skill = read(root, "SKILL.md") || "";
  const { body } = splitFrontmatter(skill);
  const refFiles = listFilesRec(root, "references").filter(
    (f) => f.endsWith(".md") && !path.basename(f).startsWith("_")
  );
  const allText = body + "\n" + refFiles.map((f) => read(root, path.join("references", f)) || "").join("\n");

  const headings = (allText.match(/^##\s+/gm) || []).length;
  const has_structure = headings >= 6 ? 1 : headings >= 3 ? 0.7 : headings >= 1 ? 0.4 : 0.1;

  const stepLines = (allText.match(/^\s*(\d+\.|[-*])\s+\S/gm) || []).length;
  const imperative =
    /\b(use|avoid|run|write|define|ask|check|start|prefer|set|extract|map|build|create|enforce)\b/gi.test(
      allText
    );
  const actionable = stepLines >= 8 ? 1 : stepLines >= 3 ? 0.7 : imperative ? 0.5 : 0.2;

  const has_rationale = /\bbecause\b|\bwhy\b|rationale|trade-?off|so that|in order to|the point is/i.test(
    allText
  )
    ? 1
    : 0.4;

  const w = wordCount(allText);
  const depth = w >= 400 && w <= 4000 ? 1 : w >= 200 ? 0.7 : w >= 100 ? 0.4 : w > 4000 ? 0.5 : 0.2;

  return {
    score: mean([has_structure, actionable, has_rationale, depth]),
    metrics: {
      has_structure: round(has_structure),
      actionable: round(actionable),
      has_rationale: round(has_rationale),
      depth: round(depth),
      headings,
      step_lines: stepLines,
      words: w,
    },
  };
}

// ---------- top-level ----------
export function scoreSkillDir(rootDir, { name, tier }) {
  const struct = structuralIntegrity(rootDir, name, tier);
  const discipline = detectDiscipline(rootDir, struct.meta);

  const A1 = discoverability(rootDir, name, tier);
  const A2 = contextEconomy(rootDir);
  const A3 = struct;
  const A4 = instructionalCalibration(rootDir, discipline);

  let B;
  if (discipline === "composition") B = compositionB(rootDir);
  else if (discipline === "investigation") B = investigationB(rootDir);
  else if (discipline === "extraction") B = extractionB(rootDir);
  else if (discipline === "guidance") B = guidanceB(rootDir);
  else B = distillationB(rootDir);

  const a1 = A1.score ?? 0;
  const a2 = A2.score ?? 0;
  const a3 = A3.score ?? 0;
  const a4 = A4.score ?? 0;
  const b = B.score ?? 0;

  let sqs = 100 * (0.15 * a1 + 0.12 * a2 + 0.18 * a3 + 0.1 * a4 + 0.45 * b);
  // Hard structural failure caps at NEEDS-WORK ceiling (74).
  if (struct.hard_fails.length) sqs = Math.min(sqs, 74);
  sqs = Math.round(sqs * 10) / 10;

  const verdict = sqs >= 75 ? "SHIP" : sqs >= 50 ? "NEEDS-WORK" : "REJECT";

  return {
    skill: name,
    tier: tier.replace(/^\./, ""),
    discipline,
    sqs,
    verdict,
    hard_fails: struct.hard_fails,
    dimensions: {
      discoverability: round(a1),
      context_economy: round(a2),
      structural_integrity: round(a3),
      instructional_calibration: round(a4),
      discipline_score: round(b),
    },
    metrics: {
      discoverability: A1.metrics,
      context_economy: A2.metrics,
      structural_integrity: A3.metrics,
      instructional_calibration: A4.metrics,
      discipline: B.metrics,
    },
    meta_version:
      struct.meta && typeof struct.meta.version === "string"
        ? struct.meta.version
        : null,
  };
}
