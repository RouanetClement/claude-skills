# Edit — Ajouter et mettre à jour des TODOs

## Format d'une tâche

```
- [ ] Description courte — [TAG] Pniveau
```

Exemple : `- [ ] Configurer le backup ChromaDB — [BACKUP] P2`

## Prérequis optionnels (needs:)

Un TODO peut déclarer une dépendance sur la ligne suivante, indentée :

```
- [ ] Description — [TAG] Pniveau
  needs: [AUTRE-TAG]
```

Plusieurs dépendances sur la même ligne, séparées par une virgule :

```
- [ ] Description — [TAG] Pniveau
  needs: [TAG-A], [TAG-B]
```

Règles :
- **Débloquée** : pas de `needs:`, ou tous les tags référencés sont `[x]`
- **Bloquée** : au moins un tag `needs:` est encore `[ ]` ou `[~]`
- Ne jamais ajouter `needs:` à une tâche déjà `[~]` ou `[x]`
- Lors de l'ajout, vérifier que les tags référencés existent dans le fichier

## Ajouter un TODO

1. Si section, tag ou priorité manquants → demander avant d'écrire
2. Insérer à la bonne position dans la section (P0 avant P1, P1 avant P2, etc.)
3. Si sous-fichiers existent → demander dans quel fichier insérer
4. Confirmer avant écriture (sauf `auto_confirm: true`)

## Mettre à jour le statut

| Transition | Résultat |
|---|---|
| → `[x]` | `- [x] Description — [TAG] Pniveau (YYYY-MM-DD)` |
| → `[~]` | `- [~] Description — [TAG] Pniveau (en cours — note optionnelle)` |
| → `[ ]` | Retirer la date ou note, retour à l'état ouvert |

Après chaque passage à `[x]` :
- Vérifier si toutes les tâches de la section sont `[x]`
- Si oui → appliquer la logique de `references/archive.md`

## Convention inline dans le code

Si l'utilisateur modifie un fichier source lié à un TODO, rappeler :
```
// TODO[TAG]: description — voir TODO.md#TAG
```

## Interdits

- Ne jamais modifier plusieurs tâches sans confirmation intermédiaire
- Ne jamais supprimer une tâche — utiliser `[x]` puis archiver
