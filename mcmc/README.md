# MCMC reference implementations

These self-contained R scripts complement, but do not replace, the student exercise templates in `ejercicios/`. Run a script with `Rscript mcmc/01-markov-chain.R` from the repository root; scripts use base R unless noted. Each sets a seed and includes executable checks.

## Learning order

| File | Topic | Course unit |
|---|---|---|
| [01-markov-chain.R](01-markov-chain.R) | Markov chain, stationarity, empirical distribution | [Unit 4](../unidades/unidad-04-introduccion-mcmc.qmd) |
| [02-metropolis-hastings.R](02-metropolis-hastings.R) | Random-walk Metropolis on a standard normal target | [Unit 5](../unidades/unidad-05-metropolis-hastings.qmd) |
| [03-gibbs.R](03-gibbs.R) | Exact Gibbs updates for a bivariate normal | [Unit 6](../unidades/unidad-06-gibbs.qmd) |
| [04-diagnostics.R](04-diagnostics.R) | Multiple-chain summaries, trace and autocorrelation | [Unit 7](../unidades/unidad-07-diagnostico-mcmc.qmd) |
| [05-hmc.R](05-hmc.R) | HMC with leapfrog integration and Metropolis correction | [Unit 9](../unidades/unidad-09-hmc.qmd) |
| [06-stan-nuts.R](06-stan-nuts.R) | Run NUTS via `cmdstanr` and inspect diagnostics | [Units 8–10](../unidades/unidad-08-stan.qmd) |

The first five examples use base R. The final example requires `cmdstanr` and a working CmdStan installation. It delegates NUTS to Stan; it is **not** a hand-written NUTS implementation. The examples are teaching references, not production samplers. Diagnostics cannot prove convergence.
