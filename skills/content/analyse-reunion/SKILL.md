---
name: analyse-reunion
description: >
  Utiliser quand l'utilisateur fournit un transcript, compte rendu, ou enregistrement de réunion
  à analyser, résumer, ou exploiter.
  Triggers: réunion, meeting, transcript, compte rendu, CR, procès-verbal, PV, actions,
  décisions, ordre du jour, standup, retro, brainstorm, call, visio, notes de réunion.
  Exclure si la demande porte sur un document générique sans lien avec une réunion
  (→ utiliser analyse-documents à la place).
---

# Analyse de Réunion — Point d'entrée

## Étape 0 — Format et profondeur

Avant toute analyse, identifier :

**Format de l'entrée :**
- Texte brut / Markdown → traitement direct
- DOCX / PPT / VTT / SRT → charger `references/ingestion.md` d'abord
- Format inconnu → demander à l'utilisateur de coller le texte brut

**Profondeur demandée :**
- Résumé rapide → Étape 1 : Sonnet + `references/analyse.md`
- Actions uniquement → Étape 1 : Sonnet + `references/analyse.md` + `references/actions.md`
- Analyse complète (CR formel, PV) → Étape 1 : Sonnet + `references/analyse.md` + `references/actions.md`
- Dynamiques de groupe / patterns → Étape 1 : Opus + tous les fichiers references

---

## Étape 1 — Choisir le modèle

| Type de tâche | Modèle | Raison |
|---|---|---|
| Extraction et nettoyage (DOCX, PPT, formats) | `claude-haiku-4-5` | Transformation mécanique sans jugement |
| Résumé, décisions, actions, blockers | `claude-sonnet-4-6` | Synthèse + arbitrage entre discussion et décision |
| Patterns communication, dynamiques de groupe, multi-réunions | `claude-opus-4-6` | Inférences comportementales et raisonnement profond |

---

## Étape 2 — Router par opération

> `analyse.md` est toujours chargé en premier — c'est la base de toute analyse de réunion.

| Contexte | Fichier à lire |
|---|---|
| Fichier non-texte (DOCX, PPT, VTT/SRT) ou format inconnu | `references/ingestion.md` (avant tout) |
| Résumé, décisions, blockers — **toujours charger** | `references/analyse.md` |
| Actions avec owner, deadline, priorité | `references/actions.md` |
| Dynamiques de groupe, patterns de communication | `references/dynamiques.md` |

---

## Règle universelle

- Présenter un plan d'analyse avant de commencer : sections couvertes et format de sortie attendu
- Ne pas inventer des décisions ou actions non mentionnées dans le transcript
- Si des parties sont illisibles ou tronquées, le signaler explicitement avant de poursuivre
