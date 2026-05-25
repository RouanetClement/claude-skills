# Session Recap — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Générer automatiquement un bilan structuré de chaque session Claude Code dans le vault SecondBrain, en lisant le transcript JSONL de la session via un hook Stop.

**Architecture:** Un hook Stop (`hooks/user/session-recap.sh`) incrémente un compteur de session par PID. Au seuil, il lit `transcript_path` depuis le payload et injecte un `systemMessage` qui déclenche le skill `session-recap`. Le skill lit le JSONL (session principale + sous-agents), extrait 7 dimensions, et écrit un snapshot horodaté dans `$SECONDBRAIN_PATH/wiki/sessions/`.

**Tech Stack:** Bash (hook), Node.js (parsing JSON dans le hook), Markdown + YAML frontmatter (skill + output), Claude Code Stop hooks API.

---

## Fichiers impactés

| Action | Chemin | Rôle |
|---|---|---|
| Créer | `hooks/user/session-recap.sh` | Hook Stop : compteur + injection systemMessage |
| Créer | `skills/gestion/session-recap/SKILL.md` | Instruction Claude de génération du bilan |
| Modifier | `scripts/sync-to-claude.sh` | Support des hooks non-PreToolUse (Stop, etc.) |
| Modifier | `CLAUDE.md` | Ajout de session-recap dans le tableau des skills |
| Modifier | `~/.claude/settings.json` | Env vars SECONDBRAIN_PATH + SESSION_RECAP_THRESHOLD |

---

## Task 1 : Mettre à jour sync-to-claude.sh pour supporter les hooks Stop

**Contexte :** Actuellement, `scripts/sync-to-claude.sh` enregistre tous les hooks `hooks/user/*.sh` comme `PreToolUse`. Le hook `session-recap.sh` est un `Stop` hook. On ajoute une convention : un commentaire `# CLAUDE_HOOK_EVENT: Stop` dans le script indique l'événement. Le script lit ce commentaire et enregistre dans le bon event.

**Files:**
- Modify: `scripts/sync-to-claude.sh:116-165`

- [ ] **Step 1 : Vérifier le comportement actuel**

```bash
grep -n "PreToolUse" scripts/sync-to-claude.sh
```

Expected output : ligne(s) mentionnant `PreToolUse` dans le bloc Node.

- [ ] **Step 2 : Remplacer le bloc Node dans sync-to-claude.sh**

Remplacer les lignes 119-165 (le bloc `node - ... NODE`) par :

```javascript
node - "$SETTINGS_FILE" "$HOOKS_DEST" "$HOOKS_ROOT" <<'NODE'
const fs   = require('fs');
const path = require('path');

const settingsFile = process.argv[2];
const hooksDestDir = process.argv[3];
const hooksSrcDir  = process.argv[4];

let settings = {};
if (fs.existsSync(settingsFile)) {
  try { settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8')); }
  catch (e) { console.error('Erreur lecture settings.json :', e.message); process.exit(1); }
}

if (!settings.hooks) settings.hooks = {};

// Lire l'event depuis le commentaire # CLAUDE_HOOK_EVENT: <event> dans la source
function readHookEvent(srcFile) {
  try {
    const content = fs.readFileSync(srcFile, 'utf8');
    const match = content.match(/^#\s*CLAUDE_HOOK_EVENT:\s*(\w+)/m);
    return match ? match[1] : 'PreToolUse';
  } catch (e) { return 'PreToolUse'; }
}

// Lire le matcher depuis # CLAUDE_HOOK_MATCHER: <matcher>
function readHookMatcher(srcFile, event) {
  try {
    const content = fs.readFileSync(srcFile, 'utf8');
    const match = content.match(/^#\s*CLAUDE_HOOK_MATCHER:\s*(.+)/m);
    return match ? match[1].trim() : (event === 'Stop' ? '' : 'Bash');
  } catch (e) { return event === 'Stop' ? '' : 'Bash'; }
}

const hookFiles = fs.readdirSync(hooksDestDir).filter(f => f.endsWith('.sh'));
let added = 0;

for (const hookFile of hookFiles) {
  const destPath = path.join(hooksDestDir, hookFile).replace(/\\/g, '/');
  const srcPath  = path.join(hooksSrcDir,  hookFile);
  const cmd      = `bash "${destPath}"`;
  const event    = readHookEvent(srcPath);
  const matcher  = readHookMatcher(srcPath, event);

  if (!settings.hooks[event]) settings.hooks[event] = [];

  const alreadyRegistered = settings.hooks[event].some(
    entry => entry.hooks && entry.hooks.some(h => h.command === cmd)
  );

  if (!alreadyRegistered) {
    const entry = { hooks: [{ type: 'command', command: cmd }] };
    if (matcher) entry.matcher = matcher;
    settings.hooks[event].push(entry);
    console.log(`  + Hook enregistre [${event}] : ${hookFile}`);
    added++;
  } else {
    console.log(`  = Deja enregistre [${event}] : ${hookFile}`);
  }
}

if (added > 0) {
  fs.writeFileSync(settingsFile, JSON.stringify(settings, null, 2) + '\n');
  console.log('settings.json mis a jour.');
} else {
  console.log('Aucune modification necessaire.');
}
NODE
```

