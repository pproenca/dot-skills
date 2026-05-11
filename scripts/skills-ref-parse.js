#!/usr/bin/env node
// Helper for scripts/skills-ref. Wraps js-yaml so the bash dispatcher doesn't
// have to embed YAML parsing logic. Subcommands:
//
//   parse <SKILL.md>                Emit frontmatter as JSON.
//   check-yaml <SKILL.md>           Exit non-zero with diagnostics on parse failure.
//   read-properties <skill-dir>     Emit full property JSON (frontmatter + computed).
//   to-prompt <skill-dir> [...]     Emit <skills>…</skills> XML for the given skills.
//
// Default command: parse.

const fs = require('fs');
const path = require('path');

let yaml;
try {
  yaml = require('js-yaml');
} catch (e) {
  console.error('js-yaml not installed. Run `npm install` in the repo root.');
  process.exit(2);
}

function readFrontmatter(file) {
  const content = fs.readFileSync(file, 'utf8');
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  return { content, frontmatter: match ? match[1] : null };
}

function parseFile(file) {
  const { frontmatter } = readFrontmatter(file);
  if (frontmatter === null) return {};
  const parsed = yaml.load(frontmatter, { filename: file });
  if (parsed == null) return {};
  if (typeof parsed !== 'object' || Array.isArray(parsed)) {
    throw new Error('Frontmatter must be a YAML mapping at the top level.');
  }
  return parsed;
}

function cmdParse(file) {
  try {
    process.stdout.write(JSON.stringify(parseFile(file)));
  } catch (e) {
    console.error('YAML parse error in ' + file + ': ' + e.message);
    process.exit(1);
  }
}

function cmdCheckYaml(file) {
  try {
    parseFile(file);
  } catch (e) {
    console.error(e.message);
    process.exit(1);
  }
}

function cmdReadProperties(dir) {
  const skillMd = path.join(dir, 'SKILL.md');
  if (!fs.existsSync(skillMd)) {
    console.error(JSON.stringify({ error: 'SKILL.md not found' }));
    process.exit(1);
  }
  const content = fs.readFileSync(skillMd, 'utf8');
  let parsed = {};
  try { parsed = parseFile(skillMd); }
  catch (e) {
    console.error(JSON.stringify({ error: 'YAML parse error: ' + e.message }));
    process.exit(1);
  }

  const result = {
    ...parsed,
    _source: skillMd,
    _directory: path.basename(dir),
    _lineCount: content.split('\n').length,
    _category: path.basename(path.dirname(dir)),
    _hasAgentsMd: fs.existsSync(path.join(dir, 'AGENTS.md')),
    _referenceCount: 0,
  };

  const refsDir = path.join(dir, 'references');
  if (fs.existsSync(refsDir)) {
    result._referenceCount = fs.readdirSync(refsDir)
      .filter(f => f.endsWith('.md') && !f.startsWith('_'))
      .length;
  }

  process.stdout.write(JSON.stringify(result, null, 2));
}

function escapeXml(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function cmdToPrompt(dirs) {
  process.stdout.write('<?xml version="1.0" encoding="UTF-8"?>\n<skills>\n');

  for (const dir of dirs) {
    const skillMd = path.join(dir, 'SKILL.md');
    if (!fs.existsSync(skillMd)) {
      process.stdout.write('  <!-- Skipped: ' + dir + ' (no SKILL.md) -->\n');
      continue;
    }

    let parsed;
    try { parsed = parseFile(skillMd); }
    catch (e) {
      process.stdout.write('  <!-- Skipped: ' + dir + ' (YAML parse error) -->\n');
      continue;
    }

    const name = parsed.name || '';
    const description = parsed.description || '';
    const afterFrontmatter = fs.readFileSync(skillMd, 'utf8')
      .replace(/^---[\s\S]*?---\n/, '')
      .trim();

    // Split CDATA terminators so embedded "]]>" can't close the section.
    const safeCdata = afterFrontmatter.replace(/]]>/g, ']]]]><![CDATA[>');

    process.stdout.write(
      '  <skill name="' + escapeXml(name) + '">\n' +
      '    <description>' + escapeXml(description) + '</description>\n' +
      '    <content><![CDATA[\n' +
      safeCdata + '\n' +
      ']]></content>\n' +
      '  </skill>\n'
    );
  }

  process.stdout.write('</skills>\n');
}

const [, , cmd, ...args] = process.argv;

switch (cmd) {
  case 'parse':
  case undefined:
    if (!args[0] && cmd === undefined) {
      console.error('Usage: skills-ref-parse.js <SKILL.md>');
      process.exit(2);
    }
    cmdParse(cmd === 'parse' ? args[0] : cmd);
    break;
  case 'check-yaml':
    cmdCheckYaml(args[0]);
    break;
  case 'read-properties':
    cmdReadProperties(args[0]);
    break;
  case 'to-prompt':
    cmdToPrompt(args);
    break;
  default:
    // Treat unknown first arg as a path → parse it.
    cmdParse(cmd);
}
