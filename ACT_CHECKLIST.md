# Act Testing Checklist & Status

## ✅ Setup Verification

- [x] Act installed (`act --version`)
- [x] Docker Desktop running
- [x] Workflow file valid (`.github/workflows/ci-cd.yml`)
- [x] Git repository initialized
- [x] Test files present (`test_calculator.py`)

## 📋 Required Secrets for Full Testing

### For `test` Job
- ✅ **No secrets required** - Can test immediately!

### For `docker-hub` Job
- [ ] `DOCKER_USERNAME` - Your Docker Hub username
- [ ] `DOCKER_TOKEN` - Docker Hub Personal Access Token (not password!)

**Note:** This job only runs on tags (`v*.*.*`), so local testing requires:
- Creating a test tag event file, OR
- Temporarily modifying the `if:` condition

### For `artifactory` Job
- [ ] `ARTIFACTORY_URL` - Your Artifactory registry URL
- [ ] `ARTIFACTORY_REPO` - Repository name in Artifactory
- [ ] `ARTIFACTORY_USERNAME` - Artifactory username
- [ ] `ARTIFACTORY_PASSWORD` - Artifactory password/API key

**Note:** This job only runs on tags, same as docker-hub job.

### For `deploy-render` Job
- [ ] `RENDER_API_KEY` - From Render Dashboard → Account Settings
- [ ] `RENDER_SERVICE_ID` - From Render service URL

**Note:** This job runs on `main`/`master` branches and tags.

## 🧪 Testing Commands

### Test Job (Easiest - Start Here!)
```bash
act push --job test --container-architecture linux/amd64
```

### Docker Hub Job (Requires Secrets + Tag Event)
```bash
# Create secrets file first
cat > .act-secrets <<EOF
DOCKER_USERNAME=your-username
DOCKER_TOKEN=your-token
EOF

# Test (may need tag event simulation)
act push --job docker-hub \
  --secret-file .act-secrets \
  --container-architecture linux/amd64
```

## ⚠️ Known Issues & Solutions

### Issue: Job doesn't run due to conditions
**Problem:** Jobs have `if:` conditions that prevent them from running on regular pushes.

**Solution Options:**
1. Use appropriate event files (see ACT_TESTING_GUIDE.md)
2. Temporarily comment out conditions for testing
3. Use `--eventpath` with a custom event JSON

### Issue: Secrets not available
**Problem:** Act can't access GitHub secrets.

**Solution:**
- Create `.act-secrets` file (don't commit!)
- Use `--secret-file .act-secrets`
- Or pass directly: `--secret KEY=value`

### Issue: Docker build fails in act
**Problem:** Docker-in-Docker may not work perfectly in act.

**Solution:**
- Test Docker builds separately: `docker build -t test .`
- Use `--dryrun` to validate workflow without executing

## 📝 Quick Validation Steps

1. **Syntax Check:**
   ```bash
   act --list  # Should show all jobs without errors
   ```

2. **Test Job:**
   ```bash
   act push --job test --container-architecture linux/amd64
   ```

3. **Dry Run (all jobs):**
   ```bash
   act push --dryrun --container-architecture linux/amd64
   ```

4. **Validate Workflow File:**
   - Check YAML syntax
   - Verify all secrets referenced exist in documentation
   - Ensure conditions are correct

## ✅ What's Already Working

- ✅ Workflow YAML syntax is valid
- ✅ Act can list all jobs
- ✅ Test job can start (Python setup works)
- ✅ Git checkout works
- ✅ All job definitions are correct

## 🔧 Recommended Additions

### 1. Add `.act-secrets.example` (already created as `.secrets.example`)
Shows what secrets are needed without exposing real values.

### 2. Add `.github/test-event-tag.json`
For testing tag-triggered jobs:
```json
{
  "ref": "refs/tags/v1.0.0",
  "ref_type": "tag"
}
```

### 3. Update `.gitignore` (if not already)
Add:
```
.act-secrets
. secrets
*.local
```

### 4. Consider adding workflow validation script
Simple script to validate YAML and check required files exist.

## 🎯 Next Steps

1. ✅ Test `test` job - **DO THIS FIRST** (no secrets needed)
2. ⏳ Test `docker-hub` job (requires Docker Hub credentials)
3. ⏳ Test `artifactory` job (optional, requires Artifactory setup)
4. ⏳ Test `deploy-render` job (optional, requires Render setup)

## 💡 Pro Tips

- Always use `--container-architecture linux/amd64` on Apple Silicon Macs
- Use `--dryrun` first to see what would happen
- Start with jobs that don't need secrets
- Test one job at a time
- Check act output for warnings/errors

