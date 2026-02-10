# Use Python 3.11 slim image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements_new.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements_new.txt

# Copy application files
COPY ./app/main.py .
COPY ./app/llm_model.py .
COPY ./app/embedding_service.py .
COPY ./model/gemma-3-4b-it /app/model/gemma-3-4b-it

# Create directory for HuggingFace cache
RUN mkdir -p /app/model

# Set HuggingFace cache directory
ENV TRANSFORMERS_CACHE=/app/model_cache
ENV HF_HOME=/app/model_cache

# Expose Streamlit port
EXPOSE 8501

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Run Streamlit
CMD ["streamlit", "run", "main.py", "--server.port=8501", "--server.address=0.0.0.0"]