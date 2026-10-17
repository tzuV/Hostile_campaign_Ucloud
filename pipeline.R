# Hostile campaign rhetoric with a local LLM
# Demo for "quantitative text analysis": replicates the text-measurement step of
# Banks & Stone (2026), "Hostile Campaign Rhetoric and Electoral Outcomes",
# Social Science Quarterly. Uses the paper's Appendix A prompts (1-8 scales) and
# a locally downloaded 7-11B model served by Ollama. No API key needed.

library(ellmer)

model <- Sys.getenv("MODEL", "qwen2.5:7b") # any 7-11B instruction model on Ollama

# Prompts adapted from Banks & Stone (2026), Appendix A
civility_prompt <- paste(
  "Rate the incivility of the following campaign statement on a scale of 1-8,",
  "where 1 is the most uncivil and 8 is the most civil. Incivility is norm-violating",
  "rhetoric or discursive behavior meant to demonstrate contempt for opposing",
  "individuals, groups, or viewpoints in a political context: invectives and ridicule",
  "(ad hominem attacks, mockery, name-calling), hyperbole and distortion,",
  "negative-emotion attribution, and conspiracy theories.",
  "Respond with ONLY a single number from 1 to 8.",
  "Statement:"
)
charattack_prompt <- paste(
  "Take the role of a political analyst. Rate the extent to which the following",
  "campaign statement employs character (person-based) attacks on an opponent, on a",
  "scale from 1 (most character attacks) to 8 (least character attacks).",
  "Respond with ONLY a single number from 1 to 8.",
  "Statement:"
)

# 1. Rate every statement with the local model --------------------------------
chat <- chat_ollama(model = model, params = params(temperature = 0, seed = 42))

score <- function(statement, prompt) {
  reply <- chat$clone()$chat(paste(prompt, statement)) # fresh context per statement
  cat(">>", substr(statement, 1, 60), "... ->", reply, "\n")
  n <- regmatches(reply, regexpr("[0-9]+(\\.[0-9]+)?", reply)) # first number in reply
  if (length(n) == 0) NA_real_ else as.numeric(n)
}

df <- read.csv("data/statements.csv", stringsAsFactors = FALSE)
df$civility    <- sapply(df$statement, score, prompt = civility_prompt)
df$char_attack <- sapply(df$statement, score, prompt = charattack_prompt) # 8 = fewest attacks

dir.create("output", showWarnings = FALSE)
write.csv(df, "output/ratings.csv", row.names = FALSE)

# 2. Candidate-level scores, incumbent-minus-challenger diffs -----------------
# (Banks & Stone average each candidate's campaign text, then take diffs)
cand <- aggregate(cbind(civility, char_attack) ~ race + role, data = df, mean)
wide <- reshape(cand, idvar = "race", timevar = "role", direction = "wide")
el <- merge(read.csv("data/elections.csv", stringsAsFactors = FALSE), wide, by = "race")
el$civility_diff   <- el$civility.incumbent - el$civility.challenger
el$charattack_diff <- el$char_attack.incumbent - el$char_attack.challenger
write.csv(el, "output/election_scores.csv", row.names = FALSE)

# 3. The paper's regression: incumbent party vote share on the rhetoric diffs -
# Toy data (N = 6 races) - swap in real texts and vote shares to replicate Table 2
fit <- lm(vote ~ civility_diff + charattack_diff, data = el)
print(summary(fit))
