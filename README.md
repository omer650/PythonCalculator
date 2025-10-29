# 🧮 Python Calculator Web App

A simple calculator web application for students to practice Python programming.

## 🎯 Project Goal

Students implement calculator methods in `calculator.py` and test them via a web interface.

## 🚀 Setup

1. **Open in VS Code**
2. **Reopen in Container** (VS Code will prompt you)
3. **Run the calculator**:
   ```bash
   python app.py
   ```
4. **Open browser**: `http://localhost:5001`

## 🧪 Test Your Code

```bash
python main.py    # CLI version
pytest           # Run tests
```

## 📝 Student Task

Implement these methods in `calculator.py`:

```python
def add(self, a, b):
    # TODO: Implement addition
    result = a + b
    self.history.append(f"{a} + {b} = {result}")
    return result

def subtract(self, a, b):
    # TODO: Implement subtraction
    result = a - b
    self.history.append(f"{a} - {b} = {result}")
    return result

def multiply(self, a, b):
    # TODO: Implement multiplication
    result = a * b
    self.history.append(f"{a} × {b} = {result}")
    return result

def divide(self, a, b):
    # TODO: Implement division
    if b == 0:
        raise ValueError("Cannot divide by zero")
    result = a / b
    self.history.append(f"{a} ÷ {b} = {result}")
    return result
```

## 🎮 How It Works

1. **Unimplemented**: Calculator shows "method not implemented yet!"
2. **Implement**: Add code to calculator methods
3. **Test**: Use web calculator to see results
4. **History**: View calculation history

## 📝 What to Do

1. **Implement methods** in `calculator.py` (replace `pass` with real code)
2. **Test your work** by running the web app or CLI
3. **Check tests** with `pytest`

## 📁 Files

- `calculator.py` - **Implement methods here** 
- `app.py` - Web server (already done)
- `main.py` - CLI version (already done)
- `test_calculator.py` - Tests (already done)

## ✅ Done!

When all methods work, the calculator will be complete! 🎉

## 🐳 Docker

### Build and Run Locally

Build the image locally:

```bash
docker build -t calculator-app:local .
```

Run the container:

```bash
docker run --rm -p 5001:5001 calculator-app:local
```

### Docker Compose

For local development with docker-compose:

```bash
# Start the application
docker-compose up

# Or run in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the application
docker-compose down
```

The compose file includes:
- Application service on port 5001
- Health checks
- Volume mounts for live development (optional)
- Network configuration

## 🔄 CI/CD

This project includes CI/CD pipelines for multiple platforms.

### GitHub Actions

GitHub Actions workflow (`.github/workflows/ci-cd.yml`) that:
- **Runs tests** on pushes and pull requests
- **Publishes to Docker Hub** on version tags (e.g., `v1.2.3`)
- **Publishes to Artifactory** on version tags (optional)

#### Required GitHub Secrets:

**For Docker Hub:**
- `DOCKER_USERNAME` – your Docker Hub username
- `DOCKER_TOKEN` – Docker Hub access token (required - use Personal Access Token, not password)

