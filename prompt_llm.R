# Minimal example: send one prompt to the local LLM (Ollama + ellmer). No API key.
# Usage (inside the container):  Rscript prompt_llm.R "Your prompt here"
library(ellmer)

# Start the Ollama server if it is not already running
if (inherits(tryCatch(models_ollama(), error = function(e) e), "error")) {
  system2("ollama", "serve", wait = FALSE)
  Sys.sleep(3)
}

args <- commandArgs(trailingOnly = TRUE)
prompt <- if (length(args) > 0) args[1] else "Say hello and introduce yourself in one sentence."

chat <- chat_ollama(model = Sys.getenv("MODEL", "qwen2.5:7b"))
cat(chat$chat(prompt), "\n")
