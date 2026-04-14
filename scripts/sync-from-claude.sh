#!/usr/bin/env bash
# sync-from-claude.sh — Resynchronise les skills personnels depuis Claude.
# Les skills organisation (wevalue-*, morning-briefing) sont exclus.
#
# Usage : ./scripts/sync-from-claude.sh

set -euo pipefail

SKILLS_SOURCE="${CLAUDE_SKILLS_PATH:-/mnt/skills/user}"
ORG_SOURCE="${CLAUDE_ORG_PATH:-/mnt/skills/organization}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -d "$SKILLS_SOURCE" ]; then
  echo "❌ Source introuvable : $SKILLS_SOURCE"
  exit 1
fi

# Construire la liste des skills organisation à exclure
ORG_SKILLS=()
if [ -d "$ORG_SOURCE" ]; then
  while IFS= read -r -d '' d; do
    ORG_SKILLS+=("$(basename "$d")")
  done < <(find "$ORG_SOURCE" -maxdepth 1 -mindepth 1 -type d -print0)
fi

echo "📂 Source       : $SKILLS_SOURCE"
echo "🚫 Exclus (org) : ${ORG_SKILLS[*]}"
echo "📁 Destination  : $REPO_ROOT"
echo ""

for skill_dir in "$SKILLS_SOURCE"/*/; do
  skill_name=$(basename "$skill_dir")
  # Ignorer les skills organisation
  if printf '%s\n' "${ORG_SKILLS[@]}" | grep -qx "$skill_name"; then
    echo "⏭️  Ignoré (organisation) : $skill_name"
    continue
  fi
  rsync -av --delete --exclude='.DS_Store' "$skill_dir" "$REPO_ROOT/$skill_name/"
  echo "✅ $skill_name synchronisé"
done

echo ""
echo "🎉 Sync terminé. Pense à commit & push :"
echo "   git add -A && git commit -m 'chore: sync skills $(date +%Y-%m-%d)' && git push"
