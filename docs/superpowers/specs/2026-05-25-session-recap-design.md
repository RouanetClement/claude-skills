# Design : skill `session-recap`

**Date :** 2026-05-25
**Statut :** approuvé — en attente d'implémentation
**Branche cible :** feat/session-recap

---

## Objectif

Générer automatiquement un bilan structuré de chaque session Claude Code et l'ingérer dans le vault SecondBrain. Ces bilans alimentent une base de connaissance pour :

1. Récupérer le contexte d'une session passée
2. Identifier les patterns d'usage récurrents
3. Détecter les nouveaux skills à créer et les améliorations à apporter aux skills existants

---

## Architecture

Le système se compose de **2 pièces** :

```
hooks/user/session-recap.sh          ← Hook Stop global (tous projets)
skills/gestion/session-recap/
  SKILL.md                           ← Instruction de génération du bilan
```

### Flux d'exécution

```
Claude finit de répondre
    └─ Hook Stop déclenché (session-recap.sh)
         ├─ Lit SESSION_RECAP_DISABLED — si "true" → exit 0
         ├─ Incrémente ~/.claude/.session_<PID>.counter
         ├─ Si compteur < SESSION_RECAP_THRESHOLD → exit 0
         └─ Trouve le JSONL de session courante (~/.claude/projects/<hash>/<session-id>.jsonl)
              └─ Injecte systemMessage :
                 "Session recap threshold reached. Invoke session-recap skill.
                  Transcript: /path/to/session.jsonl"
                      └─ Claude invoque le skill session-recap
                           ├─ Lit le JSONL via Read tool (session principale + sous-agents)
                           ├─ Extrait les 7 dimensions
                           └─ Écrit wiki/sessions/YYYY-MM-DD_HH-MM_session-recap.md
                                dans $SECONDBRAIN_PATH
```

**Compteur de session :** Le hook crée `~/.claude/.session_<PID>.counter` au premier déclenchement (PID du processus Claude Code). Ce fichier est automatiquement orphelin à la fermeture — pas de nettoyage nécessaire.

