#!/bin/bash

set -e

echo "🚀 Deploying RAG Application..."

# Build and start all services
docker-compose up -d --build

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for database..."
sleep 10

# Enable PGVector extension
docker-compose exec postgres psql -U narisetti -d vector_db_genai -c "\dx"

# Wait for application
echo "⏳ Waiting for application..."
sleep 10

# Health check
curl -s http://localhost:8000/health && echo "✅ Application is running!"

echo "📍 Access at: http://localhost:8000"