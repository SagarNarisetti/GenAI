import os
import glob
from dotenv import load_dotenv
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.document_loaders import PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
load_dotenv()


class EmbeddingService:
    def __init__(self):
        # Using a model compatible with Gemma 3's high performance
        model_name = os.getenv("EMBEDDING_MODEL", "sentence-transformers/all-MiniLM-L6-v2")
        self.embedding_model = HuggingFaceEmbeddings(model_name=model_name)
        
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=1000, 
            chunk_overlap=100
        )

    def load_and_split_pdfs(self, directory_path):
        """Load and split PDFs using the more stable PyPDFLoader"""
        all_docs = []
        pdf_files = glob.glob(os.path.join(directory_path, "*.pdf"))
        
        if not pdf_files:
            print(f"No PDFs found in {directory_path}")
            return []

        for pdf_path in pdf_files:
            print(f"📄 Processing: {pdf_path}")
            try:
                loader = PyPDFLoader(pdf_path)
                # This loads and splits by page automatically
                pages = loader.load()
                # Then we split pages into smaller chunks
                chunks = self.text_splitter.split_documents(pages)
                all_docs.extend(chunks)
            except Exception as e:
                print(f"Could not read {pdf_path}: {e}")
        
        return all_docs

    def create_embeddings(self, chunks):
        texts = [chunk.page_content for chunk in chunks]
        return self.embedding_model.embed_documents(texts)
    
if __name__ == "__main__":
    service = EmbeddingService()
    
    # Ensure './data' exists
    if not os.path.exists('./data'):
        os.makedirs('./data')
        print("Created './data' directory. Please place a PDF inside the directory.")
    else:
        docs = service.load_and_split_pdfs('./data')
        
        if docs:
            print(f"\n 🆗 Total Chunks Created: {len(docs)}")
            print(f"Preview of first chunk:\n{docs[0].page_content[:300]}...")
            
            # Now test the actual embedding
            print("\nGenerating vectors...")
            vectors = service.create_embeddings(docs)
            print(f"Created {len(vectors)} embeddings successfully!")