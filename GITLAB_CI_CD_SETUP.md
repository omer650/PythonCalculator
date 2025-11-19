# 🚀 GitLab CI/CD Setup Guide

**Complete Educational Guide to Setting Up GitLab CI/CD with Docker Compose**

> **📌 Quick Setup**: For quick setup instructions, see the [main README.md](README.md#gitlab-cicd) GitLab CI/CD section.
>
> **📖 This Guide**: This document provides comprehensive, educational content designed for students learning DevOps. It includes detailed explanations of concepts, troubleshooting, and links to official documentation.

This guide provides step-by-step instructions to set up a complete CI/CD environment using GitLab, Docker, and Docker Compose, with educational explanations of DevOps concepts.

---

## 📋 Table of Contents

1. [What is CI/CD?](#what-is-cicd)
2. [What You'll Learn](#what-youll-learn)
3. [Prerequisites](#prerequisites)
4. [Architecture Overview](#architecture-overview)
5. [Quick Start](#quick-start)
6. [Detailed Setup Instructions](#detailed-setup-instructions)
7. [GitLab Runner Registration via UI](#gitlab-runner-registration-via-ui)
8. [Understanding the CI/CD Pipeline](#understanding-the-cicd-pipeline)
9. [Testing Your Pipeline](#testing-your-pipeline)
10. [Troubleshooting](#troubleshooting)
11. [Additional Resources](#additional-resources)

---

## 🎯 What is CI/CD?

**CI/CD** stands for **Continuous Integration** and **Continuous Deployment/Delivery**.

- **Continuous Integration (CI)**: Automatically test and build your code whenever you push changes
- **Continuous Deployment (CD)**: Automatically deploy your application after successful builds

### Why Use CI/CD?

- ✅ **Automated Testing**: Catch bugs before they reach production
- ✅ **Consistent Builds**: Same environment every time
- ✅ **Faster Releases**: Automate repetitive tasks
- ✅ **Better Collaboration**: See what's broken immediately

**Learn More**: [GitLab CI/CD Introduction](https://docs.gitlab.com/ee/ci/introduction/)

---

## 📚 What You'll Learn

By completing this setup, you will understand:

1. **GitLab Runner**: What it is and how it executes CI/CD jobs
2. **Docker-in-Docker (DinD)**: How to build Docker images inside CI jobs
3. **Pipeline Stages**: Test → Build → Deploy workflow
4. **Container Registries**: Storing and managing Docker images
5. **Infrastructure as Code**: Managing services with Docker Compose

---

## ✅ Prerequisites

Before starting, ensure you have:

### Required Software

1. **Docker** (version 20.10 or later)
   - **Installation**: [Docker Desktop for Mac/Windows](https://docs.docker.com/get-docker/)
   - **Installation**: [Docker Engine for Linux](https://docs.docker.com/engine/install/)
   - **Verify**: Run `docker --version`

2. **Docker Compose** (version 2.0 or later)
   - Usually included with Docker Desktop
   - **Installation**: [Docker Compose Installation Guide](https://docs.docker.com/compose/install/)
   - **Verify**: Run `docker compose version`

### System Requirements

- **RAM**: At least 4GB available (GitLab needs ~2GB)
- **Disk Space**: At least 10GB free
- **Ports**: 8080, 8081, 8082, 2224 must be available

### Knowledge Prerequisites

- Basic understanding of Git
- Basic understanding of Docker (containers, images)
- Basic command line usage

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│              Docker Compose Stack (Local Machine)           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐      ┌──────────────┐      ┌──────────┐ │
│  │  GitLab CE   │◄─────┤ GitLab Runner│─────►│Artifactory│ │
│  │  Port 8080   │      │              │      │ Port 8081 │ │
│  │              │      │              │      │ Port 8082 │ │
│  └──────────────┘      └──────────────┘      └──────────┘ │
│         │                     │                     │        │
│         └─────────────────────┴─────────────────────┘        │
│                    gitlab-network (bridge)                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Components Explained

- **GitLab CE**: Source code repository and CI/CD orchestrator
- **GitLab Runner**: Executes CI/CD jobs (builds, tests, deployments)
- **Artifactory OSS**: Docker registry for storing built images
- **Docker Network**: Allows services to communicate internally

**Learn More**: [GitLab Architecture](https://docs.gitlab.com/ee/development/architecture.html)

---

## ⚡ Quick Start

**For quick setup instructions, see the [main README.md](README.md#gitlab-cicd) GitLab CI/CD section.**

**One-command automated setup:**
```bash
make setup
```

This will:
1. Start all services (GitLab, Runner, Artifactory)
2. Wait for GitLab to initialize
3. Display the GitLab root password
4. Register the GitLab Runner automatically

**Total time: ~3-5 minutes**

**For detailed explanations and educational content, continue reading below.**

---

## 📖 Detailed Setup Instructions

### Step 1: Start the Services

Start GitLab, GitLab Runner, and Artifactory using Docker Compose:

```bash
make up
```

Or manually:

```bash
docker-compose -f docker-compose.gitlab.yml up -d
```

**What happens:**
- GitLab CE starts (takes 2-3 minutes to fully initialize)
- GitLab Runner starts (waits for GitLab)
- Artifactory OSS starts (Docker registry)

**Verify services are running:**

```bash
make status
```

Or:

```bash
docker ps
```

You should see three containers: `gitlab-ce`, `gitlab-runner`, and `artifactory-oss`.

**Learn More**: [Docker Compose Documentation](https://docs.docker.com/compose/)

---

### Step 2: Get GitLab Root Password

GitLab generates a random root password on first startup. Retrieve it:

```bash
make bootstrap
```

Or manually:

```bash
docker exec gitlab-ce cat /etc/gitlab/initial_root_password
```

**⚠️ Important**: Save this password! It's only shown once.

**Output example:**
```
Username: root
Password: <random-generated-password>
```

---

### Step 3: Access GitLab

1. Open your browser: **http://localhost:8080**
2. Login with:
   - **Username**: `root`
   - **Password**: (from Step 2)

3. **First-time setup**: GitLab may ask you to set a new password. You can skip this for now.

4. **Create a project**:
   - Click "New project" or "Create a project"
   - Choose "Create blank project"
   - Name it (e.g., "python-calculator")
   - Set visibility (Private is fine for learning)
   - Click "Create project"

**Learn More**: [GitLab User Guide](https://docs.gitlab.com/ee/user/)

---

### Step 4: Push Your Code to GitLab

If you haven't already, push your calculator project to GitLab:

```bash
# Add GitLab as remote (replace with your project URL)
git remote add gitlab http://localhost:8080/root/python-calculator.git

# Push your code
git push gitlab main
```

Or use SSH (port 2224):

```bash
git remote add gitlab ssh://git@localhost:2224/root/python-calculator.git
git push gitlab main
```

---

### Step 5: Register GitLab Runner

The GitLab Runner needs to be registered with your GitLab instance. You can do this in two ways:

#### Option A: Using the Registration Script (Easier)

```bash
make register
```

Follow the prompts:
- GitLab URL: `http://gitlab` (internal) or `http://localhost:8080` (external)
- Registration Token: (get from GitLab UI - see Option B below)

#### Option B: Manual Registration via Command Line

See [GitLab Runner Registration via UI](#gitlab-runner-registration-via-ui) section below to get your registration token, then:

```bash
docker exec -it gitlab-runner gitlab-runner register
```

**Learn More**: [GitLab Runner Registration](https://docs.gitlab.com/runner/register/)

---

## 🎯 GitLab Runner Registration via UI

This section explains how to register a GitLab Runner using the GitLab web interface.

### What is a GitLab Runner?

A **GitLab Runner** is a lightweight agent that executes CI/CD jobs. Think of it as a worker that:
- Receives jobs from GitLab
- Runs tests, builds Docker images, deploys applications
- Reports results back to GitLab

**Learn More**: [What is GitLab Runner?](https://docs.gitlab.com/runner/)

### Step-by-Step: Get Registration Token from GitLab UI

1. **Navigate to your project** in GitLab (http://localhost:8080)

2. **Go to Settings → CI/CD**:
   - Click on your project name in the top bar
   - In the left sidebar, click **Settings**
   - Expand **CI/CD** section

3. **Expand the Runners section**:
   - Scroll down to **Runners**
   - Click to expand it

4. **Find "Set up a specific runner manually"**:
   - Look for a section titled "Set up a specific runner manually"
   - You'll see:
     - **Registration token**: A long string like `glrt-xxxxxxxxxxxxxxxxxxxx`
     - **GitLab URL**: `http://localhost:8080` or `http://gitlab`

5. **Copy the registration token**:
   - Click the copy icon next to the token
   - Save it somewhere safe

**Screenshot Guide**: [GitLab Runner Registration UI](https://docs.gitlab.com/runner/register/index.html#registering-a-specific-runner)

### Runner Executor Types

When registering, you'll choose an **executor**. For this project, use:

- **Docker Executor**: Runs each CI job in a Docker container
  - **Why**: Isolated, reproducible, and fast
  - **Learn More**: [Docker Executor Documentation](https://docs.gitlab.com/runner/executors/docker/)

Other executor types:
- **Shell**: Runs jobs directly on the runner machine
- **Kubernetes**: Runs jobs in Kubernetes pods
- **VirtualBox**: Runs jobs in virtual machines

**Learn More**: [GitLab Runner Executors](https://docs.gitlab.com/runner/executors/)

### Complete Registration

Once you have the token, register the runner:

```bash
make register
```

Or manually:

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

**Registration Parameters Explained**:
- `--url`: GitLab instance URL (use `http://gitlab` for internal network)
- `--registration-token`: Token from GitLab UI
- `--executor docker`: Use Docker executor
- `--docker-image docker:24`: Default image for jobs
- `--description`: Human-readable name
- `--tag-list`: Tags to identify this runner
- `--run-untagged`: Accept jobs without tags

**Verify Registration**:

```bash
docker exec gitlab-runner gitlab-runner list
```

You should see your runner listed.

**Learn More**: [Complete Runner Registration Guide](https://docs.gitlab.com/runner/register/)

---

## 🔄 Understanding the CI/CD Pipeline

Your project includes a `.gitlab-ci.yml` file that defines the CI/CD pipeline. Let's break it down:

### Pipeline Stages

```yaml
stages:
  - test    # Run tests
  - build   # Build Docker image
  - push    # Push to registries
```

### Stage 1: Test

**What it does**: Runs your Python tests using pytest

```yaml
test:
  stage: test
  image: python:3.11-slim
  script:
    - pip install --no-cache-dir -r requirements.txt
    - python -m pytest test_calculator.py -v
```

**When it runs**: On every push to any branch and on merge requests

**Why**: Catch bugs before building Docker images

### Stage 2: Build

**What it does**: Builds a Docker image and pushes it to GitLab Container Registry

```yaml
build:
  stage: build
  image: docker:24-dind
  services:
    - docker:24-dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:latest .
    - docker push $CI_REGISTRY_IMAGE:latest
```

**Docker-in-Docker (DinD) Explained**:
- **Problem**: We need to build Docker images inside a CI job
- **Solution**: Use `docker:24-dind` image which runs a Docker daemon inside the container
- **How**: The `services` section starts a DinD container that the job connects to

**When it runs**: After tests pass, on all branches and tags

**Why**: Create a deployable artifact (Docker image)

**Learn More**: 
- [Docker-in-Docker](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#use-docker-in-docker-dind)
- [GitLab Container Registry](https://docs.gitlab.com/ee/user/packages/container_registry/)

### Stage 3: Push (Optional)

**What it does**: Pushes the Docker image to Artifactory (optional registry)

```yaml
push:artifactory:
  stage: push
  when: manual
  allow_failure: true
```

**When it runs**: Manually triggered from GitLab UI (optional step)

**Why**: Store images in multiple registries for redundancy

### Pipeline Flow Diagram

```
┌─────────┐      ┌─────────┐      ┌─────────┐
│  Push   │─────►│  Test   │─────►│  Build  │
│  Code   │      │  Stage  │      │  Stage  │
└─────────┘      └─────────┘      └─────────┘
                       │                │
                       ▼                ▼
                  ❌ Fail          ✅ Success
                       │                │
                       │                ▼
                       │         ┌─────────────┐
                       │         │   Push to   │
                       │         │  Registry   │
                       │         └─────────────┘
                       │
                       └───► Pipeline Stops
```

**Learn More**: [GitLab CI/CD Pipelines](https://docs.gitlab.com/ee/ci/pipelines/)

---

## 🧪 Testing Your Pipeline

### Trigger a Pipeline

1. **Make a small change** to your code:

```bash
echo "# Test CI/CD" >> README.md
git add README.md
git commit -m "Test CI/CD pipeline"
git push gitlab main
```

2. **View the pipeline**:
   - Go to your project in GitLab
   - Click **CI/CD → Pipelines** in the left sidebar
   - You should see a new pipeline running

3. **Watch it execute**:
   - Click on the pipeline to see details
   - Click on each job to see logs
   - Watch the stages execute: test → build → push

### Expected Results

- ✅ **Test stage**: Should pass (green checkmark)
- ✅ **Build stage**: Should build and push Docker image
- ⏸️ **Push stage**: Manual, won't run automatically

### View Built Images

After a successful build:

1. Go to **Packages & Registries → Container Registry**
2. You should see your Docker image: `calculator-app:latest`

**Learn More**: [Viewing Pipeline Results](https://docs.gitlab.com/ee/ci/pipelines/index.html#view-pipelines)

---

## 🔧 Troubleshooting

### Problem: GitLab takes too long to start

**Solution**: GitLab needs 2-3 minutes to fully initialize. Wait and check:

```bash
docker logs gitlab-ce
```

Look for: `gitlab Reconfigured!`

**Learn More**: [GitLab Startup Time](https://docs.gitlab.com/ee/administration/operations/index.html)

---

### Problem: Runner not picking up jobs

**Symptoms**: Pipeline shows "stuck" or "pending" jobs

**Solutions**:

1. **Check runner status**:
```bash
docker exec gitlab-runner gitlab-runner list
```

2. **Check runner logs**:
```bash
docker logs gitlab-runner
```

3. **Verify runner is registered**:
   - Go to GitLab → Settings → CI/CD → Runners
   - Check if your runner appears with a green circle

4. **Restart runner**:
```bash
docker restart gitlab-runner
```

**Learn More**: [Runner Troubleshooting](https://docs.gitlab.com/runner/troubleshooting/)

---

### Problem: Docker build fails in CI

**Symptoms**: Build stage fails with Docker errors

**Solutions**:

1. **Check Docker-in-Docker is working**:
   - Look for errors about Docker daemon
   - Verify `docker:24-dind` service is running

2. **Check Dockerfile**:
   - Ensure Dockerfile exists in project root
   - Test locally: `docker build -t test .`

3. **Check build logs**:
   - Click on the failed build job
   - Read the error messages

**Learn More**: [Docker Build Troubleshooting](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#troubleshooting)

---

### Problem: Cannot access GitLab at localhost:8080

**Solutions**:

1. **Check if GitLab is running**:
```bash
docker ps | grep gitlab-ce
```

2. **Check port conflicts**:
```bash
lsof -i :8080
```

3. **Check GitLab logs**:
```bash
docker logs gitlab-ce
```

4. **Try different port**: Edit `docker-compose.gitlab.yml` and change `8080:80` to `8081:80`

---

### Problem: Registration token not working

**Solutions**:

1. **Get a new token**:
   - Go to GitLab → Settings → CI/CD → Runners
   - Click "Reset registration token"
   - Copy the new token

2. **Use correct URL**:
   - For internal network: `http://gitlab`
   - For external access: `http://localhost:8080`

3. **Check GitLab is accessible**:
```bash
docker exec gitlab-runner curl http://gitlab
```

**Learn More**: [Runner Registration Issues](https://docs.gitlab.com/runner/register/#troubleshooting)

---

### Problem: Out of memory errors

**Symptoms**: Containers crash or GitLab is slow

**Solutions**:

1. **Check available memory**:
```bash
docker stats
```

2. **Reduce GitLab memory usage** (already configured in docker-compose):
   - `puma['worker_processes'] = 2`
   - `sidekiq['max_concurrency'] = 5`

3. **Close other applications** to free up RAM

---

### Problem: Artifactory not accessible

**Solutions**:

1. **Check Artifactory is running**:
```bash
docker ps | grep artifactory
```

2. **Check Artifactory logs**:
```bash
docker logs artifactory-oss
```

3. **Access Artifactory UI**: http://localhost:8081
   - Default login: `admin` / `password`

---

## 📚 Additional Resources

### Official GitLab Documentation

- **GitLab CI/CD**: [https://docs.gitlab.com/ee/ci/](https://docs.gitlab.com/ee/ci/)
- **GitLab Runner**: [https://docs.gitlab.com/runner/](https://docs.gitlab.com/runner/)
- **Docker Executor**: [https://docs.gitlab.com/runner/executors/docker/](https://docs.gitlab.com/runner/executors/docker/)
- **Container Registry**: [https://docs.gitlab.com/ee/user/packages/container_registry/](https://docs.gitlab.com/ee/user/packages/container_registry/)
- **Pipeline Configuration**: [https://docs.gitlab.com/ee/ci/yaml/](https://docs.gitlab.com/ee/ci/yaml/)

### GitLab Runner Specific

- **Installation**: [https://docs.gitlab.com/runner/install/](https://docs.gitlab.com/runner/install/)
- **Registration**: [https://docs.gitlab.com/runner/register/](https://docs.gitlab.com/runner/register/)
- **Troubleshooting**: [https://docs.gitlab.com/runner/troubleshooting/](https://docs.gitlab.com/runner/troubleshooting/)
- **Docker-in-Docker**: [https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#use-docker-in-docker-dind](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#use-docker-in-docker-dind)

### Docker Resources

- **Docker Documentation**: [https://docs.docker.com/](https://docs.docker.com/)
- **Docker Compose**: [https://docs.docker.com/compose/](https://docs.docker.com/compose/)
- **Docker Best Practices**: [https://docs.docker.com/develop/dev-best-practices/](https://docs.docker.com/develop/dev-best-practices/)

### Learning Resources

- **GitLab CI/CD Tutorial**: [https://docs.gitlab.com/ee/ci/introduction/](https://docs.gitlab.com/ee/ci/introduction/)
- **GitLab Runner Tutorial**: [https://docs.gitlab.com/tutorials/create_register_first_runner/](https://docs.gitlab.com/tutorials/create_register_first_runner/)
- **DevOps Concepts**: [https://about.gitlab.com/topics/devops/](https://about.gitlab.com/topics/devops/)

---

## 🎓 Key Concepts Summary

### CI/CD Pipeline
A series of automated steps that test, build, and deploy your code.

### GitLab Runner
An agent that executes CI/CD jobs. Think of it as a worker that follows instructions.

### Docker-in-Docker (DinD)
Running Docker inside a Docker container. Needed to build Docker images in CI jobs.

### Container Registry
A place to store Docker images. GitLab has a built-in registry, and Artifactory is an external one.

### Pipeline Stages
Logical groups of jobs. Stages run sequentially: test → build → deploy.

---

## ✅ Next Steps

Now that you have GitLab CI/CD set up:

1. **Experiment**: Make changes to `.gitlab-ci.yml` and see what happens
2. **Add more tests**: Expand your test suite
3. **Add deployment**: Automatically deploy to a server
4. **Learn GitLab CI/CD variables**: Store secrets securely
5. **Explore GitLab features**: Issues, Merge Requests, CI/CD schedules

**Happy Learning! 🚀**

---

## 📝 Quick Reference Commands

```bash
# Start services
make up

# Stop services
make down

# View logs
make logs

# Get GitLab password
make bootstrap

# Register runner
make register

# Complete setup
make setup

# Check status
make status

# Clean everything
make clean
```

---

**Last Updated**: 2024
**GitLab Version**: Latest CE
**Docker Version**: 24+

