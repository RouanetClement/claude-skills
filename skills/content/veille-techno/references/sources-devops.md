# Sources DevOps — Défauts

RSS feeds, requêtes WebSearch et topics GitHub pour la veille DevOps / Platform Engineering.
Surcharges via `~/.claude/veille-config.yaml` sous `themes.devops`.

## RSS Feeds

| URL | Description |
|---|---|
| `https://kubernetes.io/feed.xml` | Kubernetes Blog officiel |
| `https://www.cncf.io/feed/` | CNCF (Cloud Native Computing Foundation) |
| `https://about.gitlab.com/atom.xml` | GitLab Blog |
| `https://github.blog/feed/` | GitHub Blog (ingénierie, features) |
| `https://thenewstack.io/feed/` | The New Stack (platform engineering) |
| `https://www.hashicorp.com/blog/feed.xml` | HashiCorp Blog (Terraform, Vault) |

## WebSearch — Requêtes par défaut

Remplacer `{YYYY}` par l'année en cours.

```
"DevOps platform engineering tendances {YYYY}"
"Kubernetes nouveautés {YYYY}"
"GitOps flux argocd {YYYY}"
"observabilité OpenTelemetry {YYYY}"
"sécurité DevSecOps supply chain {YYYY}"
"SRE site reliability engineering {YYYY}"
"infrastructure as code Terraform OpenTofu {YYYY}"
"eBPF cilium réseau Kubernetes {YYYY}"
```

## GitHub Topics

```
platform-engineering
kubernetes
gitops
opentelemetry
devops
devsecops
helm
ebpf
```

Requête GitHub :
```
GET https://api.github.com/search/repositories
  ?q=topic:{topic}+pushed:>{DATE_LIMITE}
  &sort=stars&order=desc&per_page=5
```
Rate limit anonyme : 10 req/min. Espacer les appels de ~7s entre topics.

## Critères de pertinence

Sans `source_authority` dans la config, boost heuristique :

- Source ∈ {kubernetes.io, cncf.io, github.blog, thenewstack.io} → +20%
- Mention de "CNCF graduated/incubating", "GA release" → +15%
- Mention de "CVE", "security advisory", "patch critique" → +20% (signaux critiques)
- Mention de "France", "OVHcloud", "Scaleway", "secteur public" → +10%
- Annonce de fin de vie (EOL) → +15%
