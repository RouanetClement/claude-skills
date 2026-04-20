---
name: redaction-linkedin-post
description: >
  Rédaction de posts LinkedIn pour le feed (≤3000 caractères). Couvre : posts from scratch,
  adaptation d'articles en posts, storytelling professionnel, posts de veille. Synonymes :
  post LinkedIn, LinkedIn post, contenu LinkedIn, publication LinkedIn, post feed,
  rédaction LinkedIn, partager sur LinkedIn, post professionnel.
---

# Rédaction LinkedIn Post

## Modèle cible

`claude-sonnet-4-6` — un post LinkedIn efficace requiert jugement éditorial (ton, hook, dosage personnel/professionnel) et adaptation à l'algorithme du feed, pas de la génération mécanique.

---

## Routing

### Cas 1 — Post from scratch

**Déclencheur** : "écris un post LinkedIn sur X", "rédige un post LinkedIn", "crée du contenu LinkedIn", "aide-moi à poster sur LinkedIn", "post de veille LinkedIn"

**Action** : charger `references/format-post.md`

**Rationnel** : la structure d'un post LinkedIn (hook visible, corps court, CTA engageant) est régie par des contraintes algorithme + UX spécifiques à la plateforme.

---

### Cas 2 — Adapter un article / contenu long en post

**Déclencheur** : "transforme cet article en post LinkedIn", "adapte ce contenu pour LinkedIn", "résume cet article en post", "tire un post de cet article Medium"

**Action** : charger `references/format-post.md` + `references/adaptation.md`

**Rationnel** : la transformation article → post est un exercice de distillation et de changement de registre (structuré → conversationnel) qui nécessite un protocole dédié.

---

## Protocole

### 1. Clarifier si nécessaire

Pour un post from scratch, identifier en **1 seule question** si plusieurs points manquent :
- **Message central** : quelle est la 1 idée que le lecteur doit retenir ?
- **Angle** : expérience personnelle, opinion tranchée, partage de ressource, leçon apprise ?
- **Cible** : qui est l'audience LinkedIn visée ? (recruteurs, pairs, clients potentiels...)
- **Ton** : inspirant, direct, humoristique, pédagogique ?

Pour une adaptation d'article → le contenu source suffit, pas de question préalable sauf si l'angle post n'est pas clair.

### 2. Appliquer le format post LinkedIn

Charger `references/format-post.md`. Points critiques :
- Hook : **ligne 1 visible avant "voir plus"** — doit donner envie de déplier
- Pas de lien dans le corps du post (pénalité algorithmique)
- Longueur idéale : 1 000-1 500 caractères pour la meilleure portée
- CTA en fin de post : question ouverte ou invitation au partage

### 3. Pour les adaptations d'article

Charger `references/adaptation.md` et suivre le protocole en 5 étapes.

### 4. Publication

LinkedIn Posts n'a pas de MCP disponible — publication manuelle uniquement.
Consulter `references/format-post.md` section "Publication" pour le guide complet.
