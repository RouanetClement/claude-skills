# Git Workflow Skill — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Créer le skill `git-workflow` couvrant branches (Gitflow), commits (Conventional Commits / Gitmoji) et PRs/MRs.

**Architecture:** Skill autonome avec un `SKILL.md` router et 3 fichiers de référence indépendants, chacun ≤ 150 lignes. Haiku pour les tâches mécaniques, Sonnet pour les décisions d'organisation.

**Tech Stack:** Markdown, YAML frontmatter, GitHub Actions (CI validation existante).

---

### Task 1 : Corriger le CI pour exclure `docs/`

Le CI actuel itère tous les répertoires racine et exige un `SKILL.md`. Le répertoire `docs/` doit être exclu.

**Files:**
- Modify: `.github/workflows/validate.yml:22`

- [ ] **Step 1 : Mettre à jour la condition d'exclusion**

Dans `.github/workflows/validate.yml`, remplacer :

```yaml
[[ "$skill" == ".github" || "$skill" == "scripts" ]] && continue
```

par :

```yaml
[[ "$skill" == ".github" || "$skill" == "scripts" || "$skill" == "docs" ]] && continue
```

(présent aux lignes 22 et 50)

- [ ] **Step 2 : Vérifier localement**

```bash
grep -n "\.github.*scripts" .github/workflows/validate.yml
```

Résultat attendu — les deux occurrences affichent `docs` dans la condition :
```
22:    [[ "$skill" == ".github" || "$skill" == "scripts" || "$skill" == "docs" ]] && continue
50:    [[ "$skill" == ".github" || "$skill" == "scripts" || "$skill" == "docs" ]] && continue
```

- [ ] **Step 3 : Commiter**

```bash
git add .github/workflows/validate.yml
git commit -m "ci: exclude docs/ from SKILL.md validation check"
```

---

### Task 2 : Créer `git-workflow/SKILL.md`

**Files:**
- Create: `git-workflow/SKILL.md`

- [ ] **Step 1 : Créer le fichier**

Contenu exact de `git-workflow/SKILL.md` :

```markdown
---
name: git-workflow
description: >
  Agent pour toutes les tâches de gestion de l'historique Git : nommage et cycle de vie des branches
  (Gitflow), rédaction et validation de commits (Conventional Commits / Gitmoji), création et
  description de Pull Requests / Merge Requests.
  UTILISER pour toute demande concernant une branche, un commit, une PR/MR, une revue de code,
  ou la stratégie de versioning.
---

# Git Workflow — Point d'entrée

## Étape 1 — Choisir le modèle

| Type de tâche | Modèle |
|---|---|
| Nommer une branche, rédiger un message de commit, créer une description de PR | `claude-haiku-4-5` |
| Décider comment découper une feature en branches ou PRs, stratégie de merge | `claude-sonnet-4-6` |

> En cas de doute → Haiku. Ces tâches sont mécaniques. Sonnet uniquement si une décision d'organisation est requise.

---

## Étape 2 — Charger la référence adaptée

| Contexte | Fichier à lire |
|---|---|
| Créer ou nommer une branche | `references/branches.md` |
| Rédiger ou valider un commit | `references/commits.md` |
| Créer, décrire ou merger une PR/MR | `references/pull-requests.md` |

> Charger uniquement la référence pertinente au contexte de la demande.

---

## Règles universelles

- **Pas de dérogation** : Claude applique les mêmes conventions que l'équipe, sans règle spécifique à son usage
- **Confirmer avant toute action irréversible** : suppression de branche, reset — résumer et attendre validation
```

- [ ] **Step 2 : Vérifier le nombre de lignes**

```bash
wc -l git-workflow/SKILL.md
```

Résultat attendu : ≤ 150 lignes.

- [ ] **Step 3 : Commiter**

```bash
git add git-workflow/SKILL.md
git commit -m "feat: add git-workflow skill router"
```

---

### Task 3 : Créer `references/branches.md`

**Files:**
- Create: `git-workflow/references/branches.md`

- [ ] **Step 1 : Créer le fichier**

Contenu exact de `git-workflow/references/branches.md` :

