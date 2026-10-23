---
name: secondbrain-lint
description: Vérifie la santé du wiki SecondBrain. Mode light (pages passées en argument, déclenché auto par /secondbrain-ingest) ou full (vault complet, manuel). Détecte frontmatter incomplet (selon le type de page), wikilinks cassés, orphelins, doublons de slug, contradictions, pages mentionnées comme `related:` mais inexistantes, dates incohérentes. Schéma de validation par type (page wiki, source, index, lint-report). Produit un rapport horodaté dans wiki/_lint/. En mode full, propose des fix automatiques avec validation utilisateur. Triggers : "lint", "audit du wiki", "vérifie la cohérence du second brain".
---

# secondbrain-lint

Audit de santé du wiki SecondBrain.

## Quand l'invoquer

- **Light (auto)** : appelé par `secondbrain-ingest` à la fin de chaque ingestion sur les pages touchées. Pas de fix proposés, juste signalement.
- **Full (manuel)** : invoqué par l'utilisateur — "lint", "audit du wiki", "vérifie la cohérence". Couvre l'intégralité de `wiki/` + les notes compagnons de `sources/`. Propose des fix automatiques validés par l'utilisateur.

## Modes

| Mode | Périmètre | Fix proposés |
|---|---|---|
| `light <chemins...>` | Pages passées en argument | Non |
| `full` | Tout `wiki/` (récursif) + notes compagnons `sources/**/*.md` | Oui, avec validation utilisateur |

## Routine

### 1. Lister le périmètre

- `light` : utiliser les chemins passés en argument.
- `full` :
  - pages wiki : `find wiki -name "*.md" -not -path "wiki/_lint/*"`
  - notes compagnons sources : `find sources -name "*.md"` (les `.md` versionnés ; les binaires sont gitignored et ne sont pas traités)

### 2. Vérifications par page

Pour chaque fichier, **router selon `type:`** dans le frontmatter et appliquer le schéma correspondant.

#### 2.a — Schéma de validation par type

| `type:` | Champs obligatoires | Champs optionnels typiques | Notes |
|---|---|---|---|
| **Pages wiki** : `concept`, `client`, `org`, `mission`, `domaine`, `personne`, `projet`, `lecture`, `veille` | `type`, `scope`, `status`, `created`, `updated` | `sensitive`, `tags`, `sources`, `related` | Schéma "page wiki standard" |
| `source` (notes compagnons dans `sources/`) | `type`, `scope`, `source_kind`, `origin` (avec sous-clés `kind` + `ref`), `ingested` | `source_file`, `hash_sha256`, `created`, `updated`, `sensitive` | **Pas de `status` requis**. `created/updated` non obligatoires (équivalents à `ingested`). |
| `index` (`wiki/index.md`) | `type`, `updated` | — | Pas de `scope` requis (transversal) |
| `lint-report` (`wiki/_lint/*.md`) | `type`, `mode`, `created` | `scope_count` | Auto-générés |
| pas de frontmatter (`wiki/log.md`) | H1 `# Log — SecondBrain` en début de fichier | — | Cas spécial |

**Validations transverses (toutes pages avec `created` ET `updated`)** :
- Format `YYYY-MM-DD` valide
- `updated >= created`

**Valeurs autorisées** :
- `type` ∈ liste ci-dessus
- `scope` ∈ {`pro`, `perso`}
- `status` ∈ {`draft`, `active`, `archived`}
- `source_kind` ∈ {`pdf`, `docx`, `pptx`, `xlsx`, `image`, `media`, `archive`, `msg`, `slack-channel-export`, `note`}
- `origin.kind` ∈ {`url`, `email`, `slack`, `manual`, `filesystem`}

#### 2.b — Liens

Détection des wikilinks `[[slug]]` et chemins `sources:` :

- **Ignorer les wikilinks à l'intérieur de** :
  - blocs de citation Markdown (lignes commençant par `>`)
  - commentaires HTML (`<!-- ... -->`)
  - blocs de code (entre triples backticks ou inline ` `` `)
- **Vérifier** :
  - Wikilinks `[[slug]]` ou `[[slug|alias]]` : la cible `<slug>.md` existe dans `wiki/` ou dans `sources/`
  - Entrées `related:` du frontmatter : chaque cible existe
  - Chemins `sources:` du frontmatter : chaque fichier existe sur le disque

#### 2.c — Indexation

- Les pages **wiki** (sauf `index.md`, `log.md`, `_lint/*`) doivent apparaître dans `wiki/index.md`.
- Les notes compagnons de `sources/` sont **exemptées** de l'indexation (référencées via `sources:` des pages wiki, pas via `index.md`).
- Le slug du fichier est **unique** dans tout `wiki/` (deux pages avec le même nom de fichier dans des sous-dossiers différents = warning).

### 3. Vérifications transversales (mode full uniquement)

#### 3.a — Contradictions

Détecter les claims opposés sur la même entité dans 2 pages distinctes (ex. *"Acme est un client actif"* vs *"Acme a été perdu en 2025"*). Heuristique : pages partageant un même slug dans `related:` + signaux de polarité opposée.

