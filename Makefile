.PHONY: help up down restart logs status clean bootstrap register setup

# Default target
help:
	@echo "🚀 GitLab CE + Runner + Artifactory Stack"
	@echo ""
	@echo "Available commands:"
	@echo "  make up          - Start all services"
	@echo "  make down        - Stop all services"
	@echo "  make restart     - Restart all services"
	@echo "  make logs        - View logs from all services"
	@echo "  make status      - Show service status"
	@echo "  make clean       - Stop and remove all containers, volumes, and networks"
	@echo "  make bootstrap   - Run bootstrap script to get GitLab root password"
	@echo "  make register    - Register GitLab Runner (run after bootstrap)"
	@echo "  make setup       - Complete setup: up, bootstrap, register"
	@echo "  make gitlab-url  - Show GitLab URL and access info"
	@echo "  make artifactory-url - Show Artifactory URL and access info"
	@echo ""

# Start all services
up:
	@echo "🚀 Starting GitLab CE, Runner, and Artifactory..."
	docker-compose -f docker-compose.gitlab.yml up -d
	@echo "⏳ Waiting for services to be ready..."
	@echo "   GitLab may take 2-3 minutes to fully start"
	@echo "   Run 'make bootstrap' after GitLab is ready to get root password"

# Stop all services
down:
	@echo "🛑 Stopping all services..."
	docker-compose -f docker-compose.gitlab.yml down

# Restart all services
restart:
	@echo "🔄 Restarting all services..."
	docker-compose -f docker-compose.gitlab.yml restart

# View logs
logs:
	docker-compose -f docker-compose.gitlab.yml logs -f

# Show service status
status:
	@echo "📊 Service Status:"
	@docker-compose -f docker-compose.gitlab.yml ps
	@echo ""
	@echo "🔍 Health Checks:"
	@docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "gitlab|artifactory|runner" || true

# Clean everything (containers, volumes, networks)
clean:
	@echo "🧹 Cleaning up all containers, volumes, and networks..."
	@echo "⚠️  This will delete ALL data."
	@echo -n "Are you sure? [y/N] " && read REPLY && [ "$$REPLY" = "y" ] || [ "$$REPLY" = "Y" ] || (echo "❌ Cleanup cancelled." && exit 1)
	@docker-compose -f docker-compose.gitlab.yml down -v
	@echo "✅ Cleanup complete!"

# Run bootstrap script
bootstrap:
	@echo "🔐 Getting GitLab root password..."
	@./scripts/bootstrap.sh

# Register GitLab Runner
register:
	@echo "📝 Registering GitLab Runner..."
	@./scripts/register.sh

# Complete setup
setup: up
	@echo "⏳ Waiting 60 seconds for GitLab to initialize..."
	@sleep 60
	@make bootstrap
	@echo ""
	@echo "⏳ Waiting 30 seconds before runner registration..."
	@sleep 30
	@make register
	@echo ""
	@echo "✅ Setup complete!"
	@make gitlab-url
	@make artifactory-url

# Show GitLab URL
gitlab-url:
	@echo ""
	@echo "🌐 GitLab Access:"
	@echo "   URL:      http://localhost:8080"
	@echo "   Username: root"
	@echo "   Password: (run 'make bootstrap' to get it)"
	@echo ""

# Show Artifactory URL
artifactory-url:
	@echo ""
	@echo "📦 Artifactory Access:"
	@echo "   URL:      http://localhost:8081"
	@echo "   Username: admin"
	@echo "   Password: password (default - change after first login)"
	@echo "   Docker:   http://localhost:8082"
	@echo ""

