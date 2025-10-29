# How to Add DOCKER_USERNAME Variable

## ❌ The Problem

You're seeing: `❌ DOCKER_USERNAME variable is not set`

This means the workflow can't find a **repository-level** variable named `DOCKER_USERNAME`.

## ✅ Solution: Add Repository Variable

### Step-by-Step Instructions

1. **Go to your GitHub repository** (not organization or environment settings)

2. **Navigate to:**
   - Click **Settings** (in the repository, top menu)
   - Click **Secrets and variables** (left sidebar)
   - Click **Actions** (submenu)
   - Click **Variables** tab (NOT Secrets tab)

3. **Add the variable:**
   - Click **New repository variable** button
   - **Name:** `DOCKER_USERNAME` (exactly this, case-sensitive)
   - **Value:** Your Docker Hub username (e.g., `morbargig`)
   - Click **Add variable**

4. **Verify it's there:**
   - You should see `DOCKER_USERNAME` in the Variables list
   - It should show your username value (not masked like secrets)

## 🔍 Important: Repository vs Environment Variables

### Repository Variables (What You Need)
- **Location:** Settings → Secrets and variables → Actions → **Variables tab**
- **Scope:** Available to all workflows in the repository
- **Access:** `${{ vars.DOCKER_USERNAME }}`
- **Visibility:** Shows the value (not masked)

### Environment Variables (NOT What We're Using)
- **Location:** Settings → Environments → [Environment Name] → Variables
- **Scope:** Only available when workflow specifies an environment
- **Access:** Different syntax, requires environment declaration
- **Note:** This workflow doesn't use environments

## ✅ Quick Check

After adding the variable, your Variables tab should show:

| Name | Value | Last updated |
|------|-------|--------------|
| 🔓 DOCKER_USERNAME | `morbargig` (visible) | now |

(Note: The lock icon shows but value is visible - that's normal for variables)

## 🎯 Complete Setup Checklist

- [ ] `DOCKER_USERNAME` added in **Variables** tab (not Secrets)
- [ ] Variable name is exactly `DOCKER_USERNAME` (case-sensitive)
- [ ] Variable value is your Docker Hub username
- [ ] `DOCKER_TOKEN` added in **Secrets** tab (not Variables)
- [ ] Secret name is exactly `DOCKER_TOKEN` (case-sensitive)
- [ ] Secret value is your Docker Hub Personal Access Token

## 🚀 Test It

After adding the variable:

1. Push to trigger the workflow, OR
2. Go to Actions tab and re-run the failed workflow

The workflow should now show:
```
✅ Credentials validated
```

Instead of the error message.

## 💡 Still Not Working?

1. **Double-check the tab:**
   - Variables → For `DOCKER_USERNAME`
   - Secrets → For `DOCKER_TOKEN`

2. **Check the exact name:**
   - Must be exactly: `DOCKER_USERNAME`
   - No spaces, correct case

3. **Verify it's repository-level:**
   - Should be in: Repository Settings → Secrets and variables → Actions
   - NOT in: Environment settings

4. **Wait a moment:**
   - Sometimes there's a short delay after adding variables
   - Try re-running the workflow after a minute

