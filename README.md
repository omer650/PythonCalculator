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

## 📚 Documentation

### Quick References
- **GitLab CI/CD Setup**: See [GitLab CI/CD section](#gitlab-cicd) above for quick setup
- **Complete GitLab Guide**: [GITLAB_CI_CD_SETUP.md](GITLAB_CI_CD_SETUP.md) - Comprehensive educational guide with detailed explanations
- **Testing Guide**: [TESTING_GUIDE.md](TESTING_GUIDE.md) - How to test your calculator
- **Troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions

### Other Documentation
- **CI/CD Overview**: [CI_CD_DOCUMENTATION.md](CI_CD_DOCUMENTATION.md) - Detailed CI/CD architecture explanation
- **GitHub Secrets**: [GITHUB_SECRETS_GUIDE.md](GITHUB_SECRETS_GUIDE.md) - Setting up GitHub Actions secrets
- **Docker Username**: [SETUP_DOCKER_USERNAME.md](SETUP_DOCKER_USERNAME.md) - Docker Hub setup

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
- `DOCKER_USERNAME` – **Secret** – your Docker Hub username
- `DOCKER_TOKEN` – **Secret** – Docker Hub Personal Access Token (not password!)

**Setup:**
1. **Add `DOCKER_USERNAME` as Secret:**
   - GitHub → Settings → Secrets and variables → Actions → Secrets
   - Click "New repository secret"
   - Name: `DOCKER_USERNAME`
   - Value: Your Docker Hub username (e.g., `morbargig`)
   - Click "Add secret"

2. **Add `DOCKER_TOKEN` as Secret:**
   - GitHub → Settings → Secrets and variables → Actions → Secrets
   - Go to [Docker Hub](https://hub.docker.com) → Account Settings → Security
   - Click "New Access Token", name it (e.g., "GitHub Actions")
   - Set permissions: "Read, Write & Delete"
   - Copy token and add as `DOCKER_TOKEN` secret

**For Artifactory (optional):**
- `ARTIFACTORY_URL` – Artifactory registry URL (e.g., `https://your-artifactory.com`)
- `ARTIFACTORY_REPO` – Docker repository name in Artifactory
- `ARTIFACTORY_USERNAME` – Artifactory username
- `ARTIFACTORY_PASSWORD` – Artifactory password/API key

#### Image Tags:
- Docker Hub: `${DOCKER_USERNAME}/calculator-app:latest` and `:vX.Y.Z`
- Artifactory: `${ARTIFACTORY_URL}/${ARTIFACTORY_REPO}/calculator-app:latest` and `:vX.Y.Z`

### GitLab CI/CD

This project includes a complete GitLab CI/CD setup with Docker Compose, including:
- GitLab CE (Community Edition) running locally
- GitLab Runner for executing CI/CD jobs
- Artifactory OSS for Docker registry

**📖 For complete educational guide, see [GITLAB_CI_CD_SETUP.md](GITLAB_CI_CD_SETUP.md)**

#### Quick Setup

**Option 1: Automated Setup (Recommended)**
```bash
make setup
```
This will start all services, wait for GitLab to initialize, display the root password, and register the GitLab Runner automatically.

**Option 2: Manual Setup**

1. **Start Services:**
   ```bash
   make up
   ```
   Wait 2-3 minutes for GitLab to fully initialize.

2. **Get GitLab Root Password:**
   ```bash
   make bootstrap
   ```
   Save the password shown (it's only displayed once).

3. **Access GitLab:**
   - Open browser: `http://localhost:8080`
   - Login with username: `root` and the password from step 2
   - Create a new project or push your code

4. **Register GitLab Runner:**

   **Step 4a: Get Registration Token from GitLab UI**
   - In GitLab: Go to **Settings → CI/CD → Runners**
   - Expand **"Set up a specific runner manually"**
   - Copy the **Registration Token** (looks like `glrt-xxxxxxxxxxxxxxxxxxxx`)
   - Note the GitLab URL shown (use `http://gitlab` for internal network)

   **Step 4b: Register the Runner**
   ```bash
   make register
   ```
   When prompted:
   - GitLab URL: `http://gitlab` (or `http://localhost:8080`)
   - Registration Token: (paste the token from Step 4a)

   **Alternative: Manual Registration**
   ```bash
   docker exec -it gitlab-runner gitlab-runner register \
     --url http://gitlab \
     --registration-token YOUR_TOKEN_HERE \
     --executor docker \
     --docker-image docker:24 \
     --description "docker-runner" \
     --tag-list "docker,linux" \
     --run-untagged="true"
   ```

5. **Verify Runner Registration:**
   ```bash
   docker exec gitlab-runner gitlab-runner list
   ```
   You should see your runner listed. Also verify in GitLab UI: **Settings → CI/CD → Runners** (should show a green circle).

#### GitLab CI/CD Pipeline

The `.gitlab-ci.yml` defines three stages:

1. **test** – Runs pytest on all branches and merge requests
2. **build** – Builds Docker image and pushes to GitLab Container Registry
3. **push** – Publishes to Artifactory (optional, manual trigger)

#### Useful Commands

```bash
make help          # Show all available commands
make up            # Start all services
make down          # Stop all services
make logs          # View logs from all services
make status        # Check service status
make bootstrap     # Get GitLab root password
make register      # Register GitLab Runner
make clean         # Remove everything (⚠️ deletes all data)
```

#### Access URLs

- **GitLab:** http://localhost:8080 (username: `root`, password: run `make bootstrap`)
- **Artifactory:** http://localhost:8081 (username: `admin`, password: `password`)
- **Artifactory Docker Registry:** http://localhost:8082

#### GitLab CI/CD Variables

**Built-in variables (automatically available):**
- `CI_REGISTRY_USER`, `CI_REGISTRY_PASSWORD`, `CI_REGISTRY` – GitLab Container Registry
- `CI_REGISTRY_IMAGE` – Registry image path

**Optional: Configure Artifactory Variables**

If you want to use Artifactory (optional), set these in GitLab: **Settings → CI/CD → Variables**

| Variable | Value | Protected | Masked |
|----------|-------|-----------|--------|
| `ARTIFACTORY_USERNAME` | `admin` | ❌ | ❌ |
| `ARTIFACTORY_PASSWORD` | `password` | ❌ | ✅ |
| `ARTIFACTORY_URL` | `http://artifactory:8082` | ❌ | ❌ |
| `ARTIFACTORY_REPO` | `docker-local` | ❌ | ❌ |

**Note:** First create the `docker-local` repository in Artifactory:
1. Login to http://localhost:8081 (admin/password)
2. Go to **Repositories → Add Repositories → Docker**
3. Name: `docker-local`, Type: Local, Save

#### Pipeline Behavior:
- **All branches/tags:** Runs tests and builds image to GitLab Container Registry
- **Artifactory push:** Manual stage (trigger from GitLab UI → Pipelines)

### CI/CD Summary

| Platform | Test | Build | Docker Hub | Artifactory | Render Deploy |
|----------|------|-------|------------|-------------|---------------|
| GitHub Actions | ✅ All pushes/PRs | ✅ On tags | ✅ On tags | ✅ On tags (optional) | ✅ On main/tags (optional) |
| GitLab CI/CD | ✅ All branches/MRs | ✅ All branches | ❌ | ✅ Manual trigger | ❌ |

**Note**: GitLab CI/CD runs locally via Docker Compose with GitLab CE, Runner, and Artifactory. See [GITLAB_CI_CD_SETUP.md](GITLAB_CI_CD_SETUP.md) for detailed educational guide.

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
