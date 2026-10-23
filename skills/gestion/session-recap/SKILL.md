---
name: session-recap
description: Génère un bilan structuré de la session Claude Code courante depuis le transcript JSONL. Deux modes — automatique (hook Stop, silencieux) et manuel (invocation directe /session-recap, "fais un bilan de session", "recap de session", avec suivi d'exécution visible). Extrait tâches, outils, skills, corrections utilisateur, profil d'usage et suggestions. Écrit un snapshot horodaté dans $SECONDBRAIN_PATH/wiki/sessions/.
---

# session-recap — Point d'entrée

Génère un bilan de session, en **deux modes d'invocation**. Ce SKILL.md est un routeur : exécuter la routine dans l'ordre en chargeant la référence indiquée à chaque étape.

## Étape 0 — Détecter le mode

| Mode | Déclencheur | Transcript | Sortie chat |
|---|---|---|---|
| **auto** | systemMessage du hook Stop contenant `Transcript path: <path>` | fourni dans le message | **silencieux** — aucun texte, sauf erreur d'écriture |
| **manuel** | invocation directe (`/session-recap`, « fais un bilan de session ») **sans** `Transcript path:` | à localiser | **suivi visible** — étapes + chemin du fichier produit |

**Règle** : message contient `Transcript path:` → `auto`. Sinon → `manuel`.

## Étape 1 — Pré-conditions

1. `$SECONDBRAIN_PATH` défini. Absent → auto : stopper silencieusement ; manuel : afficher `[session-recap] $SECONDBRAIN_PATH non défini` et stopper.
2. **Normaliser le chemin pour la plateforme courante.** `$SECONDBRAIN_PATH` peut être renseigné sous une forme non résoluble par l'outil `Write` :
   - forme WSL `/mnt/<lettre>/reste` → sur Windows natif, convertir en `<LETTRE>:/reste` (ex. `/mnt/c/Users/x` → `C:/Users/x`) ;
   - forme git-bash `/<lettre>/reste` → idem (`/c/Users/x` → `C:/Users/x`) ;
   - sur Linux/WSL, laisser le chemin tel quel.

   Vérifier que le chemin normalisé existe avant d'aller plus loin. Inexistant → auto : stopper silencieusement ; manuel : afficher `[session-recap] Vault introuvable : <chemin normalisé>` et stopper. Toutes les étapes suivantes utilisent **le chemin normalisé**.
3. Créer `<vault>/wiki/sessions/` si absent.
4. Transcript introuvable/illisible → auto : stopper silencieusement ; manuel : signaler l'erreur et stopper.

## Étape 2 — Router par phase

Exécuter les phases dans l'ordre ; charger chaque référence au moment de la phase.

| Phase | Action | Référence |
|---|---|---|
| A | Obtenir le transcript (localisation en mode manuel) + extraction **ciblée** (jamais un `Read` intégral) + repérage des sous-agents | `references/extraction.md` |
| B | Identifier le type de session, puis extraire les 7 dimensions d'analyse | `references/dimensions.md` |
| C | Construire le frontmatter YAML + le corps Markdown, puis écrire le fichier | `references/output.md` |

## Règle universelle

- **Mode auto** : silence total dans le chat pendant toutes les phases ; seule exception, l'erreur d'écriture (`[session-recap] Erreur d'écriture : <message>`).
- **Mode manuel** : restituer un suivi lisible de chaque phase et, en fin de course, le chemin du bilan produit.
