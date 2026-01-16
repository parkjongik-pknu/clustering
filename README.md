# Clustering Methods

This repository contains R codes about Gaussian Mixture Model(GMM) and Cluster-Weighted Model(CWM).
* **GMM** is a probabilistic clustering method by assuming distribution to the covariates. Each observation have probability of being included in each cluster. This leads better performance than distance-based clustering methods(like K-means).

* **CWM** is a clustering method about the relationship between a response variable Y and explanatory variables X. While GMM focuses on the distribution of X, CWM focuses on the joint probability distribution $f(x,y)$

This repository contains GMM and CWM implementation in R.

<br>
* ## HOW TO INSTALL AND LOAD:

You can install this package directly from GitHub using `devtools`.

<br>
```R
install.packages("devtools")

library(devtools)

install_github("parkjongik-pknu/clustering")

library(clustering)



<br>
HOW TO USE:
<br>
<br>
In GMM
<br>
<br>

clustering_gmm <- function(X, g=6, max_iter=200, tol=1e-6, init_methods="kmeans")

X : Data you want to use in clustering analysis(explanatory variables)

g : The number of cluster(if you choose 6, there is one cluster, two clusters, ... up to six clusters)

init_methods : you can choose "kmeans", "kmedoids", "heirarchical"

<br>
In CWM
<br>
<br>

clustering_cwm <- function(X, Y, g=6, max_iter=200, tol=1e-6, init_method="kmeans")

X : a explanatory variables you want to use in clustering analysis

Y : response variables you want to use in clustering analysis

g : The number of cluster(if you choose 6, there is one cluster, two clusters, ... up to six clusters)

init_methods : you can choose "kmeans", "kmedoids", "heirarchical"

