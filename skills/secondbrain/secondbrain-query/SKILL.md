---
name: secondbrain-query
description: Interroge le wiki SecondBrain. Lit index.md, identifie 3-7 pages candidates par catégorie/tags/concept proche, lit ces pages, descend dans sources/ uniquement si nécessaire, répond avec citations [chemin:ligne]. Mode --log pour append au journal (réponses traçables, "publiables"). Triggers : "query", "que sait-on sur", "cherche dans le wiki", "interroge le second brain".
---

# secondbrain-query

Interrogation du wiki SecondBrain.

## Quand l'invoquer

- Utilisateur demande : "que sait-on sur X ?", "qu'ai-je appris sur X ?", "trouve X dans le wiki"
- Mots-clés explicites : "query", "interroge le second brain", "cherche dans le wiki"
- Mode tracé : `/query --log "<question>"` ou phrase incluant "trace cette réponse au log"

## Modes

| Mode | Append à `log.md` | Quand |
|---|---|---|
| **conversational** (défaut) | Non | Question rapide, exploration |
| **traced** (`--log "question"`) | Oui | Réponse "publiable" qui doit être retraçable |

## Routine

### 1. Lire `wiki/index.md`

Parcourir les sections pour identifier les catégories pertinentes (Domaines, Clients, Missions, Concepts pro, Concepts perso, Projets, Lectures, Veille).

### 2. Identifier 3 à 7 pages candidates

Critères :
- match direct du mot-clé sur le slug ou le titre
- présence du concept dans `tags:`
- proximité sémantique (synonymes, sujets liés)
- pages `related:` des candidats directs (élargissement de proche en proche)

### 3. Lire les pages candidates

Lire le fichier complet (ou les 200 premières lignes si très long). Ne **pas** descendre dans `sources/` à ce stade.

### 4. Descendre dans `sources/` si nécessaire

Uniquement si la réponse reste incomplète. Suivre les liens `sources:` du frontmatter des pages lues à l'étape 3.

### 5. Synthétiser et répondre

Format :

```
**Réponse :**

<synthèse en 5-15 lignes, structurée>

**Sources :**

- [[slug-page-1]] (`wiki/<scope>/<categorie>/<slug-page-1>.md:<ligne>`)
- [[slug-page-2]] (`wiki/<scope>/<categorie>/<slug-page-2>.md:<ligne>`)
- (Source brute) `sources/<scope>/<type>/YYYY-MM-DD_<slug>.md:<ligne>` — si descendue à l'étape 4

**Pistes complémentaires :** <2-3 suggestions de pages à enrichir/créer si lacunes détectées>
```

### 6. Mode traced — append au log

Si invoqué avec `--log "<question>"`, append à `wiki/log.md` :

```markdown
## YYYY-MM-DD — query: <question>

<résumé de la réponse en 2-3 lignes>

Pages consultées : [[slug1]], [[slug2]], ...
```

## Principes

- **Privilégier le wiki** (L2) sur les sources brutes (L1). Le wiki = synthèse déjà compilée par Claude. Y descendre dans les sources, c'est un signal de lacune dans le wiki.
- **Citations obligatoires.** Chaque claim non trivial = un wikilink ou un chemin de source.
- **Honnête sur les lacunes.** Si l'info n'est pas dans le wiki → le dire, suggérer une `ingest`.
