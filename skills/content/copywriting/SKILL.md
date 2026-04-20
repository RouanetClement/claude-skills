---
name: copywriting
description: >
  Rédaction persuasive et frameworks de conversion. Utiliser pour : écrire un email
  de vente, un CTA, une landing page, un accroche, une intro percutante. Synonymes :
  copywriting, persuasion, conversion, AIDA, PAS, Before-After-Bridge, texte qui convertit,
  rédaction commerciale, texte persuasif, accroche, pitch écrit.
---

# Copywriting

## Modèle cible

`claude-sonnet-4-6` — la rédaction persuasive exige du jugement éditorial et de la créativité contextuelle, pas seulement de la génération mécanique.

---

## Routing

### Cas 1 — Rédaction persuasive (from scratch ou réécriture)

**Déclencheur** : "écris un email de vente", "rédige un CTA", "crée une accroche", "améliore cette intro", "écris une landing page", "rends ce texte plus percutant"

**Action** : charger `references/frameworks.md`

**Rationnel** : Sonnet suffit — il s'agit d'appliquer des frameworks structurés (AIDA, PAS, BAB, FAB) à un brief donné. Pas de jugement architectural complexe.

---

### Cas 2 — Analyse / critique d'un texte existant

**Déclencheur** : "analyse ce texte persuasif", "que vaut ce copywriting ?", "identifie les faiblesses de cette page", "audit de ce message de vente", "diagnostic de conversion"

**Action** : charger `references/frameworks.md` + `references/anti-patterns.md`

**Rationnel** : l'analyse requiert à la fois les standards de qualité (frameworks) et les patterns d'échec (anti-patterns) pour un diagnostic complet.

---

## Protocole

### 1. Clarifier le contexte minimal

Avant de produire, identifier (en **1 seule question** si plusieurs points manquent) :
- **Cible** : qui lit ce texte ? (client B2B, grand public, décideur...)
- **Objectif de conversion** : cliquer, acheter, s'inscrire, rappeler, lire la suite ?
- **Ton** : urgence, confiance, aspiration, résolution de problème ?
- **Contrainte de format** : longueur, plateforme, support ?

### 2. Choisir le framework adapté

Consulter `references/frameworks.md` — le framework est sélectionné selon l'intensité du pain point et le stade du funnel (voir section "Choisir entre frameworks").

### 3. Produire sans sur-expliquer

Livrer le texte directement. Si plusieurs approches sont viables, proposer 2 versions courtes avec label du framework utilisé.

### 4. Pour une analyse/critique

Appliquer la checklist de relecture de `references/anti-patterns.md` + vérifier l'alignement avec les frameworks de `references/frameworks.md`. Conclure par 3 recommandations prioritaires.
