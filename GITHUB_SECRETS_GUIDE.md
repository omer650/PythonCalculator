# GitHub Secrets and Variables Required for CI/CD

This document lists all GitHub secrets and variables needed for the CI/CD pipeline to work fully.

## 📋 Complete List

### 🔴 Required (for Docker Hub publishing)

These are **required** if you want to publish Docker images to Docker Hub:

| Name | Type | Description | How to Get |
|------|------|-------------|------------|
| `DOCKER_USERNAME` | **Secret** | Your Docker Hub username | Your Docker Hub account username |
| `DOCKER_TOKEN` | **Secret** | Docker Hub Personal Access Token | See instructions below ⬇️ |

**Important:**
- Both `DOCKER_USERNAME` and `DOCKER_TOKEN` → Set as **Secrets** (Settings → Secrets and variables → Actions → Secrets)

### 🟡 Optional (for Artifactory publishing)

These secrets are **optional** - the workflow will skip Artifactory publishing if not set:

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `ARTIFACTORY_URL` | Your Artifactory registry URL | From your Artifactory instance (e.g., `artifactory.company.com`) |
| `ARTIFACTORY_REPO` | Repository name in Artifactory | The Docker repository name (e.g., `docker` or `docker-local`) |
| `ARTIFACTORY_USERNAME` | Artifactory username | Your Artifactory account username |
| `ARTIFACTORY_PASSWORD` | Artifactory password or API key | Your Artifactory password or generated API key |

### 🟡 Optional (for Render.com deployment)

These secrets are **optional** - the workflow will skip Render deployment if not set:

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `RENDER_API_KEY` | Render.com API key | See instructions below ⬇️ |
| `RENDER_SERVICE_ID` | Render service ID | See instructions below ⬇️ |

## 🔧 How to Add Secrets

### Adding Docker Hub Username (Secret)

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **Secrets** tab
4. Click **New repository secret**
5. Name: `DOCKER_USERNAME`
6. Value: Your Docker Hub username (e.g., `morbargig`)
7. Click **Add secret**

### Adding Docker Hub Token (Secret)

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **Secrets** tab
4. Click **New repository secret**
5. Name: `DOCKER_TOKEN`
6. Value: Your Docker Hub Personal Access Token
7. Click **Add secret**

## 📝 Detailed Instructions

### Docker Hub Token (`DOCKER_TOKEN`)

**⚠️ IMPORTANT:** Use a Personal Access Token, NOT your password!

