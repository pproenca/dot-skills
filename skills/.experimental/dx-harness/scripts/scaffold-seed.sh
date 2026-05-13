#!/usr/bin/env bash
# scaffold-seed.sh — render seed.sh into a scratch dir
# Part of: dx-harness
#
# Generates a seed script that creates a canonical test user
# (dev@local.test / password) and minimal fixtures. Idempotent: re-running
# does not error or duplicate. The credentials are written to AGENTS.md too
# so devs and agents find them without asking.
#
# Usage:
#   bash scaffold-seed.sh <fingerprint-json>

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

require_jq
[[ $# -eq 1 ]] || die "Usage: $0 <fingerprint-json>"
FP="$1"
[[ -f "$FP" ]] || die "Fingerprint file not found: $FP"

DB_KIND=$(jq -r '.db_kind // ""' "$FP")
LANGS=$(jq -r '.languages | join(",")' "$FP")

# Real bcrypt hash of literal string "password" (cost 10).
# Generated with `htpasswd -bnBC 10 "" password | cut -d: -f2`.
# Most bcrypt libraries (bcryptjs, passlib, golang.org/x/crypto/bcrypt) accept $2a$ and $2b$.
BCRYPT_PASSWORD='$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW'

# Choose the seed strategy by framework / DB
SEED_BODY=""
case "$DB_KIND" in
  prisma)
    SEED_BODY='npx prisma db seed'
    ;;
  postgres|unknown-sql)
    SEED_BODY="psql \"\${DATABASE_URL:?DATABASE_URL must be set}\" <<SQL
-- Idempotent: use ON CONFLICT DO NOTHING
INSERT INTO users (id, email, password_hash, created_at)
VALUES (1, 'dev@local.test', '${BCRYPT_PASSWORD}', NOW())
ON CONFLICT (id) DO NOTHING;
SQL"
    ;;
  mysql)
    SEED_BODY="mysql \"\${DATABASE_URL:?DATABASE_URL must be set}\" <<SQL
INSERT IGNORE INTO users (id, email, password_hash, created_at)
VALUES (1, 'dev@local.test', '${BCRYPT_PASSWORD}', NOW());
SQL"
    ;;
  mongodb)
    SEED_BODY="mongosh \"\${DATABASE_URL:?DATABASE_URL must be set}\" --eval \"
db.users.updateOne(
  { email: 'dev@local.test' },
  { \\\$setOnInsert: { email: 'dev@local.test', passwordHash: '${BCRYPT_PASSWORD}', createdAt: new Date() } },
  { upsert: true }
)\""
    ;;
  *)
    SEED_BODY='echo "TODO: customize seed for your stack — see references/fix-recipes.md (scaffold-seed)"'
    ;;
esac

OUT_DIR=$(scratch_dir "seed")
TMPL="${DX_SKILL_DIR}/assets/templates/seed.sh.tmpl"
[[ -f "$TMPL" ]] || die "Template missing: $TMPL"

render_template "$TMPL" "${OUT_DIR}/seed.sh" \
  "SEED_BODY=${SEED_BODY}" \
  "TEST_EMAIL=dev@local.test" \
  "TEST_PASSWORD=password"

chmod +x "${OUT_DIR}/seed.sh"
log "Wrote seed to ${OUT_DIR}/seed.sh"
printf '%s\n' "$OUT_DIR"
