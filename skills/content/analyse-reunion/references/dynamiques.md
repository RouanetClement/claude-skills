# Dynamiques de groupe et patterns de communication

**Modèle requis : `claude-opus-4-6`** — ce fichier ne doit être chargé que pour des analyses comportementales profondes.

Objectif : analyser les dynamiques de groupe et les patterns de communication à partir du transcript, de manière factuelle et non jugeante.

---

## Axes d'analyse

### 1. Prise de parole
- Qui prend le plus de place (volume de texte, nombre d'interventions) ?
- Participants silencieux ou peu présents
- Présence d'un facilitateur ou animateur naturel
- Équilibre ou déséquilibre des prises de parole

### 2. Style de décision
| Style | Indicateurs dans le transcript |
|---|---|
| Consensuel | "On est d'accord ?", reformulations collectives, validation explicite |
| Directif | Une personne tranche sans solliciter le groupe |
| Sans décision claire | Sujet abordé, discussion, puis passage à autre chose sans conclusion |

### 3. Conflits et tensions
- Désaccords explicites : formulations directes de positions opposées
- Tensions implicites : reformulations défensives, "Oui, mais...", sujets rebroussés
- Évitement : sujets introduits puis écartés rapidement
- Résolution : le désaccord est-il résolu avant la fin de la réunion ?

### 4. Engagement
- Questions posées (curiosité, clarification, défi)
- Reformulations (compréhension active)
- Allers-retours : rebonds entre participants vs monologues successifs
- Signaux de désengagement : réponses courtes, absence de questions

### 5. Patterns négatifs
- Interruptions fréquentes (si visible dans le transcript)
- Monopolisation de la parole par un ou deux participants
- Sujets systématiquement évités ou court-circuités
- Décisions imposées sans espace de discussion

---

## Format de sortie

```
## Dynamiques observées

**Prise de parole** : [description factuelle — ex: "Marc représente ~60% des interventions"]
**Style de décision** : [consensuel / directif / absent — + exemple du transcript]
**Tensions** : [oui / non — si oui, description factuelle]
**Points d'attention** :
- [Pattern 1 observé]
- [Pattern 2 observé]

## Recommandations (si demandées)
[Suggestions concrètes, formulées comme options — pas comme injonctions]
```

---

## Analyse multi-réunions

Si plusieurs transcripts sont fournis (ex : plusieurs semaines de standup) :

1. Appliquer les axes ci-dessus à chaque réunion
2. Construire un tableau de tendances :

| Semaine | Prise de parole | Style décision | Tensions | Engagement |
|---|---|---|---|---|
| S1 | ... | ... | ... | ... |
| S2 | ... | ... | ... | ... |

3. Identifier :
   - Les patterns stables (récurrents sur toutes les réunions)
   - Les évolutions (amélioration ou dégradation)
   - Les blocages récurrents non résolus

---

## Précautions

- Formuler les observations de manière factuelle, ancrées dans le transcript
- Citer des extraits courts comme appui (`"[formulation exacte]"`)
- Ne pas inférer d'intentions ou d'états intérieurs non exprimés
- Éviter les jugements de valeur sur les personnes — analyser les comportements observés, pas les individus
- Si le transcript est trop court ou trop fragmentaire pour une analyse fiable, le signaler
