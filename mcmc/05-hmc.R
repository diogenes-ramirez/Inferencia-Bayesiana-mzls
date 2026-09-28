# One-dimensional HMC for a standard normal target, using leapfrog and MH correction.
set.seed(905)
log_density <- function(q) dnorm(q, log = TRUE)
grad_log_density <- function(q) -q

leapfrog <- function(q, p, step_size, n_steps) {
  stopifnot(length(q) == 1L, length(p) == 1L, is.finite(q), is.finite(p),
            length(step_size) == 1L, is.finite(step_size), step_size > 0,
            length(n_steps) == 1L, is.finite(n_steps), n_steps >= 1,
            n_steps == as.integer(n_steps))
  p <- p + 0.5 * step_size * grad_log_density(q)
  for (j in seq_len(n_steps)) {
    q <- q + step_size * p
    if (j < n_steps) p <- p + step_size * grad_log_density(q)
  }
  p <- p + 0.5 * step_size * grad_log_density(q)
  list(q = q, p = -p) # Momentum reversal makes the proposal reversible.
}

hmc <- function(n = 12000L, step_size = 0.25, n_steps = 10L, initial = 0) {
  stopifnot(length(n) == 1L, is.finite(n), n >= 2, n == as.integer(n),
            length(initial) == 1L, is.finite(initial))
  q <- numeric(n)
  q[1L] <- initial
  accepted <- 0L
  for (i in 2:n) {
    p0 <- rnorm(1)
    proposal <- leapfrog(q[i - 1L], p0, step_size, n_steps)
    # proposal$p is momentum-reversed; its kinetic energy equals p_end's.
    log_alpha <- log_density(proposal$q) - proposal$p^2 / 2 -
      log_density(q[i - 1L]) + p0^2 / 2
    if (log(runif(1)) < min(0, log_alpha)) {
      q[i] <- proposal$q
      accepted <- accepted + 1L
    } else q[i] <- q[i - 1L]
  }
  list(draws = q, acceptance = accepted / (n - 1L))
}

stopifnot(isTRUE(all.equal(grad_log_density(0.7), -0.7)),
          is.finite(leapfrog(0, 1, 0.1, 3)$q))

fit <- hmc(12000L)
post <- fit$draws[2001:12000]
stopifnot(abs(mean(post)) < 0.1, abs(sd(post) - 1) < 0.1)
cat(sprintf("Acceptance rate: %.3f; mean: %.3f; SD: %.3f\n", fit$acceptance, mean(post), sd(post)))
plot(fit$draws, type = "l", xlab = "Iteration", ylab = "q", main = "HMC trace")