**How to get Docker Hub token:**
1. Go to [Docker Hub](https://hub.docker.com) → Account Settings → Security
2. Click "New Access Token"
3. Give it a name (e.g., "GitHub Actions")
4. Copy the token immediately (it won't be shown again)
5. Set permissions: "Read, Write & Delete" for publishing images

**For Artifactory (optional):**
- `ARTIFACTORY_URL` – Artifactory registry URL (e.g., `https://your-artifactory.com`)
- `ARTIFACTORY_REPO` – Docker repository name in Artifactory
- `ARTIFACTORY_USERNAME` – Artifactory username
- `ARTIFACTORY_PASSWORD` – Artifactory password/API key

#### Image Tags:
- Docker Hub: `${DOCKER_USERNAME}/calculator-app:latest` and `:vX.Y.Z`
- Artifactory: `${ARTIFACTORY_URL}/${ARTIFACTORY_REPO}/calculator-app:latest` and `:vX.Y.Z`

### GitLab CI/CD

GitLab CI/CD pipeline (`.gitlab-ci.yml`) that includes:

**Stages:**
1. **test** – Runs pytest on all branches and merge requests
2. **build** – Builds Docker image and pushes to GitLab Container Registry
3. **publish** – Publishes to Docker Hub and Artifactory (on version tags)

#### Required GitLab CI/CD Variables:

**Built-in GitLab variables (automatically available):**
- `CI_REGISTRY_USER`, `CI_REGISTRY_PASSWORD`, `CI_REGISTRY` – GitLab Container Registry
- `CI_REGISTRY_IMAGE` – Registry image path

**Custom variables to add:**

**For Docker Hub:**
- `DOCKERHUB_USERNAME` – Docker Hub username
- `DOCKERHUB_TOKEN` – Docker Hub Personal Access Token (required - not password)

**How to get Docker Hub token:**
1. Go to [Docker Hub](https://hub.docker.com) → Account Settings → Security
2. Click "New Access Token"
3. Give it a name (e.g., "GitLab CI/CD")
4. Copy the token immediately
5. Set permissions: "Read, Write & Delete"

**For Artifactory:**
- `ARTIFACTORY_URL` – Artifactory registry URL
- `ARTIFACTORY_REPO` – Docker repository name
- `ARTIFACTORY_USERNAME` – Artifactory username
- `ARTIFACTORY_PASSWORD` – Artifactory password/API key

#### GitLab Pipeline Behavior:
- **All branches/tags:** Runs tests and builds image to GitLab registry
- **Version tags (vX.Y.Z):** Also publishes to Docker Hub and Artifactory
- **Artifactory publish:** Manual stage (can be triggered from GitLab UI)

#### Setting GitLab Variables:
Go to: `Settings → CI/CD → Variables` in your GitLab project

### CI/CD Summary

| Platform | Test | Build | Docker Hub | Artifactory | Render Deploy |
|----------|------|-------|------------|-------------|---------------|
| GitHub Actions | ✅ All pushes/PRs | ✅ On tags | ✅ On tags | ✅ On tags (optional) | ✅ On main/tags (optional) |
| GitLab CI/CD | ✅ All branches/MRs | ✅ All branches | ✅ On tags | ✅ On tags (manual) | ❌ |

### Testing CI/CD

**GitHub:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

**GitLab:**
```bash
git tag v1.0.0
git push origin v1.0.0
# Then manually trigger Artifactory publish in GitLab UI if needed
```

## ☁️ Render.com Deployment

This project includes configuration for deploying to [Render.com](https://render.com), a cloud platform for hosting Docker containers and web services.

### Render Configuration

The `render.yaml` file configures automatic deployment to Render.com:

- **Service Type:** Web Service (Docker)
- **Region:** Oregon (configurable)
- **Plan:** Free tier (upgradeable)
- **Health Check:** `/health` endpoint
- **Auto Deploy:** Enabled (deploys on push to main)

### Setup Options

#### Option 1: Automatic Deployment (Recommended)

1. **Connect Repository to Render:**
   - Go to [Render Dashboard](https://dashboard.render.com)
   - Click "New +" → "Web Service"
   - Connect your GitHub/GitLab repository
   - Select the repository and branch (e.g., `main`)
   - Render will detect `render.yaml` automatically

2. **Configure Service:**
   - Render will use settings from `render.yaml`
   - Set environment variables if needed (in Render dashboard)
   - Review and create service

3. **Automatic Deploys:**
   - Every push to `main` branch triggers automatic deployment
   - Build logs available in Render dashboard

#### Option 2: Manual Deployment via CI/CD

Configure GitHub Actions to trigger Render deployments:

**Required GitHub Secrets:**
- `RENDER_API_KEY` – Your Render API key (get from Render Dashboard → Account Settings → API Keys)
- `RENDER_SERVICE_ID` – Your Render service ID (found in service URL: `https://dashboard.render.com/web/{SERVICE_ID}`)

**Deployment Behavior:**
- Triggers on push to `main`/`master` branches
- Triggers on version tags (`v*.*.*`)
- Skips automatically if credentials not set

#### Option 3: Docker Image Deployment

If you've published images to Docker Hub, you can deploy from Docker Hub:

1. In Render Dashboard, create new "Web Service"
2. Choose "Docker" environment
3. Enter Docker image: `{DOCKER_USERNAME}/calculator-app:latest`
4. Configure as needed

### Render Environment Variables

Set these in Render Dashboard → Environment:

- `FLASK_ENV=production` (already in render.yaml)
- `PYTHONUNBUFFERED=1` (already in render.yaml)
- Add custom variables as needed

### Render Service URLs

After deployment, your service will be available at:
- Free tier: `https://calculator-app.onrender.com` (or custom domain)
- Custom domains can be configured in Render dashboard

### Render Deploy Commands

The service uses:
- **Build Command:** (empty, handled by Docker)
- **Start Command:** `python app.py`
- **Health Check:** `GET /health`

### Monitoring & Logs

- View logs: Render Dashboard → Service → Logs
- Metrics: CPU, Memory, Request count
- Alerts: Configure in Render Dashboard

### Render Limitations (Free Tier)

- Services sleep after 15 minutes of inactivity (wake on first request)
- Limited build minutes per month
- Single instance

**Upgrade for:**
- Always-on services (no sleep)
- Multiple instances
- More build minutes
- Custom domains with SSL
