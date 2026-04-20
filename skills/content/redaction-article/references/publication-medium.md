# Publication Medium — MCP et fallback manuel

## Chemin primaire — MCP `medium` (si disponible)

### Vérification de disponibilité
Avant de tenter la publication MCP, vérifier :
1. Le MCP `medium` est listé dans les outils disponibles de la session
2. Un appel de test ne retourne pas d'erreur de connexion
3. Si indisponible ou erreur → basculer immédiatement sur le **Chemin fallback manuel**

### Workflow avec MCP

**Étape 1 — Créer le draft**
```
Outil : medium.create_post (ou équivalent selon l'implémentation)
Paramètres :
  - title : titre de l'article
  - content : contenu Markdown complet
  - status : "draft" (recommandé — toujours réviser avant publication)
```

**Étape 2 — Ajouter les tags**
- Maximum 5 tags par article
- Choisir les tags les plus populaires dans la niche :

| Niche | Tags recommandés |
|---|---|
| Tech / Dev | `programming`, `software-development`, `javascript`, `python`, `web-development` |
| Carrière | `career`, `productivity`, `leadership`, `self-improvement`, `work` |
| Business | `entrepreneurship`, `startup`, `marketing`, `business`, `strategy` |
| IA / Data | `artificial-intelligence`, `machine-learning`, `data-science`, `chatgpt` |
| Écriture | `writing`, `content-marketing`, `blogging`, `storytelling`, `medium` |

**Étape 3 — Options de publication**
- `status: "draft"` → article en brouillon, révision manuelle requise avant publication
- `status: "public"` → publication immédiate
- Recommandation : toujours créer en draft et relire sur l'interface Medium avant publication finale

---

## Chemin fallback — Manuel

À utiliser si : MCP `medium` absent de la session, non connecté, erreur d'authentification, ou demande explicite de l'utilisateur.

### Conversion Markdown → Medium

| Markdown | Medium |
|---|---|
| `# Titre` | Ne pas inclure dans le corps — c'est le titre de l'article |
| `## Section` | H2 dans l'éditeur Medium |
| `**gras**` | Gras natif Medium |
| `*italique*` | Italique natif Medium |
| `` `code inline` `` | Code inline Medium |
| Bloc de code (` ``` `) | Bloc de code Medium (avec coloration syntaxique) |
| `> citation` | Citation Medium (pull quote) |
| `---` | Séparateur horizontal |

### Étapes de publication manuelle

1. **Ouvrir** medium.com → "Write a story"
2. **Coller** le titre dans le champ titre (en haut, grand)
3. **Coller** le corps dans l'éditeur — vérifier que la mise en forme est correcte
4. **Image de couverture** : ajouter via le menu "+" → "Image" en début d'article
5. **Tags** : bouton "Tags" dans la barre de publication → ajouter 5 tags (cf. tableau ci-dessus)
6. **Audience** : choisir entre "Followers" ou "Public" (tous les lecteurs Medium)
7. **Publication** : "Publish now" ou planifier via "Schedule"

### Canonical URL (si article cross-posté)

Si l'article existe déjà sur un autre site (blog personnel, Substack, etc.) :
- Medium → "..." (trois points) → "Advanced settings" → "Set canonical link"
- Entrer l'URL originale pour éviter le duplicate content SEO

---

## Notes importantes

- **Medium Partner Program** : les articles publiés en "public" sont éligibles aux revenus MPP si le compte est enregistré
- **Séries** : regrouper des articles liés dans une "Series" Medium pour améliorer la découvrabilité
- **Mise en avant dans des publications** : soumettre à des publications Medium actives (ex: Towards Data Science, Better Programming) pour une portée élargie
