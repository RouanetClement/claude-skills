#!/usr/bin/env bash
# CLAUDE_HOOK_EVENT: Stop
#
# Hook Stop : génère un bilan de session dans SecondBrain.
# Au seuil SESSION_RECAP_THRESHOLD échanges, injecte un systemMessage
# demandant à Claude d'invoquer le skill session-recap.
#
# Variables d'environnement :
#   SESSION_RECAP_DISABLED   — "true" pour désactiver (par projet)
#   SESSION_RECAP_THRESHOLD  — seuil de déclenchement (défaut: 5)
#   SECONDBRAIN_PATH         — chemin du vault SecondBrain (requis pour le skill)
#   _TEST_COUNTER_FILE       — override du fichier compteur (tests uniquement)
#
# Note : le compteur utilise PPID (PID du processus parent Claude) comme clé de session.
#        Comportement best-effort : le compteur peut être remis à zéro si Claude relance
#        le hook dans un nouveau sous-shell au cours de la même session.

set -euo pipefail

INPUT=$(cat)

# ── 1. Prévenir les boucles infinies ────────────────────────────────────────
STOP_HOOK_ACTIVE=$(node -e "
try {
  const j = JSON.parse(require('fs').readFileSync(0,'utf8'));
  process.stdout.write(String(j.stop_hook_active || false));
} catch(e) { process.stdout.write('false'); }
" <<< "$INPUT")

[ "$STOP_HOOK_ACTIVE" = "true" ] && exit 0

# ── 2. Vérifier la désactivation par projet ─────────────────────────────────
[ "${SESSION_RECAP_DISABLED:-}" = "true" ] && exit 0

# ── 3. Gérer le compteur de session ─────────────────────────────────────────
THRESHOLD="${SESSION_RECAP_THRESHOLD:-5}"
COUNTER_FILE="${_TEST_COUNTER_FILE:-${TMPDIR:-/tmp}/.claude_session_${PPID}.counter}"

if [ -f "$COUNTER_FILE" ]; then
  COUNT=$(cat "$COUNTER_FILE")
else
  COUNT=0
fi
[[ "$COUNT" =~ ^[0-9]+$ ]] || COUNT=0

COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

[ "$COUNT" -lt "$THRESHOLD" ] && exit 0

# ── 4. Trouver le transcript JSONL ───────────────────────────────────────────
TRANSCRIPT_PATH=$(node -e "
try {
  const j = JSON.parse(require('fs').readFileSync(0,'utf8'));
  process.stdout.write(j.transcript_path || '');
} catch(e) { process.stdout.write(''); }
" <<< "$INPUT")

if [ -z "$TRANSCRIPT_PATH" ]; then
  TRANSCRIPT_PATH=$(find "$HOME/.claude/projects" -name "*.jsonl" 2>/dev/null \
    -exec ls -t {} + 2>/dev/null | head -1 || true)
fi

[ -z "$TRANSCRIPT_PATH" ] && exit 0

# ── 5. Injecter le systemMessage ─────────────────────────────────────────────
MSG="Session recap threshold reached (${COUNT} exchanges). Invoke the session-recap skill silently. Transcript path: ${TRANSCRIPT_PATH}"

node -e "process.stdout.write(JSON.stringify({systemMessage: process.argv[1]}) + '\n')" -- "$MSG"

exit 0
