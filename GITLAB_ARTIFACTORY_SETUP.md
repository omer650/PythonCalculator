# 🚀 GitLab CE + Runner + Artifactory OSS Stack

**Complete CI/CD Infrastructure Setup Guide**

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Quick Start](#quick-start)
4. [Detailed Setup](#detailed-setup)
5. [CI/CD Pipeline](#cicd-pipeline)
6. [Artifactory Configuration](#artifactory-configuration)
7. [Troubleshooting](#troubleshooting)
8. [Presentation Slides](#presentation-slides)

---

## 🎯 Overview

This stack provides a complete, self-contained CI/CD infrastructure:

- **GitLab CE** - Source code management and CI/CD orchestration
- **GitLab Runner** - Executes CI/CD jobs
- **Artifactory OSS** - Docker registry and artifact storage

**All services run locally via Docker Compose - no cloud required!**

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Compose Stack                  │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────┐ │
│  │  GitLab CE   │    │ GitLab Runner│    │Artifactory│ │
│  │  :8080       │◄───┤              │───►│  :8081    │ │
│  │              │    │              │    │  :8082    │ │
│  └──────────────┘    └──────────────┘    └──────────┘ │
│         │                    │                  │       │
│         └────────────────────┴──────────────────┘       │
│                    Shared Network                         │
└─────────────────────────────────────────────────────────┘
```

**Ports:**
- GitLab: `8080` (HTTP), `8443` (HTTPS), `2224` (SSH)
- Artifactory: `8081` (Web UI), `8082` (Docker Registry)
- GitLab Runner: No exposed ports (internal only)

---

## ⚡ Quick Start

### Prerequisites

- Docker and Docker Compose installed
- At least 4GB RAM available
- Ports 8080, 8081, 8082, 2224 available

### One-Command Setup

```bash
make setup
```

This will:
1. Start all services
2. Wait for GitLab to initialize
3. Display root password
4. Register GitLab Runner

**Total time: ~3-5 minutes**

---

## 📖 Detailed Setup

### Step 1: Start Services

```bash
make up
```

**Wait 2-3 minutes** for GitLab to fully initialize.

### Step 2: Get GitLab Root Password

```bash
make bootstrap
```

**Output:**
```
Username: root
Password: <generated-password>
```

**⚠️ Save this password!** It's only shown once.

### Step 3: Access GitLab

1. Open browser: `http://localhost:8080`
2. Login with `root` and the password from Step 2
3. Create a new project or push your code

### Step 4: Register GitLab Runner

1. In GitLab: **Settings → CI/CD → Runners → Expand**
2. Copy the **Registration Token**
3. Run:

```bash
make register
```

Enter the token when prompted.

### Step 5: Configure Artifactory

1. Open browser: `http://localhost:8081`
2. Login: `admin` / `password` (change after first login)
3. Create Docker repository:
   - **Repositories → Add Repositories → Docker**
   - Name: `docker-local`
   - Type: Local
   - Save

### Step 6: Configure GitLab CI/CD Variables

In GitLab: **Settings → CI/CD → Variables → Expand**

Add these variables:

| Variable | Value | Protected | Masked |
|----------|-------|-----------|--------|
| `ARTIFACTORY_USERNAME` | `admin` | ❌ | ❌ |
| `ARTIFACTORY_PASSWORD` | `password` | ❌ | ✅ |
| `ARTIFACTORY_URL` | `http://artifactory:8082` | ❌ | ❌ |
| `ARTIFACTORY_REPO` | `docker-local` | ❌ | ❌ |

**Note:** `ARTIFACTORY_URL` uses internal Docker network name (`artifactory`), not `localhost`.

---

## 🔄 CI/CD Pipeline

### Pipeline Stages

The `.gitlab-ci.yml` defines three stages:

1. **Test** - Runs pytest on all branches/MRs
2. **Build** - Builds Docker image and pushes to GitLab Container Registry
3. **Push** - Pushes image to Artifactory (manual trigger)

### Pipeline Flow

```
┌─────────┐     ┌─────────┐     ┌─────────┐
│  Test   │────►│  Build  │────►│  Push   │
│         │     │         │     │(Manual) │
└─────────┘     └─────────┘     └─────────┘
   ✅              ✅               ⏸️
```

### Triggering the Pipeline

**Automatic:**
- Push to any branch → Runs `test` and `build` stages
- Create Merge Request → Runs `test` stage

**Manual:**
- Push to Artifactory → Trigger `push:artifactory` job from GitLab UI

### Viewing Pipeline Results

1. Go to your project in GitLab
2. Click **CI/CD → Pipelines**
3. Click on a pipeline to see job details

---

## 📦 Artifactory Configuration

### Docker Registry Setup

1. **Create Repository:**
   - Repositories → Add Repositories → Docker
   - Name: `docker-local`
   - Type: Local
   - Save

2. **Configure Access:**
   - Repositories → `docker-local` → Set Me Up
   - Copy Docker login command

3. **Test Push (Manual):**
   ```bash
   docker login localhost:8082 -u admin -p password
   docker tag calculator-app:latest localhost:8082/docker-local/calculator-app:latest
   docker push localhost:8082/docker-local/calculator-app:latest
   ```

### Accessing Images

**Pull from Artifactory:**
```bash
docker login localhost:8082 -u admin -p password
docker pull localhost:8082/docker-local/calculator-app:latest
```

**In CI/CD:**
The `.gitlab-ci.yml` automatically:
- Logs into Artifactory
- Tags images with correct registry path
- Pushes to Artifactory

---

## 🛠️ Makefile Commands

| Command | Description |
|---------|-------------|
| `make up` | Start all services |
| `make down` | Stop all services |
| `make restart` | Restart all services |
| `make logs` | View logs from all services |
| `make status` | Show service status |
| `make bootstrap` | Get GitLab root password |
| `make register` | Register GitLab Runner |
| `make setup` | Complete setup (up + bootstrap + register) |
| `make clean` | Remove all containers and volumes |
| `make gitlab-url` | Show GitLab access info |
| `make artifactory-url` | Show Artifactory access info |

---

## 🔍 Troubleshooting

### GitLab Not Starting

**Symptoms:** Container keeps restarting

**Solutions:**
1. Check logs: `docker logs gitlab-ce`
2. Ensure enough RAM (4GB+)
3. Check port conflicts: `lsof -i :8080`
4. Increase Docker memory limit

### Runner Not Registering

**Symptoms:** Registration fails with connection error

**Solutions:**
1. Ensure GitLab is fully started (wait 2-3 minutes)
2. Use internal URL: `http://gitlab` (not `localhost`)
3. Check runner container: `docker logs gitlab-runner`
4. Verify network: `docker network ls`

### Artifactory Not Accessible

**Symptoms:** Can't access web UI or push images

**Solutions:**
1. Check container status: `docker ps | grep artifactory`
2. Check logs: `docker logs artifactory-oss`
3. Verify port: `curl http://localhost:8081/artifactory/api/system/ping`
4. Wait 1-2 minutes for initialization

### Pipeline Jobs Failing

**Symptoms:** Jobs stuck in "pending" or failing

**Solutions:**
1. Check runner status: `docker exec gitlab-runner gitlab-runner list`
2. Verify runner is active in GitLab: Settings → CI/CD → Runners
3. Check runner logs: `docker logs gitlab-runner`
4. Ensure Docker socket is mounted: `docker exec gitlab-runner ls /var/run/docker.sock`

### Artifactory Push Failing

**Symptoms:** Push job fails with authentication error

**Solutions:**
1. Verify GitLab CI/CD variables are set correctly
2. Check Artifactory URL uses internal name: `http://artifactory:8082`
3. Test manual login: `docker login localhost:8082 -u admin -p password`
4. Verify repository exists: `docker-local`

---

## 📊 Presentation Slides

### Slide 1: Title
**GitLab CE + Runner + Artifactory OSS Stack**
*Complete CI/CD Infrastructure in Docker*

---

### Slide 2: What We're Building
- ✅ Self-contained CI/CD infrastructure
- ✅ GitLab CE for source control and pipelines
- ✅ GitLab Runner for job execution
- ✅ Artifactory OSS for Docker registry
- ✅ All running locally via Docker Compose

---

### Slide 3: Architecture
```
GitLab CE (Port 8080)
    ↕
GitLab Runner
    ↕
Artifactory OSS (Ports 8081, 8082)
```

**All connected via Docker network**

---

### Slide 4: Quick Start
```bash
make setup
```

**That's it!** Complete setup in 3-5 minutes.

---

### Slide 5: CI/CD Pipeline
1. **Test** - Automated pytest on every push
2. **Build** - Docker image built and pushed to GitLab registry
3. **Push** - Manual trigger to push to Artifactory

---

### Slide 6: Key Features
- ✅ Zero cloud dependencies
- ✅ Complete CI/CD workflow
- ✅ Docker image registry
- ✅ Easy to demo and present
- ✅ Production-ready patterns

---

### Slide 7: Access Points
- **GitLab:** `http://localhost:8080`
- **Artifactory:** `http://localhost:8081`
- **Docker Registry:** `localhost:8082`

---

### Slide 8: Next Steps
1. Push your code to GitLab
2. Watch the pipeline run
3. View artifacts in Artifactory
4. Customize for your needs

---

## 📝 Summary

This stack provides:

✅ **Ready-to-run** Docker Compose configuration  
✅ **Complete CI/CD** pipeline with GitLab  
✅ **Docker registry** via Artifactory  
✅ **Easy management** via Makefile  
✅ **Automated setup** scripts  
✅ **Clear documentation** for handoff  

**Perfect for:**
- Demonstrations
- Training
- Local development
- Proof of concepts

---

## 🔗 Additional Resources

- [GitLab CE Documentation](https://docs.gitlab.com/ee/)
- [GitLab Runner Documentation](https://docs.gitlab.com/runner/)
- [Artifactory OSS Documentation](https://www.jfrog.com/confluence/display/JFROG/Getting+Started+with+Artifactory+as+a+Docker+Registry)

---

**Questions?** Check the troubleshooting section or review the Makefile commands.

