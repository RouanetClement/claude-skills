---
name: skill-builder
description: >
  Use when creating a new Claude skill, making a major update to an existing skill, or validating
  a skill before merging. Triggers: "créer un skill", "nouveau skill", "mettre à jour skill",
  "refonte SKILL.md", "écrire une référence", "valider skill", "audit skill",
  "create skill", "skill design", "skill builder".
  Ce skill couvre : conception du routeur SKILL.md, rédaction des fichiers references/,
  optimisation de la description YAML, checklist qualité pré-PR.
  NE PAS utiliser pour modifier du contenu métier dans un skill existant — utiliser le skill concerné.
---

# Skill Builder — Point d'entrée

## Étape 0 — Audit préalable (OBLIGATOIRE pour création / mise à jour majeure)

Avant toute conception, appliquer la règle `## Adding or Modifying Skills > Step 0` de `CLAUDE.md`.
Présenter les résultats de l'audit à l'utilisateur et obtenir sa validation avant de continuer.

> Cette étape est **obligatoire**. Ne pas la sauter même pour un "skill simple".

**Vérifier les copies du skill avant toute modification** (création comprise : aucune copie homonyme ne doit exister). Un skill peut exister en trois exemplaires :

| Copie | Rôle |
|---|---|
| `claude-skills/skills/<cat>/<skill>/` | **source de vérité** — seule copie à éditer |
| `~/.claude/skills/<skill>/` | copie chargée, écrasée par `scripts/sync-to-claude.sh` |
| `<projet>/.claude/skills/<skill>/` | copie projet éventuelle (ex. vault SecondBrain) |

`diff -rq` entre les copies. Si une copie hors source est **plus récente** (édition directe, cas observé sur `session-recap` et `secondbrain-morning-briefing` en 2026) → la rapatrier dans la source **avant** de modifier, sinon la prochaine synchro efface ce travail. Après merge, recopier la source vers les autres emplacements.
> Red flag : "c'est juste un petit skill, pas besoin d'auditer."

---

## Étape 1 — Choisir le modèle

| Phase | Modèle | Raison |
|---|---|---|
| Conception (routing, architecture, choix références) | `claude-opus-4-6` | Méta-raisonnement — décisions structurantes sur le skill lui-même |
| Rédaction de la description YAML | `claude-sonnet-4-6` | Formulation précise, couverture de synonymes, CSO |
| Rédaction des fichiers `references/` | `claude-sonnet-4-6` | Si contenu nouveau à conceptualiser |
| Rédaction des fichiers `references/` | `claude-haiku-4-5` | Si transformation / reformatage de contenu existant |
| Validation / checklist pré-PR | `claude-haiku-4-5` | Vérification mécanique de conformité |

> Doute sur la phase ? → Sonnet.

---

## Étape 2 — Router par phase

| Phase détectée | Fichier à lire |
|---|---|
| Conception du SKILL.md : routing, architecture, modèles, structure | `references/design.md` |
| Écriture ou révision de la `description:` YAML | `references/description-cso.md` |
| Rédaction ou révision des fichiers `references/*.md` | `references/references-format.md` |
| Validation qualité avant PR (checklist, anti-rationalisation) | `references/checklist.md` |

---

## Règle universelle

Obtenir la validation de l'utilisateur après chaque livrable (description, routing, chaque référence)
avant de passer à l'étape suivante.