**Steps:**
1. Go to [Docker Hub](https://hub.docker.com) and sign in
2. Click your profile icon → **Account Settings**
3. Click **Security** tab
4. Click **New Access Token**
5. Enter a name (e.g., "GitHub Actions CI/CD")
6. Select permissions: **Read, Write & Delete** (needed for pushing images)
7. Click **Generate**
8. **Copy the token immediately** - it won't be shown again!
9. Add it as `DOCKER_TOKEN` secret in GitHub

**Format:** 
- Token looks like: `dckr_pat_xxxxxxxxxxxxxxxxxxxxxxxxxx`
- Length: ~40+ characters

### Render.com Secrets

#### Getting `RENDER_API_KEY`:
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click your profile → **Account Settings**
3. Scroll to **API Keys** section
4. Click **Create API Key**
5. Give it a name (e.g., "GitHub Actions")
6. Copy the API key
7. Add it as `RENDER_API_KEY` secret in GitHub

#### Getting `RENDER_SERVICE_ID`:
1. Go to your Render service (or create one)
2. Look at the service URL in the browser: `https://dashboard.render.com/web/{SERVICE_ID}`
3. Copy the `{SERVICE_ID}` part from the URL
4. Add it as `RENDER_SERVICE_ID` secret in GitHub

**Example:** If URL is `https://dashboard.render.com/web/srv-abc123def456`, then `SERVICE_ID = srv-abc123def456`

### Artifactory Secrets

Get these from your organization's Artifactory administrator:
- **ARTIFACTORY_URL**: Usually like `artifactory.company.com` or `company.jfrog.io`
- **ARTIFACTORY_REPO**: Typically `docker`, `docker-local`, or similar
- **ARTIFACTORY_USERNAME**: Your Artifactory login username
- **ARTIFACTORY_PASSWORD**: Your password or API key

## ✅ Quick Setup Checklist

### Minimum Setup (CI only)
- [ ] **No secrets or variables required!** 
- Tests will run on every push
- Docker publishing requires setup below

### Docker Hub Publishing
- [ ] `DOCKER_USERNAME` - **Secret** - Your Docker Hub username
- [ ] `DOCKER_TOKEN` - **Secret** - Personal Access Token (not password!)

### Full Setup (All Features)
- [ ] `DOCKER_USERNAME` + `DOCKER_TOKEN`
- [ ] `ARTIFACTORY_URL` + `ARTIFACTORY_REPO` + `ARTIFACTORY_USERNAME` + `ARTIFACTORY_PASSWORD` (optional)
- [ ] `RENDER_API_KEY` + `RENDER_SERVICE_ID` (optional)

## 🎯 What Each Secret Does

### `DOCKER_USERNAME` & `DOCKER_TOKEN` (Both Secrets)
- **Used by:** `docker-hub` job
- **When:** On pushes to `main`/`master` branches or version tags (`v1.0.0`, etc.)
- **Purpose:** Authenticates to Docker Hub and pushes images
- **Required:** Yes, for Docker Hub publishing
- **Note:** Both are stored as **Secrets** (Settings → Secrets)

### `ARTIFACTORY_*` secrets
- **Used by:** `artifactory` job
- **When:** On version tags (`v1.0.0`, etc.)
- **Purpose:** Authenticates to Artifactory and pushes images
- **Required:** No - workflow skips if not set

### `RENDER_API_KEY` & `RENDER_SERVICE_ID`
- **Used by:** `deploy-render` job
- **When:** On `main`/`master` branches and tags
- **Purpose:** Triggers Render.com deployments via API
- **Required:** No - workflow skips if not set

## 🔍 How to Verify Secrets

### Check if secrets are set (in workflow):

The workflow automatically checks for secrets:

**Artifactory:**
```yaml
if [ -z "${{ secrets.ARTIFACTORY_URL }}" ] || [ -z "${{ secrets.ARTIFACTORY_USERNAME }}" ] || [ -z "${{ secrets.ARTIFACTORY_PASSWORD }}" ]; then
    echo "Artifactory credentials not set, skipping..."
```

**Render:**
```yaml
if [ -z "${{ secrets.RENDER_API_KEY }}" ] || [ -z "${{ secrets.RENDER_SERVICE_ID }}" ]; then
    echo "Render credentials not set, skipping..."
```

### Test locally with act:

Create `.act-secrets` file (don't commit!):
```
DOCKER_USERNAME=your-username
DOCKER_TOKEN=your-token
RENDER_API_KEY=your-key
RENDER_SERVICE_ID=your-service-id
```

Then test:
```bash
act push --secret-file .act-secrets --job docker-hub
```

## ⚠️ Security Best Practices

1. **Never commit secrets to git** - Always use GitHub Secrets
2. **Use tokens, not passwords** - Tokens can be revoked without changing passwords
3. **Rotate tokens regularly** - Change tokens periodically for security
4. **Use least privilege** - Give tokens only the permissions they need
5. **Delete unused secrets** - Remove secrets you no longer use

## 📊 Secret Usage Matrix

| Name | Type | Docker Hub | Artifactory | Render | Required |
|------|------|-----------|-------------|--------|----------|
| `DOCKER_USERNAME` | Secret | ✅ | ❌ | ❌ | For Docker Hub |
| `DOCKER_TOKEN` | Secret | ✅ | ❌ | ❌ | For Docker Hub |
| `ARTIFACTORY_URL` | ❌ | ✅ | ❌ | Optional |
| `ARTIFACTORY_REPO` | ❌ | ✅ | ❌ | Optional |
| `ARTIFACTORY_USERNAME` | ❌ | ✅ | ❌ | Optional |
| `ARTIFACTORY_PASSWORD` | ❌ | ✅ | ❌ | Optional |
| `RENDER_API_KEY` | ❌ | ❌ | ✅ | Optional |
| `RENDER_SERVICE_ID` | ❌ | ❌ | ✅ | Optional |

## 🚀 Getting Started

1. **Minimum (CI only):**
   - Push code → Tests run automatically ✅
   - No secrets needed for testing!

2. **With Docker Hub:**
   - Add `DOCKER_USERNAME` and `DOCKER_TOKEN`
   - Create a tag: `git tag v1.0.0 && git push origin v1.0.0`
   - Image will be published automatically

3. **With All Features:**
   - Add all Docker Hub secrets
   - Add Artifactory secrets (optional)
   - Add Render secrets (optional)
   - Full pipeline will run on tags

## 📖 Related Files

- `.github/workflows/ci-cd.yml` - Workflow definitions
- `README.md` - Project documentation with secret references
- `CI_CD_DOCUMENTATION.md` - Comprehensive CI/CD guide

## ❓ Common Questions

**Q: Do I need all secrets?**  
A: No! Only `DOCKER_USERNAME` and `DOCKER_TOKEN` if you want Docker Hub publishing. Others are optional.

**Q: What if I don't add optional secrets?**  
A: The workflow will automatically skip those jobs. Your CI will still work perfectly!

**Q: Can I use my Docker Hub password?**  
A: No! Use a Personal Access Token. It's more secure and easier to manage.

**Q: How do I test secrets locally?**  
A: Use act with a `.act-secrets` file (see Testing section above).

**Q: Where are secrets stored?**  
A: GitHub encrypts and stores them securely. They're only accessible to your workflows.


