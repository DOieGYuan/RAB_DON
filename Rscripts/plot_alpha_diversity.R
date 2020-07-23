setwd(your working directory with alpha diversity results, e.g., faith_pd.csv)

library(tidyverse)
library(stringr)
library(ggpubr)
library(patchwork)

# Rarefraction
files = c("faith_pd","chao1",
          "shannon","observed_otus","simpson")
for(nowfile in files){
  dat = read_csv(paste(nowfile,".csv",sep = "")) %>%
    pivot_longer(-c(id,label,source,type,reactor),
                 values_to = "diversity",names_to = "depth") %>%
    mutate(depth=str_remove(depth,pattern = "depth-")) %>%
    mutate(depth=str_remove(depth,pattern = "_iter-.*")) %>%
    filter(label != "bak"&label != "a10"&label != "a11")
 
  p1 = ggplot(dat,aes(x=as.numeric(depth), y= diversity,
                      group=label,color = source)) +
    geom_smooth(method = "loess", span=.1, se = T) +
    scale_x_continuous(limits = c(0,15000),
                       expand = c(0,0)) +
    scale_y_continuous(limits = c(0,round(max(dat$diversity),0)+1)) +
    theme_bw() +
    scale_color_brewer(palette = "Set2") +
    ylab(paste(nowfile)) +
    xlab("Sequences per sample") +
    theme(text = element_text(size =4),
          legend.title = element_blank(),
          legend.background = element_blank(),
          legend.key.height = unit(5, "pt"),
          legend.key.width = unit(3, "pt"))
 
  # Boxplot
  max.depth = as.double(dat$depth) %>% unique() %>% max()
  dat.box = filter(dat,depth==max.depth) %>%
    group_by(label) %>%
    summarise(diversity = mean(diversity)) %>%
    left_join(select(dat,c(label,source))%>% unique())
  
  p2 = ggplot(dat.box, aes(x = source, y = diversity, fill = source)) +
    geom_boxplot(outlier.size = .5) + 
    geom_point(position = position_jitterdodge(jitter.width = 0.2),
               aes(color = source), size = 1, alpha = .5) +
    theme_bw() +
    theme(panel.grid.minor.x = element_blank(),
          panel.grid.major.x = element_blank()) +
    xlab(NULL) + 
    ylab(paste(nowfile)) +
    scale_fill_brewer(palette = "Set2") +
    scale_color_brewer(palette = "Set2") +
    scale_y_continuous(limits = c(0,round(max(dat.box$diversity),0)+1)) +
    theme(text = element_text(size =4))

  p = p1 + p2 + plot_layout(widths = c(4,2.5))
  ggsave(paste("1.",nowfile,".pdf",sep=""),
         wi=6.5,he=3,device = "pdf")
  
  sig <- compare_means(diversity~source, 
                       data = dat.box, 
                       paired = F, 
                       method = "wilcox", 
                       p.adjust.method = "BH")
  write_tsv(sig, paste("1.",nowfile,".pairwise.Wilcoxon.tsv",sep=""))
  sig2 <- compare_means(diversity~source, 
                        data = dat.box, 
                        paired = F, 
                        method = "kruskal.test", 
                        p.adjust.method = "BH")
  write_tsv(sig2, paste("1.",nowfile,".kruskal.tsv",sep=""))
}