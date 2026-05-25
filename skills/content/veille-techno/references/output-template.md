# Template de sortie — Fichier de veille

Format des fichiers `veille-{theme}-YYYY-MM-DD.md` déposés dans `sources/inbox/`.

## Frontmatter obligatoire

```yaml
---
type: source
scope: pro
source_kind: note
theme: ia          # ia | devops | publique
origin:
  kind: manual
  ref: veille-techno-skill
ingested: YYYY-MM-DD
---
```

Ce frontmatter permet à `secondbrain-ingest` d'inférer automatiquement :
- `scope: pro` → pas de question sur le périmètre
- `origin.ref: veille-techno-skill` → traçabilité + dédup cross-thème
- `theme: {ia|devops|publique}` → page wiki cible = `wiki/pro/veille/YYYY-MM_{theme}.md`

## Structure du corps

```markdown
# Veille {IA|DevOps|Secteur public FR} — YYYY-MM-DD

Horizon : du YYYY-MM-DD au YYYY-MM-DD (N jours)

## Articles & actualités

- **[Titre article](url)** · domaine-source.com · YYYY-MM-DD
  Résumé en 2-3 lignes. Ce qui est notable / pourquoi ça compte.

- **[Titre article 2](url)** · domaine-source.com · YYYY-MM-DD
  Résumé.

## GitHub — Repos tendance

- **org/repo** — description courte (⭐ N stars, poussé le YYYY-MM-DD)

## Synthèse

Tendances et signaux faibles détectés sur la période.
2-4 phrases de prose. Pas de liste.

## Erreurs de collecte

- Feed `https://...` : [raison de l'échec]
- GitHub topic `X` : rate limit atteint
```

Section "Erreurs de collecte" omise si aucune erreur.

## Nommage du fichier

```
{inbox_path}/veille-{theme}-YYYY-MM-DD.md

  theme ∈ {ia, devops, publique}
  date  = date d'exécution du skill (timezone locale, format YYYY-MM-DD)
```

## Règles de rédaction

- Les titres d'articles doivent être en français si la source est FR, sinon en langue originale.
- Les résumés sont toujours en français (traduits si source anglophone).
- Les URLs sont copiées telles quelles (pas de raccourcissement).
- Maximum `items_per_theme` articles (config, défaut : 10) + 5 repos GitHub.
- Ne jamais inventer de contenu. Si un feed est vide sur la période → "Aucun article sur la période."
