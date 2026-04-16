# Actions — Extraction et structuration

Objectif : identifier, structurer et prioriser toutes les actions décidées ou évoquées dans un transcript de réunion.

---

## Format d'une action

```
- [ ] [Description de l'action] — @[owner] — [deadline] — P[0-3]
```

Exemples :
```
- [ ] Envoyer le budget révisé à Sophie — @marc — vendredi 19/04 — P1
- [ ] Mettre à jour la roadmap Q2 — @? — [date?] — P2
- [ ] Relancer le prestataire sur le délai de livraison — @lea — dès que possible — P0
```

---

## Règles d'extraction

| Champ | Règle |
|---|---|
| Description | Verbe d'action + objet clair. Reformuler si le verbatim est ambigu |
| Owner (`@nom`) | Personne nommée dans la réunion. Si non mentionné : `@?` |
| Deadline | Date ou délai mentionné. Si absent : `[date?]` |
| Priorité | P2 par défaut. Ajuster si urgence explicite (voir tableau ci-dessous) |

Signaler en fin de liste les actions avec `@?` ou `[date?]` pour clarification.

---

## Tableau de priorités

| Priorité | Critère | Exemples de formulations |
|---|---|---|
| P0 | Bloquant, risque immédiat | "urgent", "bloque tout", "avant ce soir" |
| P1 | Critique pour la semaine | "cette semaine", "avant vendredi", "impératif" |
| P2 | Important, cette itération | par défaut, sans précision d'urgence |
| P3 | Backlog, pas urgent | "quand on aura le temps", "à terme", "nice to have" |

---

## Formats de sortie

### Markdown (par défaut)
Liste `- [ ]` standard, triée par priorité décroissante (P0 en premier).

### Notion-ready
Propriétés par action :
- `Tâche` (title)
- `Assigné` (person)
- `Échéance` (date)
- `Priorité` (select : P0 / P1 / P2 / P3)
- `Statut` (select : À faire / En cours / Terminé)

### Slack-ready
Bullet list formatée, mentions `@nom` et date :
```
• Envoyer le budget révisé → @marc avant vendredi [P1]
• Mettre à jour la roadmap Q2 → @? [date à confirmer] [P2]
```

---

## Edge cases

**Action collective** ("on va faire X", "l'équipe va...") :
→ Décomposer en items individuels si les responsables sont identifiables.
→ Si non identifiables : noter `@équipe` et signaler.

**Action conditionnelle** ("si le client valide, alors...") :
→ Conserver la condition dans la description :
`- [ ] [Si validation client] Lancer la phase 2 — @paul — [date?] — P1`

**Action récurrente** ("chaque lundi, envoyer...") :
→ Noter la fréquence dans la description :
`- [ ] [Récurrent — chaque lundi] Envoyer le rapport d'avancement — @claire — P2`

**Mention sans engagement** ("on pourrait peut-être faire X") :

❌ `- [ ] Faire X — @? — [date?] — P3` ← ne pas extraire une mention comme action

✅ Ne pas extraire. Signaler séparément si potentiellement actionnable :
`(Note : X évoqué sans engagement — à confirmer avec l'équipe)`
