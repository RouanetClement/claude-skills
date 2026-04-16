---
name: gestion-projet
description: >
  Utiliser quand l'utilisateur veut gérer un projet, suivre l'avancement, préparer un compte rendu,
  analyser des risques, ou communiquer via Slack.
  Triggers: suivi projet, avancement, compte rendu, rapport projet, Slack, mise à jour équipe,
  analyse de risques, synthèse projet, project status, team update.
  NE PAS utiliser pour les opérations Notion directes (pages, databases, blocs) → utiliser gestion-notion.
---

# Gestion de Projet — Point d'entrée

## Étape 1 — Choisir le modèle

| Type de tâche | Modèle |
|---|---|
| Recherche dans Slack | `claude-haiku-4-5` |
| Rédaction de message Slack simple | `claude-haiku-4-5` |
| Synthèse de l'avancement projet | `claude-haiku-4-5` |
| Préparation de compte rendu ou rapport de projet | `claude-sonnet-4-6` |
| Analyse de risques ou décision d'organisation | `claude-sonnet-4-6` |

---

## Étape 2 — Charger la référence adaptée

| Contexte | Fichier à lire |
|---|---|
| Actions sur Slack | `references/slack.md` |

---

## Règles universelles

- **Confirmer avant d'écrire** : pour toute action qui modifie des données (création, mise à jour, envoi), résumer ce qui va être fait et attendre validation
- **Scope minimal** : ne modifier que ce qui est demandé — pas de "nettoyage" non sollicité
- **Traçabilité** : noter la date et le contexte sur les éléments créés si le schéma le permet
