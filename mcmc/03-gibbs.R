# Gibbs sampler for a standardized bivariate normal with correlation rho.
set.seed(603)
rho <- 0.8
n <- 30000L
draws <- matrix(0, nrow = n, ncol = 2L, dimnames = list(NULL, c("x", "y")))
for (i in 2:n) {
  # The full conditionals are Normal(rho * other, 1 - rho^2).
  draws[i, 1] <- rnorm(1, rho * draws[i - 1L, 2], sqrt(1 - rho^2))
  draws[i, 2] <- rnorm(1, rho * draws[i, 1], sqrt(1 - rho^2))
}
post <- draws[5001:n, , drop = FALSE]
stopifnot(abs(mean(post[, 1])) < 0.08, abs(mean(post[, 2])) < 0.08,
          abs(cor(post)[1, 2] - rho) < 0.05)
print(c(mean_x = mean(post[, 1]), mean_y = mean(post[, 2]), correlation = cor(post)[1, 2]))
plot(post[, 1:2], pch = 16, cex = 0.3, xlab = "x", ylab = "y", main = "Gibbs draws")
