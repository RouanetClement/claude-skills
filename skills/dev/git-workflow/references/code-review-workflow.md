# Code Review — Protocole équipe

## Principe de surcharge

Ce fichier étend `superpowers:requesting-code-review` et `superpowers:receiving-code-review`.
Ses règles prennent **priorité** sur les comportements par défaut de ces deux skills.
Les instructions utilisateur (ce fichier) prévalent sur les superpowers skills.

Format de lecture des sections ci-dessous :
- **Hérité** : comportement par défaut conservé tel quel
- **Ajouté** : règle équipe supplémentaire
- **Surchargé** : règle équipe qui remplace le comportement par défaut

---

## Quand déclencher une review

**Obligatoire :**
- Avant tout merge sur `main` ou `develop`
- Après implémentation d'un plan complet

**Optionnel :**
- Quand bloqué sur une décision d'architecture
- Après un refactoring significatif

**Cadence recommandée :**
Ne pas attendre la fin — reviewer par tranche, après chaque tâche logique.
Éviter les PRs "tout en un" : une PR de 800 lignes est une PR mal découpée.

---

## Préparation avant de demander (extends requesting-code-review)

**Hérité :** isolation du contexte reviewer via `BASE_SHA`/`HEAD_SHA` ; tri des commentaires par sévérité.

**Ajouté :**
- Inclure dans le contexte transmis au reviewer le lien vers le TODO.md ou le ticket associé
- Si la PR inclut de l'IaC (Terraform, Helm) ou du YAML CI/CD, le signaler explicitement en début de contexte

**Surchargé — niveaux de sévérité :**

| Niveau | Signification |
|---|---|
| `[BLOQUANT]` | Merge interdit tant que non résolu |
| `[IMPORTANT]` | À corriger avant merge, sauf accord explicite |
| `[MINEUR]` | Suggestion non bloquante |
| `[ELOGE]` | Bon pattern à noter et reproduire |

```
# ❌ Sévérité vague
"Cette variable mériterait un meilleur nom"

# ✅ Sévérité explicite
"[MINEUR] Renommer `d` en `durationMs` pour la lisibilité"
"[BLOQUANT] Le token JWT est loggé en clair ligne 42"
```

---

## Traitement du feedback (extends receiving-code-review)

**Hérité :** lire → comprendre → reformuler → clarifier si ambigu → implémenter un à un → tester chaque correction.

**Ajouté :**
Après résolution de chaque commentaire `[BLOQUANT]`, mettre à jour le fil PR avec la référence au commit de correction :
> "Résolu dans `abc1234` — token retiré du logger."

**Surchargé — formules interdites :**

```
# ❌ Sycophantie à éliminer
"Super remarque !"
"Très bonne idée, je corrige de suite !"

# ✅ Remplacer par l'action ou une question technique
"Corrigé dans abc1234."
"Je comprends la remarque — ma contrainte est X. Est-ce que Y conviendrait ?"
```

---

## Revue d'artefacts non-code

Ces artefacts sont de **premier rang** : les mêmes règles de review s'appliquent.

**IaC (Terraform, Helm) :**
- Vérifier l'idempotence — `terraform plan` ne doit pas détecter de drift résiduel
- Aucune valeur de secret en dur — utiliser des références à un vault ou des variables d'environnement
- Le `state file` ne doit jamais être commité

**YAML CI/CD :**
- Les secrets sont injectés via `env:` ou des variables de pipeline — jamais en clair dans le YAML
- `runs-on: self-hosted` doit être justifié dans un commentaire
- Chaque job doit avoir un `timeout-minutes` défini

**Markdown / documentation :**
- Les exemples de code dans les blocs ` ``` ` doivent être exécutables tels quels
- Vérifier les liens — un lien mort est un `[IMPORTANT]`

---

## Transition draft → ready-for-review

```
# ❌ Passer en "ready" trop tôt
- Des TODO restent dans le code
- Des tests échouent en local
- La description de PR est vide

# ✅ Critères pour marquer "ready"
- CI verte (tous les jobs passants)
- Tests passants en local
- Auto-review du diff complet effectuée (self-review)
- Description de PR renseignée (contexte + ce qui change + comment tester)
```

---

## Protocole désaccord avec reviewer

1. **Reformuler** le feedback pour confirmer la compréhension avant de répondre
2. **Exposer l'alternative** avec justification technique — pas "je préfère X" mais "X pose problème car Y, j'ai opté pour Z"
3. **Si désaccord persistant** → escalader : "Je demande une 2ème opinion à [personne/équipe]"
4. **Règle absolue** : ne jamais merger avec un commentaire `[BLOQUANT]` non résolu, même si le reviewer est absent
