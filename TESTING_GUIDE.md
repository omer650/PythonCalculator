# Testing CI/CD Workflows - GitHub Actions, GitLab CI/CD, and Docker Compose

## Quick Test Steps

### Option 1: Test via GitHub Push (Recommended)

1. **Commit and push the changes:**
   ```bash
   git add .github/ Dockerfile .dockerignore README.md
   git commit -m "Add CI/CD workflow with Docker Hub publishing"
   git push origin main
   ```

2. **Watch the workflow run:**
   - Go to: https://github.com/bargigsoftwar/GitExercise/actions
   - Click on the running workflow
   - View logs for the "Run tests (pytest)" job

3. **Test the Docker build (when ready):**
   - Create and push a tag:
     ```bash
     git tag v1.0.0
     git push origin v1.0.0
     ```
   - This will trigger the Docker build and publish job

### Option 2: Test Locally with Act

If Docker Desktop is running:

```bash
# Install act (if not installed)
brew install act

# Test the CI job only
act push --job test --container-architecture linux/amd64

# Test with a mock Docker secret (for docker job testing)
act push --job docker --secret DOCKER_USERNAME=testuser --secret DOCKER_TOKEN=testtoken --container-architecture linux/amd64
```

### Option 3: Test Docker Build Locally

Build and test the Docker image:

```bash
# Build the image
docker build -t calculator-app:test .

# Test running it
docker run -p 5001:5001 calculator-app:test

# In another terminal, test the API
curl http://localhost:5001/health
```

## Current Workflow Behavior

- **On push to main/master/team-z-moshe**: Runs tests only
- **On tag v*.*.***: Runs tests + Builds and publishes Docker image to Docker Hub

## Required GitHub Secrets (for Docker publishing)

**Docker Hub Configuration:**

1. **Add Variable (Settings → Variables):**
   - `DOCKER_USERNAME`: Your Docker Hub username

2. **Add Secret (Settings → Secrets):**
   - `DOCKER_TOKEN`: Your Docker Hub Personal Access Token (not password)

**Generate Docker Hub Token:**
1. [Docker Hub](https://hub.docker.com) → Account Settings → Security
2. Click "New Access Token"
3. Name it (e.g., "GitHub Actions")
4. Copy token (shown only once)
5. Permissions: "Read, Write & Delete"

## Testing the Different Triggers

### Test CI on Push
```bash
git add .
git commit -m "Test CI workflow"
git push origin main
```

### Test Docker Publish on Tag
```bash
git tag v1.0.0
git push origin v1.0.0
```

## Docker Compose Testing

### Local Development with Docker Compose

```bash
# Start services
docker-compose up

# Run in background
docker-compose up -d

# View logs
docker-compose logs -f calculator-app

# Stop services
docker-compose down

# Rebuild and restart
docker-compose up --build

# Health check
curl http://localhost:5001/health
```

## GitLab CI/CD Testing

If you have a GitLab repository:

1. **Push the `.gitlab-ci.yml` file:**
   ```bash
   git add .gitlab-ci.yml
   git commit -m "Add GitLab CI/CD pipeline"
   git push origin main
   ```

2. **Set GitLab CI/CD Variables:**
   - Go to: `Settings → CI/CD → Variables`
   - Add: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` (Personal Access Token, not password)
   - Add (optional): `ARTIFACTORY_URL`, `ARTIFACTORY_REPO`, `ARTIFACTORY_USERNAME`, `ARTIFACTORY_PASSWORD`

3. **Watch the pipeline:**
   - Go to: `CI/CD → Pipelines` in GitLab

4. **Test with a version tag:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

## Artifactory Setup

### Artifactory Configuration

**For GitHub Actions:**
- Secrets needed: `ARTIFACTORY_URL`, `ARTIFACTORY_REPO`, `ARTIFACTORY_USERNAME`, `ARTIFACTORY_PASSWORD`
- Images are published to: `${ARTIFACTORY_URL}/${ARTIFACTORY_REPO}/calculator-app`

**For GitLab CI/CD:**
- Variables needed: `ARTIFACTORY_URL`, `ARTIFACTORY_REPO`, `ARTIFACTORY_USERNAME`, `ARTIFACTORY_PASSWORD`
- Publish is manual (trigger from GitLab UI)

### Typical Artifactory URLs
- JFrog Artifactory: `your-artifactory.jfrog.io` or `artifactory.yourdomain.com`
- Repository format: Usually `docker` or `docker-local`

## Render.com Deployment Testing

### Option 1: Automatic Deployment (Recommended)

1. **Setup:**
   - Create account at [render.com](https://render.com)
   - Go to Dashboard → New + → Web Service
   - Connect GitHub/GitLab repository
   - Render will detect `render.yaml` automatically

2. **Test Deployment:**
   ```bash
   git add render.yaml
   git commit -m "Add Render deployment"
   git push origin main
   ```
   - Render will automatically build and deploy
   - Check deployment status in Render Dashboard

3. **Verify Deployment:**
   ```bash
   # Get your Render URL from dashboard
   curl https://calculator-app.onrender.com/health
   ```

### Option 2: Test via GitHub Actions

1. **Get Render Credentials:**
   - Render Dashboard → Account Settings → API Keys → Create API Key
   - Service URL: `https://dashboard.render.com/web/{SERVICE_ID}`
   - Extract SERVICE_ID from URL

2. **Add GitHub Secrets:**
   - GitHub → Settings → Secrets → Actions
   - Add: `RENDER_API_KEY`
   - Add: `RENDER_SERVICE_ID`

3. **Trigger Deployment:**
   ```bash
   git push origin main
   # Check GitHub Actions → deploy-render job
   ```

### Option 3: Manual Deployment

1. **In Render Dashboard:**
   - Create new Web Service
   - Select Docker environment
   - Point to Docker Hub image: `{username}/calculator-app:latest`
   - Configure and deploy

### Render Health Check

Test your deployed service:
```bash
# Health endpoint
curl https://calculator-app.onrender.com/health

# Expected response:
# {"status":"healthy","message":"Calculator web app is running!"}
```

### Render Logs

View deployment and application logs:
- Render Dashboard → Service → Logs
- Real-time log streaming
- Historical logs available
