library(vegan)
library(ggplot2)

# DON relative abundance
env <- read.delim('DON.relativeAbundance.tsv', row.names = 1,
                  sep = '\t', stringsAsFactors = FALSE,
                  check.names = FALSE)
env = data.frame(t(env))
env_pca <- rda(env, scale = TRUE)
# Species relative abundance
otu <- read.delim('ASV.relativeAbundance.tsv', row.names = 1,
                  sep = '\t', stringsAsFactors = FALSE,
                  check.names = FALSE)
otu = data.frame(t(otu))

otu_hel <- decostand(otu, method = 'hellinger')
otu_pca <- rda(otu_hel, scale = FALSE)
par(mfrow = c(1, 2))
biplot(env_pca, choices = c(1, 2), scaling = 1, 
       main = 'DON-PCA', col = c('red', 'blue'))
biplot(otu_pca, choices = c(1, 2), scaling = 1, 
       main = 'ASV-PCA', col = c('red', 'blue'))

# Procrustes Analysis
site_env <- summary(otu_pca, scaling = 1)$site
site_otu <- summary(otu_pca, scaling = 1)$site
proc <- procrustes(X = env_pca, Y = otu_pca, symmetric = TRUE)
summary(proc)
plot(proc, kind = 1, type = 'text')

names(proc)

head(proc$Yrot)  #Procrustes Y
head(proc$X)  #Procrustes X
proc$ss  #M2
proc$rotation

plot(proc, kind = 2)
residuals(proc)  #Residues

prot <- protest(X = env_pca, Y = otu_pca, permutations = how(nperm = 999))
prot

names(prot)
prot$signif  #p-value
prot$ss  #M2

# Plot
Y <- cbind(data.frame(proc$Yrot), data.frame(proc$X))
X <- data.frame(proc$rotation)
group <- read.delim('group.txt', sep = '\t', stringsAsFactors = FALSE, check.names = FALSE)
Y$sample <- rownames(Y)
Y <- merge(Y, group, by = 'sample')
p <- ggplot(Y) +
  geom_point(aes(X1, X2, color = group), size = 1.5, shape = 16) +
  geom_point(aes(PC1, PC2, color = group), size = 1.5, shape = 1) +
  scale_color_manual(values = c('red2', 'purple2', 'green3'), limits = c('AB1', 'AB2', 'AS')) +
  geom_segment(aes(x = X1, y = X2, xend = PC1, yend = PC2), arrow = arrow(length = unit(0.1, 'cm')),
               color = 'blue', size = 0.3) +
  theme(panel.grid = element_blank(), panel.background = element_rect(color = 'black', fill = 'transparent'),
        legend.key = element_rect(fill = 'transparent')) +
  labs(x = 'Dimension 1', y = 'Dimension 2', color = '') +
  geom_vline(xintercept = 0, color = 'gray', linetype = 2, size = 0.3) +
  geom_hline(yintercept = 0, color = 'gray', linetype = 2, size = 0.3) +
  geom_abline(intercept = 0, slope = X[1,2]/X[1,1], size = 0.3) +
  geom_abline(intercept = 0, slope = X[2,2]/X[2,1], size = 0.3) +
  annotate('text', label = sprintf(paste('M^2 == ', round(prot$ss,5),sep="")),
           x = -0.21, y = 0.42, size = 3, parse = TRUE) +
  annotate('text', label = paste("p = ",prot$signif,sep=""),
           x = -0.21, y = 0.38, size = 3, parse = TRUE)
p
ggsave('1.procrustes.ASVvsDON.pdf', p, width = 4.25, height = 3)

# Mantel
env.dist = vegdist(env)
otu.dist = vegdist(otu)
mantel(env.dist, otu.dist, method="spearman",
       permutations = 999, parallel = 4)
