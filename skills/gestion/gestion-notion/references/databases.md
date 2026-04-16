# Databases Notion

## Outils MCP disponibles

| Outil | Action |
|---|---|
| `notion-create-database` | Créer une nouvelle base avec son schéma de propriétés |
| `notion-update-data-source` | Modifier une base existante (propriétés, titre) |
| `notion-create-view` | Créer une vue (table, board, calendar, gallery, list) |
| `notion-update-view` | Modifier les filtres, tris ou colonnes d'une vue existante |
| `notion-fetch` | Lire le schéma et les entrées d'une base |

---

## Types de propriétés Notion

| Type | Usage typique |
|---|---|
| `title` | Nom principal de l'entrée (obligatoire, unique par base) |
| `rich_text` | Description, notes libres |
| `number` | Budget, points d'effort, score |
| `select` | Statut, priorité (une seule valeur) |
| `multi_select` | Tags, équipes (plusieurs valeurs) |
| `date` | Échéance, date de création, période |
| `people` | Responsable, assigné, reviewer |
| `checkbox` | Tâche accomplie, flag booléen |
| `url` | Lien externe, repo GitHub, doc Google |
| `email` | Contact |
| `phone` | Contact téléphonique |
| `relation` | Lien vers une autre base Notion |
| `rollup` | Agrégation depuis une relation |
| `formula` | Calcul basé sur d'autres propriétés |

---

## Règle fondamentale : respecter le schéma existant

- **Ne jamais créer de nouvelle propriété** sans demande explicite de l'utilisateur
- Avant d'ajouter une entrée : `notion-fetch` sur la base pour récupérer les propriétés
- Utiliser **uniquement les valeurs existantes** pour `select` et `multi_select`
  (ex : si Statut = ["À faire", "En cours", "Terminé"], ne pas inventer "Validé")

---

## Création de vue : choisir le bon type

| Type de vue | Usage recommandé |
|---|---|
| `table` | Vue par défaut, toutes les propriétés visibles |
| `board` | Kanban par statut ou priorité |
| `calendar` | Visualisation par date d'échéance |
| `gallery` | Pages avec image de couverture |
| `list` | Vue minimaliste, titre seul |

---

## Rate limits à respecter

- **Limite globale** : 180 requêtes / minute
- **Limite recherche** : 30 `notion-search` / minute
- Pour les opérations batch (créer plusieurs entrées) : espacer les requêtes d'au moins 350 ms
- En cas d'erreur 429 (rate limit) : attendre 10 secondes avant de réessayer

---

## Edge case : fichiers et images

L'upload de fichiers ou d'images dans Notion **n'est pas possible via MCP**.
→ Utiliser l'API Notion directe (endpoint `POST /v1/blocks`) avec un token d'accès dédié.
→ Ne pas promettre cette fonctionnalité via les outils MCP disponibles.
