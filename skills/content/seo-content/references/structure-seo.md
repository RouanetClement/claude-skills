# Structure SEO — Recherche de mots-clés et anatomie d'article

## Anatomie d'un article optimisé

```
H1 (keyword principal)
├── Intro (≤100 mots) — keyword en premier paragraphe, promesse + accroche
│
├── H2 Section 1 (keyword secondaire ou variante)
│   └── Contenu + liste ou exemple si possible
│
├── H2 Section 2
│   └── Contenu
│
├── ... (H2 tous les 250-300 mots)
│
└── Conclusion (≤150 mots)
    ├── Résumé en 2-3 points
    └── CTA clair (télécharger, commenter, partager, contacter)
```

**Règles structurelles :**
- Pas de H1 dans le corps (le titre de l'article EST le H1)
- H2 pour les sections principales, H3 pour les sous-points
- Intro : ne pas reprendre le title mot pour mot — paraphraser avec keyword

---

## Recherche de mots-clés sans outil payant

### Google Suggest
1. Taper le sujet dans Google sans valider
2. Noter les suggestions de complétion automatique
3. Taper le sujet + espace + lettre (a, b, c...) pour des variantes

### People Also Ask (PAA)
- Cliquer sur un résultat → revenir aux SERPs → noter les questions PAA
- Ces questions = sujets de H2 potentiels + bases de featured snippets

### Recherches associées
- Bas de page Google → "Recherches associées" : 8 suggestions de mots-clés proches
- Idéal pour mots-clés LSI (Latent Semantic Indexing)

### AnswerThePublic (version gratuite)
- Génère les questions + prépositions autour d'un mot-clé
- Limité à quelques recherches/jour en version gratuite

---

## Keyword principal vs mots-clés secondaires

| Type | Rôle | Placement |
|---|---|---|
| **Keyword principal** (1 seul) | Intention principale — le terme pour lequel ranker | H1, intro, 1 H2, conclusion |
| **Mots-clés secondaires** (3-5) | Variantes sémantiques, questions liées | H2, corps du texte |
| **LSI / longue traîne** | Enrichissement sémantique, réponses aux PAA | H3, paragraphes de détail |

---

## Featured Snippet Optimization

Google extrait un bloc réponse en position 0 pour les requêtes en "comment", "qu'est-ce que", "pourquoi".

**Pour cibler un featured snippet :**
1. Identifier une question PAA correspondant à un H2 de l'article
2. Juste après le H2, répondre à la question en ≤50 mots (réponse directe)
3. Format liste (puces ou numérotée) ou définition selon le type de question
4. Puis développer la réponse dans les paragraphes suivants

**Exemple de structure :**
```markdown
## Comment intégrer des mots-clés naturellement ?

Intégrer un mot-clé naturellement consiste à le placer dans les
zones prioritaires (titre, intro, H2) avec une densité de 1-2 %,
en variant les formes (synonymes, dérivés) pour éviter la répétition.

[Suite de l'explication en détail...]
```

---

## Longueur optimale selon l'intention

| Type d'article | Longueur recommandée | Rationnel |
|---|---|---|
| Informatif / tutoriel | 1 500-2 500 mots | Couvrir le sujet en profondeur, signaux E-E-A-T |
| Comparatif / versus | 2 000-3 000 mots | Multiple angles, tableaux, sections par critère |
| Définition / glossaire | 800-1 200 mots | Réponse précise, featured snippet prioritaire |
| Listicle (top N) | 1 200-2 000 mots | Chaque item développé, éviter les listes creuses |

---

## Schema Markup Article (JSON-LD minimal)

À insérer dans le `<head>` de la page pour les rich results :

```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Titre de l'article (≤110 chars)",
  "author": {
    "@type": "Person",
    "name": "Prénom Nom"
  },
  "datePublished": "2026-04-20",
  "dateModified": "2026-04-20",
  "description": "Meta description de l'article"
}
```
