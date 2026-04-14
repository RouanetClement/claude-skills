# Gestion TODO Skill — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Créer le skill `gestion-todo` couvrant toutes les opérations TODO : lecture, édition, archivage, triage des priorités, organisation hiérarchique et gestion de la config projet.

**Architecture:** Skill autonome avec un `SKILL.md` router et 6 références indépendantes, chacune ≤ 150 lignes. Haiku par défaut, Sonnet pour les restructurations complexes. Config projet optionnelle dans `.claude/todo-config.md`.

**Tech Stack:** Markdown, YAML frontmatter, GitHub Actions (CI validation existante).

---

### Task 1 : Créer `gestion-todo/SKILL.md`

**Files:**
- Create: `gestion-todo/SKILL.md`

- [ ] **Step 1 : Créer le fichier**

Contenu exact de `gestion-todo/SKILL.md` :

```markdown
---
name: gestion-todo
description: >
  Agent pour la gestion complète des TODOs dans un projet : lecture et résumé des tâches ouvertes,
  ajout et mise à jour de statuts, archivage des sections complètes, réévaluation des priorités,
  organisation hiérarchique et découpage en sous-fichiers.
  Format de référence : TODO.md / DONE.md avec priorités P0-P3 et tags [TAG].
  Adaptable via .claude/todo-config.md dans le projet cible.
  UTILISER pour toute demande concernant les TODOs, le backlog, les priorités ou l'organisation
  des tâches d'un projet.
---

# Gestion TODO — Point d'entrée

## Étape 0 — Lire la config projet

Chercher `.claude/todo-config.md` à la racine du projet cible.
S'il existe, lire les overrides et les appliquer à toutes les étapes suivantes.
Sinon, utiliser les valeurs par défaut du format wevalue-ai-lab (voir `references/config.md`).

---

## Étape 1 — Choisir le modèle

| Type de tâche | Modèle |
|---|---|
| Toutes les opérations courantes (lire, éditer, archiver, triage) | `claude-haiku-4-5` |
| Restructuration avec décision d'organisation complexe (découpage sous-fichiers) | `claude-sonnet-4-6` |

> En cas de doute → Haiku. Sonnet uniquement si une décision d'architecture de fichiers est requise.

---

## Étape 2 — Router par opération

| Contexte détecté | Fichier à lire |
|---|---|
| Résumer / lister TODOs ouverts, début de session | `references/consult.md` |
| Marquer `[x]`/`[~]`, ajouter un TODO | `references/edit.md` |
| Archiver une section complète vers `DONE.md` | `references/archive.md` |
| Réévaluer les priorités P0-P3 | `references/triage.md` |
| Organiser : hiérarchie, regroupement, découpage sous-fichiers | `references/structure.md` |
| Initialiser ou modifier la config projet | `references/config.md` |

---

## Règle universelle

Confirmer avant toute écriture, sauf si `auto_confirm: true` dans la config.
```

- [ ] **Step 2 : Vérifier le nombre de lignes**

```bash
wc -l gestion-todo/SKILL.md
```

Résultat attendu : ≤ 150 lignes.

- [ ] **Step 3 : Commiter**

```bash
git add gestion-todo/SKILL.md
git commit -m "feat: add gestion-todo skill router"
```

---

### Task 2 : Créer `references/consult.md`

**Files:**
- Create: `gestion-todo/references/consult.md`

- [ ] **Step 1 : Créer le fichier**

Contenu exact de `gestion-todo/references/consult.md` :

```markdown
# Consult — Lecture et résumé des TODOs

## Session start

Si `session_start_summary: true` (défaut) :
1. Lire le fichier défini par `todo_file` (défaut : `TODO.md`)
2. Lire les sous-fichiers référencés via `[ref] chemin/fichier.md` s'ils existent
3. Afficher le résumé standardisé ci-dessous

## Consultation explicite

Même comportement que session start. Filtres disponibles :
- Par priorité : ex. "montre les P1" → afficher seulement P1
- Par section : ex. "montre [BACKUP]" → afficher seulement cette section
- Par statut : ex. "en cours" → afficher seulement `[~]`

## Format de sortie standardisé

```
## TODOs ouverts — YYYY-MM-DD

