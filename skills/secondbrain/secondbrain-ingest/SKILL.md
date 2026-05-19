---
name: secondbrain-ingest
description: Ingère une nouvelle source (fichier dans sources/inbox/, chemin explicite, URL, ou texte collé) dans le wiki SecondBrain. Détecte le type, extrait le contenu via sous-agent adapté (analyse-documents, extraction-pdf, extraction-docx, extraction-linkedin), met à jour les pages wiki concernées, crée la note compagnon pour les binaires (avec hash SHA-256 + origine), append wiki/log.md, lint léger des pages touchées. Triggers : "ingest", "ajoute cette source au second brain", "intègre ce PDF/article/note", drop dans sources/inbox/.
---

# secondbrain-ingest

Ingestion d'une source dans le wiki SecondBrain (pattern Karpathy LLM Wiki).

## Quand l'invoquer

- Utilisateur dit : "ingest", "ajoute cette source", "intègre ce PDF/article/note", "ingère <chemin>"
- Un fichier vient d'apparaître dans `sources/inbox/` et l'utilisateur demande son traitement
- Utilisateur colle une URL ou du texte en demandant de l'ajouter au wiki

## Routine

### 1. Identifier le type de source

Demander/inférer parmi :

- **fichier local** dans `sources/inbox/` (à déplacer) ou chemin explicite
- **URL** (article web, page Notion publique…)
- **copier-coller** (texte brut, transcript)

Si plusieurs candidats dans `inbox/`, demander lequel traiter (ou tous en batch).

### 2. Acquérir la source

| Cas | Action |
|---|---|
| Fichier `.md/.txt/.html` dans `inbox/` | Déplacer vers `sources/<scope>/<type>/YYYY-MM-DD_<slug>.<ext>` (ne pas modifier le contenu) |
| Fichier binaire (`.pdf/.docx/.pptx/.xlsx/...`) dans `inbox/` | Déplacer vers `sources/<scope>/<type>/YYYY-MM-DD_<slug>.<ext>` (binaire, gitignored) ; créer la note compagnon `.md` (étape 4) |
| URL | `WebFetch` → sauver le markdown extrait dans `sources/<scope>/articles/YYYY-MM-DD_<slug>.md` avec frontmatter `origin.kind: url` + `origin.ref: <URL>` |
| Copier-coller | Sauver dans `sources/<scope>/notes/YYYY-MM-DD_<slug>.md` avec frontmatter `origin.kind: manual` |

`<slug>` = kebab-case ASCII dérivé du titre. Date = aujourd'hui (timezone locale).
`<type>` = `articles | pdfs | docs | transcripts | messages | notes | code` selon la nature.

### 3. Inférer le scope

Lire le contenu, identifier les indices : mention de WeValue, d'un client, d'une mission → `pro`. Sujet personnel, lecture, projet privé → `perso`. **Si ambigu → demander à l'utilisateur**.

### 4. Pour les binaires : créer la note compagnon

Si la source est un binaire (cf. liste dans `CLAUDE.md` § Règle des binaires), créer le fichier `.md` jumeau au même chemin (même `<slug>` + `.md`).

Frontmatter obligatoire :

```yaml
---
type: source
scope: pro | perso
source_kind: pdf | docx | pptx | xlsx | image | media | archive
source_file: ./<slug>.<ext-binaire>
origin:
  kind: url | email | slack | manual | filesystem
  ref: <URL | message-id | permalink-Slack | description>
hash_sha256: <hash>
ingested: YYYY-MM-DD
---
```

Calculer le hash via `sha256sum <fichier>` (Git Bash) ou `certutil -hashfile <fichier> SHA256` (Windows natif).

Demander à l'utilisateur l'**origine** (URL, message-id, "remis par X le Y") si non évidente.

Le corps de la note compagnon contient :
- titre extrait
- résumé (étape 5)
- métadonnées (auteur, date document, nombre de pages…)
- sections clés extraites

### 5. Extraire le contenu

Router vers le sous-agent adapté (skill du userspace) :

