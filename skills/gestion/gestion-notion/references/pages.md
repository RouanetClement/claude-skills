# Pages Notion

## Outils MCP disponibles

| Outil | Action |
|---|---|
| `notion-search` | Rechercher une page existante par titre ou contenu |
| `notion-fetch` | Lire le contenu complet d'une page (propriétés + blocs) |
| `notion-create-pages` | Créer une nouvelle page ou une entrée dans une base |
| `notion-update-page` | Modifier le contenu ou les propriétés d'une page |
| `notion-move-pages` | Déplacer une page vers un autre parent |
| `notion-duplicate-page` | Dupliquer une page existante |

---

## Protocole Créer

1. **Rechercher d'abord** (`notion-search`) — éviter les doublons
2. Si création dans une base de données : `notion-fetch` sur la DB pour récupérer le schéma
3. Résumer ce qui va être créé (titre, propriétés, parent) → attendre validation
4. Créer avec `notion-create-pages`

Exemple : créer une entrée "Sprint 14 — Revue" dans la base "Sprints"
→ search "Sprint 14" → aucun résultat → fetch DB "Sprints" pour le schéma → confirmer → créer

---

## Protocole Modifier

1. `notion-fetch` sur la page cible — lire l'état actuel
2. Identifier exactement le delta (quelles propriétés ou blocs changent)
3. Résumer les modifications → attendre validation
4. `notion-update-page` avec uniquement les champs modifiés

❌ `notion-update-page` directement sans fetch → risque d'écraser des blocs existants ou d'utiliser une valeur de select inconnue

✅ `notion-fetch` → identifier le schéma et l'état → delta minimal → `notion-update-page`

---

## Protocole Déplacer / Dupliquer

**Déplacer** (`notion-move-pages`) :
- Cas d'usage : réorganiser l'arborescence, archiver une page dans un dossier dédié
- Précaution : les liens internes vers la page restent valides, mais les mentions dans d'autres pages ne se mettent pas à jour automatiquement

**Dupliquer** (`notion-duplicate-page`) :
- Cas d'usage : créer un template instancié, copier un compte rendu pour une nouvelle réunion
- Précaution : les relations vers d'autres pages pointent vers les originaux — vérifier après duplication

---

## Format standard d'une page Notion

```
Titre : [titre clair, daté si applicable — ex: "CR Comité Produit 2025-06-10"]
Propriétés : [selon le schéma de la base — Statut, Date, Responsable, Tags…]

Contenu (blocs) :
## Contexte
[Pourquoi cette page existe, quel événement ou besoin]

## Contenu principal
[Corps du document]

## Actions / Next steps
- [ ] Action 1 — @responsable — échéance
- [ ] Action 2
```

---

## Bonnes pratiques

- Utiliser la **langue du workspace** (détecter via les pages existantes avant de créer)
- Préférer les **liens internes** (IDs Notion) aux mentions textuelles
- Ne pas dupliquer l'information : vérifier avant de créer
- Titres : clairs, avec date si la page représente un événement ou une livraison
