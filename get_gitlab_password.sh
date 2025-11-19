#!/bin/bash
# Script to get GitLab root password

echo "=========================================="
echo "GitLab Login Information"
echo "=========================================="
echo ""
echo "URL: http://localhost:8080"
echo "Username: root"
echo ""
echo "Getting password from container..."
echo ""

PASSWORD=$(docker compose -f docker-compose.gitlab.yml exec -T gitlab grep 'Password:' /etc/gitlab/initial_root_password 2>/dev/null | cut -d' ' -f2)

if [ -z "$PASSWORD" ]; then
    echo "⚠️  GitLab is still initializing. Please wait a few minutes and try again."
    echo ""
    echo "To check status:"
    echo "  docker compose -f docker-compose.gitlab.yml ps gitlab"
    echo ""
    echo "To view logs:"
    echo "  docker compose -f docker-compose.gitlab.yml logs -f gitlab"
else
    echo "Password: $PASSWORD"
    echo ""
    echo "⚠️  IMPORTANT: This password is stored in /etc/gitlab/initial_root_password"
    echo "   inside the container. It will be deleted after 24 hours for security."
    echo ""
    echo "After logging in, you should:"
    echo "  1. Change the root password"
    echo "  2. Create a new user account if needed"
fi

echo ""
echo "=========================================="

