from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.document_loaders import PyPDFLoader
# from langchain_community.vectorstores import PGVector
from langchain_postgres import PGVector

from typing import List, Optional
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class EmbeddingService:
    """
    Service for managing document embeddings and vector storage.
    
    This class handles the complete RAG pipeline:
    - Loading and processing PDFs
    - Creating embeddings
    - Storing in vector database
    - Retrieving relevant context
    """
    
    def __init__(self, database_url: str, collection_name: str = "document_embeddings"):
        """
        Initialize the embedding service.
        
        Args:
            database_url: PostgreSQL connection string
            collection_name: Name for the vector collection
            
        Reality: Sets up connection to PGVector and initializes the embedding model.
        The embedding model converts text into 384-dimensional vectors.
        """
        self.database_url = database_url
        self.collection_name = collection_name
        
        # Initialize embedding model (runs locally, no API calls)
        # This model converts text into numerical vectors
        logger.info("🔄 Loading embedding model...")
        self.embeddings = HuggingFaceEmbeddings(
            model_name="sentence-transformers/all-MiniLM-L6-v2",
            model_kwargs={'device': 'cpu'}  # Use 'cuda' if you have GPU
        )
        logger.info("✅ Embedding model loaded")
        
        # Initialize vector store connection
        self.vector_store = None
        self._initialize_vector_store()
    
    def _initialize_vector_store(self):
        """
        Initialize connection to PGVector database.
        
        Reality: Creates the vector extension in PostgreSQL if it doesn't exist,
        and sets up the table schema for storing embeddings.
        """
        try:
            # This creates the vector store or connects to existing one
            self.vector_store = PGVector(
                collection_name=self.collection_name,
                connection_string=self.database_url,
                embedding_function=self.embeddings,
            )
            logger.info("✅ Connected to PGVector database")
        except Exception as e:
            logger.error(f"❌ Failed to initialize vector store: {e}")
            raise
    
    def process_pdf(self, pdf_path: str, chunk_size: int = 1000, chunk_overlap: int = 200) -> int:
        """
        Process a PDF file and store embeddings in the database.
        
        Args:
            pdf_path: Path to the PDF file
            chunk_size: Maximum characters per chunk
            chunk_overlap: Characters to overlap between chunks
            
        Returns:
            Number of chunks created and stored
            
        Reality: This is the core RAG setup process:
        1. Extracts all text from PDF
        2. Splits into overlapping chunks (to preserve context)
        3. Converts each chunk to a vector
        4. Stores vectors in PGVector for later retrieval
        """
        try:
            logger.info(f"📄 Processing PDF: {pdf_path}")
            
            # STEP 1: Load PDF
            # PyPDFLoader extracts text from each page
            loader = PyPDFLoader(pdf_path)
            documents = loader.load()
            logger.info(f"📖 Loaded {len(documents)} pages")
            
            # STEP 2: Split into chunks
            # Why? LLMs have context limits, and smaller chunks improve retrieval accuracy
            text_splitter = RecursiveCharacterTextSplitter(
                chunk_size=chunk_size,
                chunk_overlap=chunk_overlap,
                length_function=len,
                separators=["\n\n", "\n", " ", ""]  # Split on paragraphs first, then sentences
            )
            chunks = text_splitter.split_documents(documents)
            logger.info(f"✂️ Split into {len(chunks)} chunks")
            
            # STEP 3: Create embeddings and store
            # For each chunk:
            #   1. Generate 384-dimensional vector using the embedding model
            #   2. Store vector + original text in PGVector
            self.vector_store.add_documents(chunks)
            logger.info(f"✅ Stored {len(chunks)} embeddings in database")
            
            return len(chunks)
            
        except Exception as e:
            logger.error(f"❌ Error processing PDF: {e}")
            raise
    
    def retrieve_context(self, query: str, k: int = 3) -> str:
        """
        Retrieve relevant text chunks for a given query.
        
        Args:
            query: User's question
            k: Number of top results to return
            
        Returns:
            Combined text from the most relevant chunks
            
        Reality: This is where the semantic search happens:
        1. Convert query to vector using same embedding model
        2. Find the k closest vectors in the database (cosine similarity)
        3. Return the original text of those chunks
        
        Example: If user asks "What is the refund policy?", this finds
        chunks about refunds, even if they don't use that exact word.
        """
        try:
            logger.info(f"🔍 Searching for: {query}")
            
            # Perform similarity search
            # This compares the query vector against all stored vectors
            results = self.vector_store.similarity_search(query, k=k)
            
            # Combine the text from retrieved chunks
            context = "\n\n".join([doc.page_content for doc in results])
            
            logger.info(f"✅ Retrieved {len(results)} relevant chunks")
            return context
            
        except Exception as e:
            logger.error(f"❌ Error retrieving context: {e}")
            return ""
    
    def retrieve_with_scores(self, query: str, k: int = 3) -> List[tuple]:
        """
        Retrieve relevant chunks with similarity scores.
        
        Args:
            query: User's question
            k: Number of results
            
        Returns:
            List of (document, score) tuples
            
        Reality: Same as retrieve_context but also returns similarity scores
        (0.0 to 1.0, higher is more similar). Useful for debugging or filtering.
        """
        try:
            results = self.vector_store.similarity_search_with_score(query, k=k)
            logger.info(f"✅ Retrieved {len(results)} chunks with scores")
            return results
        except Exception as e:
            logger.error(f"❌ Error retrieving with scores: {e}")
            return []
    
    def clear_collection(self):
        """
        Delete all embeddings from the collection.
        
        Reality: Drops the entire vector collection from the database.
        Use this to reset or when uploading new documents.
        """
        try:
            # Note: PGVector doesn't have a built-in clear method
            # You'll need to manually delete from the table
            logger.warning("⚠️ Clear collection not fully implemented")
            logger.info("You may need to manually delete from the database")
        except Exception as e:
            logger.error(f"❌ Error clearing collection: {e}")


# Example usage and testing
if __name__ == "__main__":
    print("🔧 Testing Embedding Service...")
    
    # Database connection string
    DATABASE_URL = "postgresql://rag_user:rag_password@localhost:5432/rag_database"
    
    # Initialize service
    service = EmbeddingService(database_url=DATABASE_URL)
    
    # Test PDF processing (replace with your actual PDF path)
    # pdf_path = "sample_document.pdf"
    # num_chunks = service.process_pdf(pdf_path)
    # print(f"✅ Processed {num_chunks} chunks")
    
    # Test retrieval
    # context = service.retrieve_context("What is the main topic of the document?")
    # print(f"📚 Retrieved context:\n{context[:500]}...")