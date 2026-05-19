---
name: veille-techno
description: Veille technologique automatisée sur 3 thèmes (IA, DevOps, Secteur public FR). Collecte parallèle via WebSearch, RSS feeds et GitHub API. Dépose les fichiers Markdown dans SecondBrain sources/inbox et déclenche l'ingestion via secondbrain-ingest. Config machine dans ~/.claude/veille-config.yaml. Triggers : "veille", "veille techno", "fais la veille", "actualités IA", "quoi de neuf en DevOps", "actu tech".
---

# veille-techno

Veille technologique orchestrée sur 3 thèmes avec dépôt automatique dans le SecondBrain.

## Quand l'invoquer

Triggers : *« veille »*, *« veille techno »*, *« fais la veille »*, *« actualités IA »*, *« quoi de neuf en DevOps »*, *« nouveautés secteur public »*, *« actu tech »*, *« quoi de neuf cette semaine »*.

## Invocations

```
/veille                        → 3 thèmes, horizon défaut (7j)
/veille --since 14d            → rattrapage 14 jours
/veille --since 2026-05-01     → depuis une date précise
/veille --theme ia             → thème IA uniquement
/veille --theme devops         → thème DevOps uniquement
/veille --theme publique       → thème secteur public FR uniquement
```

## Pipeline d'exécution

### Étape 0 — Configuration

1. Lire `~/.claude/veille-config.yaml` si présent.
   - `second_brain.inbox_path` : chemin absolu vers `sources/inbox/` du SecondBrain
   - `defaults.horizon_days` (défaut : 7), `defaults.items_per_theme` (défaut : 10)
   - `themes.{ia|devops|publique}.enabled` (défaut : true pour les 3)
   - `themes.{ia|devops|publique}.rss_feeds` / `github_topics` / `search_queries` (surcharges)
   - `themes.{ia|devops|publique}.source_authority` (boost de score optionnel)
2. Calculer `DATE_LIMITE` :
   - `--since 14d` → aujourd'hui − 14 jours
   - `--since 2026-05-01` → date explicite
   - défaut → aujourd'hui − `horizon_days`
3. Si `~/.claude/veille-config.yaml` est absent → utiliser les defaults dans `references/sources-*.md`.
   Afficher : "⚠️ Config absente — utilisation des defaults. Créez ~/.claude/veille-config.yaml pour personnaliser."

### Étape 1 — Dispatcher les sous-agents

Lancer **N sous-agents Sonnet en parallèle** (un par thème activé, ou un seul si `--theme`).

Chaque sous-agent reçoit :
- Le contenu de `references/sources-{theme}.md` (defaults)
- Les surcharges de la config YAML pour ce thème (si présentes)
- La `DATE_LIMITE` calculée
- Le `inbox_path` cible
- Le template de sortie de `references/output-template.md`

### Étape 2 — Chaque sous-agent (par thème)

```
a. Fusionner sources du fichier références + surcharges config YAML

b. WebSearch — pour chaque requête configurée :
     Remplacer {YYYY} par l'année en cours dans la requête
     Ajouter "after:DATE_LIMITE" si la syntaxe le permet
     Extraire : titre, URL, source (domaine), date publication, résumé 2-3 lignes

c. WebFetch RSS — pour chaque feed configuré :
     Récupérer le XML/Atom via WebFetch
     Parser : extraire <title>, <link>, <pubDate>/<published>, <description>/<summary>
     Garder uniquement les items publiés après DATE_LIMITE
     Fail-soft : si WebFetch échoue → logger l'erreur et continuer avec les autres feeds

d. WebFetch GitHub API — pour chaque topic configuré :
     GET https://api.github.com/search/repositories
       ?q=topic:{topic}+pushed:>{DATE_LIMITE}
       &sort=stars&order=desc&per_page=5
     Extraire : full_name, description, stargazers_count, pushed_at
     Fail-soft : rate limit ou erreur → logger et continuer

e. Déduplication URL au sein du thème :
     Construire un set d'URLs vues (normaliser : supprimer utm_*, trailing slash)
     En cas de doublon → garder la version la plus informative (résumé le plus long)
     Si source_authority configurée : appliquer boost de score avant tri

f. Trier par pertinence + récence
   Garder items_per_theme articles + 5 repos GitHub max

g. Écrire {inbox_path}/veille-{theme}-YYYY-MM-DD.md
   (cf. references/output-template.md pour le format exact)
   Section "## Erreurs de collecte" si des sources ont échoué
```

### Étape 3 — Ingestion SecondBrain

Pour chaque fichier créé à l'étape 2, invoquer `secondbrain-ingest` avec le chemin explicite :

```
Le frontmatter du fichier (scope: pro, origin.ref: veille-techno-skill, theme: {theme})
permet à secondbrain-ingest d'opérer sans questions interactives.
La page wiki de destination sera : wiki/pro/veille/YYYY-MM_{theme}.md
```

Note cross-thème : si un article apparaît dans plusieurs fichiers de veille (même URL normalisée),
`secondbrain-ingest` déduplique à l'ingestion via `origin.ref`.

### Étape 4 — Restitution

```
✅ Veille terminée — {DATE} (horizon : depuis {DATE_LIMITE})

📰 Thèmes collectés :
  · IA       : N articles, M repos GitHub  → veille-ia-YYYY-MM-DD.md
  · DevOps   : N articles, M repos GitHub  → veille-devops-YYYY-MM-DD.md
  · Publique : N articles, M repos GitHub  → veille-publique-YYYY-MM-DD.md

📥 Ingestion SecondBrain :
  · Fichiers déposés dans {inbox_path}
  · Pages wiki créées/mises à jour : [[veille/YYYY-MM_ia]], [[veille/YYYY-MM_devops]], ...

⚠️  Erreurs de collecte (le cas échéant) :
  · Feed https://... : timeout
  · GitHub topic X : rate limit

💡 Signaux notables de la semaine :
  <2-3 phrases de synthèse transversale>
```

## Références chargées par thème

| Thème | Fichier | Contenu |
|---|---|---|
| `ia` | `references/sources-ia.md` | Feeds RSS + requêtes + topics GitHub IA |
| `devops` | `references/sources-devops.md` | Feeds RSS + requêtes + topics GitHub DevOps |
| `publique` | `references/sources-publique.md` | Feeds RSS + requêtes + topics GitHub secteur public FR |
| (tous) | `references/output-template.md` | Frontmatter obligatoire + structure Markdown de sortie |

## Garde-fous

- **Ne jamais fabriquer** de contenu. Si une source est inaccessible → la lister dans "Erreurs de collecte", pas d'hallucination de son contenu.
- **inbox_path obligatoire** : si absent de la config et impossible à inférer → stopper et demander.
- **Fail-soft** : l'échec d'une source individuelle n'arrête pas le thème ; l'échec d'un thème n'arrête pas les autres.
- **secondbrain-ingest** doit être disponible (user-global via sync-to-claude.sh) pour l'étape 3.