#### 3.b — Lacunes

Pages mentionnées comme `related:` ou via wikilink (hors citations / code / commentaires) dans une page mais qui n'existent pas → liste de pages "à créer".

#### 3.c — Pages orphelines

Pages présentes dans `wiki/` mais référencées par aucune autre page ET pas dans `index.md`. Suspectes : à enrichir, à archiver, ou à réindexer.

#### 3.d — Cohérence orgs / clients

- Une page `type: client` ne doit pas être dupliquée en `type: org` (et vice-versa) avec le même slug → warning.
- Pages `personne` avec `tags: [partenaire, ...]` ou `tags: [client, ...]` devraient avoir un `related:` vers l'`org`/`client` correspondant — sinon suggestion.

#### 3.e — Hygiène du dépôt Git

```bash
git fetch -q --prune
git status --porcelain                    # fichiers non suivis / modifiés
gh pr list --state open                   # PR en souffrance
git branch -r --no-merged origin/main     # branches distantes orphelines
```

- Fichier non suivi ou modifié non commité → **warning** (ex. recap de session oublié). Fix proposé : `secondbrain-publish` (ou `--all`).
- PR ouverte depuis > 2 jours → **warning**.
- Branche distante non fusionnée → **warning**, avec diagnostic : contenu déjà présent sur `main` (cherry-pick, PR rejouée) ou PR fermée volontairement (`gh pr list --state all --search "head:<b>"`). Fix proposé : suppression de la branche — **jamais sans validation**.
- Copie projet `.claude/skills/<skill>/` différente de `~/.claude/skills/<skill>/` → **warning** : une des deux copies a été éditée hors du dépôt source `claude-skills` ; la prochaine synchro écrasera l'une ou l'autre.

### 4. Produire le rapport

Écrire dans `wiki/_lint/YYYY-MM-DD-HHmm-{light|full}.md` :

```markdown
---
type: lint-report
mode: light | full
created: YYYY-MM-DD
scope_count: <nombre de pages auditées>
---

# Lint report — YYYY-MM-DD HH:mm — mode <light|full>

## Périmètre

- Pages wiki auditées : <N>
- Notes compagnons sources auditées : <M>
- Total : <N+M>

## Erreurs (<N>)

### `wiki/.../page-x.md` (type: concept)

- Frontmatter manque `created`
- Wikilink `[[concept-z]]` cible inexistante

### `sources/pro/pdfs/...md` (type: source)

- `origin.ref` vide

## Warnings (<N>)

### `wiki/.../page-y.md` (type: personne)

- Page non listée dans `wiki/index.md`
- `tags: [partenaire]` sans `related: [[<org>]]`

## Suggestions (<N>)

- Pages référencées mais inexistantes (à créer ?) : `[[client-acme]]`, `[[concept-w]]`
- Page potentiellement orpheline : `wiki/perso/concepts/old-idea.md` (aucune autre page n'y pointe)

## Fix automatiques proposés (mode full uniquement)

- [ ] **1.** Créer `wiki/pro/clients/client-acme.md` avec frontmatter minimal
- [ ] **2.** Ajouter `[[old-idea]]` dans `wiki/index.md` section "Concepts perso"
- [ ] **3.** Compléter le frontmatter de `wiki/.../page-x.md` (champ `created` = date du premier commit du fichier)

Pour appliquer : répondre `apply <numéros>` ou `apply all`.
```

### 5. Append à `wiki/log.md`

```markdown
## YYYY-MM-DD — lint <mode>: <X> erreurs, <Y> warnings, <Z> suggestions

Rapport : `wiki/_lint/YYYY-MM-DD-HHmm-<mode>.md`
```

### 6. Si mode `full` : proposer les fix

Lister les fix automatiques numérotés et attendre la décision utilisateur (`apply 1,3`, `apply all`, `skip`). N'appliquer que les fix validés.

### 7. Restituer

Synthèse courte à l'utilisateur :

```
🩺 Lint <mode> terminé sur <N> pages
- ❌ <X> erreurs
- ⚠️ <Y> warnings
- 💡 <Z> suggestions

Rapport complet : wiki/_lint/YYYY-MM-DD-HHmm-<mode>.md

[Si full] Veux-tu appliquer les <K> fix automatiques proposés ?
```

## Heuristiques

- **Pas de panique sur les `draft`** : une page wiki en `status: draft` peut avoir un frontmatter encore lacunaire pendant 7 jours après création. Au-delà : warning.
- **Veille mensuelle** : pages `wiki/pro/veille/YYYY-MM_*.md` sont auto-archivées 6 mois après création (suggestion `status: archived`).
- **Sources brutes (binaires)** : `lint` ne touche pas les fichiers binaires de `sources/` (PDF, DOCX, etc.) — c'est immutable. Mais il **valide les notes compagnons `.md`** versionnées qui les accompagnent (frontmatter `type: source`).
- **Tags purs** : un `tag: [partenaire]` sans `related: [[org]]` correspondante est une suggestion, pas une erreur — l'utilisateur peut avoir une raison.
