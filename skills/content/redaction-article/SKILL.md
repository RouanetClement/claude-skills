---
name: redaction-article
description: >
  Rédaction et publication d'articles long-form pour Medium. Couvre tout le pipeline :
  angle éditorial, structure, rédaction, optimisation SEO, publication via MCP ou manuelle.
  Synonymes : article Medium, article de blog, long-form, contenu éditorial, rédaction article,
  publier sur Medium, écrire un article, publication Medium.
---

# Rédaction Article (Medium)

## Modèle cible

`claude-sonnet-4-6` — la rédaction long-form requiert jugement éditorial, cohérence de ton sur 1 500-2 500 mots, et orchestration de skills spécialisés.

---

## Routing

### Cas 1 — Écriture from scratch ou réécriture d'article

**Déclencheur** : "écris un article sur X", "rédige un article Medium", "aide-moi à écrire cet article", "améliore cet article", "réécris ce contenu en article long-form"

**Action** : charger `references/format-medium.md`

**Orchestration** :
- Pour les sections persuasives (intro, hook, CTA) → orchestrer le skill `copywriting`
- Pour l'optimisation SEO (title, mots-clés, structure) → orchestrer le skill `seo-content`

**Rationnel** : la structure Medium est spécifique (titre, subtitle, intro en 3 temps, pull quotes). Les dimensions persuasion et SEO sont couvertes par des skills dédiés — ne pas dupliquer.

---

### Cas 2 — Publication uniquement

**Déclencheur** : "publie cet article sur Medium", "comment publier sur Medium", "envoie cet article sur Medium", "crée un draft Medium"

**Action** : charger `references/publication-medium.md`

**Rationnel** : la publication est un workflow technique distinct de la rédaction. Pas besoin de charger le format.

---

### Cas 3 — Pipeline complet (rédaction + publication)

**Déclencheur** : "écris ET publie un article sur X", "pipeline complet Medium", "de l'idée à la publication"

**Action** : charger `references/format-medium.md` + `references/publication-medium.md`

**Orchestration** : même que Cas 1 pour la rédaction, puis Cas 2 pour la publication.

---

## Protocole

### 1. Clarifier l'angle et la cible

Avant de rédiger, identifier (en **1 seule question** si plusieurs points manquent) :
- **Sujet et angle** : quelle thèse défend cet article ? (pas juste le sujet général)
- **Cible** : qui lit ? (développeurs, managers, entrepreneurs, grand public ?)
- **Ton** : expert/pédagogique, opinionné, narratif, cas pratique ?
- **SEO** : article ciblant un mot-clé spécifique ou audience Medium uniquement ?

### 2. Structurer selon le format Medium

Appliquer `references/format-medium.md` — respecter l'anatomie (titre → subtitle → intro 3 temps → corps → conclusion + CTA).

### 3. Optimiser si SEO visé

Si l'article cible un mot-clé Google, orchestrer `seo-content` pour :
- Valider le title tag (≤60 chars, keyword en début)
- Intégrer les mots-clés secondaires dans les H2
- Vérifier la densité et la meta description

### 4. Renforcer les sections persuasives

Pour intro, hook et CTA, orchestrer `copywriting` — appliquer AIDA pour la structure globale, PAS ou BAB pour le hook d'intro.

### 5. Publier

Suivre `references/publication-medium.md` — chemin MCP si disponible, sinon chemin manuel.
