FROM rocker/r-ver:4.4

# System libraries: compilers/headers for R packages, curl for Ollama
RUN apt-get update && apt-get install -y --no-install-recommends \
        r-base-dev libcurl4-openssl-dev libssl-dev curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Ollama: local LLM server (uses the GPU automatically if one is attached)
RUN curl -fsSL https://ollama.com/install.sh | sh

# The only R package the pipeline needs
RUN Rscript -e 'install.packages("ellmer", repos = "https://cloud.r-project.org")'

WORKDIR /app
COPY pipeline.R prompt_llm.R entrypoint.sh ./
COPY data ./data
RUN chmod +x entrypoint.sh

# 7-11B instruction model, downloaded on first run (~4.7 GB).
# Override with: docker run -e MODEL=llama3.1:8b ...
ENV MODEL=qwen2.5:7b

ENTRYPOINT ["./entrypoint.sh"]
