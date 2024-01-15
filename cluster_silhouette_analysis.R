# Load necessary libraries
library(stats)       # Provides functions for hierarchical clustering
library(cluster)     # For silhouette analysis and clustering

# Pre-processing: Ensure the genetic distance matrix is symmetric and zeroes on the diagonal
genetic_distance_matrix[upper.tri(genetic_distance_matrix)] <- t(genetic_distance_matrix)[upper.tri(genetic_distance_matrix)]
diag(genetic_distance_matrix) <- 0

# Perform hierarchical clustering using the complete linkage method
hc <- hclust(as.dist(genetic_distance_matrix), method = "complete")

# Define the maximum number of clusters to consider
max_k <- 15 # Change this range as needed
avg_silhouettes <- numeric(max_k)

# Calculate the average silhouette width for different numbers of clusters
for (k in 2:max_k) {
  # Assign data points to k clusters
  cluster_assignments <- cutree(hc, k)
  # Calculate silhouette scores
  silhouette_scores <- silhouette(cluster_assignments, as.dist(genetic_distance_matrix))
  # Compute the average silhouette width for all points
  avg_silhouettes[k] <- mean(silhouette_scores[, 'sil_width'])
}

# Determine the optimal number of clusters based on the highest average silhouette score
optimal_clusters <- which.max(avg_silhouettes)
print(optimal_clusters)

# Plot the relationship between the number of clusters and the average silhouette width
plot(2:max_k, avg_silhouettes[-1], type='b', xlab='Number of clusters', ylab='Average silhouette width')

# Set the number of clusters to the optimal or a predefined number
K <- optimal_clusters
cluster_assignments <- cutree(hc, k = K)

# Plot the hierarchical clustering dendrogram
plot(hc, labels = NULL, hang = -1, main = "Hierarchical Clustering Dendrogram")

# Color the dendrogram by cluster assignments
colors <- rainbow(K)
rect.hclust(hc, k = K, border = colors)