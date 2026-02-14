"""
Streamlit Application UI
-------------------------
This is the frontend interface for the RAG application.

Features:
1. Chat interface for asking questions
2. PDF upload functionality
3. Display of RAG context (for transparency)
4. Session state management
"""

import streamlit as st
from llm_model import GemmaLLM
from huggingface_hub.utils import HFValidationError
from embedding_service import EmbeddingService
import os
from pathlib import Path
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Database configuration
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    # This shows a red box in the Streamlit UI if the variable is missing
    st.error("🚨 DATABASE_URL not found! check your .env file or Docker Compose settings.")
    st.stop()

MODEL_PATH = os.getenv("MODEL_PATH", "/app/model/gemma-3-4b-it")
if not os.path.exists(MODEL_PATH):
    st.error(f"🚨 Model not found at {MODEL_PATH}! Please check your .env file or Docker setup.")
    st.warning("To download the model, run:\n\nhuggingface-cli download google/gemma-3-4b-it --local-dir ./model/gemma-3-4b-it")
    st.stop()
# Page configuration
st.set_page_config(
    page_title="RAG Chat Application",
    page_icon="🤖",
    layout="wide"
)


def initialize_session_state():
    """
    Initialize Streamlit session state variables.
    
    Reality: Streamlit reruns the entire script on each interaction.
    Session state preserves variables across reruns (like chat history).
    """
    if "messages" not in st.session_state:
        st.session_state.messages = []
    
    if "llm" not in st.session_state:
        with st.spinner("🔄 Initializing Gemma3 model..."):
            try:
                st.session_state.llm = GemmaLLM(model_path=MODEL_PATH)
                print(f"\n✅ Gemma3 model initialized successfully! Path: {MODEL_PATH}")
            except (HFValidationError, OSError) as e:
                st.error(f"❌ Failed to load model: {e}")
                st.warning(f"Check if the directory exists and contains config files: {MODEL_PATH}")
                # Optional: Stop execution if the model is critical
                st.stop()
            except Exception as e:
                st.error(f"An unexpected error occurred: {e}")
                st.stop()
    
    if "embedding_service" not in st.session_state:
        with st.spinner("🔄 Connecting to vector database..."):
            st.session_state.embedding_service = EmbeddingService(database_url=DATABASE_URL)
    
    if "pdf_processed" not in st.session_state:
        st.session_state.pdf_processed = False


def display_chat_history():
    """
    Display all previous messages in the chat.
    
    Reality: Renders each message with role-appropriate styling.
    User messages appear on the right, assistant on the left.
    """
    for message in st.session_state.messages:
        with st.chat_message(message["role"]):
            st.markdown(message["content"])


def handle_pdf_upload():
    """
    Handle PDF file upload and processing.
    
    Reality: 
    1. Saves uploaded file to disk
    2. Extracts text and creates embeddings
    3. Stores in PGVector
    4. Updates UI to show success
    """
    st.sidebar.header("📄 Upload PDF")
    uploaded_file = st.sidebar.file_uploader("Choose a PDF file", type="pdf")
    
    if uploaded_file is not None:
        if st.sidebar.button("🚀 Process PDF"):
            with st.spinner("Processing PDF..."):
                try:
                    # Save uploaded file temporarily
                    upload_dir = Path("/tmp/uploads")
                    upload_dir.mkdir(exist_ok=True)
                    pdf_path = upload_dir / uploaded_file.name
                    
                    with open(pdf_path, "wb") as f:
                        f.write(uploaded_file.getbuffer())
                    
                    # Process the PDF
                    num_chunks = st.session_state.embedding_service.process_pdf(str(pdf_path))
                    
                    st.session_state.pdf_processed = True
                    st.sidebar.success(f"✅ Processed {num_chunks} chunks!")
                    
                    # Clean up
                    os.remove(pdf_path)
                    
                except Exception as e:
                    st.sidebar.error(f"❌ Error: {str(e)}")
                    logger.error(f"PDF processing error: {e}")


def handle_user_input(prompt: str):
    """
    Process user input and generate response.
    
    Args:
        prompt: User's message
        
    Reality: This is the main chat logic:
    1. Add user message to chat history
    2. If PDF uploaded: retrieve relevant context, use RAG
    3. If no PDF: use standard chat
    4. Display response and add to history
    """
    # Add user message to chat
    st.session_state.messages.append({"role": "user", "content": prompt})
    
    # Display user message
    with st.chat_message("user"):
        st.markdown(prompt)
    
    # Generate assistant response
    with st.chat_message("assistant"):
        with st.spinner("🤔 Thinking..."):
            try:
                if st.session_state.pdf_processed:
                    # RAG MODE: Retrieve context and generate response
                    logger.info("Using RAG mode")
                    
                    # Retrieve relevant context from vector DB
                    context = st.session_state.embedding_service.retrieve_context(prompt, k=3)
                    
                    # Show retrieved context (optional, for transparency)
                    with st.expander("📚 Retrieved Context"):
                        st.text(context[:500] + "..." if len(context) > 500 else context)
                    
                    # Generate response with context
                    response = st.session_state.llm.generate_rag_response(
                        query=prompt,
                        context=context
                    )
                else:
                    # STANDARD MODE: Direct chat without RAG
                    logger.info("Using standard mode")
                    response = st.session_state.llm.generate_response(prompt)
                
                # Display response
                st.markdown(response)
                
                # Add to chat history
                st.session_state.messages.append({"role": "assistant", "content": response})
                
            except Exception as e:
                error_msg = f"❌ Error: {str(e)}"
                st.error(error_msg)
                logger.error(f"Response generation error: {e}")


def main():
    """
    Main application function.
    
    Reality: This is the entry point when Streamlit runs.
    Sets up the UI layout and handles user interactions.
    """
    # Initialize
    initialize_session_state()
    
    # Title and description
    st.title("🤖 RAG Chat Application")
    st.markdown("Ask questions and upload PDFs to chat with your documents!")
    
    # Sidebar for PDF upload
    handle_pdf_upload()
    
    # Display status
    if st.session_state.pdf_processed:
        st.sidebar.success("✅ RAG Mode Active")
    else:
        st.sidebar.info("💬 Standard Chat Mode")
    
    # Clear chat button
    if st.sidebar.button("🗑️ Clear Chat"):
        st.session_state.messages = []
        st.rerun()
    
    # Display chat history
    display_chat_history()
    
    # Chat input
    # This creates the text input at the bottom of the chat
    if prompt := st.chat_input("Ask me anything..."):
        handle_user_input(prompt)


# Run the application
if __name__ == "__main__":
    main()