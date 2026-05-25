# Sources Secteur Public FR — Défauts

RSS feeds, requêtes WebSearch et topics GitHub pour la veille secteur public français.
Surcharges via `~/.claude/veille-config.yaml` sous `themes.publique`.

## RSS Feeds

| URL | Description |
|---|---|
| `https://www.numerique.gouv.fr/actualites/feed/` | DINUM — numérique public France |
| `https://www.data.gouv.fr/fr/activity/rss/` | data.gouv.fr — données ouvertes |
| `https://www.ssi.gouv.fr/feed/` | ANSSI — cybersécurité France |
| `https://code.gouv.fr/rss.xml` | code.gouv.fr — logiciels libres État |
| `https://www.numerique.gouv.fr/publications/feed/` | DINUM publications et guides |

## WebSearch — Requêtes par défaut

Remplacer `{YYYY}` par l'année en cours.

```
"DINUM actualité {YYYY}"
"logiciel libre administration France {YYYY}"
"IA secteur public France {YYYY}"
"DSFR design system état nouveautés {YYYY}"
"interopérabilité données publiques {YYYY}"
"souveraineté numérique France {YYYY}"
"RGAA accessibilité numérique {YYYY}"
"cloud souverain administration France {YYYY}"
"commande publique numérique {YYYY}"
```

## GitHub Topics

```
etalab
dsfr
publiccode
french-government
open-data-france
socle-interministériel
```

Requête GitHub :
```
GET https://api.github.com/search/repositories
  ?q=topic:{topic}+pushed:>{DATE_LIMITE}
  &sort=stars&order=desc&per_page=5
```
Rate limit anonyme : 10 req/min. Espacer les appels de ~7s entre topics.

## Critères de pertinence

Sans `source_authority` dans la config, boost heuristique :

- Source ∈ {numerique.gouv.fr, data.gouv.fr, ssi.gouv.fr, code.gouv.fr} → +30%
- Mention de "DINUM", "DSFR", "Etalab", "ANSSI", "DINUM" → +20%
- Mention de "réglementation", "arrêté", "décret", "circulaire", "RGPD" → +15%
- Source en langue française → +5%
- Mention de "WeValue", "conseil", "DSI", "transformation numérique" → +10% (contexte métier)
