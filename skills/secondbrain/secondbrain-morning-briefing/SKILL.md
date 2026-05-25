---
name: secondbrain-morning-briefing
description: Briefing matinal personnalisé d'un Valuer WeValue, **adapté au vault SecondBrain** : remplace la mémoire YAML par le wiki Obsidian comme source ET destination du briefing. Lit les pages personnes/missions/orgs/clients pour enrichir le contexte (croisement contacts ↔ wiki), produit le briefing dans `wiki/<scope>/briefings/YYYY-MM-DD.md`, append au log, MAJ état dans `_state.md` et missions actives. Quatre sources Email/Slack/Notion/Calendrier (pro WeValue) + optionnellement Gmail/Calendar perso si branchés. Quatre modes : COMPLET / INCRÉMENTAL / RATTRAPAGE / RAFRAÎCHISSEMENT. Scoring adaptatif. Triggers : "briefing", "morning briefing", "briefing matinal", "quoi de neuf", "qu'est-ce que j'ai raté", "rattraper mes messages", "faire le point", "résumé matinal", "ma journée", "what did I miss", "daily briefing", "recap".
---

# secondbrain-morning-briefing

Briefing matinal d'un Valuer WeValue, **adossé au vault SecondBrain**. Ce skill est une adaptation du `morning-briefing` v8.2 (plugin `anthropic-skills:morning-briefing`) : il en reprend la philosophie de scoring et la structure de sortie, mais **remplace la mémoire YAML par le vault Obsidian**.

## Principe directeur

**Le vault SecondBrain est la mémoire du briefing.**

1. **En entrée** : le skill lit le wiki pour avoir le contexte métier (qui est qui, quelles missions sont actives, quels concepts/orgs/personnes en jeu) et l'état opérationnel.
2. **En sortie** : le skill écrit dans le wiki (briefing du jour, MAJ missions, append log, MAJ `_state.md`) — pas dans un YAML opaque.

Conséquence : le contexte du briefing s'enrichit naturellement à chaque ingestion (un nouvel client/personne ingéré via `/secondbrain-ingest` est immédiatement reconnu dans le prochain briefing).

## Quand l'invoquer

Triggers : *« briefing »*, *« morning briefing »*, *« briefing matinal »*, *« briefing du matin »*, *« synthèse du matin »*, *« quoi de neuf »*, *« qu'est-ce que j'ai raté »*, *« rattraper mes messages »*, *« faire le point »*, *« point du matin »*, *« résumé des messages »*, *« what did I miss »*, *« catch up »*, *« daily digest »*, *« daily briefing »*, *« recap »*, *« récap »*, *« mon programme »*, *« ma journée »*.

---

## Étape 0 — Charger l'état depuis le wiki

### 0.1 Lire l'état opérationnel

```
Lire : wiki/pro/briefings/_state.md
```

Parser le frontmatter YAML. Tous les champs équivalents à la mémoire YAML du skill original s'y trouvent : `utilisateur`, `preferences_utilisateur`, `scoring_adjustments`, `documents_suivis`, `sujets_en_cours`, `rappels`, `curseurs`, `dernier_briefing`.

**Si le frontmatter est absent / vide** → mode COMPLET (1ᵉʳ briefing), peupler au fil de la collecte.

### 0.2 Lire l'état perso (si configuré)

```
Lire : wiki/perso/briefings/_state.md
```

