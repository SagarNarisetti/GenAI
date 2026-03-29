from langchain_postgres import PGVector
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.document_loaders import DirectoryLoader, UnstructuredPDFLoader

from sqlalchemy import create_engine
import os

class VectorStoreService:
    """Manages PGVector database operations"""
    
    def __init__(self,):
        self.database_url = os.getenv("DATABASE_URL")

        self.collection_name = "pdf_documents"
        
    def get_vector_store(self):
        """Initialize or connect to PGVector store"""
        return PGVector(
            collection_name=self.collection_name,
            connection_string=self.database_url,
            embedding_function=self.embedding_model,
        )
    
    def add_documents(self, documents):
        """Add documents to vector store"""
        vector_store = self.get_vector_store()
        vector_store.add_documents(documents)
        return len(documents)
    
    def similarity_search(self, query: str, k: int = 4):
        """Search for similar documents"""
        vector_store = self.get_vector_store()
        return vector_store.similarity_search(query, k=k)

if __name__ == "__main__":
    service = VectorStoreService()
    print("Vector store initialized with collection:", service.collection_name)