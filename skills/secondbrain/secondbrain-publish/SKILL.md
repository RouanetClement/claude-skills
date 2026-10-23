---
name: secondbrain-publish
description: Publie les changements du vault SecondBrain sur main via branche + PR, en une commande — le push direct sur main est bloqué par le hook protect-main. Enchaîne branche feature/*, commit Conventional Commits, push, PR gh, puis merge + nettoyage sur demande, et vérifie en fin de course que le dépôt est propre (0 PR ouverte, 0 branche orpheline, local = origin). Mode --all pour inclure les fichiers non suivis (recaps de session, sources) après les avoir listés. Triggers : "publie", "publish", "pousse", "ouvre une PR", "commit et PR", "merge la PR", "rajoute tout ce qui manque", "mets tout sur main", "synchronise le vault", "envoie sur GitHub".
---

# secondbrain-publish

Publication des changements du vault SecondBrain sur `main`, **toujours via une PR** (le hook `protect-main.sh` bloque tout push sur la branche par défaut).

## Modes

| Invocation | Effet |
|---|---|
| `publish` (défaut) | fichiers **suivis** modifiés → branche → commit → push → PR → *« je fusionne ? »* |
| `publish --all` | idem + fichiers **non suivis**, listés et montrés avant `git add` |
| `publish --merge` | idem + merge immédiat (l'utilisateur a dit « merge » dans la même demande) |
| `publish --check` | aucun commit : seulement l'étape 5 (état du dépôt) |

Détection en langage naturel : « rajoute tout ce qui manque » / « mets tout sur main » → `--all --merge` ; « ouvre une PR » → défaut ; « merge la PR » sur une PR déjà ouverte → aller directement à l'étape 4.

## Étape 0 — Pré-conditions (stopper au premier échec)

```bash
cd "$SECONDBRAIN_PATH"            # normaliser /c/... ou /mnt/c/... en C:/... sous Windows
git fetch -q --prune
git status --porcelain
gh auth status
```

- Rien à publier (statut vide, pas de commit en avance sur `origin/main`) → passer à l'étape 5 et le dire.
- Commits locaux sur `main` en avance sur `origin/main` → les **embarquer** dans la branche (étape 1 la crée depuis HEAD), puis réaligner `main` après merge.
- Conflit, rebase en cours ou `gh` non authentifié → **stopper** et signaler. Ne jamais forcer.

## Étape 1 — Branche

- Déjà sur une branche `feature/*` (ex. créée par `secondbrain-morning-briefing`) → la réutiliser.
- Sinon : `git switch -c feature/<slug>`, avec `<slug>` dérivé du contenu en kebab-case ASCII, daté si pertinent :
  - `feature/briefing-YYYY-MM-DD`, `feature/ingest-<sujet>`, `feature/session-recap-YYYY-MM-DD`, `feature/vault-sync-YYYY-MM-DD` (fourre-tout `--all`).

## Étape 2 — Sélection et contrôle des fichiers

1. **Suivis modifiés** : `git diff --name-only` + `git diff --cached --name-only`.
2. **Non suivis** (`--all` uniquement) : `git ls-files --others --exclude-standard`. **Lister à l'utilisateur** avant de les ajouter (en mode `--merge`, la liste figure dans le compte rendu).
3. **Contrôles bloquants** (règle des binaires de `CLAUDE.md`) :
   - aucun `.pdf/.docx/.pptx/.xlsx/.odt`, image bitmap, média ou archive ne doit être ajouté — s'il apparaît, c'est que le `.gitignore` est troué : stopper et signaler ;
   - tout binaire présent dans `sources/` doit avoir sa note compagnon `.md`.
4. `git add` **fichier par fichier** (jamais `git add -A` / `git add .`).

## Étape 3 — Commit, push, PR

- **Message** : Conventional Commits, en français sans accents dans le sujet (style du dépôt) :
  `feat(briefing): …`, `feat(wiki): …`, `docs(sessions): …`, `chore(vault): …`. Corps : liste des pages touchées.
  Terminer par la ligne d'attribution `Co-Authored-By:` fournie par le harness.
- **Windows / Git Bash** : pour un message ou un corps de PR long ou riche en apostrophes, l'écrire dans un fichier du scratchpad puis `git commit -F <fichier>` / `gh pr create --body-file <fichier>` — jamais de long heredoc.
- `git push -u origin <branche>` → si refus du hook ou du remote : stopper, montrer l'erreur.
- `gh pr create --base main --title "<titre>" --body-file <fichier>`. Corps : résumé par page/source touchée, mention `sensitive: true` si le lot en contient, ligne de génération fournie par le harness.

## Étape 4 — Merge (sur demande explicite, ou `--merge`)

```bash
gh pr merge <N> --merge --delete-branch
git switch main && git pull --ff-only
```

- Stratégie `--merge` (pas de squash) : les commits locaux restent identiques à ceux de `origin/main`, le `pull --ff-only` suffit.
- Échec (conflit, checks rouges) → stopper, laisser la PR ouverte, signaler.

## Étape 5 — État du dépôt (toujours, en fin de course)

```bash
git fetch -q --prune
git status -sb                            # attendu : ## main...origin/main, rien d'autre
gh pr list --state open                   # attendu : vide (hors PR volontairement laissée ouverte)
git branch -r --no-merged origin/main     # branches distantes orphelines
```

- Branche orpheline trouvée → l'inspecter (`git log main..<b>`, `gh pr list --state all --search "head:<b>"`) et **proposer** sa suppression avec la raison (contenu déjà intégré ? PR fermée volontairement ?). Ne jamais la supprimer sans accord.

## Restitution

Courte, en tutoiement :

```
<N> fichier(s) publiés via la PR #<n> (<lien>) — <fusionnée | ouverte, je fusionne ?>
État : main = origin/main · 0 PR ouverte · <0 | k> branche(s) orpheline(s)
```

## Garde-fous

- **Jamais** de push sur `main`, de `--force`, de `reset --hard` ou de suppression de branche distante sans accord explicite.
- **Merge** uniquement sur demande (« merge », « fusionne », « mets sur main ») ou `--merge`.
- Les sources `sources/` sont append-only : un fichier source **modifié** (pas ajouté) dans le lot → le signaler avant de committer.
- Le repo est privé et le restera : `sensitive: true` se publie sans mise en garde supplémentaire.
- Ce skill ne crée ni ne modifie de contenu wiki : il publie ce qui existe.
