# Design — Skill `git-workflow`

**Date** : 2026-04-14  
**Statut** : approuvé

---

## Objectif

Créer un skill `git-workflow` qui guide Claude dans l'application des conventions de branches, commits et PRs/MRs. Le skill sert également de documentation de référence pour les conventions de l'équipe — Claude suit les mêmes règles que l'équipe, sans convention dérogatoire.

---

## Architecture

Structure Option A — skill autonome avec références par sous-domaine :

```
git-workflow/
├── SKILL.md
└── references/
    ├── branches.md
    ├── commits.md
    └── pull-requests.md
```

---

## SKILL.md — Router

**Sélection du modèle :**
- `claude-haiku-4-5` par défaut — les 3 tâches sont mécaniques (appliquer des conventions)
- `claude-sonnet-4-6` si la demande implique une décision d'organisation (ex: découpage d'une feature en plusieurs PRs)

**Routing par contexte :**

| Contexte détecté | Référence chargée |
|---|---|
| Créer / nommer une branche | `references/branches.md` |
| Rédiger / valider un commit | `references/commits.md` |
| Créer / décrire / merger une PR/MR | `references/pull-requests.md` |

---

## `references/branches.md`

**Stratégie : Gitflow**
- Branches permanentes : `main`, `develop`
- Branches temporaires : `feature/*`, `release/*`, `hotfix/*`
- `feature/*` partent de `develop`, mergent dans `develop`
- `hotfix/*` partent de `main`, mergent dans `main` ET `develop`
- `release/*` partent de `develop`, mergent dans `main` ET `develop`
- Supprimer la branche après merge

**Nommage :**
- Format préféré : `type/TICKET-description` (ex: `feat/PROJ-42-user-auth`)
- Format alternatif si pas de ticket : `type/description` (ex: `feat/user-auth`)
- Kebab-case, minuscules
- Types : `feat`, `fix`, `chore`, `refactor`, `docs`, `hotfix`, `release`

**Branches protégées (`main` et `develop`) :**
- Aucun push direct
- Aucun force push
- Passage obligatoire par PR/MR
- CI verte requise avant merge
- Minimum 1 approbation requise avant merge

---

## `references/commits.md`

**Format Conventional Commits :**
```
type(scope): description courte

Corps optionnel — le "pourquoi", pas le "quoi"
```

**Gitmoji :** peut remplacer `type`
- Accepter l'emoji collé directement : `✨(auth): add user login`
- Accepter le code texte : `:sparkles:(auth): add user login`

**Types Conventional Commits :** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`

**Règle SRP (Single Responsibility) :**
- Un commit = un sujet logique unique
- Si des modifications portent sur plusieurs sujets distincts → découper en commits séparés
- Raison : facilite les reviews sur les PRs importantes, historique lisible

**Règles de forme :**
- Présent impératif : "add feature" pas "added" ni "adding"
- Première ligne < 72 caractères
- Corps optionnel pour expliquer le "pourquoi" (jamais le "quoi")

**Interdits :**
- Secrets ou credentials
- Fichiers générés ou binaires lourds
- `--no-verify` sauf exception explicitement documentée dans le message de commit

---

## `references/pull-requests.md`

**Règles de merge :**
- Stratégie : Squash & Merge uniquement
- CI verte obligatoire avant merge
- Minimum 1 approbation requise avant merge
- Aucun force-push sur une branche en cours de review

**Taille :**
- Pas de limite stricte
- Favoriser les PRs courtes et ciblées — plus facile à reviewer, moins risqué

**Process :**
- Self-review obligatoire avant de demander une review externe
- Résoudre tous les commentaires avant merge

**Structure de description suggérée (non imposée) :**
```
## Contexte
Pourquoi ce changement existe.

## Ce qui change
Résumé des modifications clés.

## Comment tester
Étapes reproductibles pour valider.

## Ticket
Lien vers le ticket (si applicable).
```
