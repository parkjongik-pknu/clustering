# Clustering Methods

This repository contains R codes about Gaussian Mixture Model(GMM) and Cluster-Weighted Model(CWM).
* **GMM** is a probabilistic clustering method that assumes a mixture distribution for the covariates. Each observation is assigned a probability of beloning to each cluster, rather than being deterministically assigned to a single cluster. This probabilistic framework often provides greater flexibility than distance-based clustering methods such as K-means.

* **CWM** is a model-based clustering approach that focuses on the relationship between a response variable $Y$ and explanatory variables $X$. While GMM models only the marginal distribution of $X$, CWM models the joint probability distribution $f(x,y)$, allowing cluster-specific relationships between $X$ and $Y$


<br>

* **HOW TO INSTALL AND LOAD:**

```
# You can install this package directly from GitHub using `devtools`.

install.packages("devtools")

library(devtools)

install_github("parkjongik-pknu/clustering")

library(clustering)
```
<br>

* **HOW TO USE:**

In **GMM**

```
clustering_gmm(X, g=6, max_iter=200, tol=1e-6, init_method="kmeans")

X : Data you want to use in clustering analysis(explanatory variables)

g : The number of clusters (tests 1 to g clusters by BIC)

init_methods : choose "kmeans", "kmedoids", "hierarchical"
```

<br>

In **CWM**
<br>

```
clustering_cwm(X, Y, g=6, max_iter=200, tol=1e-6, init_method="kmeans")

X : explanatory variables you want to use in clustering analysis

Y : a response variable you want to use in clustering analysis

g : The number of clusters (tests 1 to g clusters by BIC)

init_methods : choose "kmeans", "kmedoids", "hierarchical"
```
