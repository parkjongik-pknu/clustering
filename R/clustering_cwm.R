# ============================================================
# clustering_cwm.R
# 공분산 구조 적용 X, 초기화 : k-means, k-medoids, heirarchical
# ============================================================


if (!requireNamespace("mvtnorm", quietly = TRUE)) stop("install.packages('mvtnorm')")
if (!requireNamespace("cluster", quietly = TRUE)) stop("install.packages('cluster')")
library(mvtnorm)
library(cluster)

# ------------------------------------------------------------
# em algorithm
# ------------------------------------------------------------
cwm_em <- function(X, Y, K, max_iter=200, tol=1e-6,
                   init_method = c("kmeans", "kmedoids", "heirarchical")){
  
  X <- as.matrix(X)
  Y <- as.numeric(Y)
  N <- nrow(X)
  D <- ncol(X)
  init_method <- match.arg(init_method)
  
  initial_clusters <- NULL
  
  # k-means 초기화
    if (init_method == "kmeans") {
    km <- kmeans(X, K, nstart=10)
    initial_clusters <- km$cluster
    mu <- km$centers
    
    # k-medoids 초기화
  } else if (init_method == "kmedoids") {
    pm <- cluster::pam(X, K)
    initial_clusters <- pm$clustering
    mu <- pm$medoids
    
    # heirarchical 초기화
  } else if (init_method == "hierarchical") {
    dist_mat <- dist(X)
    hc <- hclust(dist_mat, method = "ward.D2")
    initial_clusters <- cutree(hc, k = K)
    mu <- t(sapply(1:K, function(k) colMeans(X[initial_clusters == k, , drop=FALSE])))
  }
  
  # 초기 pi
  pi <- table(initial_clusters) / N
  
  
  # covariance_k 초기화
  Sigma <- lapply(1:K, function(k){
    idx <- which(initial_clusters == k)
    if(length(idx) > 1) 
      cov(X[idx,,drop=FALSE]) 
    else diag(D)
  })
  
  # 회귀계수 초기화
  beta <- lapply(1:K, function(k){
    idx <- which(initial_clusters == k)
    if(length(idx) > D){
      coef(lm(Y[idx] ~ X[idx,]))
    } else {
      rep(0, D+1)
    }
  })
  
  # sigma^2 초기화
  sigma2 <- rep(var(Y), K)
  
  ll_old <- -Inf
  loglik_history <- numeric()
  iter <- 1
  
  # ------------------------------------------------------------
  # em algorithm
  # ------------------------------------------------------------
  while(iter <= max_iter){
    
    # ------------------- E-step -------------------
    fx <- sapply(1:K, function(k){ #marginal(x) dist pdf 구하기
      dmvnorm(X, mu[k,], Sigma[[k]])
    })
     
    fy_x <- sapply(1:K, function(k){ #y|X dist pdf 구하기
      mu_y <- beta[[k]][1] + X %*% beta[[k]][-1]
      dnorm(Y, mean = mu_y, sd = sqrt(sigma2[k]))
    })
    
    joint <- sapply(1:K, function(k){ #y,x joint pdf 구하기
      pi[k] * fx[,k] * fy_x[,k]
    })
    
    posterior_prob <- joint / (rowSums(joint))
    Nk <- colSums(posterior_prob)
    
    # ------------------- Log-likelihood 계산 for visualization -------------------
    ll_new <- sum(log(rowSums(joint) + 1e-15))
    loglik_history <- c(loglik_history, ll_new)
    
    if((ll_new - ll_old) < tol) break
    ll_old <- ll_new
    
    # ------------------- M-step -------------------
    
    # pi_k 업데이트
    pi <- Nk / N
    
    # mu_k 업데이트
    mu <- t(sapply(1:K, function(k){
      colSums(posterior_prob[,k] * X) / Nk[k]
    }))
    
    # covariance_k 업데이트
    Sigma <- lapply(1:K, function(k){
      diff <- sweep(X, 2, mu[k,], "-")
      t(diff) %*% (posterior_prob[,k] * diff) / Nk[k]
    })
    
    # beta_k 업데이트
    X_design <- cbind(1, X)
    
    beta <- lapply(1:K, function(k){
      W <- posterior_prob[,k] #posterior를 가중치로 사용
      W_mat <- diag(W)
      solve(t(X_design) %*% W_mat %*% X_design,
            t(X_design) %*% W_mat %*% Y)
    })
    
    # sigma^2 업데이트
    sigma2 <- sapply(1:K, function(k){
      mu_y <- beta[[k]][1] + X %*% beta[[k]][-1]
      sum(posterior_prob[,k] * (Y - mu_y)^2) / Nk[k]
    })
    
    iter <- iter + 1
  }
  # ------------------- END EM -------------------
  
  num_params <- (K-1) + K*D + K*D*(D+1)/2 + K*(D+1) + K
  
  bic <- log(N)*num_params - 2*ll_new
  
  list(
    K = K,
    pi = pi,
    mu = mu,
    Sigma = Sigma,
    beta = beta,
    sigma2 = sigma2,
    bic = bic,
    loglik = ll_new,
    loglik_history = loglik_history,
    posterior_prob = posterior_prob,
    cluster = max.col(posterior_prob)
  )
}

# ------------------------------------------------------------
# choose best model
# ------------------------------------------------------------
clustering_cwm <- function(X, Y, g=6, max_iter=200, tol=1e-6, init_method="kmeans"){
  
  Ks <- 2:g
  
  fits <- lapply(Ks, function(K){
    cat(sprintf("Fitting CWM (K=%d)...\n", K))
    cwm_em(X, Y, K, max_iter, tol)
  })
  
  bics <- sapply(fits, `[[`, "bic")
  best_idx <- which.min(bics)
  
  list(
    best = fits[[best_idx]],
    all = fits,
    Ks = Ks,
    BICs = bics
  )
}

# ------------------------------------------------------------
# Plotting
# ------------------------------------------------------------
plot_cwm <- function(res){
  best <- res$best
  
  par(mfrow=c(1,2))
  
  plot(res$Ks, res$BICs, type="b", pch=19,
       main="CWM BIC vs K", xlab="K", ylab="BIC")
  grid()
  
  plot(best$loglik_history, type="o", pch=19,
       main=sprintf("CWM Log-likelihood (K=%d)", best$K),
       xlab="Iteration", ylab="LL")
  grid()
  
  par(mfrow=c(1,1))
}
