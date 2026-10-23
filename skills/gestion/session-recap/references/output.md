# Construction & écriture du bilan

## 1. Frontmatter YAML

```
---
date: YYYY-MM-DD
heure: "HH:MM"
projet: <basename du répertoire courant>
repo: <owner/repo via git remote origin, omis si absent>
type_session: <dev|cv|content|gestion|multi|exploration>
mode_invocation: <auto|manuel>
skills_utilises:
  - <skill-name>
outils_principaux:
  - <outil>
technos:          # présent uniquement si type_session=dev
  - <techno>
methodologie:     # présent uniquement si type_session=dev
  - <TDD|BDD>
nb_echanges: N
sous_agents_invoques: N
---
```

## 2. Corps Markdown

```
## Résumé exécutif
<1-2 phrases : objectif principal + résultat global>

## Tâches demandées
- [x] ...
- [ ] ...

## Skills & outils utilisés
| Skill / Outil | Usages | Contexte |
|---|---|---|

## Contexte technique
<présent uniquement si type_session=dev>

## Instructions, corrections & précisions de l'utilisateur
- "..."

## Profil d'usage observé
<patterns détectés>

## Sous-agents
<présent uniquement si sous_agents_invoques > 0>

## Suggestions
### Nouveaux skills candidats
- `<nom>` — <raison>

### Améliorations de skills existants
- `<skill>` : <amélioration>
```

## 3. Écrire le fichier

Chemin cible : `<vault>/wiki/sessions/YYYY-MM-DD_HH-MM_session-recap.md`

où `<vault>` est le `$SECONDBRAIN_PATH` **normalisé à l'étape 1 du SKILL.md** (jamais la valeur brute : une forme `/mnt/c/...` échoue sous Windows natif).

Écrire via l'outil `Write`.
- **Mode auto** : aucun texte visible dans le chat. Si Write échoue : afficher uniquement `[session-recap] Erreur d'écriture : <message>`.
- **Mode manuel** : après écriture, restituer le suivi d'exécution (étapes franchies, mode détecté, chemin du fichier produit). Si Write échoue : signaler l'erreur.

## 4. Versionnement du bilan

Le bilan est écrit **non suivi** par Git. Il ne doit pas rester orphelin (cas observé : recap du 16/10 resté hors Git une semaine).

- **Mode auto** : ne **jamais** committer ni pousser (action sortante, et le mode est silencieux). Le fichier sera embarqué par `secondbrain-publish`, qui inclut par défaut les `wiki/sessions/*.md` non suivis.
- **Mode manuel** : terminer la restitution par une ligne *« Bilan non commité — je le publie (`secondbrain-publish`) ? »*.
