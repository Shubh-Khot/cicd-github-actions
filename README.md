# CI/CD Pipeline with GitHub Actions

A complete CI/CD pipeline using GitHub Actions for a containerized Python (FastAPI) application deployed to AWS EKS. Implements automated testing, Docker builds, security scanning, and staged deployments.

## Pipeline Overview

```
Push to main/PR
      │
      ▼
  [Lint & SAST]
      │
      ▼
[Unit & Integration Tests]
   (with PostgreSQL)
      │
      ▼
[Build & Push Docker Image]
   (GHCR + layer cache)
      │
      ▼
[Trivy Security Scan]
      │
      ▼
[Deploy → Staging] ──── smoke tests ────► [Deploy → Production]
                                              (manual approval)
```

## Workflows

### `ci.yml` — Continuous Integration
| Job     | What it does |
|---------|-------------|
| `lint`  | Flake8 linting + Bandit SAST |
| `test`  | Pytest with PostgreSQL service container, coverage report |
| `build` | Multi-stage Docker build, push to GHCR |
| `scan`  | Trivy vulnerability scan → GitHub Security tab |

### `cd.yml` — Continuous Deployment
| Job              | Trigger           | Target       |
|------------------|-------------------|--------------|
| `deploy-staging` | CI passes on main | EKS staging  |
| `deploy-prod`    | Staging passes + manual approval | EKS prod |

## Required Secrets

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS credentials for EKS access |
| `AWS_SECRET_ACCESS_KEY` | AWS credentials for EKS access |
| `SLACK_WEBHOOK_URL` | Slack notifications on deploy |

## Local Development

```bash
# Build image
docker build -t myapp:local .

# Run locally
docker run -p 8000:8000 -e ENVIRONMENT=dev myapp:local

# Run tests
pip install -r app/requirements.txt pytest
pytest app/tests/ -v
```

## Key Features

- **Multi-stage Docker builds** — minimal final image size
- **Layer caching** — GitHub Actions cache for fast re-builds
- **Security scanning** — Trivy results uploaded to GitHub Security tab
- **Staged deployments** — staging gate before prod with required approval
- **Automatic rollback** — `kubectl rollout undo` on failed prod deployment
- **Non-root container** — runs as `appuser` for security
