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

1. Vérifier que `$SECONDBRAIN_PATH` est défini. Si absent : stopper silencieusement sans aucun message visible.
2. Créer `$SECONDBRAIN_PATH/wiki/sessions/` si absent.

## Routine

### 1. Lire le transcript JSONL

Lire le fichier indiqué dans le systemMessage via l'outil `Read`.

Le JSONL contient des entrées JSON ligne par ligne. Types pertinents :

| type | Contenu utile |
|---|---|
| `user` | Message utilisateur (`message.content`) |
| `assistant` | Réponse Claude (`message.content[].text`) |
| `tool_use` | Appel outil (`name`, `input`) |
| `tool_result` | Résultat outil (`content`) |

Pour les sous-agents : chercher les entrées `tool_use` avec `name = "Agent"`. L'`input.prompt` est la tâche déléguée ; la `tool_result` correspondante contient le résultat. Si une `subagent_transcript_path` est disponible, lire ce JSONL secondaire pour les internals.

### 2. Identifier le type de session

Analyser les skills invoqués, les outils utilisés, les extensions de fichiers modifiés :

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
Liste chronologique des demandes utilisateur. Marquer `[x]` si un livrable est visible (fichier créé, commande réussie, confirmation explicite). Marquer `[via sous-agent: NomAgent]` si délégué.

**D2 — Skills & outils utilisés**
Tableau : `| Skill/Outil | Nb usages | Contexte |`

**D3 — Instructions, corrections & précisions utilisateur**
Chaque message où l'utilisateur corrige une approche, précise une contrainte, ou valide explicitement. Citer fidèlement.

**D4 — Contexte technique** *(uniquement si type_session = dev)*
- **Technos** : imports, extensions de fichiers, noms de packages dans les commandes Bash
- **Méthodologie** : skill tdd invoqué → TDD ; fichiers `*.spec.*` / `*.test.*` créés → TDD

**D5 — Profil d'usage observé**
Patterns récurrents, préférences de workflow, style de communication détectés dans cette session.

**D6 — Sous-agents**
Pour chaque appel `Agent` tool : prompt envoyé, résultat, internals si JSONL secondaire accessible. Sinon : `[internals non disponibles]`.

**D7 — Suggestions**
- Nouveaux skills candidats : demandes sans skill dédié
- Améliorations : skills invoqués avec contournements fréquents

### 4. Construire le frontmatter YAML

```
---
date: YYYY-MM-DD
heure: "HH:MM"
projet: <basename du répertoire courant>
repo: <owner/repo via git remote origin, omis si absent>
type_session: <dev|cv|content|gestion|multi|exploration>
skills_utilises:
  - <skill-name>
outils_principaux:
  - <outil>
technos:          # présent uniquement si type_session=dev
  - <techno>
methodologie:     # présent uniquement si type_session=dev
  - <TDD|BDD>
nb_echanges: N
sous_agents_invoques: N
---
```

### 5. Construire le corps Markdown

```
## Résumé exécutif
<1-2 phrases : objectif principal + résultat global>

## Tâches demandées
- [x] ...
- [ ] ...

## Skills & outils utilisés
| Skill / Outil | Usages | Contexte |
|---|---|---|

## Contexte technique
<présent uniquement si type_session=dev>

## Instructions, corrections & précisions de l'utilisateur
- "..."

## Profil d'usage observé
<patterns détectés>

## Sous-agents
<présent uniquement si sous_agents_invoques > 0>

## Suggestions
### Nouveaux skills candidats
- `<nom>` — <raison>

### Améliorations de skills existants
- `<skill>` : <amélioration>
```

### 6. Écrire le fichier

Chemin cible : `$SECONDBRAIN_PATH/wiki/sessions/YYYY-MM-DD_HH-MM_session-recap.md`

Écrire via l'outil `Write`. **Aucun texte visible dans le chat.** Si Write échoue : afficher uniquement `[session-recap] Erreur d'écriture : <message>`.
