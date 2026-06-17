from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.document_loaders import PyPDFLoader

# from langchain_community.vectorstores.pgvector import PGVector
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

    def __init__(
        self,
        database_url: str,
        collection_name: str = "document_embeddings",
        embedding_model: Optional[str] = None,
    ):
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
            model_name=embedding_model,
            model_kwargs={"device": "cpu"},  # Keeps execution local on your hardware
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
            self.vector_store = PGVector(
                embeddings=self.embeddings,
                collection_name=self.collection_name,
                connection=self.database_url,
                use_jsonb=True,
            )
            logger.info("✅ Connected to PGVector database")
        except Exception as e:
            logger.error(f"❌ Failed to initialize vector store: {e}")
            raise

    def process_pdf(
        self, pdf_path: str, chunk_size: int = 1000, chunk_overlap: int = 200
    ) -> int:
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
                separators=[
                    "\n\n",
                    "\n",
                    " ",
                    "",
                ],  # Split on paragraphs first, then sentences
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
    # --- CONFIGURATION ---
    # Replace with your actual DB credentials
    DB_URL = "postgresql+psycopg://sagar:narisetti@localhost:5432/rag_database"
    embedding_model_path = "/model/all-MiniLM-L6-v2"  # Local embedding model
    COLLECTION = "test_collection"
    TEST_PDF = "./data/DocTailoredRealitiesBrandonSanderson.pdf"  # test PDF file path
    print("\n🚀 --- STARTING INTEGRATION TEST --- 🚀")

    try:
        # 1. Initialize Service
        service = EmbeddingService(
            database_url=DB_URL,
            collection_name=COLLECTION,
            embedding_model=embedding_model_path,
        )

        # 2. Test PDF Processing (The "Write" Test)
        if os.path.exists(TEST_PDF):
            num_chunks = service.process_pdf(TEST_PDF)
            print(f"✅ Success: Processed {num_chunks} chunks from PDF.")
        else:
            print(
                f"⚠️ Skip: '{TEST_PDF}' not found. Test retrieval with existing data."
            )

        # 3. Test Semantic Retrieval (The "Read" Test)
        test_query = "What is the main topic of this document?"
        print(f"\n🔍 Testing Retrieval for: '{test_query}'")

        results = service.retrieve_with_scores(test_query, k=2)

        if not results:
            print("❌ Failure: No results retrieved. Is the database empty?")
        else:
            print(f"✅ Success: Retrieved {len(results)} results.")

            # 4. Inspect the first result for quality
            doc, score = results[0]
            print(f"\nTop Result Score: {score:.4f}")
            print(f"Top Result Preview: {doc.page_content[:150]}...")
            if score < 1.0:
                print("\n⭐ TEST PASSED: System is returning relevant matches.")
            else:
                print(
                    "\n⚠️ TEST UNCERTAIN: High distance score. Check embedding quality."
                )

    except Exception as e:
        print(f"\n❌ TEST FAILED: {str(e)}")
