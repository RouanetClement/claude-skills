---
name: seo-content
description: >
  Optimisation SEO éditoriale d'articles et contenus web. Utiliser pour : intégrer
  des mots-clés naturellement, structurer un article pour Google, écrire un title tag
  et meta description, améliorer la lisibilité SEO. Synonymes : SEO, référencement,
  mots-clés, title tag, meta description, structure article SEO, search engine optimization,
  optimisation contenu, SERP, featured snippet.
---

# SEO Content

## Modèle cible

`claude-sonnet-4-6` — l'optimisation SEO exige jugement éditorial (pertinence sémantique, intention de recherche) et pas seulement de la transformation mécanique.

---

## Routing

### Cas 1 — Optimiser un article existant

**Déclencheur** : "optimise ce contenu pour le SEO", "intègre ces mots-clés", "améliore le title tag / meta description", "rends cet article plus lisible pour Google", "audit SEO on-page"

**Action** : charger `references/on-page-seo.md`

**Rationnel** : l'optimisation on-page est un travail de placement et de reformulation guidé par des règles précises — une seule référence suffit.

---

### Cas 2 — Recherche de mots-clés + structure d'article

**Déclencheur** : "trouve les mots-clés pour cet article", "structure un article SEO sur X", "plan d'article optimisé pour Google", "comment ranker sur [sujet]", "recherche de mots-clés sans outil payant"

**Action** : charger `references/on-page-seo.md` + `references/structure-seo.md`

**Rationnel** : la recherche de mots-clés et la structuration requièrent à la fois les règles on-page et la méthodologie de recherche / anatomie d'article.

---

## Protocole

### 1. Identifier le mot-clé principal et l'intention de recherche

Avant toute optimisation, confirmer :
- **Mot-clé principal** (1 seul) — celui sur lequel le contenu doit ranker
- **Intention** : informationnelle (apprendre), navigationnelle (trouver un site), transactionnelle (acheter/s'inscrire)
- **Mots-clés secondaires / LSI** (3-5) si disponibles

Si non fournis, proposer 3 options basées sur le contenu existant.

### 2. Appliquer les règles on-page

Charger `references/on-page-seo.md`. Ordre de priorité :
1. Title tag + H1 (impact le plus fort)
2. Premier paragraphe (indexation prioritaire)
3. Structure H2/H3 (crawlabilité + lisibilité)
4. Meta description (taux de clic)
5. Liens internes + alt text

### 3. Pour la recherche de mots-clés et la structure

Charger `references/structure-seo.md`. Suivre la méthode sans outil payant (Google Suggest, PAA, recherches associées).

### 4. Livrer avec explication minimale

Livrer les éléments optimisés directement. Mentionner brièvement le rationnel SEO uniquement si le changement n'est pas évident.
