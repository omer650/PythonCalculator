#!/bin/bash
# Script to wait for GitLab to be ready and show access information

echo "=========================================="
echo "Waiting for GitLab to be ready..."
echo "=========================================="
echo ""
echo "Port Configuration:"
echo "  - HTTP:  localhost:8080 -> container:80"
echo "  - HTTPS: localhost:8443 -> container:443"
echo "  - SSH:   localhost:2224 -> container:22"
echo ""

MAX_WAIT=600  # 10 minutes
ELAPSED=0
INTERVAL=10

while [ $ELAPSED -lt $MAX_WAIT ]; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null)
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "301" ]; then
        echo ""
        echo "✅ GitLab is READY!"
        echo ""
        echo "=========================================="
        echo "Access GitLab:"
        echo "=========================================="
        echo "  URL:      http://localhost:8080"
        echo "  Username: root"
        echo ""
        echo "Getting password..."
        PASSWORD=$(docker compose -f docker-compose.gitlab.yml exec -T gitlab grep 'Password:' /etc/gitlab/initial_root_password 2>/dev/null | cut -d' ' -f2)
        if [ -n "$PASSWORD" ]; then
            echo "  Password: $PASSWORD"
        else
            echo "  Password: (Run ./get_gitlab_password.sh to get it)"
        fi
        echo ""
        echo "=========================================="
        exit 0
    fi
    
    echo -n "."
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

echo ""
echo "⏳ GitLab is taking longer than expected to start."
echo "   This is normal for first-time initialization."
echo ""
echo "Check status with: ./check_gitlab_status.sh"
echo "View logs with: docker compose -f docker-compose.gitlab.yml logs -f gitlab"
exit 1

