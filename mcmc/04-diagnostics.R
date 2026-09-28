# Basic diagnostics for independent chains targeting a standard normal.
# These summaries are screens, not proof of convergence.
set.seed(704)
n <- 5000L
n_chains <- 4L
stopifnot(n >= 2L, n_chains >= 2L)
chains <- replicate(n_chains, {
  x <- numeric(n)
  for (i in 2:n) x[i] <- 0.8 * x[i - 1L] + rnorm(1, sd = sqrt(1 - 0.8^2))
  x
})
colnames(chains) <- paste0("chain", seq_len(n_chains))
stopifnot(all(dim(chains) == c(n, n_chains)), all(is.finite(chains)))
plot(chains[, 1], type = "l", xlab = "Iteration", ylab = "Value", main = "Chain 1 trace")
acf(chains[, 1], main = "Chain 1 autocorrelation")
print(rbind(mean = colMeans(chains), sd = apply(chains, 2, sd)))
