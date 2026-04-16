# Recherche et navigation Notion

## Outils MCP disponibles

| Outil | Action |
|---|---|
| `notion-search` | Recherche full-text dans le workspace |
| `notion-fetch` | Lire une page ou database par ID |
| `notion-get-users` | Lister les membres du workspace |
| `notion-get-teams` | Lister les équipes |
| `notion-get-comments` | Lire les commentaires d'une page |
| `notion-create-comment` | Ajouter un commentaire sur une page |

---

## Stratégie de recherche

**Règle fondamentale** : toujours `notion-search` avant de créer — éviter les doublons.

Ordre recommandé :
1. Lancer `notion-search` avec un titre ou mots-clés précis
2. Si plusieurs résultats : filtrer par type d'objet (page ou database) et lire les titres
3. Si aucun résultat : tenter avec des mots-clés partiels ou synonymes
4. Si toujours aucun résultat : procéder à la création

---

## Filtres de recherche

`notion-search` accepte des filtres optionnels :
- **filter by object type** : `page` ou `database`
- **filter by property** : filtrer sur une propriété spécifique (ex: Statut = "En cours")

Exemple — trouver toutes les bases de données du workspace :
```
notion-search(query="", filter={ object: "database" })
```

Exemple — trouver les pages contenant "Sprint 14" :
```
notion-search(query="Sprint 14", filter={ object: "page" })
```

---

## Pagination cursor-based

Pour les workspaces avec beaucoup de résultats, `notion-search` retourne un curseur de pagination :
- Récupérer le champ `next_cursor` dans la réponse
- Passer `start_cursor=<next_cursor>` à l'appel suivant
- Continuer jusqu'à ce que `has_more = false`

Ne jamais supposer que la première page de résultats est exhaustive sur un grand workspace.

---

## Récupérer un ID à partir d'un titre

Pattern fréquent : l'utilisateur donne un titre, il faut l'ID Notion pour les actions suivantes.

1. `notion-search(query="Titre de la page")`
2. Dans les résultats, récupérer l'objet dont le titre correspond exactement
3. Extraire le champ `id` (UUID format : `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)
4. Utiliser cet ID pour `notion-fetch`, `notion-update-page`, etc.

---

## Users et Teams

**`notion-get-users`** : liste tous les membres avec leur ID, email et nom d'affichage
- Usage : résoudre un prénom en ID pour une assignation (`people` property)
- Usage : vérifier qui est dans le workspace avant une mention

**`notion-get-teams`** : liste les équipes configurées dans le workspace
- Usage : assigner une page ou tâche à une équipe entière

---

## Commentaires

**Lire** (`notion-get-comments`) : récupérer les annotations ou retours laissés sur une page
- Cas d'usage : préparer une synthèse des retours de review avant une réunion

**Ajouter** (`notion-create-comment`) : laisser une annotation contextualisée
- Cas d'usage : signaler un point d'attention sur une décision sans modifier le contenu principal
- Cas d'usage : répondre à un commentaire existant dans le cadre d'une review

Exemple — annoter une page de spec après lecture :
```
notion-create-comment(page_id="<id>", text="Point à clarifier : la section 3.2 mentionne 
un délai de 5j mais le ticket Jira indique 3j — à aligner.")
```
