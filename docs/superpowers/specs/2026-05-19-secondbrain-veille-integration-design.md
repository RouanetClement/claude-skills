# Design — SecondBrain + Veille Technologique Integration

**Date** : 2026-05-19  
**Branche cible** : `feat/secondbrain-veille-integration`  
**Statut** : Approuvé

---

## Contexte

Ce document couvre trois sous-systèmes interdépendants :

1. **Mécanisme de réinstallation des sources externes** — reproduire l'environnement Claude Code sur n'importe quelle machine
2. **Intégration des skills secondbrain** dans `claude-skills-repo` — centraliser les skills actuellement dans le repo SecondBrain
3. **Skill `veille-techno`** — veille technologique automatisée (IA, DevOps, Secteur public FR) avec dépôt automatique dans le SecondBrain

---

## Sous-système 1 — Mécanisme de réinstallation externe

### Problème

Le repo permet déjà de réinstaller les MCPs (`install-mcps.sh`) et les hooks git (`install-hooks.sh`), mais les **plugins Claude Code** et les **extensions IDE** ne sont pas capturés. Un `git clone` sur une nouvelle machine laisse ces composants manquants.

### Solution

Ajout d'un dossier `external/` avec des manifests JSON par catégorie + scripts dédiés + un `bootstrap.sh` orchestrateur.

### Artefacts

```
external/
├── plugins.json                  ← Plugins Claude Code (name + version)
├── vscode-extensions.json        ← IDs extensions VS Code
├── jetbrains-plugins.json        ← IDs plugins JetBrains
└── veille-config.example.yaml   ← Template de config veille (à personnaliser par machine)

scripts/
├── install-plugins.sh        ← claude plugin install depuis external/plugins.json
├── install-ide-extensions.sh ← code --install-extension / idea installPlugins
└── bootstrap.sh              ← orchestre tout (hooks + mcps + plugins + ide + sync + veille-config)
```

### Format des manifests

**`external/plugins.json`** :
```json
[
  { "name": "superpowers", "version": "5.1.0" }
]
```

**`external/vscode-extensions.json`** :
```json
[
  { "id": "anthropic.claude-code", "description": "Claude Code IDE extension" }
]
```

**`external/jetbrains-plugins.json`** :
```json
[
  { "id": "cc.plugin.id", "description": "Claude Code JetBrains plugin" }
]
```

### Bootstrap flow

```bash
./scripts/bootstrap.sh
  → ./scripts/install-hooks.sh
  → ./scripts/install-mcps.sh
  → ./scripts/install-plugins.sh
  → ./scripts/install-ide-extensions.sh
  → ./scripts/sync-to-claude.sh
  → Copie external/veille-config.example.yaml → ~/.claude/veille-config.yaml
       (uniquement si absent — ne jamais écraser)
       Affiche : "⚠️  Éditez ~/.claude/veille-config.yaml : mettez à jour second_brain.inbox_path"
```

Après `git clone` sur une nouvelle machine : `./scripts/bootstrap.sh` reproduit l'environnement complet.

> **`veille-config.yaml` est machine-spécifique** (chemin absolu local). Il n'est jamais versionné dans le repo. L'example template dans `external/` sert uniquement d'amorce au premier bootstrap.

### Contraintes

