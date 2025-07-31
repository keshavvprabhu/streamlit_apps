# Multi-stage Dockerfile for Streamlit project with UV
FROM python:3.13-slim as base

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_CACHE_DIR=/tmp/uv-cache \
    UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    PYTHONPATH="/app/src:/app"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install UV
RUN pip install --no-cache-dir uv

# Create non-root user
RUN groupadd --gid 1000 appuser \
    && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash appuser

# Set working directory
WORKDIR /app

# Copy dependency files first for better Docker layer caching
COPY --chown=appuser:appuser pyproject.toml ./

# Install dependencies
RUN uv sync --no-dev

# Copy source code
COPY --chown=appuser:appuser src/ ./src/
COPY --chown=appuser:appuser main.py ./

# Create Streamlit config directory
RUN mkdir -p /app/.streamlit \
    && chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Create Streamlit configuration
RUN echo '[server]\nport = 8501\naddress = "0.0.0.0"\nheadless = true\nenableCORS = false\nenableXsrfProtection = false\nmaxUploadSize = 200\n\n[browser]\ngatherUsageStats = false\n\n[theme]\nbase = "light"\n\n[logger]\nlevel = "info"' > /app/.streamlit/config.toml

# Expose Streamlit port
EXPOSE 8501

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Default command
CMD ["uv", "run", "streamlit", "run", "main.py", "--server.port=8501", "--server.address=0.0.0.0"]


# ====================
# Development stage
# ====================
FROM base as development

# Switch back to root to install dev dependencies
USER root

# Install development dependencies
RUN uv sync

# Install additional development tools
RUN apt-get update && apt-get install -y \
    vim \
    nano \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Switch back to appuser
USER appuser

# Development command with hot reload
CMD ["uv", "run", "streamlit", "run", "main.py", "--server.port=8501", "--server.address=0.0.0.0", "--server.runOnSave=true", "--server.fileWatcherType=poll"]


# ====================
# Testing stage
# ====================
FROM development as testing

# Run tests as part of the build
RUN uv run pytest src/test_helpers.py -v --tb=short

# Command to run tests
CMD ["uv", "run", "pytest", "src/", "-v", "--cov=src", "--cov-report=term-missing"]


# ====================
# Production stage
# ====================
FROM base as production

# Production-specific environment variables
ENV STREAMLIT_SERVER_ENABLE_STATIC_SERVING=true \
    STREAMLIT_SERVER_ENABLE_CORS=false \
    STREAMLIT_SERVER_ENABLE_XSRF_PROTECTION=false \
    STREAMLIT_BROWSER_GATHER_USAGE_STATS=false

# Production Streamlit config with additional optimizations
RUN echo '[server]\nport = 8501\naddress = "0.0.0.0"\nheadless = true\nenableCORS = false\nenableXsrfProtection = false\nmaxUploadSize = 200\nenableStaticServing = true\nrunOnSave = false\n\n[browser]\ngatherUsageStats = false\n\n[theme]\nbase = "light"\n\n[logger]\nlevel = "warning"\n\n[global]\ndataFrameSerialization = "legacy"' > /app/.streamlit/config.toml

# Production command with error handling
CMD ["sh", "-c", "uv run streamlit run main.py --server.port=8501 --server.address=0.0.0.0 || (echo 'Streamlit failed to start' && exit 1)"]


# ====================
# Debug stage for troubleshooting
# ====================
FROM development as debug

# Install debugging tools
USER root
RUN apt-get update && apt-get install -y \
    strace \
    gdb \
    procps \
    && rm -rf /var/lib/apt/lists/*

USER appuser

# Debug command - keeps container running for inspection
CMD ["tail", "-f", "/dev/null"]
