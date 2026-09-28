# A two-state Markov chain with a known stationary distribution.
set.seed(401)
p01 <- 0.15
p10 <- 0.35
n <- 50000L
state <- integer(n)
state[1] <- 0L
for (i in 2:n) {
  state[i] <- if (state[i - 1L] == 0L) rbinom(1, 1, p01) else rbinom(1, 1, 1 - p10)
}

# For this chain, pi(1) = p01 / (p01 + p10).
stationary_one <- p01 / (p01 + p10)
empirical_one <- mean(state[-seq_len(1000L)])
stopifnot(abs(empirical_one - stationary_one) < 0.03)
cat(sprintf("Theoretical P(state=1): %.3f; empirical after burn-in: %.3f\n", stationary_one, empirical_one))
plot(state[1:500], type = "s", xlab = "Iteration", ylab = "State", main = "Two-state Markov chain")
