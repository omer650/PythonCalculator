# CI/CD Setup Documentation for LLM Understanding

## Overview

This project implements a comprehensive CI/CD (Continuous Integration/Continuous Deployment) pipeline that supports multiple platforms and container registries. The setup enables automated testing, Docker image building, and publishing to Docker Hub and JFrog Artifactory.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Source Code Repository                     │
│  (GitHub/GitLab repository with calculator web app)          │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ├─── On Push/PR ──────────┐
                   │                          │
                   │                          ▼
                   │                  ┌──────────────┐
                   │                  │  Run Tests    │
                   │                  │   (pytest)    │
                   │                  └──────┬───────┘
                   │                         │
                   ├─── On Tag v*.*.* ──────┘
                   │                         │
                   │                         ▼
                   │                  ┌──────────────┐
                   │                  │ Build Docker │
                   │                  │    Image     │
                   │                  └──────┬───────┘
                   │                         │
                   │                         ├───► Docker Hub
                   │                         │
                   │                         ├───► Artifactory
                   │                         │
                   │                         └───► GitLab Registry (GitLab only)
                   │
                   └─── Docker Compose (Local Development)
```

## File Structure and Purpose

### 1. Dockerfile
**Location:** `/Dockerfile`  
**Purpose:** Defines the Docker container image for the Flask calculator application.

**Key Components:**
- Base image: `python:3.11-slim` (lightweight Python 3.11)
- Working directory: `/app`
- Creates non-root user `appuser` for security
- Installs dependencies from `requirements.txt`
- Exposes port 5001 (Flask default for this app)
- Runs `app.py` as the container entrypoint

**Security Features:**
- Runs as non-root user
- Minimal base image to reduce attack surface
- No unnecessary packages installed

### 2. .dockerignore
**Location:** `/.dockerignore`  
**Purpose:** Prevents unnecessary files from being copied into Docker build context, reducing image size and build time.

**Excluded Items:**
- Python cache files (`__pycache__/`, `*.pyc`)
- Virtual environments (`.venv/`, `venv/`)
- Git files (`.git/`, `.gitignore`)
- CI/CD files (`.github/`, `.gitlab-ci.yml`)
- Documentation (`.md` files)
- Test files (`test_*.py`)

### 3. docker-compose.yml
**Location:** `/docker-compose.yml`  
**Purpose:** Provides local development environment orchestration using Docker Compose.

**Services:**
- `calculator-app`: Main application service
  - Builds from local Dockerfile
  - Maps host port 5001 to container port 5001
  - Includes health check endpoint
  - Optional volume mounts for live code reloading
  - Runs on `calculator-network` bridge network

**Features:**
- Easy local development setup
- Health monitoring
- Network isolation
- Restart policies

### 4. .github/workflows/ci-cd.yml
**Location:** `/.github/workflows/ci-cd.yml`  
**Purpose:** GitHub Actions workflow definition for CI/CD automation.

**Structure:**

#### Triggers:
- **Push events:** Main/master/team-z-moshe branches → Runs tests
- **Pull requests:** Same branches → Runs tests
- **Tag events:** Version tags matching `v*.*.*` → Runs tests + Publishes images

#### Jobs:

1. **`test` Job:**
   - Runs on: All pushes, PRs, and tags
   - Steps:
     - Checks out code
     - Sets up Python 3.11
     - Installs dependencies from `requirements.txt`
     - Runs pytest with quiet flag
   - Purpose: Validates code quality and correctness

2. **`docker-hub` Job:**
   - Runs on: Version tags only (`v*.*.*`)
   - Depends on: `test` job (must pass)
   - Steps:
     - Checks out code
     - Sets up Docker Buildx (multi-platform builds)
     - Logs into Docker Hub using secrets
     - Extracts version tag
     - Builds Docker image
     - Tags with version and `latest`
     - Pushes to Docker Hub
   - Purpose: Publishes images to public/private Docker Hub registry

3. **`artifactory` Job:**
   - Runs on: Version tags only (`v*.*.*`)
   - Depends on: `test` job (must pass)
   - Steps:
     - Checks out code
     - Sets up Docker Buildx
     - Checks if Artifactory credentials exist (graceful skip)
     - Logs into Artifactory registry
     - Extracts version tag
     - Builds Docker image
     - Tags with version and `latest`
     - Pushes to Artifactory
   - Purpose: Publishes images to enterprise Artifactory registry
   - **Note:** Skips automatically if credentials not configured

#### Required GitHub Configuration:

**Docker Hub:**
- `DOCKER_USERNAME` - **Secret** - Docker Hub username
- `DOCKER_TOKEN` - **Secret** - Docker Hub Personal Access Token (not password!)

**Setup Instructions:**
1. **Add `DOCKER_USERNAME` Secret:**
   - GitHub → Settings → Secrets and variables → Actions → Secrets tab
   - Click "New repository secret"
   - Name: `DOCKER_USERNAME`
   - Value: Your Docker Hub username
   - Click "Add secret"

2. **Add `DOCKER_TOKEN` Secret:**
   - GitHub → Settings → Secrets and variables → Actions → Secrets tab
   - Go to [Docker Hub](https://hub.docker.com) → Account Settings → Security
   - Click "New Access Token"
   - Name: "GitHub Actions CI/CD"
   - Permissions: "Read, Write & Delete"
   - Click "Generate"
   - **Copy token immediately** (won't be shown again)
   - Add as `DOCKER_TOKEN` secret in GitHub
- `ARTIFACTORY_URL`: Artifactory registry URL (optional)
- `ARTIFACTORY_REPO`: Artifactory repository name (optional)
- `ARTIFACTORY_USERNAME`: Artifactory username (optional)
- `ARTIFACTORY_PASSWORD`: Artifactory password/API key (optional)

### 5. .gitlab-ci.yml
**Location:** `/.gitlab-ci.yml`  
**Purpose:** GitLab CI/CD pipeline definition for GitLab projects.

**Stages:**

1. **`test` Stage:**
   - Job: `test`
   - Runs on: All branches, merge requests, and tags
   - Uses: `python:3.11-slim` image
   - Script: Installs dependencies and runs pytest
   - Purpose: Validates code before deployment

2. **`build` Stage:**
   - Job: `build`
   - Runs on: All branches and tags
   - Uses: `docker:24` with Docker-in-Docker service
   - Script:
     - Logs into GitLab Container Registry (automatic credentials)
     - Determines version (tag or branch-commit hash)
     - Builds Docker image
     - Tags with version and `latest`
     - Pushes to GitLab Container Registry
   - Purpose: Builds and stores images in GitLab's registry

3. **`publish` Stage:**
   - **Job: `publish-dockerhub`**
     - Runs on: Version tags matching `v[0-9]+\.[0-9]+\.[0-9]+$`
     - Uses: `docker:24` with Docker-in-Docker
     - Script:
       - Logs into Docker Hub
       - Pulls image from GitLab registry
       - Tags for Docker Hub
       - Pushes to Docker Hub
     - Purpose: Publishes images to Docker Hub from GitLab registry
   
   - **Job: `publish-artifactory`**
     - Runs on: Version tags matching `v[0-9]+\.[0-9]+\.[0-9]+$`
     - Uses: `docker:24` with Docker-in-Docker
     - Script:
       - Checks for Artifactory credentials
       - Logs into Artifactory
       - Pulls image from GitLab registry
       - Tags for Artifactory
       - Pushes to Artifactory
     - **Manual trigger:** Must be manually started from GitLab UI
     - **Allow failure:** Pipeline continues if this job fails
     - Purpose: Publishes images to enterprise Artifactory registry

#### GitLab CI/CD Variables:

**Built-in (automatic):**
- `CI_REGISTRY`: GitLab Container Registry URL
- `CI_REGISTRY_USER`: GitLab registry username
- `CI_REGISTRY_PASSWORD`: GitLab registry password (auto-generated)
- `CI_REGISTRY_IMAGE`: Full registry image path
- `CI_COMMIT_TAG`: Tag name if triggered by tag
- `CI_COMMIT_REF_SLUG`: Branch/tag name (sanitized)
- `CI_COMMIT_SHORT_SHA`: Short commit hash

**Custom (must be set in GitLab UI):**
- `DOCKERHUB_USERNAME`: Docker Hub username
- `DOCKERHUB_TOKEN`: Docker Hub access token
- `ARTIFACTORY_URL`: Artifactory registry URL
- `ARTIFACTORY_REPO`: Artifactory repository name
- `ARTIFACTORY_USERNAME`: Artifactory username
- `ARTIFACTORY_PASSWORD`: Artifactory password/API key

## Workflow Comparison

| Feature | GitHub Actions | GitLab CI/CD |
|---------|---------------|--------------|
| **Test Execution** | ✅ All pushes/PRs | ✅ All branches/MRs |
| **Build Trigger** | ✅ On tags only | ✅ All branches/tags |
| **GitLab Registry** | ❌ N/A | ✅ Always builds |
| **Docker Hub Publish** | ✅ On tags | ✅ On version tags |
| **Artifactory Publish** | ✅ On tags (auto-skip) | ✅ On tags (manual) |
| **Image Caching** | ✅ GHA cache | ✅ GitLab cache |
| **Multi-platform** | ✅ Buildx | ✅ Buildx (via Docker-in-Docker) |

## Image Naming Conventions

### GitHub Actions → Docker Hub
- Format: `{DOCKER_USERNAME}/calculator-app:{VERSION}`
- Example: `myuser/calculator-app:v1.2.3`
- Also tags: `myuser/calculator-app:latest`

### GitHub Actions → Artifactory
- Format: `{ARTIFACTORY_URL}/{ARTIFACTORY_REPO}/calculator-app:{VERSION}`
- Example: `artifactory.company.com/docker/calculator-app:v1.2.3`
- Also tags: `artifactory.company.com/docker/calculator-app:latest`

### GitLab CI/CD → GitLab Registry
- Format: `{CI_REGISTRY_IMAGE}:{VERSION}`
- Example: `registry.gitlab.com/username/project/calculator-app:main-abc1234`
- For tags: `registry.gitlab.com/username/project/calculator-app:v1.2.3`
- Also tags: `latest` for all builds

### GitLab CI/CD → Docker Hub
- Format: `{DOCKERHUB_USERNAME}/calculator-app:{VERSION}`
- Example: `myuser/calculator-app:v1.2.3`

### GitLab CI/CD → Artifactory
- Format: `{ARTIFACTORY_URL}/{ARTIFACTORY_REPO}/calculator-app:{VERSION}`
- Example: `artifactory.company.com/docker/calculator-app:v1.2.3`

## Key Concepts

### Docker Buildx
- **Purpose:** Multi-platform Docker builds
- **Usage:** Enabled in both GitHub Actions and GitLab CI/CD
- **Benefits:** Can build for multiple architectures (amd64, arm64, etc.)
- **In this setup:** Currently builds for `linux/amd64` only

### Docker-in-Docker (DIND)
- **Usage:** GitLab CI/CD uses `docker:24-dind` service
- **Purpose:** Allows Docker daemon to run inside GitLab runners
- **Security:** Runs in privileged mode (isolated in CI environment)

### Image Tagging Strategy
- **Version tags:** `v1.2.3` format (semantic versioning)
- **Latest tag:** Always updated to point to most recent version
- **Branch tags:** GitLab builds also tag with branch-commit format

### Secret Management

**GitHub:**
- **Secrets:** Stored in Repository Settings → Secrets and variables → Actions → Secrets
- **Variables:** Stored in Repository Settings → Secrets and variables → Actions → Variables
- Access: Encrypted at rest, masked in logs
- Usage: 
  - Secrets: `${{ secrets.SECRET_NAME }}`
  - Variables: `${{ vars.VARIABLE_NAME }}`
- **Important:** Use Personal Access Tokens, never passwords
  - Docker Hub: 
    - `DOCKER_USERNAME` → **Secret** (your Docker Hub username)
    - `DOCKER_TOKEN` → **Secret** (Personal Access Token)
  - Tokens can be rotated/revoked without affecting account password
  - Better security: scope-specific permissions, expiration support

**GitLab:**
- Stored in: Settings → CI/CD → Variables
- Access: Can be protected (only available in protected branches)
- Usage: Referenced as `$VARIABLE_NAME` or `${VARIABLE_NAME}`
- **Important:** Use Personal Access Tokens for Docker Hub (`DOCKERHUB_TOKEN`)
  - Never use account passwords in CI/CD
  - Tokens are more secure and can be individually managed

## Testing and Validation

### Local Testing

1. **Docker Build:**
   ```bash
   docker build -t calculator-app:test .
   docker run -p 5001:5001 calculator-app:test
   ```

2. **Docker Compose:**
   ```bash
   docker-compose up
   # Test: curl http://localhost:5001/health
   ```

3. **Local Tests:**
   ```bash
   pip install -r requirements.txt
   pytest
   ```

### CI/CD Testing

1. **GitHub Actions:**
   - Push to repository → Tests run automatically
   - Create tag: `git tag v1.0.0 && git push origin v1.0.0`
   - View logs: GitHub → Actions tab

2. **GitLab CI/CD:**
   - Push to repository → Pipeline runs automatically
   - Create tag: `git tag v1.0.0 && git push origin v1.0.0`
   - View logs: GitLab → CI/CD → Pipelines
   - Manual trigger: GitLab UI → Pipelines → Run pipeline for Artifactory publish

## Decision Rationale

### Why Multiple CI/CD Systems?
- **Flexibility:** Different organizations use different platforms
- **Redundancy:** Can use either GitHub or GitLab based on preference
- **Enterprise:** Artifactory support for organizations requiring private registries

### Why Artifactory Support?
- **Enterprise requirement:** Many organizations use Artifactory for artifact management
- **Compliance:** Centralized artifact storage and tracking
- **Security:** Private registries for internal use

### Why Docker Compose?
- **Developer experience:** Easy local development setup
- **Consistency:** Matches production container environment
- **Testing:** Can test Docker setup without pushing to registry

### Why Non-Root User in Docker?
- **Security best practice:** Reduces attack surface
- **Container standards:** Industry-standard container security
- **Compliance:** Required by many security policies

### Why Version Tags Only for Publishing?
- **Semantic versioning:** Ensures only tagged releases are published
- **Stability:** Prevents accidental publishing of development builds
- **Control:** Maintains version history and rollback capability

## Common Issues and Solutions

### Issue: Docker Hub Login Fails
- **Cause:** Invalid credentials or expired token
- **Solution:** Regenerate Docker Hub Personal Access Token (not password) and update `DOCKER_TOKEN` secret
- **Note:** Always use tokens, never passwords. Tokens can be revoked/recreated without changing your account password

### Issue: Artifactory Publish Skipped
- **Cause:** Missing Artifactory credentials
- **Solution:** Add all four Artifactory secrets/variables

### Issue: GitLab Pipeline Fails on Docker Build
- **Cause:** Docker-in-Docker service not running
- **Solution:** Check GitLab runner configuration, ensure privileged mode enabled

### Issue: Tests Fail in CI but Pass Locally
- **Cause:** Dependency version differences or environment issues
- **Solution:** Pin dependency versions, check Python version matches

### Issue: Image Too Large
- **Cause:** Unnecessary files included in build context
- **Solution:** Update `.dockerignore` to exclude more files

## Extension Points

### Adding Multi-Architecture Builds
- Update GitHub Actions to build for `linux/amd64,linux/arm64`
- Update GitLab CI to use `buildx --platform` flags

### Adding Kubernetes Deployment
- Add Kubernetes manifests directory
- Add deployment job that applies manifests after image publish

### Adding Security Scanning
- Add Trivy or Snyk scan jobs
- Scan Docker images before publishing

### Adding Automated Testing
- Add integration tests
- Add performance tests
- Add security tests

### Adding Notifications
- Add Slack/Teams notifications on pipeline completion
- Add email notifications on failures

## Environment Variables Reference

### Application Runtime
- `FLASK_ENV`: Flask environment (development/production)
- `FLASK_DEBUG`: Enable/disable debug mode

### CI/CD (Not for application use)
- GitHub Actions uses `GITHUB_*` variables
- GitLab CI/CD uses `CI_*` variables
- Docker build contexts use build-time variables

## Version Tagging Format

**Standard:** `v{major}.{minor}.{patch}`
- Examples: `v1.0.0`, `v2.1.3`, `v0.1.0`
- **Regex:** `^v[0-9]+\.[0-9]+\.[0-9]+$`

**Best Practices:**
- Use semantic versioning (SemVer)
- Never reuse version tags
- Tag from release branches when possible

## Registry URLs Reference

### Docker Hub
- Registry URL: `docker.io` (default, can be omitted)
- Login: `docker login` or `docker login docker.io`
- Public images: No URL prefix needed
- Private images: `docker.io/{username}/{image}`

### GitLab Container Registry
- Registry URL: `registry.gitlab.com` (GitLab.com) or custom instance
- Login: Uses `CI_REGISTRY_USER` and `CI_REGISTRY_PASSWORD` automatically
- Format: `registry.gitlab.com/{group}/{project}/{image}`

### Artifactory
- Registry URL: Varies by organization
- Common formats:
  - `{instance}.jfrog.io`
  - `artifactory.{company}.com`
  - `docker.{company}.local`
- Login: Uses organization-specific credentials
- Format: `{registry-url}/{repository}/{image}`


### 6. render.yaml
**Location:** `/render.yaml`  
**Purpose:** Render.com service configuration file for automated deployment.

**Configuration:**
- **Type:** Web Service (Docker)
- **Environment:** Docker (uses Dockerfile)
- **Region:** Oregon (configurable)
- **Plan:** Free tier (configurable)
- **Auto Deploy:** Enabled (deploys on push to main branch)
- **Health Check:** `/health` endpoint
- **Port:** 5001 (auto-detected from EXPOSE in Dockerfile)

**Features:**
- Automatic deployments on Git push
- Health monitoring
- Environment variables support
- Single instance (free tier), scalable on paid plans

**Environment Variables:**
- `FLASK_ENV=production` – Production Flask environment
- `PYTHONUNBUFFERED=1` – Ensures Python output is unbuffered

### 7. GitHub Actions Render Deployment Job

**Location:** `/.github/workflows/ci-cd.yml` (deploy-render job)

**Purpose:** Optional GitHub Actions job to trigger Render deployments via API.

**Behavior:**
- Runs on pushes to `main`/`master` branches
- Runs on version tags (`v*.*.*`)
- Depends on: `test` job (must pass)
- Skips gracefully if Render credentials not configured

**Steps:**
1. Checkout code
2. Verify Render credentials exist
3. Trigger Render deployment via API

**Required GitHub Secrets:**
- `RENDER_API_KEY`: Render API key (from Render Dashboard → Account Settings → API Keys)
- `RENDER_SERVICE_ID`: Service ID from Render service URL (e.g., `https://dashboard.render.com/web/{SERVICE_ID}`)

