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

COPY ./model/gemma-3-4b-it/.cache /model/gemma-3-4b-it/.cache/
COPY ./model/gemma-3-4b-it/.gitattributes /model/gemma-3-4b-it/
COPY ./model/gemma-3-4b-it/added_tokens.json /model/gemma-3-4b-it/
COPY ./model/gemma-3-4b-it/chat_template.json /model/gemma-3-4b-it/
COPY ./model/gemma-3-4b-it/config.json /model/gemma-3-4b-it/
COPY ./model/gemma-3-4b-it/generation_config.json /model/gemma-3-4b-it/
COPY ./model/gemma-3-4b-it/model-00001-of-00002.safetensors /model/gemma-3-4b-it/
COPY ./model/gemma-3-4b-it/model-00002-of-00002.safetensors /model/gemma-3-4b-it/
COPY ./model/gemma-3-4b-it/model.safetensors.index.json /model/gemma-3-4b-it/
COPY ./model/gemma-3-4b-it/preprocessor_config.json /model/gemma-3-4b-it/
COPY ./model/gemma-3-4b-it/processor_config.json /model/gemma-3-4b-it/
COPY ./model/gemma-3-4b-it/README.md /model/gemma-3-4b-it/
COPY ./model/gemma-3-4b-it/special_tokens_map.json /model/gemma-3-4b-it/
COPY ./model/gemma-3-4b-it/tokenizer_config.json /model/gemma-3-4b-it/
COPY ./model/gemma-3-4b-it/tokenizer.json /model/gemma-3-4b-it/
COPY ./model/gemma-3-4b-it/tokenizer.model /model/gemma-3-4b-it/

# Create directory for HuggingFace cache
RUN mkdir -p /app/model

# Set HuggingFace cache directory
ENV HF_HOME=/app/model
ENV TRANSFORMERS_CACHE=/app/model

# Expose Streamlit port
EXPOSE 8501

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Run Streamlit
CMD ["streamlit", "run", "main.py", "--server.port=8501", "--server.address=0.0.0.0"] 