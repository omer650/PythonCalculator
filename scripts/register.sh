#!/bin/bash
# Register GitLab Runner with GitLab instance

set -e

echo "📝 GitLab Runner Registration Script"
echo "===================================="
echo ""

# Check if GitLab container is running
if ! docker ps | grep -q gitlab-ce; then
    echo "❌ Error: GitLab container is not running!"
    echo "   Run 'make up' first to start GitLab"
    exit 1
fi

# Check if GitLab Runner container is running
if ! docker ps | grep -q gitlab-runner; then
    echo "❌ Error: GitLab Runner container is not running!"
    echo "   Run 'make up' first to start the runner"
    exit 1
fi

echo "📋 To register the runner, you need:"
echo "   1. GitLab URL: http://gitlab (internal) or http://localhost:8080 (external)"
echo "   2. Registration Token from GitLab"
echo ""
echo "   Get the token from:"
echo "   GitLab → Settings → CI/CD → Runners → Expand 'Set up a specific runner manually'"
echo ""

# Prompt for GitLab URL
read -p "Enter GitLab URL [http://gitlab]: " GITLAB_URL
GITLAB_URL=${GITLAB_URL:-http://gitlab}

# Prompt for registration token
read -p "Enter Registration Token: " REGISTRATION_TOKEN

if [ -z "$REGISTRATION_TOKEN" ]; then
    echo "❌ Error: Registration token is required!"
    exit 1
fi

echo ""
echo "🔄 Registering GitLab Runner..."
echo ""

# Register the runner
docker exec -it gitlab-runner gitlab-runner register \
    --non-interactive \
    --url "$GITLAB_URL" \
    --registration-token "$REGISTRATION_TOKEN" \
    --executor "docker" \
    --docker-image "docker:24" \
    --docker-privileged \
    --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
    --description "docker-runner" \
    --tag-list "docker,linux" \
    --run-untagged="true" \
    --locked="false" \
    --access-level="not_protected"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ GitLab Runner registered successfully!"
    echo ""
    echo "📊 Runner Status:"
    docker exec gitlab-runner gitlab-runner list
    echo ""
    echo "🎉 Setup complete! Your CI/CD pipeline is ready to use."
else
    echo ""
    echo "❌ Registration failed. Please check:"
    echo "   1. GitLab URL is correct"
    echo "   2. Registration token is valid"
    echo "   3. GitLab is accessible from the runner container"
    exit 1
fi

