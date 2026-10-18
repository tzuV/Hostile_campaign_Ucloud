# Hostile_campaign_Ucloud

R pipeline that recreates the text-analysis method of Banks & Stone (2026),
"Hostile Campaign Rhetoric and Electoral Outcomes", using a local LLM via
[Ollama](https://ollama.com) and [ellmer](https://ellmer.tidyverse.org/). A
local 7-11B model rates campaign statements for incivility and character
attacks, aggregates to candidate level, and regresses vote share on the
scores. No API key, no Docker.

## Contents

- `setup.sh` — installs Ollama + the `ellmer` package, pulls the model
- `pipeline.R` — the whole analysis: rate statements → candidate diffs → regression
- `prompt_llm.R` — sends a single prompt to the local model
- `data/` — toy example: 6 races × 2 candidates × 2 statements, plus vote shares

## Run

```sh
./setup.sh          # first run downloads the model, ~4.7 GB
ollama serve &      # start the server (skip if already running)
Rscript pipeline.R
```

Results go to `output/ratings.csv` and `output/election_scores.csv`; the
regression table is printed to the console.

Prompt the model directly:

```sh
Rscript prompt_llm.R "Rate the incivility of this statement on a scale of 1-8: 'My opponent is a liar.'"
```

## Choose another model

Any 7-11B Ollama model works, e.g. `llama3.1:8b`, `gemma2:9b`:

```sh
MODEL=llama3.1:8b ollama pull llama3.1:8b
MODEL=llama3.1:8b Rscript pipeline.R
```

The election data is toy data (N = 6); the regression is illustrative only.
Replace `data/` with real campaign texts and vote shares to replicate the paper.
