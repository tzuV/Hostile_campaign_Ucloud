# Hostile_campaign_Ucloud

Minimal pipeline that recreates the text-analysis method of Banks & Stone (2026),
"Hostile Campaign Rhetoric and Electoral Outcomes" (Social Science Quarterly), in R
with [ellmer](https://ellmer.tidyverse.org/). A local 7-11B model (downloaded at
runtime) rates campaign statements for incivility and character attacks using the
paper's prompts (Appendix A), aggregates to candidate level, and regresses
incumbent-party vote share on the resulting scores. No API key needed.

## Contents

- `setup.sh` — one-command setup: builds the image and runs everything
- `pipeline.R` — the whole analysis: rate statements → candidate diffs → regression
- `prompt_llm.R` — minimal script that sends a single prompt to the local model
- `data/` — toy example: 6 races × 2 candidates × 2 statements, plus vote shares
- `entrypoint.sh` — starts Ollama, downloads the model, runs `pipeline.R`
- `Dockerfile` — R + ellmer + Ollama

## Quick start (one command)

```sh
./setup.sh
```

This builds the image, downloads the model (first run only, ~4.7 GB), and runs
the full analysis. Uses the GPU automatically if one is available.

## Build and run by hand

```sh
docker build -t hostile-rhetoric .
```

## Run (first run downloads the model, ~4.7 GB)

```sh
docker run --rm -v "$PWD/output:/app/output" hostile-rhetoric
```

## Run on a GPU node (e.g. Ucloud)

```sh
docker run --rm --gpus all \
  -v "$PWD/output:/app/output" \
  -v "$HOME/.ollama:/root/.ollama" \
  hostile-rhetoric
```

Mounting `~/.ollama` caches the downloaded model between runs.

## Choose another 7-11B model

```sh
docker run --rm -e MODEL=llama3.1:8b -v "$PWD/output:/app/output" hostile-rhetoric
```

Any Ollama model in the 7-11B range works, e.g. `qwen2.5:7b` (default),
`llama3.1:8b`, `gemma2:9b`.

## Just prompt the model

`prompt_llm.R` is a minimal script that sends one prompt to the local model and
prints the reply (it starts the Ollama server itself if needed):

```sh
docker run -it --rm --gpus all -v "$HOME/.ollama:/root/.ollama" \
  --entrypoint bash hostile-rhetoric
# inside the container:
Rscript prompt_llm.R "Rate the incivility of this statement on a scale of 1-8: 'My opponent is a liar.'"
```

## Output

- `output/ratings.csv` — per-statement civility and character-attack scores (1-8)
- `output/election_scores.csv` — candidate scores, diffs, and the regression data
- console — the OLS regression of vote share on the rhetoric diffs

The election data is toy data (N = 6), so the regression is illustrative only.
Replace `data/` with real campaign texts and vote shares to replicate the paper.
