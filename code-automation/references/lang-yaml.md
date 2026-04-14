# YAML — K8s / Helm / CI-CD

---

## Conventions générales

- Indentation **2 espaces** (jamais de tabulations)
- Séparer les ressources K8s par `---`
- Commenter les valeurs non évidentes
- Pas de valeurs magiques : nommer via variables/anchors si réutilisées

---

## Kubernetes

### Structure manifeste

```yaml
# Toujours : apiVersion, kind, metadata, spec
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  namespace: production
  labels:
    app: api-server
    version: "1.2.0"
    managed-by: helm      # ou kubectl, argocd...
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
    spec:
      # Toujours spécifier les requests ET les limits
      containers:
        - name: api
          image: myapp/api:1.2.0    # jamais :latest en prod
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "256Mi"
          # Variables d'env depuis Secret ou ConfigMap, pas en dur
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: api-secrets
                  key: database-url
```

### Checklist ressource K8s

- [ ] `namespace` explicite
- [ ] Labels cohérents (`app`, `version`, `managed-by`)
- [ ] `resources.requests` et `resources.limits` définis
- [ ] Pas de `image: latest`
- [ ] Secrets via `secretKeyRef` ou `envFrom`, jamais en clair
- [ ] `livenessProbe` et `readinessProbe` définis pour les Deployments
- [ ] `PodDisruptionBudget` si haute disponibilité requise

---

## Helm

### Structure chart

```
chart/
├── Chart.yaml          ← metadata
├── values.yaml         ← valeurs par défaut documentées
├── values.dev.yaml     ← surcharges dev
├── values.prod.yaml    ← surcharges prod
└── templates/
    ├── _helpers.tpl    ← helpers réutilisables
    ├── deployment.yaml
    ├── service.yaml
    └── ingress.yaml
```

### values.yaml — toujours documenté

```yaml
# Nombre de réplicas
replicaCount: 1

image:
  repository: myapp/api
  tag: ""          # overridé par CI/CD
  pullPolicy: IfNotPresent

# Ressources CPU/mémoire
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi
```

---

## CI/CD (GitHub Actions / GitLab CI)

### Principes

- **Jobs atomiques** : chaque job a une responsabilité claire
- **Fail fast** : les checks rapides (lint, type-check) en premier
- **Secrets via vault** : jamais de credentials en dur dans le YAML
- **Artifacts** : conserver les outputs utiles (rapports de test, binaires)

### Exemple GitHub Actions

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  test:
    needs: lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: coverage/
```

### Checklist pipeline

- [ ] Versions d'actions fixées (`@v4`, pas `@latest`)
- [ ] Cache des dépendances activé
- [ ] Secrets référencés via `${{ secrets.NAME }}`
- [ ] `if: always()` sur l'upload d'artifacts de test
- [ ] Environnements de déploiement avec approbation pour prod
