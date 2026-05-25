# Sources IA — Défauts

RSS feeds, requêtes WebSearch et topics GitHub pour la veille IA.
Surcharges via `~/.claude/veille-config.yaml` sous `themes.ia`.

## RSS Feeds

| URL | Description |
|---|---|
| `https://huggingface.co/blog/feed.xml` | HuggingFace Blog (modèles, datasets, releases) |
| `https://bair.berkeley.edu/blog/feed.xml` | BAIR Berkeley AI Research |
| `https://ai.googleblog.com/feeds/posts/default` | Google AI Blog |
| `https://openai.com/news/rss.xml` | OpenAI News |
| `https://www.inria.fr/fr/actualites/actualites-de-linria.rss` | INRIA (recherche IA France) |
| `https://mistral.ai/news/rss.xml` | Mistral AI News |

## WebSearch — Requêtes par défaut

Remplacer `{YYYY}` par l'année en cours. Ajouter un filtre temporel si possible.

```
"actualité IA générative {YYYY}"
"LLM gouvernance France {YYYY}"
"AI agents nouveautés {YYYY}"
"modèles de langage open source {YYYY}"
"RAG retrieval augmented generation {YYYY}"
"anthropic claude nouveautés {YYYY}"
"mistral IA France {YYYY}"
"EU AI Act mise en œuvre {YYYY}"
"MCP Model Context Protocol {YYYY}"
```

## GitHub Topics

```
llm
ai-agents
rag
llm-fine-tuning
prompt-engineering
langchain
llamaindex
mcp-server
```

Requête GitHub :
```
GET https://api.github.com/search/repositories
  ?q=topic:{topic}+pushed:>{DATE_LIMITE}
  &sort=stars&order=desc&per_page=5
```
Rate limit anonyme : 10 req/min. Espacer les appels de ~7s entre topics.

## Critères de pertinence

Sans `source_authority` dans la config, boost de score heuristique :

- Source ∈ {huggingface.co, arxiv.org, inria.fr, mistral.ai} → +20%
- Mention de "France", "gouvernance", "réglementation", "EU AI Act" → +15%
- Mention de "open source", "open weights" → +10%
- Titre en français → +5% (signale une pertinence locale)
- Contenu derrière paywall (détecté à la lecture) → −30%