Si `sources_branchees.gmail_perso = true` ou `.calendar_perso = true` → activer la collecte perso en parallèle. Sinon → skip (pas de briefing perso aujourd'hui).

### 0.3 Charger le dernier briefing pour la continuité

```
Si dernier_briefing.fichier ≠ null :
  Lire : wiki/pro/briefings/<dernier-briefing>.md
  Extraire les sections "À traiter / À suivre / À noter" pour comparer.
  → permet de calculer la progression (items résolus / encore présents).
```

### 0.4 Charger le contexte métier du wiki

**C'est la grande nouveauté par rapport au skill original.** Le briefing s'appuie sur le wiki pour :

1. **Lire `wiki/index.md`** → vue d'ensemble des entités existantes
2. **Lister les missions actives** :
   ```
   find wiki/pro/missions/ -name "*.md" | xargs grep -l "^status: active"
   ```
   Pour chacune : extraire le titre, les `related:`, les sujets clés mentionnés en H2/H3. Ces missions deviennent des **anchors de scoring** : tout email/message qui les touche reçoit un bonus.
3. **Indexer les pages `personnes`** :
   ```
   find wiki/pro/personnes/ wiki/perso/personnes/ -name "*.md"
   ```
   Pour chaque page, extraire l'email pro et le nom (via frontmatter ou body). Construire un dictionnaire `{email: slug_personne}` pour le croisement contact → wiki.
4. **Indexer `clients/` et `orgs/`** :
   ```
   find wiki/pro/clients/ wiki/pro/orgs/ -name "*.md"
   ```
   Pour reconnaître les domaines email (`@ssi.gouv.fr` → [[anssi]], `@atos.net` → [[atos]], `@wevalue.consulting` → [[wevalue]], etc.).

### 0.5 Identifier l'utilisateur

Si `utilisateur.user_id_slack` est vide dans `_state.md` :
```
slack_read_user_profile  → récupérer nom, display_name, user_id, timezone
```
Mettre à jour le frontmatter de `_state.md`.

### 0.6 Déterminer le mode de recherche

Même logique que le skill original (cf. `anthropic-skills:morning-briefing` §0.3) :

| Condition | Mode |
|---|---|
| `dernier_briefing.status` ∈ {partiel, erreur} | COMPLET (forcer) |
| Pas de `dernier_briefing` OU > 7 jours | RATTRAPAGE |
| Entre 3 et 7 jours | COMPLET |
| Hier ou avant-hier | INCRÉMENTAL ⭐ (mode privilégié) |
| Aujourd'hui (briefing déjà fait) | RAFRAÎCHISSEMENT |

### 0.7 Contexte temporel

Récupérer l'heure actuelle. Adapter le greeting (Bonjour / Hello / Voici la suite / Petit point de fin de journée / Bon week-end), comme dans le skill original (§0.4).

---

## Étape 1 — Configuration filtrage & scoring

Identique au skill original (§1.1 à 1.5) :
- Valeurs par défaut Slack/Email/Notion/Calendrier
- Barème de scoring 0-10 (mention +3, urgent +3, non lu +2, multi-source +2, sujet en cours +2, etc.)
- Classification : Score ≥5 → 🔴 À TRAITER, 3-4 → 📋 À SUIVRE, 1-2 → 💡 À NOTER, ≤0 → EXCLURE
- Déduplication conversations Slack + regroupement emails RE:/FW:

### 1.6 Bonus de scoring "wiki match" (nouveau)

```
Pour chaque item collecté :
  Pour chaque email/personne du contact principal :
    Si l'email match le dictionnaire {email: slug_personne} construit à l'étape 0.4 :
      → +1 (contact identifié dans le wiki)
    Si la personne est reliée à une mission active (related: dans la page mission) :
      → +2 (sujet actif sur mission)
  Pour chaque domaine email :
    Si match avec un client/org du wiki :
      → +1 (contexte org identifié)
```

Avantage : le briefing prioritise automatiquement les items liés aux missions actives, sans configuration manuelle.

---

## Étape 2 — Collecte des données

Identique au skill original (§2.1 à 2.6) selon le mode :

- **COMPLET** : 4 sources, fenêtre 5 jours, pagination 2x sur Slack `to:me`
- **INCRÉMENTAL** : fenêtre depuis curseurs, 1 page Slack
- **RATTRAPAGE** : fenêtre 10 jours, filtrage agressif post-collecte
- **RAFRAÎCHISSEMENT** : assemblage depuis le briefing du matin + delta minimal

Outils utilisés (MCP) :
- `slack_search_public_and_private`, `slack_read_channel`, `slack_read_thread`, `slack_read_user_profile`
- `outlook_email_search`, `outlook_calendar_search`
- `notion-search` (avec skip intelligent si `notion_last_success` > 14j)
- Si perso activé : équivalents Gmail / Google Calendar

⚠️ **Séparation pro/perso** : ne JAMAIS mélanger les sources WeValue avec Gmail/Calendar perso dans le même briefing. Les deux briefings sont produits en parallèle dans `wiki/pro/briefings/` et `wiki/perso/briefings/`.

---

## Étape 3 — Croisement et enrichissement par le wiki (nouveau)

Pour chaque item scoré :

1. **Enrichir le résumé avec le contexte wiki** :
   - Si l'expéditeur a une page personne → préfixer le résumé avec le rôle/org. Ex. *« Email de Grégoire Molveau (Chef du BAE ANSSI, mission [[cert-anssi]]) »* au lieu de *« Email de gregoire.molveau@ssi.gouv.fr »*.
   - Si un mot-clé matche une mission active → ajouter le wikilink `[[mission-slug]]`.
   - Si un concept apparaît (ex. "boussole IA", "DSFR") → wikilink `[[concept-slug]]`.

2. **Détecter les sujets-mission** :
   - Items rattachés à une mission active → grouper sous une sous-section dédiée *« 📍 Mission [[<slug>]] »* dans la section À TRAITER ou À SUIVRE.
   - Items orphelins (pas rattachés à une mission) → section normale.

3. **Détecter les MAJ de page à proposer** :
   - Nouveau contact email/Slack avec un domaine org existant → suggestion *« créer page personne via /secondbrain-ingest »*.
   - Document partagé sur une mission active → suggestion *« ajouter à sources: de la page mission »*.
   - Information factuelle sur une page existante → suggestion de MAJ ciblée.

---

## Étape 4 — Produire le briefing dans `wiki/<scope>/briefings/YYYY-MM-DD.md`

### 4.1 Frontmatter

```yaml
---
type: briefing
scope: pro    # ou perso
status: active
sensitive: true
mode: complet | incremental | rattrapage | rafraichissement
heure_briefing: HH:MM
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources:
  - sources/... (si une source précise du jour a été générée par /ingest)
related:
  - "[[<mission-1>]]"      # missions touchées par le briefing
  - "[[<mission-2>]]"
items_a_traiter: <N>
items_a_suivre: <X>
items_a_noter: <Y>
reunions_jour: <Z>
---
```

### 4.2 Corps du briefing

Structure identique à la sortie du skill original :

```markdown
# Briefing matinal — YYYY-MM-DD

<Greeting contextuel selon l'heure>

## 📅 Ta journée

<calendrier du jour, conflits ⚠️, invitations en attente ⏰>

## 🔴 À traiter (<N> items)

<items score ≥ 5, groupés par mission active si applicable>

### 📍 Mission [[<slug>]]

<sous-items rattachés>

## 📋 À suivre (<X> items)

<items score 3-4>

## 💡 À noter (<Y> items)

<items score 1-2, condensés>

## 📊 Continuité depuis le briefing du <hier>

- ✅ Résolus : <items du dernier briefing qui ont reçu une réponse ou été traités>
- 🔁 Encore présents : <items du dernier briefing toujours actifs>
- 🆕 Nouveaux : <items apparus depuis>

## 💡 Suggestions d'enrichissement du wiki

<MAJ proposées détectées à l'étape 3>

## 💪 <Phrase motivante adaptée à la journée et au contexte WeValue>
```

### 4.3 MAJ automatique du wiki (Q4 = automatique)

**Sans demander confirmation** (mode automatique validé) :

1. **Append à `wiki/log.md`** :
   ```markdown
   ## YYYY-MM-DD — briefing: mode <mode>, <N> à traiter, <X> à suivre, <Y> à noter

   Rapport : `wiki/pro/briefings/YYYY-MM-DD.md`
   Missions touchées : [[<slug-1>]], [[<slug-2>]]
   ```

2. **MAJ `wiki/pro/briefings/_state.md` frontmatter** :
   - `dernier_briefing.date`, `.status`, `.mode`, `.fichier`
   - `curseurs.email_recu_plus_recent`, etc. (datetimes les plus récentes vues)
   - `scoring_adjustments` (apprentissage des contacts vus / ignorés)
   - `documents_suivis` (nouveaux docs en circulation détectés)
   - `sujets_en_cours` (synthèse 1-2 phrases des threads importants pour éviter de les re-lire au prochain briefing)
   - `rappels` (items 🔴 non résolus, snapshot pour le prochain briefing)

3. **MAJ ciblées des pages mission active** :
   - Si un sujet identifié comme appartenant à une mission a un développement significatif (score ≥ 5, contenu actionnable) → ajouter une ligne sous une section `## Notes du <YYYY-MM-DD>` (créée si absente) de la page mission.
   - Format de ligne : `- <date HH:MM> — [<source>] <résumé en 1 ligne> → [briefing](../briefings/YYYY-MM-DD.md)`.

### 4.4 Briefing perso (si sources perso branchées)

En parallèle, produire `wiki/perso/briefings/YYYY-MM-DD.md` avec les sources Gmail/Calendar perso. **Aucune fuite** : les contacts pro ne déclenchent pas d'items perso, et vice-versa.

---

## Étape 5 — Restituer à l'utilisateur

Afficher dans la conversation :

```
<Greeting>

📅 Ta journée — <date>
[calendrier]

🔴 À traiter ([N])
[items]

📋 À suivre ([X])
[items condensés]

💡 À noter ([Y])
[items condensés]

📊 Depuis hier
[continuité]

💡 Le wiki à enrichir
[suggestions de MAJ wiki — l'utilisateur peut dire "applique 1, 3" pour déclencher /secondbrain-ingest]

💪 [Phrase motivante]

📄 Briefing complet : wiki/pro/briefings/YYYY-MM-DD.md
```

L'utilisateur a un message court et lisible dans la conversation, et peut consulter le fichier détaillé dans Obsidian pour la version exhaustive.

---

## Garde-fous

- **Confidentialité pro/perso** : aucune fuite entre les deux scopes. Briefings et `_state.md` strictement séparés.
- **Sources brutes append-only** : si une source du jour (transcript, email lourd) doit être sauvegardée → passer par `/secondbrain-ingest` après le briefing.
- **Sensibilité** : tous les briefings ont `sensitive: true`. Vault privé, pas de push hors local sans confirmation.
- **Pas de fabrication** : si une info manque (contact non identifié, sujet flou), le briefing dit *« contact non identifié »* / *« sujet à clarifier »* — il ne hallucine pas un rôle ou une mission.
- **Lecture seule du wiki par défaut** : le briefing ne modifie QUE `_state.md`, le briefing du jour, le log, et les sections `## Notes du <date>` des missions actives. Il ne touche pas aux pages concepts/personnes/orgs/clients existantes.
- **Préserver le ton WeValue** : conversation, pas rapport. Tutoiement. Phrase motivante alignée mission (« révéler le potentiel », gouvernance partagée, consultant augmenté).

## Heuristiques (héritées du skill original v8.2)

- **Pas de meeting prep automatique** (V8.2) : le calendrier liste les réunions, conflits et invitations en attente, mais pas de croisement automatique participants × messages (trop de faux positifs).
- **Économie INCRÉMENTAL** : 40-50% de tokens en moins vs COMPLET grâce à la mémoire wiki.
- **RATTRAPAGE** : sortie condensée en TOP 5 + résumé exécutif 200 mots max.
- **RAFRAÎCHISSEMENT** : assemblage depuis le briefing du matin + delta minimal.

## Migration depuis le skill `morning-briefing` v8.2

Une fois ce skill validé et testé sur 2-3 briefings, désactiver le skill `morning-briefing` plugin original pour éviter le double trigger.

Procédure (à valider par user) :
1. Désactiver le skill dans la config plugin Claude Code.
2. Importer dans `_state.md` les valeurs utiles de l'ancien YAML (channels_suivis, bruit_connu, scoring_adjustments) — opération one-shot.
3. Première utilisation du nouveau skill → mode COMPLET pour reconstruire le contexte.