| Type | Sous-agent |
|---|---|
| PDF texte simple | `analyse-documents` |
| PDF complexe (tableaux, multi-colonnes) | `extraction-pdf` |
| DOCX | `extraction-docx` |
| PPTX | `extraction-docx` (gère aussi PPTX) |
| Profil LinkedIn | `extraction-linkedin` |
| Article web déjà en markdown | traitement direct (pas de sous-agent) |
| Texte / transcript / note | traitement direct |

### 6. Identifier les pages wiki cibles

Lire `wiki/index.md` pour repérer les entités existantes. Pour chaque entité/concept clé identifié dans la source :

- **Page existante** → MAJ in-place. Ajouter une section `## Notes d'ingestion <YYYY-MM-DD>` ou enrichir les sections existantes ; mettre à jour `updated:` dans le frontmatter ; ajouter le chemin de la source dans `sources:`.
- **Nouvelle entité** → créer la page sous `wiki/<scope>/<categorie>/<slug>.md` avec frontmatter complet (cf. `CLAUDE.md`).

Choix de la catégorie selon `type` :
- `concept` → `wiki/<scope>/concepts/`
- `client` → `wiki/pro/clients/` (organisation **client de WeValue**)
- `org` → `wiki/<scope>/orgs/` (autres organisations : employeur, partenaire, sous-traitant, écosystème)
- `mission` → `wiki/pro/missions/`
- `domaine` → `wiki/pro/domaines/`
- `personne` → `wiki/<scope>/personnes/`
- `projet` → `wiki/perso/projets/`
- `lecture` → `wiki/perso/lectures/`
- `veille` → `wiki/pro/veille/YYYY-MM_<theme>.md`
- `briefing` → `wiki/<scope>/briefings/YYYY-MM-DD.md` (en général produit par `secondbrain-morning-briefing`, pas par `ingest`)

**Convention slug** : pas de préfixe redondant avec le dossier (`workshop-ia-lba.md` plutôt que `mission-workshop-ia-lba.md`).

### 7. Mettre à jour `wiki/index.md`

Pour chaque page nouvellement créée, insérer la ligne `- [[slug]]` dans la section appropriée. Trier alphabétiquement à l'intérieur de chaque section. Mettre à jour `updated:` dans le frontmatter de `index.md`.

### 8. Append à `wiki/log.md`

Format :

```markdown
## YYYY-MM-DD — ingest: <pages-touchées-séparées-virgules> ← <chemin-source>

Brève description (1-2 lignes) si non triviale.
```

### 9. Lint léger des pages touchées

Pour chaque page créée ou modifiée :

- frontmatter complet (champs obligatoires : `type`, `scope`, `status`, `created`, `updated`)
- `updated >= created`
- wikilinks dans le corps pointent vers des fichiers existants
- entrées `related:` existent

Si un problème est détecté : signaler dans le retour final (sans bloquer l'ingestion).

### 10. Restituer à l'utilisateur

Bloc de synthèse :

```
✅ Ingestion terminée

Source : sources/<scope>/<type>/YYYY-MM-DD_<slug>.<ext>
Scope : <pro|perso>

Pages wiki :
- ✨ créées : [[<slug-page>]] (chemin)
- 🔁 mises à jour : [[<slug-page>]] (chemin)

Index : 1 entrée ajoutée dans <section>
Log : entrée datée ajoutée
Lint léger : OK | <N issues> (détails ci-dessous)

Suggestions :
- Tu pourrais documenter <X> qui apparaît mais n'a pas encore de page.
```

## Garde-fous

- **Source brute = immutable.** Ne jamais réécrire le contenu d'un fichier dans `sources/` après ingestion.
- **Scope ambigu** → demander avant d'écrire. Ne jamais "deviner" pour aller plus vite.
- **`sensitive: true`** → si la source touche un client / sujet sensible, alerter l'utilisateur et flagger les pages produites.
- **Git** : `git add` + `git commit` autonomes en fin d'ingestion (pas de push automatique en V1 — l'utilisateur push quand il veut).
