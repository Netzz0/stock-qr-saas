.PHONY: help build up down logs test clean

help:
	@echo "Stock QR SaaS - Make targets:"
	@echo ""
	@echo "  build          Build all services"
	@echo "  up             Start all services (docker-compose)"
	@echo "  down           Stop all services"
	@echo "  logs           Show logs from all services"
	@echo "  test           Run all tests"
	@echo "  clean          Clean build artifacts and caches"
	@echo "  db-migrate     Run database migrations"
	@echo "  db-reset       Reset database (WARNING: deletes data!)"
	@echo "  backend-dev    Start backend in development mode"
	@echo "  frontend-dev   Start frontend in development mode"
	@echo ""

build:
	@echo "Building all services..."
	docker-compose build

up:
	@echo "Starting all services..."
	docker-compose up -d

down:
	@echo "Stopping all services..."
	docker-compose down

logs:
	docker-compose logs -f

test:
	@echo "Running tests..."
	cd backend && dotnet test
	cd frontend && npm test

clean:
	@echo "Cleaning build artifacts..."
	find . -type d -name bin -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name obj -exec rm -rf {} + 2>/dev/null || true
	rm -rf frontend/dist frontend/node_modules 2>/dev/null || true
	rm -rf .DS_Store **/.DS_Store 2>/dev/null || true

db-migrate:
	@echo "Running database migrations..."
	cd backend && dotnet ef database update

db-reset:
	@echo "WARNING: This will reset the database!"
	@read -p "Continue? [y/N] " confirm && test $$confirm = y || exit 1
	docker-compose down -v
	docker-compose up -d postgres
	sleep 5
	cd backend && dotnet ef database update

backend-dev:
	cd backend && dotnet run

frontend-dev:
	cd frontend && npm run dev

.DEFAULT_GOAL := help