> Attention : remplacer aussi l'appel `node - "$SETTINGS_FILE" "$HOOKS_DEST"` par `node - "$SETTINGS_FILE" "$HOOKS_DEST" "$HOOKS_ROOT"` (ligne ~119).

- [ ] **Step 3 : Vérifier que le script est valide bash**

```bash
bash -n scripts/sync-to-claude.sh
```

Expected : aucune sortie (aucune erreur de syntaxe).

- [ ] **Step 4 : Vérifier que les hooks existants sont toujours correctement détectés**

```bash
grep "CLAUDE_HOOK_EVENT" hooks/user/protect-main.sh || echo "pas de metadata → PreToolUse par défaut"
```

Expected : `pas de metadata → PreToolUse par défaut` — le hook existant n'a pas le commentaire, donc il reste PreToolUse (comportement inchangé).

- [ ] **Step 5 : Commit**

```bash
git add scripts/sync-to-claude.sh
git commit -m "feat(sync): support hook events autres que PreToolUse via CLAUDE_HOOK_EVENT header"
```

---

## Task 2 : Créer hooks/user/session-recap.sh

**Contexte :** Hook Stop qui s'exécute après chaque réponse Claude. Il gère un compteur de session, trouve le transcript JSONL, et injecte un systemMessage quand le seuil est atteint. Le champ `stop_hook_active` prévient les boucles infinies.

**Files:**
- Create: `hooks/user/session-recap.sh`

- [ ] **Step 1 : Créer le script de test**

Créer `hooks/user/test-session-recap.sh` (ne sera pas synced, juste pour validation locale) :

