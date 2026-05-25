---
name: generation-cv-docx
description: >
  Génère un ou plusieurs CV au format DOCX depuis un profil YAML normalisé.
  Propose 4 templates : classique (corporate), moderne (bicolonne + photo opt.),
  minimaliste (ATS-safe), wevalue (à venir). Pour plusieurs templates, parallélise
  la génération via sous-agents (skill orchestration-agents). Requiert Python 3.x
  + python-docx (+ Pillow pour la photo).
---

# Génération de CV DOCX — Point d'entrée

## Modèle

**`claude-haiku-4-5`** par défaut — tâche mécanique : mapping YAML → python-docx.
**`claude-sonnet-4-6`** si le profil est incomplet et nécessite un jugement éditorial
sur les champs manquants ou le contenu à rédiger.

---

## Étape 1 — Sélection du ou des templates

Si les templates ne sont pas précisés dans la demande, afficher :

> "Quel(s) template(s) souhaitez-vous ? (sélection multiple possible)
> - **classique** : sobre, colonne unique, serif, idéal corporate / conseil / finance
> - **moderne** : bicolonne avec sidebar colorée + photo optionnelle, idéal tech / startup
> - **minimaliste** : noir & blanc, colonne unique, 100 % lisible par les ATS
> - **wevalue** : [en cours de développement — charte WeValue à venir]"

**Si WeValue est sélectionné** : afficher le message de `template-wevalue.md`
et demander de choisir parmi classique / moderne / minimaliste.
Si WeValue est sélectionné **parmi d'autres templates** : retirer WeValue de la sélection, afficher le message d'indisponibilité, et continuer avec les templates restants.

**Compagnon visuel** : si disponible dans la session, proposer de l'activer
pour afficher les aperçus de templates avant le choix.

Charger après sélection :
- `references/shared-patterns.md`
- `references/template-<nom>.md` pour chaque template retenu
- `references/infos-complementaires.md`

---

## Étape 2 — Collecte des infos complémentaires (une seule passe)

1. Lire dans `infos-complementaires.md` les sections de **tous** les templates sélectionnés
2. Calculer l'**union** des champs requis (dédupliqués — ex : `linkedin_url` n'est
   demandé qu'une fois même si classique et moderne sont tous deux sélectionnés)
3. Identifier les champs absents du profil YAML fourni
4. Poser les questions pour les champs manquants en **une seule passe**
   (en bloc si ≤ 3 champs, un par un si > 3)
5. Si `moderne` figure dans la sélection : demander si une photo doit être incluse ;
   si oui, demander le chemin absolu (`.jpg` ou `.png`)
6. Tout champ non fourni → valeur `None` → le bloc est omis dans le script (`if valeur:`)

---

## Étape 3 — Génération du ou des scripts Python

### Cas A — template unique

Générer directement `generer_cv_<template>.py` complet entre triple backticks ` ```python `.
Profil embarqué en dictionnaire Python (pas de lecture YAML externe).

### Cas B — templates multiples

Invoquer le skill `orchestration-agents` pour dispatcher un sous-agent par template
en parallèle. Chaque sous-agent reçoit :
- Le profil YAML complet (dictionnaire Python sérialisé)
- Les infos complémentaires collectées (linkedin_url, site_web, github_url, chemin_photo)
- Le template cible (une seule valeur par agent)
- Instruction : générer `generer_cv_<template>.py` selon `template-<template>.md`
- Le sous-agent invoque le skill `generation-cv-docx` en mode Cas A (template unique) — il reçoit un seul template et suit le routing normal depuis l'Étape 2

Afficher les scripts générés séquentiellement avec leurs instructions d'exécution.

### Règles communes

- Profil embarqué en dictionnaire Python (jamais de lecture YAML externe)
- `if valeur:` sur **tout** champ optionnel — ne jamais afficher un label sans valeur
- Photo (template `moderne`) : `python-docx` + `Pillow`, table 2 colonnes en en-tête
- Nom du fichier de sortie : `cv-<template>.docx`

---

## Étape 4 — Instructions d'exécution

Après chaque script généré, toujours indiquer :

```
pip install python-docx          # toujours requis
pip install Pillow               # uniquement pour le template moderne avec photo
python generer_cv_<template>.py
# Résultat : cv-<template>.docx dans le répertoire courant
# Pour convertir en PDF → skill generation-cv-pdf
```

---

## Ajouter un nouveau template

1. Créer `references/template-<nom>.md` en suivant la structure de `template-classique.md`
2. Ajouter une section `## <nom>` dans `references/infos-complementaires.md` (champs requis + règle photo)
3. Ajouter le template au menu de l'Étape 1 ci-dessus
