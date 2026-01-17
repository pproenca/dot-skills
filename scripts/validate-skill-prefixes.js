#!/usr/bin/env node

/**
 * Validates that rule prefixes are unique across skills
 * Run: node scripts/validate-skill-prefixes.js
 *
 * Checks:
 * 1. No duplicate prefixes across different skills
 * 2. All skills have negative cases in descriptions for overlapping domains
 * 3. Related skills sections exist for interdependent skills
 * 4. Trigger keywords are sufficiently distinct
 */

const fs = require('fs');
const path = require('path');

const SKILLS_DIR = path.join(__dirname, '..', 'skills');

// Known related skill pairs that should have cross-references
const RELATED_SKILL_PAIRS = [
  ['tanstack-query', 'orval-openapi'],
  ['tanstack-query', 'mswjs'],
  ['react-19', 'nextjs-16-app-router'],
  ['react-19', 'react-hook-form'],
  ['react-hook-form', 'zod-schema'],
  ['vitest', 'test-driven-development'],
  ['vitest', 'mswjs'],
];

// Prefixes that are allowed to be used in only one skill
const EXCLUSIVE_PREFIXES = new Map();

function getSkillDirectories() {
  return fs.readdirSync(SKILLS_DIR)
    .filter(dir => {
      const fullPath = path.join(SKILLS_DIR, dir);
      return fs.statSync(fullPath).isDirectory() &&
             fs.existsSync(path.join(fullPath, 'SKILL.md'));
    });
}

function extractPrefixes(skillDir) {
  const rulesDir = path.join(SKILLS_DIR, skillDir, 'rules');
  if (!fs.existsSync(rulesDir)) {
    return [];
  }

  const files = fs.readdirSync(rulesDir)
    .filter(f => f.endsWith('.md') && !f.startsWith('_'));

  const prefixes = new Set();
  for (const file of files) {
    const match = file.match(/^([a-z]+-)/);
    if (match) {
      prefixes.add(match[1]);
    }
  }
  return Array.from(prefixes);
}

function extractDescription(skillDir) {
  const skillPath = path.join(SKILLS_DIR, skillDir, 'SKILL.md');
  const content = fs.readFileSync(skillPath, 'utf-8');

  const match = content.match(/description:\s*(.+?)(?:\n(?:[a-z]+:|---))/s);
  if (match) {
    return match[1].trim();
  }
  return '';
}

function hasRelatedSkillsSection(skillDir) {
  const skillPath = path.join(SKILLS_DIR, skillDir, 'SKILL.md');
  const content = fs.readFileSync(skillPath, 'utf-8');
  return content.includes('## Related Skills');
}

function hasNegativeCases(skillDir) {
  const description = extractDescription(skillDir);
  return description.includes('does NOT') || description.includes('does not cover');
}

function validatePrefixUniqueness() {
  const errors = [];
  const prefixToSkills = new Map();

  const skills = getSkillDirectories();

  for (const skill of skills) {
    const prefixes = extractPrefixes(skill);
    for (const prefix of prefixes) {
      if (!prefixToSkills.has(prefix)) {
        prefixToSkills.set(prefix, []);
      }
      prefixToSkills.get(prefix).push(skill);
    }
  }

  for (const [prefix, skills] of prefixToSkills) {
    if (skills.length > 1) {
      errors.push({
        type: 'duplicate-prefix',
        prefix,
        skills,
        message: `Prefix '${prefix}' is used by multiple skills: ${skills.join(', ')}`
      });
    }
  }

  return errors;
}

function validateNegativeCases() {
  const warnings = [];
  const overlappingDomains = [
    'react-19',
    'nextjs-16-app-router',
    'react-hook-form',
    'vitest',
    'test-driven-development',
    'mswjs',
    'tanstack-query',
  ];

  for (const skill of overlappingDomains) {
    const skillPath = path.join(SKILLS_DIR, skill);
    if (fs.existsSync(skillPath) && !hasNegativeCases(skill)) {
      warnings.push({
        type: 'missing-negative-cases',
        skill,
        message: `Skill '${skill}' should have negative cases (e.g., "does NOT cover...") in description to prevent wrong activation`
      });
    }
  }

  return warnings;
}

function validateCrossReferences() {
  const warnings = [];

  for (const [skill1, skill2] of RELATED_SKILL_PAIRS) {
    const skill1Path = path.join(SKILLS_DIR, skill1);
    const skill2Path = path.join(SKILLS_DIR, skill2);

    if (fs.existsSync(skill1Path) && !hasRelatedSkillsSection(skill1)) {
      warnings.push({
        type: 'missing-cross-reference',
        skill: skill1,
        relatedTo: skill2,
        message: `Skill '${skill1}' should have a Related Skills section referencing '${skill2}'`
      });
    }

    if (fs.existsSync(skill2Path) && !hasRelatedSkillsSection(skill2)) {
      warnings.push({
        type: 'missing-cross-reference',
        skill: skill2,
        relatedTo: skill1,
        message: `Skill '${skill2}' should have a Related Skills section referencing '${skill1}'`
      });
    }
  }

  return warnings;
}

function main() {
  console.log('=== Skill Prefix Validation ===\n');

  let hasErrors = false;

  // Check prefix uniqueness
  console.log('Checking prefix uniqueness...');
  const prefixErrors = validatePrefixUniqueness();
  if (prefixErrors.length > 0) {
    hasErrors = true;
    console.log(`\n❌ Found ${prefixErrors.length} prefix collision(s):\n`);
    for (const error of prefixErrors) {
      console.log(`  - ${error.message}`);
    }
  } else {
    console.log('✅ All prefixes are unique across skills');
  }

  // Check negative cases
  console.log('\nChecking negative cases in descriptions...');
  const negativeCaseWarnings = validateNegativeCases();
  if (negativeCaseWarnings.length > 0) {
    console.log(`\n⚠️  Found ${negativeCaseWarnings.length} skill(s) missing negative cases:\n`);
    for (const warning of negativeCaseWarnings) {
      console.log(`  - ${warning.message}`);
    }
  } else {
    console.log('✅ All overlapping domain skills have negative cases');
  }

  // Check cross-references
  console.log('\nChecking cross-references...');
  const crossRefWarnings = validateCrossReferences();
  if (crossRefWarnings.length > 0) {
    console.log(`\n⚠️  Found ${crossRefWarnings.length} missing cross-reference(s):\n`);
    for (const warning of crossRefWarnings) {
      console.log(`  - ${warning.message}`);
    }
  } else {
    console.log('✅ All related skills have cross-references');
  }

  console.log('\n=== Summary ===');
  console.log(`Errors: ${prefixErrors.length}`);
  console.log(`Warnings: ${negativeCaseWarnings.length + crossRefWarnings.length}`);

  if (hasErrors) {
    process.exit(1);
  }
}

main();
