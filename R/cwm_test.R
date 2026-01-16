
library(MASS)
#---------------------------------------------------------------------
# cwm test

source("C:/Users/박종익/Desktop/스터디/코드/공분산 x/clustering_cwm.R")


library(mvtnorm)
set.seed(123)

N <- 1000
pi <- c(0.5, 0.5) #군집 두개, 혼합비율 0.5씩


# means
mu1 <- c(0, 0)
mu2 <- c(3, 3)

# covariance
Sigma1 <- matrix(c(1,0,0,3), 2, 2)
Sigma2 <- matrix(c(2,0,0,2), 2, 2)

# beta
beta1_true <- c(-2,  1,  2)
beta2_true <- c( 4, -3,  3)


Z <- sample(1:2, N, replace=TRUE, prob=pi)
X <- matrix(0, N, 2)
Y <- rep(0, N)

for (i in 1:N){
  if(Z[i]==1){
    X[i,] <- rmvnorm(1, mu1, Sigma1)
    Y[i]  <- beta1_true[1] + beta1_true[2]*X[i,1] + beta1_true[3]*X[i,2] + rnorm(1)
  } else {
    X[i,] <- rmvnorm(1, mu2, Sigma2)
    Y[i]  <- beta2_true[1] + beta2_true[2]*X[i,1] + beta2_true[3]*X[i,2] + rnorm(1)
  }
}

res <- clustering_cwm(X, Y, init_method = "kmedoids")

print(res$BICs)
cat("\nBest K =", res$best$K, "\n\n")

plot_cwm(res)

# true beta vs estimated beta
true_beta <- list(cluster1 = beta1_true,
                  cluster2 = beta2_true)
# Estimated beta from CWM result
beta_est <- res$best$beta   # list of length K
beta_est <- beta_est[c(2,1)]


for (k in 1:length(beta_est)) {
  cat(sprintf("Cluster %d\n", k))
  
  # true beta
  if (k == 1) bt <- beta1_true
  else bt <- beta2_true
  
  # print side-by-side
  comp <- cbind(True = bt, Estimated = round(beta_est[[k]], 4))
  print(comp)
  cat("\n")
}
