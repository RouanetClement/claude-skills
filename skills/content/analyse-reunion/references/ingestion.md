# Ingestion — Formats d'entrée

Objectif : normaliser le contenu d'une réunion avant toute analyse, quel que soit le format source.

---

## Texte brut / Markdown

Normalisation minimale :
- Supprimer les espaces multiples et les lignes vides consécutives (> 2)
- Conserver les sauts de section naturels (ligne vide simple)
- Détecter et conserver les noms de participants si présents

Aucune transformation structurelle — le texte est prêt pour l'analyse.

---

## DOCX

Protocole d'extraction :
1. Extraire le texte structuré en préservant les niveaux de titres (H1, H2, H3)
2. Les titres deviennent des séparateurs de section dans le texte normalisé
3. Les tableaux : convertir en Markdown (`| col | col |`)
4. Les listes : conserver sous forme de puces Markdown
5. Ignorer les métadonnées de mise en forme (police, couleur, taille)

Résultat attendu : Markdown structuré, titres conservés, contenu fidèle.

---

## PPT / Présentation

Protocole d'extraction :
- Chaque slide = une section numérotée (`## Slide N — Titre`)
- Texte du slide = contenu principal de la section
- Notes du slide = contexte additionnel, indiqué entre `> [Note: ...]`
- Ignorer les éléments purement visuels (images sans légende, formes décoratives)

Exemple de sortie :
```
## Slide 3 — Bilan Q1
- CA : +12% vs Q4
- Taux de satisfaction : 87%
> [Note: À détailler avec l'équipe commerciale en séance]
```

---

## VTT / SRT (transcripts avec timestamps)

Protocole :
1. Supprimer tous les timestamps (`00:01:23,456 --> 00:01:27,890`)
2. Supprimer les numéros de séquence (lignes numériques seules)
3. Conserver les speaker labels si présents (`SPEAKER_01:`, `Marie:`)
4. Fusionner les segments consécutifs du même speaker en un seul paragraphe
5. Conserver une ligne vide entre changements de locuteur

Exemple avant/après :
```
# Avant (VTT)
1
00:00:05,000 --> 00:00:08,000
Marie: Bonjour à tous.

2
00:00:08,500 --> 00:00:12,000
Marie: On commence par le point budget.

# Après
Marie: Bonjour à tous. On commence par le point budget.
```

---

## Format inconnu

Si le format n'est pas identifiable :
1. Ne pas tenter d'extraction hasardeuse
2. Demander à l'utilisateur : "Pouvez-vous coller le texte brut du transcript ?"
3. Si l'utilisateur fournit un fichier inaccessible : préciser les formats supportés

---

## Ajouter un nouveau format

Pour étendre la prise en charge à un nouveau format (ex. Zoom JSON, Teams transcript) :
1. Identifier le schéma d'extraction : quels champs contiennent le texte, les speakers, les timestamps
2. Documenter le mapping vers la structure normalisée (texte + speaker labels)
3. Tester sur un exemple réel avant d'ajouter au protocole