**API Endpoint:**
- `POST https://api.render.com/deploy/{SERVICE_ID}?key={API_KEY}`
- Triggers a new deployment of the service

## Render.com Deployment

### Deployment Methods

#### Method 1: Automatic via Git Integration (Recommended)
1. Connect repository to Render.com
2. Render detects `render.yaml` automatically
3. Service auto-deploys on every push to main branch
4. Build logs visible in Render dashboard

#### Method 2: Manual via CI/CD API
- Configure GitHub Actions with Render secrets
- Actions job triggers Render deployment via API
- Useful for triggering deployments on tags/releases

#### Method 3: Docker Image Deployment
- Deploy using pre-built Docker images from Docker Hub
- Point Render service to Docker Hub image
- Useful when using existing CI/CD pipelines

### Render Service Configuration

**render.yaml Structure:**
```yaml
services:
  - type: web              # Web service
    name: calculator-app   # Service name
    env: docker            # Docker environment
    region: oregon         # Deployment region
    plan: free            # Service plan
    dockerfilePath: ./Dockerfile
    dockerContext: .
    envVars:              # Environment variables
      - key: FLASK_ENV
        value: production
    healthCheckPath: /health
    autoDeploy: true      # Auto-deploy on push
    startCommand: python app.py
```

**Render Regions:**
- `oregon` (US West)
- `frankfurt` (Europe)
- `singapore` (Asia Pacific)