- `install-plugins.sh` : nécessite que la CLI `claude` soit installée et authentifiée
- `install-ide-extensions.sh` : détecte la plateforme (Windows/Mac/Linux) et l'IDE disponible (`code`, `idea`). Ne fait pas d'erreur fatale si l'IDE est absent.
- Chaque script est idempotent (pas d'erreur si déjà installé)

---

## Sous-système 2 — Intégration des skills SecondBrain

### Problème

Les 4 skills secondbrain (`secondbrain-ingest`, `secondbrain-query`, `secondbrain-lint`, `secondbrain-morning-briefing`) sont actuellement dans `.claude/skills/` du repo SecondBrain. Ils ne sont pas versionnés dans `claude-skills-repo` et ne seront pas disponibles sur une nouvelle machine après bootstrap.

### Solution

Migration vers une nouvelle catégorie `skills/secondbrain/` dans ce repo. Suppression des skills du repo SecondBrain pour éviter les conflits de sources dupliquées.

### Artefacts

```
skills/secondbrain/
├── secondbrain-ingest/
│   └── SKILL.md              ← migré tel quel (162 lignes)
├── secondbrain-query/
│   └── SKILL.md              ← migré tel quel (80 lignes)
├── secondbrain-lint/
│   └── SKILL.md              ← migré tel quel (178 lignes)
└── secondbrain-morning-briefing/
    └── SKILL.md              ← migré tel quel (322 lignes)
```

### Note d'architecture

Ces SKILL.md sont des **prompts monolithiques**, non des routers Progressive Disclosure. La limite de 150 lignes s'applique uniquement aux fichiers `references/` — pas de violation CI. Une tâche `[SECONDBRAIN-REFACTOR]` est ajoutée à `TODO.md` pour la réécriture future en routers.

### Règle de source unique (anti-conflit)

Claude Code charge les skills en cascade : user-global (`~/.claude/skills/`) puis projet (`.claude/skills/`). Avoir les deux actifs simultanément crée un conflit silencieux.

**Règle** : après migration, les skills secondbrain n'existent que dans `claude-skills-repo`. Pour évoluer un skill : modifier ici, relancer `sync-to-claude.sh`. Jamais de `secondbrain-*` dans `.claude/skills/` d'un projet.

### Étapes de migration

1. Copier les 4 SKILL.md → `skills/secondbrain/*/SKILL.md`
2. Mettre à jour `CLAUDE.md` (ce repo) : nouvelle catégorie + 4 entrées + note exception architecture
3. Ajouter `[SECONDBRAIN-REFACTOR]` P3 dans `TODO.md`
4. Supprimer `.claude/skills/secondbrain-*/` du repo SecondBrain
5. Ajouter dans le `CLAUDE.md` du repo SecondBrain :
   > "Skills secondbrain maintenus dans `claude-skills-repo`. Disponibles via `sync-to-claude.sh`. Ne pas recréer localement dans `.claude/skills/`."

### Sync

`sync-to-claude.sh` (sans modification) poussera automatiquement les skills vers `~/.claude/skills/` — disponibles en user-global dès le prochain sync.

---

## Sous-système 3 — Skill `veille-techno`

### Problème

Pas de mécanisme de veille technologique automatisée. La collecte est manuelle et fragmentée. Les résultats ne sont pas intégrés au SecondBrain.

### Solution

Skill `veille-techno` qui orchestre une collecte parallèle sur 3 thèmes (IA, DevOps, Secteur public FR), dépose 3 fichiers Markdown dans le SecondBrain et déclenche l'ingestion.

### Localisation

`skills/content/veille-techno/` — aux côtés de `recherche-synthese` (catégorie contenu).

### Artefacts

```
skills/content/veille-techno/
├── SKILL.md                  ← Router Sonnet + orchestration parallèle
└── references/
    ├── sources-ia.md         ← Feeds RSS + requêtes WebSearch + topics GitHub (IA)
    ├── sources-devops.md     ← idem DevOps
    ├── sources-publique.md   ← idem secteur public FR
    └── output-template.md   ← Frontmatter obligatoire + structure Markdown de sortie

external/veille-config.example.yaml  ← Template versionné (chemins fictifs)
~/.claude/veille-config.yaml         ← Config réelle machine (non versionnée, générée par bootstrap.sh)
```

`sync-to-claude.sh` **ne touche pas** `veille-config.yaml` (machine-spécifique). C'est `bootstrap.sh` qui génère la config initiale depuis le template si elle est absente.

### Config `~/.claude/veille-config.yaml`

```yaml
second_brain:
  inbox_path: "C:/Users/cleme/Documents/Claude/Projects/SecondBrain/sources/inbox"

defaults:
  horizon_days: 7
  items_per_theme: 10

themes:
  ia:
    enabled: true
    rss_feeds:
      - https://huggingface.co/blog/feed.xml
      - https://bair.berkeley.edu/blog/feed.xml
    github_topics: [llm, ai-agents, rag]
    search_queries:
      - "actualité IA générative 2026"
      - "LLM gouvernance France 2026"
      - "AI agents nouveautés 2026"
    # source_authority: { "huggingface.co": 1.2, "arxiv.org": 1.1 }  ← boost de score optionnel
  devops:
    enabled: true
    rss_feeds:
      - https://kubernetes.io/feed.xml
      - https://www.cncf.io/feed/
    github_topics: [platform-engineering, kubernetes, gitops]
    search_queries:
      - "DevOps platform engineering tendances 2026"
      - "Kubernetes nouveautés 2026"
  publique:
    enabled: true
    rss_feeds:
      - https://www.numerique.gouv.fr/actualites/feed/
      - https://www.data.gouv.fr/fr/activity/rss/
    github_topics: [etalab, dsfr, publiccode]
    search_queries:
      - "DINUM actualité 2026"
      - "logiciel libre administration France 2026"
      - "IA secteur public France 2026"
      - "DSFR nouveautés 2026"
```

Si `~/.claude/veille-config.yaml` est absent, le skill utilise les defaults dans `references/sources-*.md`.

### Pipeline d'exécution

```
/veille [--since Nd | --since YYYY-MM-DD] [--theme ia|devops|publique]

  1. Lire ~/.claude/veille-config.yaml (fallback: defaults des références)
  2. Dispatcher 3 sous-agents en parallèle — modèle : claude-sonnet (Sonnet)

  Chaque sous-agent (par thème) :
    a. Charger references/sources-{theme}.md (défauts)
    b. Fusionner avec la config YAML (surcharges + source_authority si présent)
    c. WebSearch : requêtes ciblées avec filtre temporel (horizon_days)
    d. WebFetch RSS : récupérer chaque feed, parser XML, extraire N items récents
    e. WebFetch GitHub API :
         /search/repositories?q=topic:{topic}&sort=stars
         &pushed:>{DATE_LIMITE}&per_page=5
       (sans auth requis, rate limit 10 req/min)
    f. Dédupliquer par URL au sein du thème (set d'URLs vues — garder le premier)
       Si source_authority configurée : appliquer le boost de score avant tri
    g. Trier par pertinence + récence (+ score si source_authority)
    h. Écrire {inbox_path}/veille-{theme}-YYYY-MM-DD.md
    ⚠️  Fail-soft : si WebFetch ou WebSearch échoue sur une source, logger l'erreur
        dans le fichier de sortie (section "## Erreurs de collecte") et continuer.
        Échec total d'un thème → section vide avec note, pas d'arrêt du skill.

  3. Pour chaque fichier créé :
       Appeler secondbrain-ingest avec chemin explicite
       (scope=pro inféré du frontmatter, pas de questions interactives)
       Note cross-thème : si un article apparaît dans plusieurs thèmes (même URL),
       secondbrain-ingest déduplique à l'ingestion via le champ origin.ref.

  4. Restituer : N items par thème, fichiers ingérés, liens vers pages wiki créées,
     liste des éventuelles erreurs de collecte
```

### Format de sortie (par thème)

```markdown
---
type: source
scope: pro
source_kind: note
theme: ia          # ia | devops | publique
origin:
  kind: manual
  ref: veille-techno-skill
ingested: YYYY-MM-DD
---

# Veille IA — YYYY-MM-DD

## Articles & actualités

- **[Titre article](url)** · Source · YYYY-MM-DD
  Résumé en 2-3 lignes.

- ...

## GitHub — Repos tendance

- **org/repo** — description courte (⭐ N stars)

## Synthèse
Tendances et signaux faibles détectés cette semaine.
```

Le frontmatter `scope: pro` et `origin.ref: veille-techno-skill` permet à `secondbrain-ingest` d'opérer sans questions interactives. La page wiki de destination sera `wiki/pro/veille/YYYY-MM_ia.md` (catégorie `veille`, gérée par `ingest`).

### Invocations

```
/veille                    → 3 thèmes, horizon défaut (7j config)
/veille --since 14d        → rattrapage 14 jours
/veille --since 2026-05-01 → depuis une date précise
/veille --theme ia         → un seul thème
```

### Note GitHub Trending

GitHub n'expose pas d'endpoint "trending" officiel. Simulation via :
```
GET /search/repositories
  ?q=topic:{topic}+pushed:>{date_limite}
  &sort=stars&order=desc&per_page=5
```
Bonne approximation sans authentification (rate limit : 10 req/min anonyme).

---

## Mises à jour CLAUDE.md (ce repo)

Nouvelles entrées dans le tableau des skills :

| Catégorie | Skill | Domaine |
|---|---|---|
| `secondbrain` | `secondbrain-ingest` | Ingestion sources → wiki SecondBrain |
| `secondbrain` | `secondbrain-query` | Interrogation wiki SecondBrain |
| `secondbrain` | `secondbrain-lint` | Audit santé wiki SecondBrain |
| `secondbrain` | `secondbrain-morning-briefing` | Briefing matinal WeValue adossé au vault |
| `content` | `veille-techno` | Veille IA / DevOps / Secteur public FR → SecondBrain |

Note d'architecture à ajouter dans CLAUDE.md :

> **Exception Progressive Disclosure** : les skills `secondbrain/` sont des prompts monolithiques (pas de router + references). Acceptable car leur complexité nécessite une logique conditionnelle dense. Refactoring prévu : voir `[SECONDBRAIN-REFACTOR]` dans TODO.md.

---

## TODO.md — Nouvelles entrées

Section `[SECONDBRAIN]` à créer :

```markdown
## [SECONDBRAIN] SecondBrain skills

- [ ] [SECONDBRAIN-REFACTOR] P3 — Réécrire les 4 skills secondbrain en routers
      Progressive Disclosure (SKILL.md router + references/) conformément à l'architecture du repo.
      Actuellement : prompts monolithiques (162–322 lignes). Décision assumée à la migration.
```

---

## Dépendances entre sous-systèmes

```
Sous-système 1 (bootstrap)
  └─ indépendant, peut être livré seul

Sous-système 2 (secondbrain skills)
  └─ indépendant de 1, mais doit être livré avant 3
     (veille-techno dépend de secondbrain-ingest disponible en user-global)

Sous-système 3 (veille-techno)
  └─ dépend de 2 (secondbrain-ingest accessible)
  └─ dépend de ~/.claude/veille-config.yaml présent sur la machine
```

**Ordre de livraison recommandé** : 1 et 2 en parallèle sur la même branche, 3 en suite.

---

## Hors périmètre

- Refactoring des skills secondbrain en Progressive Disclosure (TODO.md `[SECONDBRAIN-REFACTOR]`)
- Planification automatique de la veille via `/schedule` (peut être ajouté post-livraison)
- Sources veille supplémentaires (Twitter/X, newsletters) — extensible via `veille-config.yaml`
- Auto-ingestion des fichiers déposés manuellement dans `sources/inbox/` (hook générique)
