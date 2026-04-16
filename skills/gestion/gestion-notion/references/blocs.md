# Blocs Notion

## Outils MCP disponibles

| Outil | Action |
|---|---|
| `notion-fetch` | Lire les blocs existants d'une page |
| `notion-update-page` | Modifier le contenu d'une page, y compris ajouter des blocs dans le body |

---

## Propriétés vs blocs : distinction fondamentale

- **Propriétés** : données structurées de la page (titre, statut, date, assigné…) — modifiées via les champs de la base de données
- **Blocs** : contenu riche de la page (texte, listes, titres, code…) — modifiés via le body de `notion-update-page`

Exemple :
- Changer le Statut d'une tâche → propriété → `notion-update-page` avec le champ `Status`
- Ajouter un paragraphe de contexte → bloc → `notion-update-page` avec le corps Markdown

---

## Types de blocs courants

| Type | Rendu Notion |
|---|---|
| `paragraph` | Texte libre |
| `heading_1` | Titre H1 (grand) |
| `heading_2` | Titre H2 (moyen) |
| `heading_3` | Titre H3 (petit) |
| `bulleted_list_item` | Liste à puces |
| `numbered_list_item` | Liste numérotée |
| `to_do` | Case à cocher |
| `toggle` | Section repliable |
| `code` | Bloc de code (avec langage) |
| `quote` | Citation |
| `divider` | Séparateur horizontal |
| `callout` | Encart coloré avec icône |

---

## Append vs replace

- **Append** (ajouter sans écraser) : inclure uniquement les nouveaux blocs dans le body, après un `notion-fetch` pour connaître l'état actuel
- **Replace** (réécrire) : envoyer la totalité du contenu dans `notion-update-page` — attention, efface le contenu existant
- Règle par défaut : **toujours append**, sauf si l'utilisateur demande explicitement un remplacement complet

---

## Richtext : formatage inline

Dans un bloc de type `paragraph`, `heading`, ou `to_do`, le texte supporte :
- **Gras** : `**texte**`
- *Italique* : `*texte*`
- `Code inline` : `` `texte` ``
- Mention page : `@[Titre de la page]`
- Mention personne : `@[Prénom Nom]`
- Mention date : `@2025-06-10`

---

## Pattern : compte-rendu de réunion

```
## Réunion — [Sujet] — [Date]

**Participants :** @Alice Martin, @Bob Durand
**Durée :** 45 min

## Points abordés
1. Avancement Sprint 14 — statut vert
2. Risque livraison API — à surveiller

## Décisions
- Décision 1 : reporter la démo au 15/06
- Décision 2 : @Alice prend en charge le ticket #42

## Actions
- [ ] Mettre à jour le backlog — @Bob — avant le 12/06
- [ ] Envoyer le CR à l'équipe — @Alice — aujourd'hui
```

---

## Limite MCP

Les blocs imbriqués (nested) sont supportés jusqu'à **2 niveaux** via MCP.
Au-delà (ex : toggle dans un toggle dans un callout), utiliser l'API Notion directe.