**Render Plans:**
- `free`: Free tier with limitations
- `starter`: $7/month
- `standard`: $25/month
- `pro`: $85/month
- Custom pricing available

### Render Deployment Flow

```
Git Push to Main
       │
       ▼
Render Detects Change (if Git connected)
       │
       ├─── Reads render.yaml ────► Configures service
       │
       ├─── Builds Docker Image ──► From Dockerfile
       │
       ├─── Starts Container ────► Runs startCommand
       │
       └─── Health Check ────────► Monitors /health endpoint
```

### Render vs Other Platforms

| Feature | Render.com | Docker Hub | Artifactory |
|---------|------------|------------|-------------|
| **Purpose** | Hosting/Deployment | Image Registry | Enterprise Registry |
| **Build** | ✅ Automatic | ❌ | ❌ |
| **Deploy** | ✅ Automatic | ❌ | ❌ |
| **Free Tier** | ✅ (with limits) | ✅ | ❌ |
| **Auto Scale** | ✅ (paid) | N/A | N/A |
| **Git Integration** | ✅ | ❌ | ❌ |

### Render Limitations (Free Tier)

- **Service Sleep:** Services sleep after 15 minutes of inactivity
- **Cold Start:** First request after sleep takes ~30 seconds
- **Build Minutes:** Limited free build minutes per month
- **Instances:** Single instance only
- **Custom Domains:** Limited on free tier