```markdown
# Branches — Conventions Gitflow

## Stratégie : Gitflow

| Branche | Rôle | Créée depuis | Merge vers |
|---|---|---|---|
| `main` | Code en production | — | — |
| `develop` | Intégration continue | — | — |
| `feature/*` | Nouvelle fonctionnalité | `develop` | `develop` |
| `release/*` | Préparation de release | `develop` | `main` + `develop` |
| `hotfix/*` | Correctif urgent en production | `main` | `main` + `develop` |

Supprimer la branche après merge.

---

## Nommage

**Format préféré** (lorsqu'un ticket existe — à utiliser chaque fois que possible) :
```
type/TICKET-description-courte
```
Exemples : `feat/PROJ-42-user-auth`, `fix/PROJ-18-login-timeout`, `hotfix/PROJ-99-null-pointer`

**Format alternatif** (sans ticket associé) :
```
type/description-courte
```
Exemples : `feat/user-auth`, `chore/update-deps`, `docs/api-readme`

**Règles de forme :**
- Kebab-case, minuscules uniquement, pas d'espaces
- Types autorisés : `feat`, `fix`, `chore`, `refactor`, `docs`, `hotfix`, `release`

---

## Branches protégées : `main` et `develop`

Les règles suivantes s'appliquent sans exception :

- Aucun push direct (`git push`)
- Aucun force push (`git push --force`)
- Passage obligatoire par Pull Request / Merge Request
- Conditions requises avant merge :
  - CI en succès
  - Au moins 1 approbation humaine
```

- [ ] **Step 2 : Vérifier le nombre de lignes**

```bash
wc -l git-workflow/references/branches.md
```

Résultat attendu : ≤ 150 lignes.

- [ ] **Step 3 : Commiter**

```bash
git add git-workflow/references/branches.md
git commit -m "feat: add branches reference for git-workflow skill"
```

---

### Task 4 : Créer `references/commits.md`

**Files:**
- Create: `git-workflow/references/commits.md`

- [ ] **Step 1 : Créer le fichier**

Contenu exact de `git-workflow/references/commits.md` :

```markdown
# Commits — Conventions

## Format

```
type(scope): description courte

Corps optionnel — expliquer le POURQUOI, pas le quoi

Footer : refs ticket, breaking changes
```

**Gitmoji** peut remplacer `type` — deux formes acceptées :
- Emoji collé directement : `✨(auth): add user login`
- Code texte (saisie manuelle) : `:sparkles:(auth): add user login`

---

## Types Conventional Commits

| Type | Gitmoji | Usage |
|---|---|---|
| `feat` | ✨ `:sparkles:` | Nouvelle fonctionnalité |
| `fix` | 🐛 `:bug:` | Correction de bug |
| `docs` | 📝 `:memo:` | Documentation uniquement |
| `style` | 🎨 `:art:` | Formatage, sans changement logique |
| `refactor` | ♻️ `:recycle:` | Refactoring sans correction ni feature |
| `test` | ✅ `:white_check_mark:` | Ajout ou correction de tests |
| `chore` | 🔧 `:wrench:` | Maintenance, dépendances, configuration |
| `perf` | ⚡️ `:zap:` | Amélioration de performance |
| `ci` | 👷 `:construction_worker:` | Configuration CI/CD |

---

## Règle SRP — Un commit, un sujet

**Un commit = un sujet logique unique.**

Si des modifications portent sur plusieurs sujets distincts → les découper en commits séparés.

Raison : facilite la review sur les PRs importantes, rend l'historique lisible, permet un revert ciblé.

Exemples de découpage correct :
```
# ❌ À éviter
git commit -m "feat(auth): add login + fix typo in dashboard + update deps"

# ✅ Correct
git commit -m "feat(auth): add login flow"
git commit -m "fix(dashboard): fix label typo"
git commit -m "chore: update dependencies"
```

---

## Règles de forme

- Présent impératif : `add feature` — pas `added` ni `adding`
- Première ligne < 72 caractères
- Corps optionnel : expliquer le pourquoi, jamais le quoi

---

## Interdits

- Secrets ou credentials en clair
- Fichiers générés ou binaires lourds non nécessaires
- `--no-verify` : interdit sauf exception documentée explicitement dans le message de commit
```

- [ ] **Step 2 : Vérifier le nombre de lignes**

```bash
wc -l git-workflow/references/commits.md
```

Résultat attendu : ≤ 150 lignes.

- [ ] **Step 3 : Commiter**

```bash
git add git-workflow/references/commits.md
git commit -m "feat: add commits reference for git-workflow skill"
```

---

### Task 5 : Créer `references/pull-requests.md`

**Files:**
- Create: `git-workflow/references/pull-requests.md`

- [ ] **Step 1 : Créer le fichier**

Contenu exact de `git-workflow/references/pull-requests.md` :

```markdown
# Pull Requests / Merge Requests — Conventions

## Règles de merge

- **Stratégie** : Squash & Merge uniquement
- **CI** : doit être en succès avant tout merge
- **Approbation** : minimum 1 review/validation humaine requise
- **Force push** : interdit sur une branche en cours de review

---

## Taille

Pas de limite stricte. Favoriser les PRs courtes et ciblées :
- Plus facile à reviewer, moins risqué en cas de revert
- Si la PR est importante, s'appuyer sur la règle SRP des commits (`references/commits.md`) pour structurer la review

---

## Process

1. **Self-review** obligatoire avant de demander une review externe — relire son diff comme si on était reviewer
2. La CI doit être verte avant de demander une review
3. Résoudre tous les commentaires avant de merger
4. Ne jamais merger sans CI verte et approbation

---

## Description — Structure suggérée

La structure est recommandée, non imposée. L'adapter au contexte.

```markdown
## Contexte
Pourquoi ce changement existe — problème résolu ou besoin couvert.

## Ce qui change
Résumé des modifications clés (pas un diff exhaustif).

## Comment tester
Étapes reproductibles pour valider le comportement attendu.

## Ticket
Lien vers le ticket associé (si applicable).
```
```

- [ ] **Step 2 : Vérifier le nombre de lignes**

```bash
wc -l git-workflow/references/pull-requests.md
```

Résultat attendu : ≤ 150 lignes.

- [ ] **Step 3 : Commiter**

```bash
git add git-workflow/references/pull-requests.md
git commit -m "feat: add pull-requests reference for git-workflow skill"
```

---

### Task 6 : Validation finale et push

**Files:** aucun fichier supplémentaire.

- [ ] **Step 1 : Vérifier la structure complète**

```bash
find git-workflow -type f | sort
```

Résultat attendu :
```
git-workflow/SKILL.md
git-workflow/references/branches.md
git-workflow/references/commits.md
git-workflow/references/pull-requests.md
```

- [ ] **Step 2 : Vérifier toutes les lignes d'un coup**

```bash
wc -l git-workflow/references/*.md
```

Résultat attendu : chaque fichier < 150 lignes.

- [ ] **Step 3 : Pusher**

```bash
git push
```
