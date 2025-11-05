# ⚡ Quick Start Guide

## 🚀 One-Command Setup

```bash
make setup
```

**Wait 3-5 minutes** for complete initialization.

---

## 📋 What Gets Created

- ✅ GitLab CE on `http://localhost:8080`
- ✅ GitLab Runner (registered automatically)
- ✅ Artifactory OSS on `http://localhost:8081`

---

## 🔐 Default Credentials

### GitLab
- **URL:** `http://localhost:8080`
- **Username:** `root`
- **Password:** Run `make bootstrap` to get it

### Artifactory
- **URL:** `http://localhost:8081`
- **Username:** `admin`
- **Password:** `password` (change after first login)

---

## 📝 Manual Setup (If Needed)

### 1. Start Services
```bash
make up
```

### 2. Get GitLab Password
```bash
make bootstrap
```

### 3. Register Runner
```bash
make register
```
(You'll need the registration token from GitLab)

### 4. Configure Artifactory
1. Login to `http://localhost:8081`
2. Create Docker repository: `docker-local`

### 5. Set GitLab Variables
In GitLab: **Settings → CI/CD → Variables**

| Variable | Value |
|----------|-------|
| `ARTIFACTORY_USERNAME` | `admin` |
| `ARTIFACTORY_PASSWORD` | `password` |
| `ARTIFACTORY_URL` | `http://artifactory:8082` |
| `ARTIFACTORY_REPO` | `docker-local` |

---

## 🎯 Next Steps

1. **Push your code** to GitLab
2. **Watch the pipeline** run automatically
3. **View artifacts** in Artifactory

---

## 🛠️ Useful Commands

```bash
make up          # Start all services
make down        # Stop all services
make logs        # View logs
make status      # Check service status
make clean       # Remove everything (⚠️ deletes data)
```

---

## 📚 Full Documentation

See `GITLAB_ARTIFACTORY_SETUP.md` for complete details.

