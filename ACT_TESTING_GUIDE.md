# Testing CI/CD with Act (GitHub Actions Locally)

[Act](https://github.com/nektos/act) allows you to run GitHub Actions workflows locally using Docker.

## Prerequisites

1. **Docker Desktop** must be running
2. **Act installed**: 
   ```bash
   brew install act
   # or
   curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
   ```

## Quick Start

### 1. Test the Test Job (No Secrets Needed)

This is the simplest job to test - it just runs pytest:

```bash
# List all available workflows and jobs
act --list

# Run the test job
act push --job test --container-architecture linux/amd64

# Run with verbose output
act push --job test --container-architecture linux/amd64 -v
```

**Expected:** Test job should pass if your code is correct.

### 2. Testing Docker Hub Publish Job

The Docker Hub job only runs on tags, so you need to simulate a tag event:

```bash
# Create a secrets file (don't commit it!)
cat > .act-secrets <<EOF
DOCKER_USERNAME=your-username
DOCKER_TOKEN=your-personal-access-token
EOF

# Test Docker build (without pushing) - modify workflow temporarily to add --no-push
# Or test with a dry run:
act push --job docker-hub \
  --eventpath .github/test-event-tag.json \
  --secret-file .act-secrets \
  --container-architecture linux/amd64 \
  --dryrun
```

**Note:** The Docker Hub job condition checks for tags. To test locally, you can:
1. Temporarily comment out the `if: startsWith(github.ref, 'refs/tags/v')` condition
2. Or create a test event JSON file that simulates a tag push

### 3. Testing Other Jobs

**Artifactory Job:**
```bash
act push --job artifactory \
  --secret-file .act-secrets \
  --container-architecture linux/amd64
```

**Render Deploy Job:**
```bash
act push --job deploy-render \
  --secret-file .act-secrets \
  --container-architecture linux/amd64
```

## Creating Test Event Files

For jobs that only trigger on specific events (like tags), create test event files:

**`.github/test-event-tag.json`:**
```json
{
  "ref": "refs/tags/v1.0.0",
  "ref_type": "tag",
  "repository": {
    "name": "test"
  }
}
```

Then use:
```bash
act push --eventpath .github/test-event-tag.json --job docker-hub
```

## Common Issues and Solutions

### Issue: "Cannot connect to Docker daemon"
- **Solution:** Make sure Docker Desktop is running
- Check: `docker ps` should work

### Issue: "Container architecture mismatch"
- **Solution:** Always use `--container-architecture linux/amd64` on Apple Silicon Macs

### Issue: "Secrets not found"
- **Solution:** Create `.act-secrets` file or use `--secret KEY=value`
- Example: `act push --secret DOCKER_TOKEN=xxx --job docker-hub`

### Issue: "Job not running due to condition"
- **Solution:** Jobs have conditions (like `if: startsWith(github.ref, 'refs/tags/v')`)
- Either temporarily modify the condition or use appropriate event files

### Issue: "GHA cache not available locally"
- **Solution:** The `cache-from: type=gha` won't work locally, but that's OK
- It will just build without cache, which is fine for testing

## Best Practices for Local Testing

1. **Start with the test job** - it doesn't need secrets
2. **Test one job at a time** - easier to debug
3. **Use dry-run first** - `--dryrun` shows what would happen without executing
4. **Keep secrets file local** - never commit `.act-secrets` or `.secrets`
5. **Use verbose mode for debugging** - `-v` or `-vv` for more output

## Act Command Reference

```bash
# List workflows
act --list

# Run specific job
act push --job test

# Run with secrets
act push --job docker-hub --secret-file .act-secrets

# Run with specific event
act push --eventpath .github/test-event-tag.json

# Dry run (show what would happen)
act push --job test --dryrun

# Verbose output
act push --job test -vv

# Run with specific workflow file
act push --workflows .github/workflows/ci-cd.yml --job test
```

## Validation Checklist

Before pushing to GitHub, verify locally:

- [ ] Test job passes: `act push --job test --container-architecture linux/amd64`
- [ ] Dockerfile builds correctly: `docker build -t test .`
- [ ] No syntax errors in workflow YAML
- [ ] All secrets documented in README
- [ ] Conditions work as expected (test with appropriate event files)

## Current Workflow Jobs

1. **test** - Runs pytest (no secrets needed, best to start here)
2. **docker-hub** - Publishes to Docker Hub (requires DOCKER_USERNAME, DOCKER_TOKEN)
3. **artifactory** - Publishes to Artifactory (requires Artifactory secrets, optional)
4. **deploy-render** - Triggers Render deployment (requires RENDER_API_KEY, RENDER_SERVICE_ID, optional)

