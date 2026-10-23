# Type de session & 7 dimensions d'analyse

## Identifier le type de session

Analyser les skills invoqués, les outils utilisés, les extensions de fichiers modifiés :

| Indice | Type déduit |
|---|---|
| Skills cv/, audit-cv, optimisation-cv, ciblage-cv | `cv` |
| Skills redaction, copywriting, seo-content, analyse-documents | `content` |
| Skills code-automation, git-workflow, tdd, skill-builder, update-config | `dev` |
| Skills gestion-notion, gestion-projet, gestion-todo | `gestion` |
| Plusieurs catégories mélangées | `multi` |
| Exploration sans livrable clair | `exploration` |

## Les 7 dimensions

**D1 — Tâches demandées**
Liste chronologique des demandes utilisateur. Marquer `[x]` si un livrable est visible (fichier créé, commande réussie, confirmation explicite). Marquer `[via sous-agent: NomAgent]` si délégué.

**D2 — Skills & outils utilisés**
Tableau : `| Skill/Outil | Nb usages | Contexte |`

**D3 — Instructions, corrections & précisions utilisateur**
Chaque message où l'utilisateur corrige une approche, précise une contrainte, ou valide explicitement. Citer fidèlement. Si aucune correction dans la session : noter `_(aucune)_`.

**D4 — Contexte technique** *(uniquement si type_session = dev)*
- **Technos** : imports, extensions de fichiers, noms de packages dans les commandes Bash.
- **Méthodologie** : skill tdd invoqué → TDD ; fichiers `*.spec.*` / `*.test.*` créés → TDD.

**D5 — Profil d'usage observé**
Patterns récurrents, préférences de workflow, style de communication détectés dans cette session.

**D6 — Sous-agents**
Pour chaque appel `Agent` tool : prompt envoyé, résultat, internals si JSONL secondaire accessible. Sinon : `[internals non disponibles]`.
Si `sous_agents_invoques = 0` : omettre entièrement la section `## Sous-agents` du corps Markdown.

**D7 — Suggestions**
- Nouveaux skills candidats : demandes sans skill dédié.
- Améliorations : skills invoqués avec contournements fréquents.
