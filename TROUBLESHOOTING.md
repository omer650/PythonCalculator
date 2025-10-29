# Troubleshooting CI/CD Issues

## ❌ Error: "Username and password required"

### Problem
The `docker/login-action` fails with: `Error: Username and password required`

### Solutions

#### 1. Check if Variables and Secrets are Set

**Check Variables:**
- Go to: Settings → Secrets and variables → Actions → **Variables** tab
- Verify `DOCKER_USERNAME` exists
- Value should be your Docker Hub username (e.g., `morbargig`)

**Check Secrets:**
- Go to: Settings → Secrets and variables → Actions → **Secrets** tab  
- Verify `DOCKER_TOKEN` exists
- Should contain your Docker Hub Personal Access Token

#### 2. Verify Variable is Repository-Level (Not Environment)

**Repository Variables** (what you need):
- Location: Settings → Secrets and variables → Actions → Variables
- Accessible via: `${{ vars.DOCKER_USERNAME }}`
- Available to all jobs in the workflow

**Environment Variables** (won't work for this):
- Location: Settings → Environments → [Environment] → Variables
- Only accessible when workflow specifies an environment
- Not what we're using here

#### 3. Common Issues

**Issue:** Variable name is wrong
- ✅ Correct: `DOCKER_USERNAME`
- ❌ Wrong: `DOCKER_USER`, `docker-username`, `DOCKERUSERNAME`

**Issue:** Using secrets instead of variables
- `DOCKER_USERNAME` → Should be a **Variable** (not secret)
- `DOCKER_TOKEN` → Should be a **Secret**

**Issue:** Typo in workflow
- Check: `vars.DOCKER_USERNAME` (not `secrets.DOCKER_USERNAME`)
- Check: `secrets.DOCKER_TOKEN` (not `vars.DOCKER_TOKEN`)

#### 4. Quick Test

Add this debug step to your workflow to see what's available:

```yaml
- name: Debug
  run: |
    echo "Variable check:"
    echo "DOCKER_USERNAME: ${DOCKER_USERNAME:-NOT SET}"
    echo "Secret check:"
    echo "DOCKER_TOKEN exists: $([ -n '${{ secrets.DOCKER_TOKEN }}' ] && echo 'YES' || echo 'NO')"
```

#### 5. Alternative: Use Both as Secrets (Temporary Fix)

If repository variables aren't working, you can temporarily use both as secrets:

```yaml
# In workflow:
username: ${{ secrets.DOCKER_USERNAME }}  # Temporary - change back to vars after fixing
password: ${{ secrets.DOCKER_TOKEN }}
```

Then add `DOCKER_USERNAME` as a secret in Settings → Secrets (not as variable).

#### 6. Verify Permissions

Ensure the workflow has permission to read variables:
- Workflows automatically have read access to repository variables
- Check workflow file doesn't have `variables: read` permission explicitly denied

## 📋 Verification Checklist

- [ ] `DOCKER_USERNAME` exists in Variables tab (Settings → Secrets and variables → Actions → Variables)
- [ ] `DOCKER_TOKEN` exists in Secrets tab (Settings → Secrets and variables → Actions → Secrets)
- [ ] Variable name is exactly `DOCKER_USERNAME` (case-sensitive)
- [ ] Secret name is exactly `DOCKER_TOKEN` (case-sensitive)
- [ ] Values are not empty
- [ ] Workflow references `vars.DOCKER_USERNAME` (not `secrets.DOCKER_USERNAME`)
- [ ] Workflow references `secrets.DOCKER_TOKEN`

## 🔍 How to Verify in Workflow Logs

Look for the "Check and set Docker credentials" step output:

✅ **Success:**
```
✅ Credentials validated
```

❌ **Failure:**
```
❌ DOCKER_USERNAME variable is not set
Location: Settings → Secrets and variables → Actions → Variables
```

## 📸 What the Setup Should Look Like

**Variables Tab:**
- Name: `DOCKER_USERNAME`
- Value: `morbargig` (or your username)

**Secrets Tab:**
- Name: `DOCKER_TOKEN`
- Value: `dckr_pat_...` (your token)

## 🆘 Still Not Working?

1. **Double-check the exact names** - they must match exactly
2. **Check if you're using repository-level variables** (not environment variables)
3. **Verify the workflow file syntax** - `vars.DOCKER_USERNAME` not `vars['DOCKER_USERNAME']`
4. **Try re-running the workflow** after adding/fixing variables
5. **Check workflow permissions** - ensure variables can be read

## 💡 Pro Tip

If you're unsure whether variables are accessible, you can add a test step:

```yaml
- name: Test variable access
  run: |
    if [ -n "${{ vars.DOCKER_USERNAME }}" ]; then
      echo "Variable is accessible: ${{ vars.DOCKER_USERNAME }}"
    else
      echo "Variable is NOT accessible"
    fi
```

