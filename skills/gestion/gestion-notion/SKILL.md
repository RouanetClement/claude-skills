---
name: gestion-notion
description: >
  Utiliser quand l'utilisateur veut interagir directement avec Notion : créer, lire,
  modifier ou déplacer des pages, gérer des bases de données, ajouter des blocs ou
  rechercher du contenu dans le workspace.
  Triggers: page Notion, database Notion, bloc, recherche workspace, create page,
  update page, notion database, notion search, consulter Notion, modifier Notion,
  ajouter dans Notion, dupliquer page, créer une entrée, base de données Notion.
  NE PAS utiliser pour gestion de projet / workflow global → utiliser gestion-projet.
---

# Gestion Notion — Point d'entrée

## Étape 1 — Choisir le modèle

| Type de tâche | Modèle | Raison |
|---|---|---|
| Fetch, search, CRUD page, ajout entrée DB | `claude-haiku-4-5` | CRUD mécanique, résultat prévisible |
| Structuration de contenu complexe, création DB avec schéma | `claude-sonnet-4-6` | Jugement éditorial ou architectural nécessaire |

---

## Étape 2 — Charger la référence adaptée

| Contexte détecté | Fichier à lire |
|---|---|
| Créer, lire, modifier, déplacer, dupliquer une page | `references/pages.md` |
| Créer ou modifier une base de données, ses vues, ses lignes | `references/databases.md` |
| Ajouter ou modifier des blocs au sein d'une page | `references/blocs.md` |
| Rechercher du contenu, naviguer dans le workspace | `references/recherche.md` |

---

## Règles universelles

- **Confirmer avant d'écrire** : pour toute action de création, modification ou déplacement, résumer ce qui va être fait et attendre validation
- **Lire avant d'écrire** : toujours fetch la page ou database cible avant de la modifier
- **Scope minimal** : ne modifier que ce qui est demandé — pas de "nettoyage" non sollicité
