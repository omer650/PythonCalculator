#!/bin/bash
# Script to check GitLab status and get login info

echo "=========================================="
echo "GitLab Status Check"
echo "=========================================="
echo ""

# Check container status
echo "Container Status:"
docker compose -f docker-compose.gitlab.yml ps gitlab
echo ""

# Check if GitLab is responding
echo "Checking if GitLab is accessible..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null)

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "301" ]; then
    echo "✅ GitLab is READY and accessible!"
    echo ""
    echo "Access GitLab at: http://localhost:8080"
    echo ""
    echo "Login Information:"
    echo "  Username: root"
    echo "  Password:"
    docker compose -f docker-compose.gitlab.yml exec -T gitlab grep 'Password:' /etc/gitlab/initial_root_password 2>/dev/null | cut -d' ' -f2 || echo "    (Password file not found - GitLab may still be initializing)"
else
    echo "⏳ GitLab is still initializing..."
    echo "   HTTP Status: $HTTP_CODE"
    echo ""
    echo "This is normal - GitLab can take 3-5 minutes to fully start on first boot."
    echo ""
    echo "To monitor progress, run:"
    echo "  docker compose -f docker-compose.gitlab.yml logs -f gitlab"
fi

echo ""
echo "=========================================="

