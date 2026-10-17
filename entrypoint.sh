#!/bin/sh
# Start the local LLM server, download the model, run the analysis.
set -e
ollama serve &
sleep 5
ollama pull "${MODEL:-qwen2.5:7b}"
Rscript pipeline.R
