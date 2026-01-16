
library(MASS)
#---------------------------------------------------------------------
# gmm test

source("C:/Users/박종익/Desktop/스터디/코드/공분산 x/clustering_gmm.R")
set.seed(123)

N1 <- 300
N2 <- 300

mu1 <- c(0, 0)
mu2 <- c(4, 4)

Sigma1 <- matrix(c(1, 0.3, 0.3, 1), 2, 2)

Sigma2 <- matrix(c(1, -0.2, -0.2, 1), 2, 2)


x1 <- mvrnorm(N1, mu1, Sigma1)
x2 <- mvrnorm(N2, mu2, Sigma2)

X <- rbind(x1, x2)

#모델 적합
res <- clustering_gmm(X, init_method = "heirarchical")
#결과
print(res$best)

#시각화(bic, log-likelihood)
plot_gmm(res)



