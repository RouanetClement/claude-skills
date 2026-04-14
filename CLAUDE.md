# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

A prompt engineering monorepo containing specialized Claude AI agents (skills) organized around a **Progressive Disclosure** architecture. Skills are lightweight routers that conditionally load specialized reference files rather than monolithic prompts.

## Validation

There is no build system. Validation runs via GitHub Actions (`.github/workflows/validate.yml`) and checks two rules:
1. Every skill directory must contain a `SKILL.md`
2. Every file under `references/` must be ≤ 150 lines

To sync skills from the Claude Code environment:
```bash
./scripts/sync-from-claude.sh
```

## Architecture

Each skill follows this layout:
```
skill-name/
├── SKILL.md          ← Router: task classification, model selection, reference loading
└── references/       ← Specialized context files loaded conditionally by SKILL.md
    └── [context].md
```

**SKILL.md is a decision tree**, not a full prompt. It:
1. Identifies the task type from user input
2. Chooses Claude Haiku (mechanical/CRUD tasks) or Claude Sonnet (reasoning/analysis)
3. Loads only the relevant reference files for that task

**References** are ~50–150 line files, each covering exactly one concept (language, pattern, or tool). They are appended to the prompt only when relevant — never all at once.

### Current Skills

| Skill | Domain |
|---|---|
| `code-automation` | Dev, scripts, APIs, IaC, CI/CD, design adaptation |
| `analyse-documents` | PDF/report extraction, synthesis, comparison |
| `gestion-projet` | Notion/Slack workflows, task tracking |
| `recherche-synthese` | Web research, benchmarking, competitive analysis |
| `redaction` | Emails, reports, documentation |

## Key Conventions

- **Model stratification**: Haiku for extraction/CRUD, Sonnet for reasoning. Default to Sonnet when uncertain.
- **150-line hard limit** on all reference files — enforced by CI. If a reference grows beyond this, split it.
- **Language**: All skill content is written in French.
- **SKILL.md frontmatter**: Must include `name` and `description` YAML fields.
- **No executable code**: This repo contains only Markdown. References provide patterns and examples, not runnable scripts.
- **Rationale over rules**: Each routing decision in SKILL.md should explain *why* (e.g., "Haiku suffices because this is pure data extraction with no judgment").

## Adding or Modifying Skills

When creating a new skill:
1. Create `skill-name/SKILL.md` with YAML frontmatter (`name`, `description`)
2. Write the router logic: task classification → model choice → reference loading
3. Add references under `skill-name/references/` if needed, each under 150 lines
4. CI will validate structure automatically on push to `main`

When editing references, verify line count stays ≤ 150 (`wc -l references/your-file.md`).