**Snapshots multiples :** Chaque déclenchement génère un NOUVEAU fichier horodaté (pas d'écrasement). Exemple :
```
wiki/sessions/
  2026-05-25_09-32_session-recap.md   ← snapshot au seuil (5 échanges)
  2026-05-25_10-14_session-recap.md   ← snapshot à 15 échanges
  2026-05-25_11-47_session-recap.md   ← snapshot final
```

---

## Format du bilan

### Frontmatter YAML

```yaml
---
date: YYYY-MM-DD
heure: "HH:MM"
projet: nom-du-repertoire-courant
repo: owner/repo                    # git remote origin si disponible, omis sinon
type_session: dev                   # dev | cv | content | gestion | multi | exploration
skills_utilises:
  - skill-name
outils_principaux:
  - Bash
  - Edit
  - Read
technos:                            # présent uniquement pour type_session: dev
  - Angular
  - RxJS
  - TypeScript
methodologie:                       # présent uniquement pour type_session: dev
  - TDD
nb_echanges: N
sous_agents_invoques: N             # 0 si aucun
---
```

### Corps Markdown

```markdown
## Résumé exécutif
Une ou deux phrases résumant l'objectif principal et le résultat global de la session.

## Tâches demandées
- [x] Tâche complétée
- [ ] Tâche en cours ou non terminée
- [x] Tâche déléguée [via sous-agent: ExploreAgent] → résultat : ...

## Skills & outils utilisés
| Skill / Outil | Usages | Contexte |
|---|---|---|
| git-workflow | 3 | commits, PR |
| Read | 12 | exploration codebase |

## Contexte technique        ← section présente uniquement pour type_session: dev
Technos identifiées, méthodologie observée, patterns de code récurrents dans la session.

## Instructions, corrections & précisions de l'utilisateur
> Citation exacte ou reformulation fidèle de chaque correction apportée.

- "Plusieurs fichiers par session plutôt qu'écraser le même"
- Règle ajoutée : X

## Profil d'usage observé
Patterns récurrents, préférences, habitudes détectées dans cette session spécifique.

## Suggestions
### Nouveaux skills candidats
- `code-snapshot` — capturer l'état du code (architecture, arbre de dossiers, stack) ;
  motivé par demande de "état des lieux du code" en session 2026-05-25

### Améliorations de skills existants
- skill Y : ajouter le cas Z (observé 3 fois dans cette session)
```

---

## Extraction depuis le JSONL

Le skill lit le transcript JSONL de la session via l'outil `Read`. Le JSONL contient :

- Tous les appels d'outils et leurs résultats (session principale)
- Les invocations `Agent` (outil + prompt + réponse du sous-agent)
- Les sessions sous-agents référencées, stockées dans des JSONL séparés sous `~/.claude/projects/<hash>/`

**Pour les sous-agents :** Le skill identifie les appels `Agent` dans le JSONL principal, extrait le chemin du transcript du sous-agent (si disponible via session ID), et lit ce JSONL pour reconstituer les internals (outils utilisés par le sous-agent, fichiers touchés, décisions).

**Limitation connue :** Si le JSONL du sous-agent n'est pas accessible (session expirée, chemin non résolu), le bilan documente l'entrée et la sortie du sous-agent avec le tag `[sous-agent : internals non disponibles]`.

---

## Configuration

Variables dans `~/.claude/settings.json` (section `env`) :

| Variable | Défaut | Description |
|---|---|---|
| `SECONDBRAIN_PATH` | — (requis) | Chemin absolu du vault SecondBrain |
| `SESSION_RECAP_THRESHOLD` | `5` | Nombre d'échanges avant premier snapshot |
| `SESSION_RECAP_DISABLED` | `false` | Désactiver pour un projet spécifique |

**Désactiver par projet** (dans `.claude/settings.json` du projet) :
```json
{ "env": { "SESSION_RECAP_DISABLED": "true" } }
```

**Structure attendue dans SecondBrain** (créée automatiquement si absente) :
```
$SECONDBRAIN_PATH/wiki/sessions/
```

---

## Comportement du skill

Le skill `session-recap` suit l'**exception monolithique** (comme les skills `secondbrain/`) : pas de router + references. La logique est dense et conditionnelle (type de session, présence de sous-agents, contenu dev vs autres).

**Instructions à Claude :**

1. Identifier le type de session depuis les outils et skills utilisés dans le transcript
2. Pour les sessions `dev` : extraire les technos (imports, extensions, noms de packages) et la méthodologie (skills tdd/bdd, patterns de fichiers de test)
3. Extraire les 7 dimensions (tâches, outils/skills, corrections, profil, suggestions, contexte tech, sous-agents)
4. Construire le frontmatter YAML + corps Markdown selon le format ci-dessus
5. Écrire dans `$SECONDBRAIN_PATH/wiki/sessions/YYYY-MM-DD_HH-MM_session-recap.md` via l'outil `Write`
6. **Silencieux** : aucune notification en session, aucun résumé affiché dans le chat. Seule exception : afficher un message d'erreur si l'écriture échoue

---

## Skill à créer en parallèle (hors scope de ce spec)

`code-snapshot` — génère un document d'architecture du codebase courant :
- Arbre de dossiers (profondeur configurable)
- Stack et dépendances principales
- Conventions détectées (patterns, naming, structure)
- Commit récent + auteurs actifs

Ce skill sera référencé dans `## Suggestions` des bilans de sessions dev.

---

## Composants à implémenter

| Composant | Chemin | Description |
|---|---|---|
| Skill | `skills/gestion/session-recap/SKILL.md` | Instruction Claude de génération |
| Hook Stop | `hooks/user/session-recap.sh` | Compteur + injection systemMessage |
| Config | `~/.claude/settings.json` (env) | SECONDBRAIN_PATH + seuils |
| Répertoire | `$SECONDBRAIN_PATH/wiki/sessions/` | Créé par le hook si absent |

---

## Critères de succès

- [ ] Un fichier `YYYY-MM-DD_HH-MM_session-recap.md` est créé dans SecondBrain après le seuil
- [ ] Le frontmatter YAML est valide et contient au minimum : date, heure, projet, type_session, skills_utilises, nb_echanges
- [ ] Les corrections/instructions de l'utilisateur sont capturées fidèlement
- [ ] Les sessions dev incluent `technos` et `methodologie` dans le frontmatter
- [ ] Les sous-agents sont documentés avec entrée + résultat (+ internals si JSONL accessible)
- [ ] Le hook ne se déclenche pas si `SESSION_RECAP_DISABLED=true`
- [ ] Génération silencieuse (aucun output visible en session sauf erreur)
