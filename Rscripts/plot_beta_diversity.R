setwd([your directory with beta diversity results])

library(tidyverse)
library(ggpubr)

pcoa <- read_tsv("weighted_Unifrac_PCoA.tsv") %>%
  select(id,`Axis 1`,`Axis 2`)
metadata <- read_tsv("metadata.tsv")
pcoa <- left_join(pcoa, metadata)

ggplot(pcoa, aes(x = `Axis 1`, y = `Axis 2`, 
                 color = source, group = source)) +
  geom_vline(xintercept = 0, color = '#696969', size = 0.4, linetype = "dashed") + 
  geom_hline(yintercept = 0, color = '#696969', size = 0.4, linetype = "dashed") +
  #stat_ellipse() +
  geom_point(size = 3) +
  theme_bw() + 
  #scale_x_continuous(limits = c(-0.6, 0.3)) +
  #scale_y_continuous(limits = c(-0.3, 0.3)) +
  theme(panel.grid = element_blank(),
        legend.title = element_blank()) +
  scale_color_brewer(palette = "Set2") +
  xlab("PCoA axis1 (75.31%)") +
  ylab("PCoA axis2 (15.64%)")
ggsave("Weighted_Unifrac_PCoA.pdf", device = "pdf",
       wi = 5, he = 4)
