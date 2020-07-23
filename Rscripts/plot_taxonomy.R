setwd([directory with taxonomic classification results, e.g., level-2.csv])

library(tidyverse)

# raw data manicipating
lv = "2"
tax <- read_csv(paste("level-", lv, ".csv", sep = ""))
tax <- select(tax, -c(index, type:reactor))
tax <- data.frame(t(tax))
write.table(tax, paste("lv-", lv, ".tsv", sep = ""),
            sep = "\t", row.names = T, col.names = F,
            quote = F)
# converted to relative abundance and reload
metadata <- read_tsv("metadata.tsv")
taxa <- read_tsv(paste("lv-", lv, ".tsv", sep = ""))
taxa <- filter(taxa, average_as > 0.01|
                 average_ab > 0.01)
taxa <- select(taxa, -c(average_ab, 
                        average_as))
taxa <- pivot_longer(taxa, -Taxonomy, names_to = "sample",
                    values_to = "abundance")

# plot
ggplot(taxa, aes(x = sample, y = abundance,
                 fill = Taxonomy)) +
  geom_col() + 
  scale_y_continuous(limits = c(0, 1), 
                     expand = c(0, 0), 
                     labels = scales::percent_format()) +
  theme_bw() +
  theme(text = element_text(size = 4),
        axis.text.x = element_text(angle = 60,
                                   hjust = 1,
                                   vjust = 1),
        legend.key.height = unit(5, "pt"),
        legend.key.width = unit(3, "pt"),
        legend.background = element_blank(),
        legend.title = element_blank(),
        panel.grid = element_blank()) +
  scale_fill_brewer(palette = "Set3") +
  ylab("Relative abundance") +
  xlab(NULL)
ggsave(paste("lv-", lv, ".pdf", sep = ""),
       wi = 4, he = 2, device = "pdf")