### P0 — Bloquant (N)
  [TAG] Description de la tâche

### P1 — Important (N)
  [TAG] Description de la tâche

### P2 — Sprint suivant (N)
  [TAG] Description de la tâche

### P3 — Backlog (N)
  [TAG] Description de la tâche

### Sections archivables
  [TAG] — toutes les tâches [x]
```

Si aucune tâche ouverte : afficher `Aucun TODO ouvert.`

## Sous-fichiers

Si `TODO.md` contient des références `[ref] chemin/fichier.md` :
- Lire chaque sous-fichier référencé
- Inclure ses tâches dans le résumé avec le fichier source entre parenthèses :
  `[TAG] Description (todo/infra.md)`
```

- [ ] **Step 2 : Vérifier le nombre de lignes**

```bash
wc -l gestion-todo/references/consult.md
```

Résultat attendu : ≤ 150 lignes.

- [ ] **Step 3 : Commiter**

```bash
git add gestion-todo/references/consult.md
git commit -m "feat: add consult reference for gestion-todo skill"
```

---

### Task 3 : Créer `references/edit.md`

**Files:**
- Create: `gestion-todo/references/edit.md`

- [ ] **Step 1 : Créer le fichier**

Contenu exact de `gestion-todo/references/edit.md` :

```markdown
# Edit — Ajouter et mettre à jour des TODOs

## Format d'une tâche

```
- [ ] Description courte — [TAG] Pniveau
```

Exemple : `- [ ] Configurer le backup ChromaDB — [BACKUP] P2`

## Ajouter un TODO

1. Si section, tag ou priorité manquants → demander avant d'écrire
2. Insérer à la bonne position dans la section (P0 avant P1, P1 avant P2, etc.)
3. Si sous-fichiers existent → demander dans quel fichier insérer
4. Confirmer avant écriture (sauf `auto_confirm: true`)

## Mettre à jour le statut

| Transition | Résultat |
|---|---|
| → `[x]` | `- [x] Description — [TAG] Pniveau (YYYY-MM-DD)` |
| → `[~]` | `- [~] Description — [TAG] Pniveau (en cours — note optionnelle)` |
| → `[ ]` | Retirer la date ou note, retour à l'état ouvert |

Après chaque passage à `[x]` :
- Vérifier si toutes les tâches de la section sont `[x]`
- Si oui → appliquer la logique de `references/archive.md`

## Convention inline dans le code

Si l'utilisateur modifie un fichier source lié à un TODO, rappeler :
```
// TODO[TAG]: description — voir TODO.md#TAG
```

## Interdits

- Ne jamais modifier plusieurs tâches sans confirmation intermédiaire
- Ne jamais supprimer une tâche — utiliser `[x]` puis archiver
```

- [ ] **Step 2 : Vérifier le nombre de lignes**

```bash
wc -l gestion-todo/references/edit.md
```

Résultat attendu : ≤ 150 lignes.

- [ ] **Step 3 : Commiter**

```bash
git add gestion-todo/references/edit.md
git commit -m "feat: add edit reference for gestion-todo skill"
```

---

### Task 4 : Créer `references/archive.md`

**Files:**
- Create: `gestion-todo/references/archive.md`

- [ ] **Step 1 : Créer le fichier**

Contenu exact de `gestion-todo/references/archive.md` :

```markdown
# Archive — Déplacer les sections complètes vers DONE.md

## Déclencheur

| Config | Comportement |
|---|---|
| `auto_archive: true` (défaut) | Archiver automatiquement quand toutes les tâches sont `[x]` |
| `auto_archive: false` | Signaler la section archivable, attendre demande explicite |

## Procédure

1. **Renommer le titre** : ajouter ` — finalisé YYYY-MM-DD` à la fin du titre de section
2. **Déplacer** : couper le bloc entier (titre + toutes les tâches) depuis `TODO.md`
3. **Coller dans `DONE.md`** : ajouter en début de fichier (plus récent en premier)
4. **Nettoyer** : supprimer la section de `TODO.md`

## Cas sous-fichiers

Si la section archivée provient d'un sous-fichier `[ref]` :
1. Supprimer la référence `[ref] chemin/fichier.md` dans `TODO.md`
2. Supprimer le bloc de la section dans le sous-fichier
3. Si le sous-fichier est vide après suppression → supprimer le fichier

## Confirmation

Avant d'écrire, afficher : "Section [TAG] complète — archivage dans DONE.md. Confirmer ?"
Sauf si `auto_confirm: true`.

## Format d'entrée dans DONE.md

```markdown
## [TAG] — Titre de la section — finalisé YYYY-MM-DD

