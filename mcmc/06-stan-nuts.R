# NUTS example using Stan through cmdstanr; NUTS itself is implemented by Stan.
# Prerequisite: install cmdstanr and CmdStan (see https://mc-stan.org/cmdstanr/).
if (!requireNamespace("cmdstanr", quietly = TRUE)) {
  stop("Install cmdstanr and CmdStan before running this example.")
}
set.seed(1006)
y <- c(1.2, 0.7, 1.5, 0.9, 1.1, 0.6, 1.4, 1.0, 0.8, 1.3)
stopifnot(length(y) > 0L, all(is.finite(y)))
stan_code <- "
data {
  int<lower=1> N;
  array[N] real y;
}
parameters { real mu; real<lower=0> sigma; }
model {
  mu ~ normal(0, 5);
  sigma ~ exponential(1);
  y ~ normal(mu, sigma);
}"
model_file <- tempfile(fileext = ".stan")
writeLines(stan_code, model_file)
mod <- cmdstanr::cmdstan_model(model_file)
fit <- mod$sample(data = list(N = length(y), y = y), seed = 1006,
                  chains = 4, parallel_chains = 4, iter_warmup = 500, iter_sampling = 1000)
print(fit$summary(c("mu", "sigma")))
print(fit$diagnostic_summary())
