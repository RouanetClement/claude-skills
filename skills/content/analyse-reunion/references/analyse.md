# Analyse de Réunion — Compte rendu structuré

Objectif : produire un compte rendu structuré et fidèle à partir d'un transcript nettoyé.

---

## Structure de sortie standard

### Contexte
- Date de la réunion
- Participants (prénom, rôle si mentionné)
- Durée estimée (si timestamps présents)
- Objectif déclaré ou déduit de la réunion

### Résumé exécutif
3 à 5 phrases couvrant : raison de la réunion, décisions principales, suite immédiate.

### Points discutés
Liste ordonnée, neutre et factuelle — reflet des échanges sans reformulation d'opinion.

### Décisions prises
Distinctes des discussions. Formuler chaque décision comme :
> "Il a été décidé que [X]."

Si aucune décision formelle n'a été prise sur un sujet → ne pas en inventer.

### Blockers / Risques
- Éléments non résolus en fin de réunion
- Risques ou alertes soulevés par les participants
- Points renvoyés à une réunion future ou en attente de validation

### Prochaines étapes
Renvoyer vers `references/actions.md` pour l'extraction détaillée.

---

## Règles de fidélité

| Catégorie | Règle |
|---|---|
| Discussion | Ce qui a été évoqué, débattu, mentionné |
| Décision | Ce qui a été tranché, acté, validé collectivement |
| Piste évoquée | Idée lancée sans validation collective |
| Point ouvert | Sujet non résolu, renvoyé ou en suspens |

Ne jamais transformer une piste en décision. Ne pas confondre "quelqu'un a dit" avec "il a été décidé".

Reformuler le verbatim en langage neutre sans déformer le sens.

**Contraste décision / piste :**

❌ Verbatim : "On s'est dit qu'on pourrait peut-être migrer vers PostgreSQL"
→ Incorrect : `Décision : migrer vers PostgreSQL`

✅ Correct :
→ `Piste évoquée : migration vers PostgreSQL — non validée collectivement`

---

## Formats de sortie

### Markdown brut (par défaut)
Structure ci-dessus, titres `##`, listes à puces.

### Compte-rendu formel (PV)
Ajouter en en-tête :
```
PROCÈS-VERBAL DE RÉUNION
Date : [date]
Objet : [objet]
Présents : [liste]
Rédacteur : [nom ou "IA"]
```
Numéroter les sections. Terminer par une section "Approbation" vide à compléter.

### Notion-ready
Blocs structurés avec propriétés :
- `Date` (date), `Participants` (multi-select), `Objectif` (text)
- Sections comme blocs Toggle : Résumé, Points discutés, Décisions, Actions

---

## Langue

Si la réunion s'est tenue en anglais → produire le CR dans la langue demandée par l'utilisateur.
Si aucune langue précisée → utiliser la langue du transcript.
