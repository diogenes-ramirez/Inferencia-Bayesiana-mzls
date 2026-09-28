# Random-walk Metropolis for a standard normal target. Symmetric Gaussian proposal.
set.seed(502)
log_target <- function(x) dnorm(x, log = TRUE)
metropolis <- function(n, proposal_sd, initial = 0) {
  draws <- numeric(n)
  draws[1] <- initial
  accepted <- 0L
  for (i in 2:n) {
    current <- draws[i - 1L]
    candidate <- rnorm(1, current, proposal_sd)
    log_alpha <- log_target(candidate) - log_target(current)
    if (log(runif(1)) < min(0, log_alpha)) {
      draws[i] <- candidate
      accepted <- accepted + 1L
    } else draws[i] <- current
  }
  list(draws = draws, acceptance = accepted / (n - 1L))
}

fit <- metropolis(30000L, proposal_sd = 2)
post <- fit$draws[5001:30000]
stopifnot(abs(mean(post)) < 0.08, abs(sd(post) - 1) < 0.08)
cat(sprintf("Acceptance rate: %.3f; posterior mean: %.3f; SD: %.3f\n", fit$acceptance, mean(post), sd(post)))
plot(fit$draws[1:1000], type = "l", xlab = "Iteration", ylab = "x", main = "Metropolis trace")
