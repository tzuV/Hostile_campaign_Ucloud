# Send one prompt to the local Ollama model. No API key.
# Usage: ollama serve & then Rscript prompt_llm.R "Your prompt here"
library(ellmer)

args <- commandArgs(trailingOnly = TRUE)
prompt <- if (length(args) > 0) args[1] else "Say hello in one sentence."

chat <- chat_ollama(model = Sys.getenv("MODEL", "qwen2.5:7b"))
cat(chat$chat(prompt), "\n")
