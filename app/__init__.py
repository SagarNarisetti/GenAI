"""
GenAI RAG Application
=====================

A Retrieval-Augmented Generation system using:
- Gemma 3 4B (local LLM)
- PGVector (vector database)
- Sentence Transformers (embeddings)
- LangChain (orchestration)
- Streamlit (UI)

Architecture:
-------------
User → Streamlit UI →
  ├─ Upload PDF → Embedding Service → PGVector (384-dim vectors)
  └─ Ask Question →
      ├─ Retrieve Context (semantic search in PGVector)
      └─ Generate Response (Gemma LLM with context) → Display

"""

__version__ = "1.0.0"
__author__ = "Sagar Narisetti"

from .llm_model import GemmaLLM
from .embedding_service import EmbeddingService

__all__ = ["GemmaLLM", "EmbeddingService"]
