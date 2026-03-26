---
name: kubernetes-ops
description: "Use when deploying and managing applications on Kubernetes. Covers deployments, services, ConfigMaps, Secrets, Helm, and troubleshooting. OSS-first: k8s is fully OSS. Triggers on: Kubernetes, k8s, kubectl, deployment, pod, service, Helm, container orchestration, cluster, namespace."
metadata:
  author: leopoldo
  source: custom
  created: 2026-03-24
  forge_strategy: build
license: MIT
upstream:
  url: null
  version: null
  last_checked: 2026-03-24
---

# Kubernetes Ops -- Container Orchestration

## Why This Exists

| Problem | Solution |
|---------|----------|
| Docker alone doesn't handle scaling, rollbacks, health | Kubernetes for production orchestration |
| k8s is complex, easy to misconfigure | Opinionated patterns for common use cases |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Managed) |
|-------------------|-------------------|
| Kubernetes (OSS) | EKS, GKE, AKS |
| Helm (package manager) | -- |
| k3s (lightweight k8s) | -- |

## Core Workflow

### 1. Deployment

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: ghcr.io/myorg/my-app:latest
          ports:
            - containerPort: 3000
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: database-url
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
          readinessProbe:
            httpGet:
              path: /api/health
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /api/health
              port: 3000
            initialDelaySeconds: 15
            periodSeconds: 20
```

### 2. Service + Ingress

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  selector:
    app: my-app
  ports:
    - port: 80
      targetPort: 3000
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
    - hosts: [myapp.com]
      secretName: myapp-tls
  rules:
    - host: myapp.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-app-service
                port:
                  number: 80
```

### 3. Essential Commands

```bash
kubectl apply -f k8s/               # Apply manifests
kubectl get pods -n production       # List pods
kubectl logs -f my-app-xxx          # Stream logs
kubectl describe pod my-app-xxx     # Debug pod issues
kubectl rollout status deployment/my-app  # Watch rollout
kubectl rollout undo deployment/my-app    # Rollback
kubectl exec -it my-app-xxx -- sh   # Shell into pod
```

## Rules

1. Always set resource requests AND limits
2. Always add readiness and liveness probes
3. Secrets via k8s Secrets or external secret manager (never ConfigMap)
4. Use namespaces for environment separation
5. Helm for complex deployments (templates, values, releases)
6. Rolling updates as default strategy (zero downtime)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| No resource limits | Pod can consume all node resources | Set requests + limits |
| No health probes | k8s can't detect unhealthy pods | Readiness + liveness probes |
| Secrets in ConfigMaps | Not encrypted at rest | k8s Secrets or external vault |
| Latest tag in production | Non-reproducible, can't rollback | Specific version tags |
| No namespace separation | Resource conflicts, access issues | Namespace per environment |
