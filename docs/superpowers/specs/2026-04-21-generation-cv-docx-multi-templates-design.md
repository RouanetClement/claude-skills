# Design — generation-cv-docx multi-templates

**Date** : 2026-04-21
**Skill cible** : `skills/cv/generation-cv-docx/`
**Statut** : validé

---

## Contexte

Le skill `generation-cv-docx` existant génère un CV Word depuis un profil YAML normalisé, mais ne propose qu'un seul template hardcodé (en-tête centré, titres bleus). L'objectif est d'ajouter la sélection de templates multiples, la collecte d'informations complémentaires selon le template choisi, et une architecture extensible pour ajouter de nouveaux templates à l'avenir.

---

## Périmètre V1

- **4 templates** : Classique Corporate, Moderne Bicolonne, Minimaliste ATS-Safe, WeValue (stub)
- **Sélection multiple** : l'utilisateur peut demander 1 ou plusieurs templates en un seul run
- **Collecte des infos une seule fois** : union des champs requis par tous les templates sélectionnés, posée en une seule passe
- **Adaptation aux champs manquants** : un champ non fourni → le bloc est omis (pas de label vide)
- **Parallélisation** : si plusieurs templates, chaque génération est déléguée à un sous-agent indépendant (skill `orchestration-agents`)
- **Photo** : optionnelle, uniquement sur Moderne Bicolonne
- **PDF** : inchangé — `generation-cv-pdf` orchestre la conversion `.docx → PDF` via `docx2pdf`
- **WeValue** : placeholder prêt à recevoir la charte graphique (couleurs, police, logo) lors d'une prochaine itération

---

## Architecture des fichiers

```
skills/cv/generation-cv-docx/
├── SKILL.md                        ← modifié
└── references/
    ├── shared-patterns.md          ← renommé depuis python-docx-patterns.md
    ├── infos-complementaires.md    ← nouveau
    ├── template-classique.md       ← nouveau
    ├── template-moderne.md         ← nouveau
    ├── template-minimaliste.md     ← nouveau
    └── template-wevalue.md         ← nouveau (stub)
```

**Règle d'extensibilité** : ajouter un template = créer `references/template-<nom>.md` + ajouter une entrée dans `SKILL.md` (menu) et dans `infos-complementaires.md` (champs requis). Aucun autre fichier à modifier.

**Contrainte CI** : chaque fichier de référence ≤ 150 lignes. Les layouts complexes sont découpés si nécessaire.

---

## Routing SKILL.md

### Modèle
- `claude-haiku-4-5` par défaut (tâche mécanique : mapping YAML → python-docx)
- `claude-sonnet-4-6` si le profil est incomplet et nécessite un jugement éditorial sur les champs manquants

### Étape 1 — Sélection du ou des templates

Si les templates ne sont pas précisés dans la demande, afficher le menu (sélection multiple possible) :

```
Quel(s) template(s) souhaitez-vous ? (vous pouvez en choisir plusieurs)
- classique  : sobre, une colonne, serif, idéal corporate / conseil / finance
- moderne    : bicolonne avec sidebar colorée, idéal tech / startup / créatif
- minimaliste: noir & blanc, une colonne, 100 % lisible par les ATS
- wevalue    : [en cours de développement — charte WeValue à venir]
```

**Si WeValue est sélectionné** : informer l'utilisateur que ce template est en attente de la charte graphique, et lui demander de choisir un ou plusieurs autres templates en attendant.

**Compagnon visuel** : si disponible dans la session, proposer de l'activer pour afficher les aperçus des templates avant que l'utilisateur ne choisisse.

Charger après le choix :
- `references/shared-patterns.md`
- `references/template-<choix>.md` pour chaque template sélectionné
- `references/infos-complementaires.md`

### Étape 2 — Collecte des infos complémentaires (une seule passe)

