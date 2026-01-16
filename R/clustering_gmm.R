# ============================================================
# clustering_gmm.R
# 공분산 구조 적용 X, 초기화 : k-means, k-medoids, heirarchical
# ============================================================


if (!requireNamespace("mvtnorm", quietly = TRUE)) stop("install.packages('mvtnorm')")
if (!requireNamespace("cluster", quietly = TRUE)) stop("install.packages('cluster')")
library(mvtnorm)
library(cluster)

# ------------------------------------------------------------
# em algorithm
# ------------------------------------------------------------
gmm_em <- function(X, K, max_iter=200, tol=1e-6,
                   init_method = c("kmeans", "kmedoids", "heirarchical")){
  
  X <- as.matrix(X)
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
  
  #초기 공분산
  Sigma <- lapply(1:K, function(k){
    idx <- which(initial_clusters == k)
    if (length(idx) > 1) {
      cov(X[idx, , drop = FALSE])
    } else {
      diag(D)
    }
  })
  
  ll_old <- -Inf
  loglik_history <- numeric()  # 시각화 위해 log-likelihood 기록
  iter <- 1
  
  # ------------------ EM algorithm ------------------
  while(iter <= max_iter){
    
    # ---------------- E-step: posterior 추정 ----------------
    like <- sapply(1:K, function(k){
      pi[k] * dmvnorm(X, mu[k,], Sigma[[k]])
    })
    
    posterior_prob <- like / (rowSums(like))
    Nk <- colSums(posterior_prob)
    
    # ---------------- Log-likelihood 계산 for visualization ----------------
    ll_new <- sum(log(rowSums(like)))
    loglik_history <- c(loglik_history, ll_new)
    
    # 수렴 체크
    if((ll_new - ll_old) < tol) break
    ll_old <- ll_new
    
    # ---------------- M-step ----------------
    # 이미 파라미터들 업데이트 공식을 아니까, Q함수를 계산할 필요가 없음.
    # pi_k 업데이트
    pi <- Nk / N 
    
    # mu_k 업데이트
    mu <- t(sapply(1:K, function(k){
      colSums(posterior_prob[,k] * X) / Nk[k]
    }))
    
    # Sigma_k 업데이트
    Sigma <- lapply(1:K, function(k){
      diff <- sweep(X, 2, mu[k,], "-")
      t(diff) %*% (posterior_prob[,k] * diff) / Nk[k]
    })
    
    iter <- iter + 1
  }
  # ------------------ END EM ------------------
  
  # 자유도
  num_params <- (K-1) + K*D + K*D*(D+1)/2
  bic <- log(N) * num_params - 2 * ll_new
  
  list(
    K = K,
    mu = mu,
    Sigma = Sigma,
    pi = pi,
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
clustering_gmm <- function(dat, g=6, max_iter=200, tol=1e-6, init_methods="kmeans"){
  
  dat <- as.matrix(dat)
  Ks <- 2:g
  
  fits <- lapply(Ks, function(K){
    cat(sprintf("Fitting GMM (K=%d)...\n", K))
    gmm_em(dat, K, max_iter, tol)
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
# Plotting 결과
# ------------------------------------------------------------
plot_gmm <- function(res){
  best <- res$best
  par(mfrow=c(1,2))
  
  plot(res$Ks, res$BICs, type="b", pch=19,
       main="BIC vs K", xlab="K", ylab="BIC")
  grid()
  
  plot(best$loglik_history, type="o", pch=19,
       main=sprintf("Log-likelihood (K=%d)", best$K),
       xlab="Iteration", ylab="LL")
  grid()
  
  par(mfrow=c(1,1))
}