- [x] Tâche 1 (YYYY-MM-DD)
- [x] Tâche 2 (YYYY-MM-DD)
```
```

- [ ] **Step 2 : Vérifier le nombre de lignes**

```bash
wc -l gestion-todo/references/archive.md
```

Résultat attendu : ≤ 150 lignes.

- [ ] **Step 3 : Commiter**

```bash
git add gestion-todo/references/archive.md
git commit -m "feat: add archive reference for gestion-todo skill"
```

---

### Task 5 : Créer `references/triage.md`

**Files:**
- Create: `gestion-todo/references/triage.md`

- [ ] **Step 1 : Créer le fichier**

Contenu exact de `gestion-todo/references/triage.md` :

```markdown
# Triage — Réévaluation des priorités

## Principe

Ne jamais réévaluer systématiquement. Déclencher uniquement sur événement.

## Déclencheurs reconnus

- Ajout d'une nouvelle application ou fonctionnalité majeure au projet
- Incident ou blocage en production
- Changement d'équipe significatif
- Demande explicite de l'utilisateur
- Événements custom listés dans `triage_triggers` (config)

## Procédure

1. Lister toutes les tâches `[ ]` et `[~]` avec leur priorité actuelle
2. Pour chaque tâche impactée par le déclencheur, proposer une nouvelle priorité avec
   justification explicite.
   Exemple : `[AUTHENTIK] P3 → P1 — 4+ apps en production, SSO devient critique`
3. Présenter le delta complet avant d'écrire :
   ```
   Réévaluation proposée :
   [TAG-A] P3 → P1 — raison
   [TAG-B] P2 → P0 — raison
   ```
4. Attendre confirmation avant d'appliquer les changements

## Règle anti-inflation P0

Maximum 2-3 tâches P0 simultanément.
Si un ajout de P0 dépasse ce seuil → signaler et demander quelle tâche P0 existante doit descendre.

## Modification dans le fichier

Modifier uniquement le niveau de priorité dans la ligne concernée :
```
- [ ] Description — [TAG] P2  →  - [ ] Description — [TAG] P0
```
```

- [ ] **Step 2 : Vérifier le nombre de lignes**

```bash
wc -l gestion-todo/references/triage.md
```

Résultat attendu : ≤ 150 lignes.

- [ ] **Step 3 : Commiter**

```bash
git add gestion-todo/references/triage.md
git commit -m "feat: add triage reference for gestion-todo skill"
```

---

### Task 6 : Créer `references/structure.md`

**Files:**
- Create: `gestion-todo/references/structure.md`

- [ ] **Step 1 : Créer le fichier**

Contenu exact de `gestion-todo/references/structure.md` :

```markdown
# Structure — Hiérarchie et découpage des TODOs

## Modèle de hiérarchie

```
TODO.md                          ← fichier principal
  ## [SECTION-A] Titre           ← section thématique (H2)
      ### P0 — Bloquant
      ### P1 — Important
      ### P2 — Sprint suivant
      ### P3 — Backlog
  [ref] todo/infra.md            ← référence vers sous-fichier
  [ref] todo/agents.md