```bash
#!/usr/bin/env bash
# Test manuel du hook session-recap
PASS=0; FAIL=0

assert_eq() {
  if [ "$1" = "$2" ]; then
    echo "  PASS: $3"; PASS=$((PASS+1))
  else
    echo "  FAIL: $3 (got '$1', expected '$2')"; FAIL=$((FAIL+1))
  fi
}

echo "=== Test 1: stop_hook_active bloque le hook ==="
PAYLOAD='{"stop_hook_active":true}'
OUT=$(echo "$PAYLOAD" | SESSION_RECAP_DISABLED="" SESSION_RECAP_THRESHOLD="1" bash hooks/user/session-recap.sh 2>/dev/null)
assert_eq "$OUT" "" "sortie vide si stop_hook_active=true"

echo "=== Test 2: SESSION_RECAP_DISABLED bloque le hook ==="
PAYLOAD='{"stop_hook_active":false}'
OUT=$(echo "$PAYLOAD" | SESSION_RECAP_DISABLED="true" SESSION_RECAP_THRESHOLD="1" bash hooks/user/session-recap.sh 2>/dev/null)
assert_eq "$OUT" "" "sortie vide si SESSION_RECAP_DISABLED=true"

echo "=== Test 3: sous le seuil, pas d'injection ==="
# Nettoyer tout compteur existant
rm -f /tmp/.claude_session_test.counter
PAYLOAD='{"stop_hook_active":false}'
OUT=$(echo "$PAYLOAD" | SESSION_RECAP_DISABLED="" SESSION_RECAP_THRESHOLD="5" \
  _TEST_COUNTER_FILE="/tmp/.claude_session_test.counter" \
  bash hooks/user/session-recap.sh 2>/dev/null)
assert_eq "$OUT" "" "pas d'injection sous le seuil (compteur=1 < seuil=5)"

echo "=== Test 4: au seuil, injection d'un systemMessage ==="
echo "5" > /tmp/.claude_session_test.counter
PAYLOAD='{"stop_hook_active":false,"transcript_path":"/tmp/fake-session.jsonl"}'
OUT=$(echo "$PAYLOAD" | SESSION_RECAP_DISABLED="" SESSION_RECAP_THRESHOLD="5" \
  _TEST_COUNTER_FILE="/tmp/.claude_session_test.counter" \
  bash hooks/user/session-recap.sh 2>/dev/null)
echo "$OUT" | node -e "
  const j=JSON.parse(require('fs').readFileSync(0,'utf8'));
  process.exit(j.systemMessage && j.systemMessage.includes('session-recap') ? 0 : 1);
" && echo "  PASS: systemMessage contient 'session-recap'" && PASS=$((PASS+1)) \
  || { echo "  FAIL: systemMessage manquant ou invalide"; FAIL=$((FAIL+1)); }

# Nettoyage
rm -f /tmp/.claude_session_test.counter

echo ""
echo "Résultat: $PASS PASS, $FAIL FAIL"
[ "$FAIL" -eq 0 ]
```

