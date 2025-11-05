#!/bin/bash
# Bootstrap script to get GitLab root password and initial setup info

set -e

echo "🔐 GitLab Bootstrap Script"
echo "=========================="
echo ""

# Check if GitLab container is running
if ! docker ps | grep -q gitlab-ce; then
    echo "❌ Error: GitLab container is not running!"
    echo "   Run 'make up' first to start GitLab"
    exit 1
fi

# Wait for GitLab to be ready
echo "⏳ Waiting for GitLab to be ready..."
timeout=300
elapsed=0
while [ $elapsed -lt $timeout ]; do
    if docker exec gitlab-ce gitlab-ctl status &>/dev/null; then
        echo "✅ GitLab is ready!"
        break
    fi
    echo "   Still waiting... ($elapsed/$timeout seconds)"
    sleep 10
    elapsed=$((elapsed + 10))
done

if [ $elapsed -ge $timeout ]; then
    echo "❌ Timeout: GitLab did not become ready in $timeout seconds"
    exit 1
fi

# Get root password
echo ""
echo "📋 GitLab Root Credentials:"
echo "============================"
echo ""
echo "Username: root"
echo ""

# Try to get the password from GitLab
PASSWORD=$(docker exec gitlab-ce grep 'Password:' /etc/gitlab/initial_root_password 2>/dev/null | cut -d' ' -f2 || echo "")

if [ -z "$PASSWORD" ]; then
    echo "⚠️  Initial root password not found in container."
    echo "   This might mean GitLab has already been configured."
    echo ""
    echo "   If you've already set a password, use that."
    echo "   Otherwise, check GitLab logs:"
    echo "   docker exec gitlab-ce cat /etc/gitlab/initial_root_password"
else
    echo "Password: $PASSWORD"
    echo ""
    echo "⚠️  IMPORTANT: Save this password! It's only shown once."
    echo "   You can also find it in:"
    echo "   docker exec gitlab-ce cat /etc/gitlab/initial_root_password"
fi

echo ""
echo "🌐 Access GitLab at: http://localhost:8080"
echo ""
echo "📝 Next Steps:"
echo "   1. Log in to GitLab with the credentials above"
echo "   2. Create a new project or push your code"
echo "   3. Get a CI/CD token: Settings → CI/CD → Runners → Expand"
echo "   4. Run 'make register' to register the GitLab Runner"
echo ""