1. Dans `infos-complementaires.md`, lire les sections de **tous** les templates sélectionnés
2. Calculer l'**union** des champs requis (dédupliqués)
3. Comparer avec ce qui est présent dans le profil YAML
4. Poser les questions pour les champs manquants **en une seule fois** (en bloc si ≤ 3, une par une si > 3)
5. Si `moderne` est parmi les templates : demander si une photo doit être incluse, et si oui, le chemin absolu du fichier image (`.jpg`, `.png`)
6. Un champ non fourni par l'utilisateur → valeur `None` → le bloc sera omis dans le script

### Étape 3 — Génération du ou des scripts Python

**Cas A — template unique :**
- Générer directement `generer_cv_<template>.py` entre triple backticks ` ```python `

**Cas B — templates multiples :**
- Invoquer le skill `orchestration-agents` pour dispatcher un sous-agent par template en parallèle
- Chaque sous-agent reçoit : le profil YAML complet + les infos complémentaires collectées + le template cible
- Chaque sous-agent génère son `generer_cv_<template>.py` indépendamment
- Une fois tous les scripts reçus, les afficher séquentiellement avec leurs instructions d'exécution respectives

**Règles communes :**
- Profil embarqué en dictionnaire Python (pas de lecture YAML externe)
- Blocs `if valeur:` pour **tout** champ optionnel — ne jamais afficher un label sans valeur
- Si photo (template `moderne`) : utiliser `python-docx` + `Pillow` (table 2 colonnes dans l'en-tête)
- Nom du fichier de sortie : `cv-<template>.docx`

### Étape 4 — Instructions d'exécution

```
pip install python-docx          # toujours
pip install Pillow               # uniquement si photo (template moderne)
python generer_cv_<template>.py
# Résultat : cv-<template>.docx dans le répertoire courant
# Pour convertir en PDF → skill generation-cv-pdf
```

---

## Structure des fichiers de référence templates

Chaque `template-<nom>.md` suit ce gabarit :

```markdown
# Template <Nom> — CV DOCX

## Caractéristiques visuelles
[mise en page, couleurs hex, police, photo oui/non + position]

## Infos complémentaires requises
[renvoi vers infos-complementaires.md]

## Preamble python-docx
[styles de page, marges, couleurs, polices]

## En-tête
[code python-docx : nom, titre, coordonnées]

## En-tête avec photo (si applicable)
[code avec Table 2 colonnes : photo gauche, infos droite]

## Sections du corps
[Expériences, Formation, Compétences, Langues, Certifications…]

## Sauvegarde
doc.save("cv-<template>.docx")
```

---

## Fichier infos-complementaires.md

```markdown
## classique
Champs à vérifier : linkedin_url, site_web
Photo : non

## moderne
Champs à vérifier : linkedin_url, site_web, github_url
Photo : oui (optionnelle — demander le chemin si absent du profil)

## minimaliste
Champs à vérifier : email, telephone, localisation (contact de base seulement)
Photo : non (incompatible ATS)

## wevalue
→ Stub — voir instructions dans template-wevalue.md
```

---

## Templates V1 — caractéristiques

| Template | Colonnes | Police | Couleur principale | Photo | Cible |
|---|---|---|---|---|---|
| classique | 1 | Georgia (serif) | Bleu ardoise `#2c3e50` | Non | Corporate, finance, conseil |
| moderne | 2 (sidebar 38%) | Arial/Helvetica | Vert `#2d6a4f` | Optionnelle | Tech, startup, créatif |
| minimaliste | 1 | Arial | Noir `#111111` | Non | Universel, compatible ATS |
| wevalue | TBD | TBD | TBD | TBD | Consulting WeValue |

---

## Ce qui ne change pas

- Le schéma d'entrée YAML (`normalisation-profil/references/schema.md`) — inchangé
- Le skill `generation-cv-pdf` — inchangé (continue d'orchestrer `.docx → PDF`)
- Les autres skills CV — inchangés

---

## Hors périmètre V1

- Template WeValue (stub uniquement — implémentation lors de la réception de la charte)
- Thème sombre