- [ ] **Step 2 : Exécuter le test (doit échouer — hook n'existe pas encore)**

```bash
bash hooks/user/test-session-recap.sh
```

Expected : erreurs car `hooks/user/session-recap.sh` n'existe pas.

- [ ] **Step 3 : Créer hooks/user/session-recap.sh**

```bash
#!/usr/bin/env bash
# CLAUDE_HOOK_EVENT: Stop
#
# Hook Stop : génère un bilan de session dans SecondBrain.
# Au seuil SESSION_RECAP_THRESHOLD échanges, injecte un systemMessage
# demandant à Claude d'invoquer le skill session-recap.
#
# Variables d'environnement lues :
#   SESSION_RECAP_DISABLED   — "true" pour désactiver (par projet)
#   SESSION_RECAP_THRESHOLD  — seuil de déclenchement (défaut: 5)
#   SECONDBRAIN_PATH         — chemin du vault SecondBrain (requis pour le skill)
#   _TEST_COUNTER_FILE       — override du fichier compteur (tests uniquement)

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

# Le fichier compteur est unique par PID (PPID = PID du processus Claude)
COUNTER_FILE="${_TEST_COUNTER_FILE:-${TMPDIR:-/tmp}/.claude_session_${PPID}.counter}"

if [ -f "$COUNTER_FILE" ]; then
  COUNT=$(cat "$COUNTER_FILE")
else
  COUNT=0
fi

COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

# Sous le seuil → rien à faire
[ "$COUNT" -lt "$THRESHOLD" ] && exit 0

# ── 4. Trouver le transcript JSONL ───────────────────────────────────────────
TRANSCRIPT_PATH=$(node -e "
try {
  const j = JSON.parse(require('fs').readFileSync(0,'utf8'));
  process.stdout.write(j.transcript_path || '');
} catch(e) { process.stdout.write(''); }
" <<< "$INPUT")

# Fallback : JSONL le plus récent dans ~/.claude/projects/
if [ -z "$TRANSCRIPT_PATH" ]; then
  TRANSCRIPT_PATH=$(find "$HOME/.claude/projects" -name "*.jsonl" 2>/dev/null \
    | xargs ls -t 2>/dev/null | head -1 || true)
fi

if [ -z "$TRANSCRIPT_PATH" ]; then
  # Impossible de trouver le transcript — ne pas injecter de message d'erreur intrusif
  exit 0
fi

# ── 5. Injecter le systemMessage ─────────────────────────────────────────────
MSG="Session recap threshold reached (${COUNT} exchanges). "
MSG+="Invoke the session-recap skill silently. "
MSG+="Transcript path: ${TRANSCRIPT_PATH}"

node -e "process.stdout.write(JSON.stringify({systemMessage: process.argv[1]}) + '\n')" -- "$MSG"

exit 0
```

- [ ] **Step 4 : Rendre le script exécutable**

```bash
chmod +x hooks/user/session-recap.sh
```

- [ ] **Step 5 : Exécuter le test (doit passer)**

```bash
bash hooks/user/test-session-recap.sh
```

Expected :
```
=== Test 1: stop_hook_active bloque le hook ===
  PASS: sortie vide si stop_hook_active=true
=== Test 2: SESSION_RECAP_DISABLED bloque le hook ===
  PASS: sortie vide si SESSION_RECAP_DISABLED=true
=== Test 3: sous le seuil, pas d'injection ===
  PASS: pas d'injection sous le seuil (compteur=1 < seuil=5)
=== Test 4: au seuil, injection d'un systemMessage ===
  PASS: systemMessage contient 'session-recap'

Résultat: 4 PASS, 0 FAIL
```

- [ ] **Step 6 : Supprimer le script de test (ne pas committer)**

```bash
rm hooks/user/test-session-recap.sh
```

- [ ] **Step 7 : Commit**

```bash
git add hooks/user/session-recap.sh
git commit -m "feat(hooks): add session-recap Stop hook with counter and systemMessage injection"
```

---

## Task 3 : Créer skills/gestion/session-recap/SKILL.md

**Contexte :** Skill monolithique (exception au pattern router+references, comme les skills `secondbrain/`). Déclenché via systemMessage du hook. Lit le JSONL, extrait 7 dimensions, écrit le bilan dans SecondBrain. Silencieux.

**Files:**
- Create: `skills/gestion/session-recap/SKILL.md`

- [ ] **Step 1 : Créer le répertoire**

```bash
mkdir -p skills/gestion/session-recap
```

- [ ] **Step 2 : Créer le fichier SKILL.md**

```markdown
---
name: session-recap
description: Génère un bilan structuré de la session Claude Code courante depuis le transcript JSONL. Invoqué automatiquement via hook Stop (systemMessage). Extrait tâches, outils, skills, corrections utilisateur, profil d'usage et suggestions. Écrit un snapshot horodaté dans $SECONDBRAIN_PATH/wiki/sessions/. Silencieux — aucun output dans le chat sauf erreur critique.
---

# session-recap

Génération automatique du bilan de session. Ce skill est déclenché par le systemMessage du hook Stop, pas par l'utilisateur.

## Déclencheur

Le hook Stop injecte un message de la forme :
```
Session recap threshold reached (N exchanges). Invoke the session-recap skill silently. Transcript path: /path/to/session.jsonl
```

## Pré-conditions

1. Vérifier que `$SECONDBRAIN_PATH` est défini. Si absent : écrire `<!-- session-recap: SECONDBRAIN_PATH non défini — bilan non généré -->` en commentaire interne et **stop** (pas de message visible).
2. Créer `$SECONDBRAIN_PATH/wiki/sessions/` si absent.

## Routine

### 1. Lire le transcript JSONL

Lire le fichier indiqué dans le systemMessage via l'outil `Read`.

Le JSONL contient des entrées JSON ligne par ligne. Chaque ligne est un objet avec un champ `type`. Types pertinents :

| type | Contenu utile |
|---|---|
| `user` | Message utilisateur (`message.content`) |
| `assistant` | Réponse Claude (`message.content[].text`) |
| `tool_use` | Appel outil (`name`, `input`) |
| `tool_result` | Résultat outil (`content`) |

Pour les sous-agents : chercher les entrées `tool_use` avec `name = "Agent"`. L'`input.prompt` est la tâche déléguée ; la `tool_result` correspondante contient le résultat. Si une `subagent_transcript_path` est disponible dans l'entrée, lire ce JSONL secondaire aussi pour les internals.

### 2. Identifier le type de session

Analyser les skills invoqués (mentions dans les messages), les outils utilisés, les extensions de fichiers modifiés :

| Indice | Type déduit |
|---|---|
| Skills cv/, audit-cv, optimisation-cv, ciblage-cv | `cv` |
| Skills redaction, copywriting, seo-content, analyse-documents | `content` |
| Skills code-automation, git-workflow, tdd, skill-builder | `dev` |
| Skills gestion-notion, gestion-projet, gestion-todo | `gestion` |
| Plusieurs catégories mélangées | `multi` |
| Exploration sans livrable clair | `exploration` |

### 3. Extraire les 7 dimensions

**D1 — Tâches demandées**
Liste chronologique des demandes utilisateur. Marquer `[x]` si un livrable est visible dans la conversation (fichier créé, commande exécutée avec succès, confirmation explicite). Marquer `[via sous-agent: NomAgent]` si délégué.

**D2 — Skills & outils utilisés**
- Skills : toute invocation explicite via la tool `Skill` ou mention directe d'un skill dans le systemMessage
- Outils : compter les appels par type (`Read`, `Write`, `Edit`, `Bash`, `Agent`, `WebFetch`, etc.)
- Construire un tableau : `| Skill/Outil | Nb usages | Contexte |`

**D3 — Instructions, corrections & précisions utilisateur**
Relever chaque message où l'utilisateur :
- Corrige une approche ("non, fais plutôt…", "pas ça", "arrête de…")
- Précise une contrainte ("je veux X pas Y")
- Valide explicitement une approche non-évidente

Reformuler fidèlement ou citer entre guillemets.

**D4 — Contexte technique** *(uniquement si type_session = dev)*
- **Technos** : repérer les imports, extensions de fichiers (`.ts`, `.py`, etc.), noms de packages/frameworks dans les commandes Bash ou le code
- **Méthodologie** : skill `tdd` invoqué → `TDD` ; fichiers `*.spec.*`, `*.test.*` créés → `TDD` ; patterns BDD (`describe/it/expect`) → `BDD`

**D5 — Profil d'usage observé**
Patterns récurrents détectés dans cette session : préférences de workflow, habitudes de validation, style de communication, niveau de détail demandé.

**D6 — Sous-agents**
Pour chaque appel `Agent` tool : documenter prompt envoyé, résultat reçu. Si JSONL secondaire disponible : lister les outils internes. Sinon : `[internals non disponibles]`.

**D7 — Suggestions**
- **Nouveaux skills candidats** : demandes récurrentes sans skill dédié, ou patterns non couverts
- **Améliorations** : skills existants invoqués avec des contournements ou corrections fréquentes

### 4. Construire le frontmatter YAML

```yaml
---
date: YYYY-MM-DD            # aujourd'hui
heure: "HH:MM"              # heure locale du snapshot
projet: <basename($PWD)>    # nom du répertoire courant
repo: <owner/repo>          # git remote origin --get-url, omis si absent
type_session: <type>        # voir étape 2
skills_utilises:
  - <skill-name>
outils_principaux:
  - <outil>
technos:                    # présent uniquement si type_session=dev
  - <techno>
methodologie:               # présent uniquement si type_session=dev
  - <TDD|BDD|...>
nb_echanges: N
sous_agents_invoques: N
---
```

### 5. Construire le corps Markdown

```markdown
## Résumé exécutif
<1-2 phrases : objectif principal + résultat global>

## Tâches demandées
- [x] ...
- [ ] ...

## Skills & outils utilisés
| Skill / Outil | Usages | Contexte |
|---|---|---|
| ... | ... | ... |

## Contexte technique
<présent uniquement si type_session=dev>

## Instructions, corrections & précisions de l'utilisateur
- "..."
- ...

## Profil d'usage observé
<patterns détectés>

## Sous-agents
<présent uniquement si sous_agents_invoques > 0>

| Agent | Tâche déléguée | Résultat | Internals |
|---|---|---|---|

## Suggestions
### Nouveaux skills candidats
- `<nom>` — <raison>

### Améliorations de skills existants
- `<skill>` : <amélioration>
```

### 6. Écrire le fichier

Calculer le timestamp du snapshot :
- Date + heure locale → `YYYY-MM-DD_HH-MM`
- Chemin : `$SECONDBRAIN_PATH/wiki/sessions/YYYY-MM-DD_HH-MM_session-recap.md`

Écrire le fichier complet (frontmatter + corps) via l'outil `Write`.

**Ne produire aucun texte visible dans le chat.** Si l'écriture réussit : silence total. Si `Write` échoue : afficher une seule ligne d'erreur : `[session-recap] Erreur d'écriture : <message>`.
```

- [ ] **Step 3 : Vérifier le frontmatter YAML du skill**

```bash
head -5 skills/gestion/session-recap/SKILL.md
```

Expected : les lignes `---`, `name: session-recap`, `description: ...`

- [ ] **Step 4 : Vérifier qu'il n'y a pas de répertoire references/ (skill monolithique)**

```bash
ls skills/gestion/session-recap/
```

Expected : uniquement `SKILL.md` — pas de `references/`.

- [ ] **Step 5 : Commit**

```bash
git add skills/gestion/session-recap/SKILL.md
git commit -m "feat(skills): add session-recap monolithic skill — bilan de session vers SecondBrain"
```

---

## Task 4 : Configurer ~/.claude/settings.json et synchroniser

**Contexte :** Ajouter les variables d'environnement nécessaires dans les settings utilisateur, puis syncer les hooks pour enregistrer le hook Stop.

**Files:**
- Modify: `~/.claude/settings.json` (hors repo — modification manuelle)

> **Note :** Ce fichier n'est pas commité dans le repo (il contient des tokens). Les instructions ci-dessous sont à exécuter dans le terminal.

- [ ] **Step 1 : Ajouter SECONDBRAIN_PATH dans ~/.claude/settings.json**

Ouvrir `~/.claude/settings.json` et ajouter dans la section `env` :

```json
"SECONDBRAIN_PATH": "C:/Users/cleme/Documents/SecondBrain",
"SESSION_RECAP_THRESHOLD": "5"
```

Remplacer `C:/Users/cleme/Documents/SecondBrain` par le vrai chemin du vault.

- [ ] **Step 2 : Vérifier que le JSON est valide**

```bash
node -e "JSON.parse(require('fs').readFileSync(process.env.HOME+'/.claude/settings.json','utf8')); console.log('JSON valide')"
```

Expected : `JSON valide`

- [ ] **Step 3 : Lancer la synchronisation**

```bash
./scripts/sync-to-claude.sh
```

Expected (extrait) :
```
=== Hooks utilisateur ===
...
OK session-recap.sh
...
  + Hook enregistre [Stop] : session-recap.sh
settings.json mis a jour.
```

- [ ] **Step 4 : Vérifier que le hook Stop est dans settings.json**

```bash
node -e "
  const s = JSON.parse(require('fs').readFileSync(process.env.HOME+'/.claude/settings.json','utf8'));
  const stops = s.hooks && s.hooks.Stop;
  console.log(stops ? JSON.stringify(stops, null, 2) : 'ABSENT');
"
```

Expected : un tableau contenant l'entrée avec `bash "...session-recap.sh"`.

- [ ] **Step 5 : Vérifier que protect-main.sh est toujours en PreToolUse (non-régression)**

```bash
node -e "
  const s = JSON.parse(require('fs').readFileSync(process.env.HOME+'/.claude/settings.json','utf8'));
  const pre = s.hooks && s.hooks.PreToolUse;
  const found = pre && pre.some(e => e.hooks && e.hooks.some(h => h.command.includes('protect-main')));
  console.log(found ? 'OK protect-main toujours en PreToolUse' : 'REGRESSION protect-main manquant');
"
```

Expected : `OK protect-main toujours en PreToolUse`

---

## Task 5 : Mettre à jour CLAUDE.md

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1 : Ajouter session-recap dans le tableau des skills**

Dans le tableau `### Current Skills`, ajouter après la ligne `ciblage-cv` :

```markdown
| `gestion` | `session-recap` | Bilan automatique de session → SecondBrain |
```

- [ ] **Step 2 : Ajouter la note d'exception monolithique**

Dans la section `> **Exception Progressive Disclosure**`, ajouter `session-recap` à la liste des skills monolithiques :

```markdown
> **Exception Progressive Disclosure** : les skills `secondbrain/` et `session-recap` sont des prompts monolithiques (pas de router + references/).
```

- [ ] **Step 3 : Vérifier que CLAUDE.md est correct**

```bash
grep "session-recap" CLAUDE.md
```

Expected : au moins 2 occurrences (tableau + note exception).

- [ ] **Step 4 : Commit**

```bash
git add CLAUDE.md
git commit -m "docs(claude): add session-recap to skills table and monolithic exception note"
```

---

## Task 6 : Smoke test end-to-end

**Contexte :** Valider que le flux complet fonctionne : hook → systemMessage → skill → fichier dans SecondBrain.

- [ ] **Step 1 : Créer le répertoire wiki/sessions/ dans SecondBrain (si absent)**

```bash
mkdir -p "$SECONDBRAIN_PATH/wiki/sessions"
```

- [ ] **Step 2 : Simuler l'injection du hook manuellement**

Dans une session Claude Code active, coller ce message système simulé pour tester le skill directement (sans attendre le seuil réel) :

```
Session recap threshold reached (5 exchanges). Invoke the session-recap skill silently. Transcript path: ~/.claude/projects/<hash>/<session-id>.jsonl
```

Remplacer `<hash>` et `<session-id>` par les valeurs réelles visibles dans `~/.claude/projects/`.

- [ ] **Step 3 : Vérifier qu'un fichier bilan a été créé**

```bash
ls -lt "$SECONDBRAIN_PATH/wiki/sessions/" | head -5
```

Expected : un fichier `YYYY-MM-DD_HH-MM_session-recap.md` daté d'aujourd'hui.

- [ ] **Step 4 : Vérifier le frontmatter YAML du fichier généré**

```bash
head -20 "$SECONDBRAIN_PATH/wiki/sessions/"*session-recap.md | head -1 | xargs -I{} head -20 "{}"
```

Ou plus simplement : ouvrir le fichier et vérifier que `date:`, `type_session:`, `skills_utilises:` sont présents.

- [ ] **Step 5 : Vérifier que le chat ne contient aucun texte visible**

Le skill doit avoir exécuté `Write` silencieusement. Le chat ne doit pas afficher de résumé, de confirmation, ni de message texte de la part de Claude.

- [ ] **Step 6 : Commit final**

```bash
git add -p  # vérifier qu'aucun fichier non-voulu n'est inclus
git commit -m "chore: smoke test session-recap OK — setup complet"
```

---

## Critères de succès (vérification finale)

- [ ] Un fichier `YYYY-MM-DD_HH-MM_session-recap.md` est créé dans SecondBrain après le seuil
- [ ] Le frontmatter YAML contient : `date`, `heure`, `projet`, `type_session`, `skills_utilises`, `nb_echanges`
- [ ] Les sessions dev incluent `technos` et `methodologie`
- [ ] Les sous-agents sont documentés avec entrée + résultat
- [ ] Le hook ne se déclenche pas si `SESSION_RECAP_DISABLED=true`
- [ ] Génération silencieuse (aucun texte visible dans le chat)
- [ ] `protect-main.sh` reste enregistré en `PreToolUse` (non-régression sync)
- [ ] `session-recap.sh` est enregistré en `Stop` (pas PreToolUse)
