-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- IMPORTANT: This schema is minimal because LangChain PGVector will auto-create
-- its own tables (langchain_pg_collection and langchain_pg_embedding)
-- 
-- If you need a custom items table, use 384 dimensions (not 1536)
-- to match the all-MiniLM-L6-v2 embedding model

-- Optional: Create sample table with CORRECT dimensions
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    item_data JSONB,
    embedding vector(384),  
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster similarity search
CREATE INDEX IF NOT EXISTS items_embedding_idx ON items 
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);