### Render Monitoring

- **Logs:** Real-time application logs
- **Metrics:** CPU, Memory, Request count
- **Health:** Automatic health check monitoring
- **Alerts:** Email/webhook notifications on failures

### Render Environment Variables

Set in Render Dashboard → Environment tab or in `render.yaml`:
- Application-specific variables
- Secret variables (encrypted)
- Environment-specific variables (staging/production)

## Updated Workflow Comparison

| Feature | GitHub Actions | GitLab CI/CD | Render.com |
|---------|---------------|--------------|------------|
| **Test Execution** | ✅ All pushes/PRs | ✅ All branches/MRs | ❌ |
| **Build Trigger** | ✅ On tags | ✅ All branches/tags | ✅ On push to main |
| **GitLab Registry** | ❌ | ✅ Always builds | ❌ |
| **Docker Hub** | ✅ On tags | ✅ On version tags | ❌ |
| **Artifactory** | ✅ On tags | ✅ On tags (manual) | ❌ |
| **Auto Deploy** | ❌ | ❌ | ✅ On push |
| **Hosting** | ❌ | ❌ | ✅ Web service |
| **Health Monitoring** | ❌ | ❌ | ✅ Built-in |

## Conclusion

This CI/CD setup provides:
- ✅ Automated testing on all code changes
- ✅ Docker image building and publishing
- ✅ Multi-registry support (Docker Hub, Artifactory, GitLab Registry)
- ✅ Cloud deployment (Render.com)
- ✅ Local development environment (Docker Compose)
- ✅ Security best practices (non-root containers, secret management)
- ✅ Flexible deployment options
- ✅ Comprehensive documentation

The setup is production-ready and can be extended based on organizational needs.

