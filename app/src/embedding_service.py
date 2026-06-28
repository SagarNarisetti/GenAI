import boto3
import json
import logging
import os
from typing import List, Optional

# LangChain Imports
from langchain_core.embeddings import Embeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.document_loaders import PyPDFLoader
from langchain_postgres import PGVector

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class BedrockTitanEmbeddings(Embeddings):
    """
    Custom LangChain wrapper for Amazon Titan Text Embeddings V2 
    to handle dynamic dimensional scaling seamlessly.
    """
    def __init__(self, region_name: str = "us-west-1", dimensions: int = 256):
        self.client = boto3.client('bedrock-runtime', region_name=region_name)
        self.model_id = "amazon.titan-embed-text-v2:0"
        self.dimensions = dimensions

    def _embed_text(self, text: str) -> List[float]:
        payload = {
            "inputText": text,
            "normalize": True,
            "dimensions": self.dimensions
        }
        response = self.client.invoke_model(
            modelId=self.model_id,
            contentType="application/json",
            accept="application/json",
            body=json.dumps(payload)
        )
        response_body = json.loads(response['body'].read().decode('utf-8'))
        return response_body.get("embedding")

    def embed_documents(self, texts: List[str]) -> List[List[float]]:
        """Embed a list of documents."""
        return [self._embed_text(text) for text in texts]

    def embed_query(self, text: str) -> List[float]:
        """Embed a single query string."""
        return self._embed_text(text)


class EmbeddingService:
    """
    Service for managing document embeddings and vector storage.
    Handles the complete RAG pipeline natively with AWS Bedrock and PGVector.
    """

    def __init__(
        self,
        database_url: str,
        collection_name: str = "document_embeddings",
        region_name: str = "us-west-1",
        dimensions: int = 256
    ):
        """
        Initialize the embedding service.
        """
        self.database_url = database_url
        self.collection_name = collection_name
        self.region_name = region_name
        self.dimensions = dimensions

        # Initialize AWS client container for embeddings
        try:
            logger.info("Initializing Bedrock Titan Wrapper...")
            # Use our custom class that mirrors LangChain's embedding contract
            self.embeddings = BedrockTitanEmbeddings(
                region_name=self.region_name, 
                dimensions=self.dimensions
            )
            logger.info(f"Embedding model configured for {self.dimensions} dimensions")

        except Exception as e:
            logger.error(f"Failed to initialize AWS Bedrock interface: {e}")
            raise

        # Initialize vector store connection
        self.vector_store = None
        self._initialize_vector_store()

    def _initialize_vector_store(self):
        """
        Initialize connection to PGVector database.
        """
        try:
            self.vector_store = PGVector(
                embeddings=self.embeddings,
                collection_name=self.collection_name,
                connection=self.database_url,
                use_jsonb=True,
            )
            logger.info("Connected to PGVector database")
        except Exception as e:
            logger.error(f" Failed to initialize vector store: {e}")
            raise

    def process_pdf(
        self, pdf_path: str, chunk_size: int = 1000, chunk_overlap: int = 200
    ) -> int:
        """
        Process a PDF file and store embeddings in the database.
        """
        try:
            logger.info(f"Processing PDF: {pdf_path}")

            # STEP 1: Load PDF
            loader = PyPDFLoader(pdf_path)
            documents = loader.load()
            logger.info(f"Loaded {len(documents)} pages")

            # STEP 2: Split into chunks
            text_splitter = RecursiveCharacterTextSplitter(
                chunk_size=chunk_size,
                chunk_overlap=chunk_overlap,
                length_function=len,
                separators=["\n\n", "\n", " ", ""]
            )
            chunks = text_splitter.split_documents(documents)
            logger.info(f"Split into {len(chunks)} chunks")

            # STEP 3: Create embeddings and store
            # PGVector automatically triggers self.embeddings.embed_documents internally
            self.vector_store.add_documents(chunks)
            logger.info(f"Stored {len(chunks)} embeddings in database")

            return len(chunks)

        except Exception as e:
            logger.error(f"Error processing PDF: {e}")
            raise

    def retrieve_context(self, query: str, k: int = 3) -> str:
        """
        Retrieve relevant text chunks for a given query.
        """
        try:
            logger.info(f"🔍 Searching for: {query}")
            results = self.vector_store.similarity_search(query, k=k)
            context = "\n\n".join([doc.page_content for doc in results])
            logger.info(f"Retrieved {len(results)} relevant chunks")
            return context
        except Exception as e:
            logger.error(f"Error retrieving context: {e}")
            return ""

    def retrieve_with_scores(self, query: str, k: int = 3) -> List[tuple]:
        """
        Retrieve relevant chunks with similarity scores.
        """
        try:
            results = self.vector_store.similarity_search_with_score(query, k=k)
            logger.info(f"Retrieved {len(results)} chunks with scores")
            return results
        except Exception as e:
            logger.error(f"Error retrieving with scores: {e}")
            return []

    def clear_collection(self):
        """
        Delete all embeddings from the collection.
        """
        try:
            # Drop the actual collection table within PGVector schema
            self.vector_store.delete_collection()
            logger.info("Collection cleared successfully")
        except Exception as e:
            logger.error(f"Error clearing collection: {e}")


# Example usage and testing
if __name__ == "__main__":
    DB_URL = "postgresql+psycopg://sagar:narisetti@localhost:5432/rag_db"
    
    print("Initializing Bedrock Titan Embeddings...")
    # Initialize the class. Use your AWS region (e.g., us-east-1)
    embedder = BedrockTitanEmbeddings(region_name="us-east-1", dimensions=256)
    
    # sample text strings
    sample_query = "Hello world, testing AWS Bedrock connection."
    sample_docs = ["First test document chunk.", "Second test document chunk."]
    
    try:
        # 3. Test a single query embedding
        print("Testing single query embedding...")
        query_vector = embedder.embed_query(sample_query)
        print(f"Success! Vector length: {len(query_vector)}")
        print(f"Sample values: {query_vector[:3]}...\n")
        
        # 4. Test multiple document embeddings
        print("Testing document batch embedding...")
        doc_vectors = embedder.embed_documents(sample_docs)
        print(f"Success! Generated {len(doc_vectors)} document vectors.")
        print(f"Batch dimension size matches: {len(doc_vectors[0]) == 256}")

    except Exception as e:
        print(f"❌ Error occurred during Bedrock API call: {e}")
    # Initialize service with lightweight 256-dimensional vectors
    service = EmbeddingService(
        database_url=DB_URL, 
        dimensions=256, 
        collection_name="document_embeddings", 
        region_name="us-west-1"
        )
    
