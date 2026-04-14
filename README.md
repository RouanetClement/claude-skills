# claude-skills

Skills personnalisés pour Claude — architecture Progressive Disclosure.

## Structure

```
skill-name/
├── SKILL.md          ← routeur léger : routing modèle + délégation
└── references/       ← fichiers spécialisés, chargés uniquement si pertinents
    └── [contexte].md
```

## Skills disponibles

| Skill | Modèle | Description |
|---|---|---|
| `code-automation` | Sonnet / Haiku | Dev, scripts, debug, IaC, CI/CD |
| `analyse-documents` | Haiku / Sonnet | Extraction, synthèse, Q&A sur documents |
| `gestion-projet` | Haiku / Sonnet | Notion, Slack, tâches, suivi |
| `recherche-synthese` | Haiku / Sonnet | Veille, recherche web, comparaisons |
| `redaction` | Sonnet | Emails, rapports, documentation |

## Règle de routing

- **Haiku** : tâche mécanique, extraction, CRUD, transform, snippet court
- **Sonnet** : raisonnement, analyse, nouvelle architecture, debug complexe
- **Doute** → Sonnet

## Principes

- `SKILL.md` = routeur léger, pas de logique métier
- Fichiers `references/` < 150 lignes chacun
- Chaque modification a un rationnel explicite
- Architecture conçue pour évoluer, pas de sur-spécification

## Mise à jour

Voir [`scripts/sync-from-claude.sh`](scripts/sync-from-claude.sh) pour resynchroniser depuis Claude.
