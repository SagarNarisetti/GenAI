-- 1. CLEAN UP: Remove old broken schemas to avoid the 'custom_id' error
DROP TABLE IF EXISTS langchain_pg_embedding;
DROP TABLE IF EXISTS langchain_pg_collection;

-- 2. ENABLE EXTENSION: Required for vector operations
CREATE EXTENSION IF NOT EXISTS vector;

-- 3. OPTIONAL CUSTOM TABLE: For your own manual testing/storage
-- Dimension 384 matches 'all-MiniLM-L6-v2'
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    item_data JSONB,
    embedding vector(384),  
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. OPTIMISE: Use HNSW for faster similarity searches as you add data
-- This index is more modern and efficient than ivfflat
CREATE INDEX IF NOT EXISTS items_embedding_idx ON items 
USING hnsw (embedding vector_cosine_ops);

-- 5. VERIFY: Ensure the extension is active
SELECT * FROM pg_extension WHERE extname = 'vector';