```

Les sous-fichiers suivent la même structure (sections → priorités).
2 niveaux recommandés, pas de limite de profondeur.

## Détection "fichier trop grand"

Seuil : `split_threshold` (défaut : 200 lignes).

| Config | Comportement |
|---|---|
| `disable_split_proposal: true` | Ne rien proposer — silence total |
| `auto_split: true` | Découpage automatique sans confirmation |
| défaut | Proposer le découpage avec plan de regroupement |

## Procédure de découpage (si proposé ou auto)

1. Analyser les sections existantes
2. Suggérer des regroupements thématiques (par domaine, feature, équipe)
3. Présenter le plan avant d'écrire :
   ```
   Plan de découpage proposé :
   todo/infra.md     ← [BACKUP], [NGINX-UPGRADE]
   todo/agents.md    ← [SINCRO-ENV], [SINCRO-CRON]
   TODO.md           ← index + références [ref]
   ```
4. Attendre validation (sauf `auto_split: true`)
5. Créer le dossier `todo_dir` (défaut : `todo/`), déplacer les sections,
   remplacer par des lignes `[ref] todo/fichier.md` dans `TODO.md`

## Réorganisation interne (sans découpage)

Pour réordonner les tâches au sein d'un fichier sans créer de sous-fichiers :
- Regrouper par section thématique
- Ordonner P0 → P3 au sein de chaque section
- Confirmer avant toute réécriture
```

- [ ] **Step 2 : Vérifier le nombre de lignes**

```bash
wc -l gestion-todo/references/structure.md
```

Résultat attendu : ≤ 150 lignes.

- [ ] **Step 3 : Commiter**

```bash
git add gestion-todo/references/structure.md
git commit -m "feat: add structure reference for gestion-todo skill"
```

---

### Task 7 : Créer `references/config.md`

**Files:**
- Create: `gestion-todo/references/config.md`

- [ ] **Step 1 : Créer le fichier**

IMPORTANT : ce fichier contient des blocs de code imbriqués (le template markdown est lui-même dans un bloc de code). Écrire le fichier tel quel, sans modifier les backticks.

Contenu exact de `gestion-todo/references/config.md` :

```markdown
# Config — Initialiser et modifier .claude/todo-config.md

## Initialisation

Si `.claude/todo-config.md` n'existe pas dans le projet cible :
1. Créer le dossier `.claude/` si nécessaire
2. Créer le fichier avec le template par défaut ci-dessous
3. Confirmer avant d'écrire (sauf `auto_confirm: true` — ce qui ne peut pas encore être lu)

## Template par défaut

```markdown
# TODO Config

## Comportement général
auto_confirm: false           # skip confirmation avant écriture
session_start_summary: true   # résumé TODOs au démarrage de session

## Archivage
auto_archive: true            # archiver automatiquement les sections [x]

## Découpage
split_threshold: 200          # lignes avant proposition de découpage
auto_split: false             # découpage automatique sans proposition
disable_split_proposal: false # ne jamais proposer le découpage

## Triage
triage_triggers: []           # événements custom déclenchant un triage
                              # ex: ["nouvelle app", "incident prod"]

## Format (overrides du format wevalue-ai-lab)
todo_file: TODO.md
done_file: DONE.md
todo_dir: todo/
priorities: [P0, P1, P2, P3]
status_open: "[ ]"
status_inprogress: "[~]"
status_done: "[x]"
```

## Modification

1. Lire la config existante
2. Appliquer les changements demandés
3. Afficher le diff avant d'écrire :
   `clé: ancienne_valeur → nouvelle_valeur`
4. Confirmer avant d'écrire

## Valeurs par défaut (si config absente)

En l'absence de `.claude/todo-config.md`, toutes les opérations utilisent
les valeurs du template ci-dessus comme référence implicite.
```

- [ ] **Step 2 : Vérifier le nombre de lignes**

```bash
wc -l gestion-todo/references/config.md
```

Résultat attendu : ≤ 150 lignes.

- [ ] **Step 3 : Commiter**

```bash
git add gestion-todo/references/config.md
git commit -m "feat: add config reference for gestion-todo skill"
```

---

### Task 8 : Validation finale et push

**Files:** aucun fichier supplémentaire.

- [ ] **Step 1 : Vérifier la structure complète**

```bash
find gestion-todo -type f | sort
```

Résultat attendu :
```
gestion-todo/SKILL.md
gestion-todo/references/archive.md
gestion-todo/references/config.md
gestion-todo/references/consult.md
gestion-todo/references/edit.md
gestion-todo/references/structure.md
gestion-todo/references/triage.md
```

- [ ] **Step 2 : Vérifier tous les line counts**

```bash
wc -l gestion-todo/references/*.md
```

Résultat attendu : chaque fichier ≤ 150 lignes.

- [ ] **Step 3 : Pusher**

```bash
git push
```
