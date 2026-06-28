### STAGE 1: The Builder Image with heavy runtime
FROM python:3.11-slim as builder

# Set working directory
WORKDIR /build

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements_new.txt .

# Install Python dependencies globally within the builder environment
RUN pip install --no-cache-dir -r requirements_new.txt


### STAGE 2: The Production Image (Tiny runtime)
FROM python:3.11-slim as production

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy directly from Python's standard system packages location
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application files 
COPY app/main.py /app/
COPY app/src/__init__.py /app/src/
COPY app/src/llm_model.py /app/src/
COPY app/src/embedding_service.py /app/src/
COPY app/src/helpers.py /app/src/
COPY app/config/params.yaml /app/config/

# Create directory for HuggingFace cache
RUN mkdir -p /app/cache
# Set HuggingFace cache directory
ENV HF_HOME=/app/cache
ENV TRANSFORMERS_CACHE=/app/cache

# Expose Streamlit port
EXPOSE 8501

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Run Streamlit
CMD ["streamlit", "run", "main.py", "--server.port=8501", "--server.address=0.0.0.0"]
