#!/bin/bash

set -e

CONTAINER_NAME="pgvector-local"
PORT=5432
DB_USER="sagar"
DB_PASS="narisetti"
DB_NAME="rag_db"
IMAGE_TAG="pgvector/pgvector:pg16"

echo "Checking the status of container: ${CONTAINER_NAME}..."

# Step 1: Start or Create the container
if [ "$(docker ps -a -q -f name=^/${CONTAINER_NAME}$)" ]; then
    if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
        echo "Container '${CONTAINER_NAME}' is already running."
    else
        echo "🔄 Container exists but is stopped. Starting it up..."
        docker start ${CONTAINER_NAME}
    fi
else
    echo "Creating and launching a fresh pgvector instance..."
    docker run -d \
      --name "${CONTAINER_NAME}" \
      -p "${PORT}":5432 \
      -e POSTGRES_USER="${DB_USER}" \
      -e POSTGRES_PASSWORD="${DB_PASS}" \
      -e POSTGRES_DB="${DB_NAME}" \
      "${IMAGE_TAG}"
fi

# Step 2: Critical Check — Wait for the database engine to finish initializing
echo "⏳ Waiting for PostgreSQL engine to accept connections..."
until docker exec -e PGPASSWORD="${DB_PASS}" "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}" -c "select 1" >/dev/null 2>&1; do
  sleep 1
done
echo "Database is ready!"

# Step 3: Run your initialization SQL schema commands
echo "🔧 Setting container into clean schema state..."
docker exec -i "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}" << 'EOF'
    -- 1. CLEAN UP
    DROP TABLE IF EXISTS langchain_pg_embedding;
    DROP TABLE IF EXISTS langchain_pg_collection;

    -- 2. ENABLE EXTENSION
    CREATE EXTENSION IF NOT EXISTS vector;

    -- 3. CUSTOM TABLE
    CREATE TABLE IF NOT EXISTS items (
        id SERIAL PRIMARY KEY,
        name TEXT NOT NULL,
        item_data JSONB,
        embedding vector(384),  
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );

    -- 4. OPTIMISE
    CREATE INDEX IF NOT EXISTS items_embedding_idx ON items 
    USING hnsw (embedding vector_cosine_ops);
EOF

echo "✨ Container is successfully configured and ready for local testing!"
echo "------------------------------------------------------------------"
