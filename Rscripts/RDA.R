library(tidyverse)
# Start from line 18

# RDA
species = read_tsv("4.RDA.species.tsv") %>%
  mutate(element=str_remove(element,pattern = "X"))
samples = read_tsv("4.RDA.samples.tsv")
arrows = read_tsv("4.RDA.arrows.tsv")
rda = rbind(species,samples,arrows) %>%
  select(c(element,RDA1,RDA2))

tax = read_tsv("ASVtaxonomy.tsv")
rda = left_join(rda,tax%>%rename(element=ASV))
#write_tsv(rda,"5.RDA.Info4plot.tsv")

rda = read_tsv("5.RDA.Info4plot.tsv")
species.occ = rda %>% group_by(phylum) %>% summarise(n=n())
others = filter(species.occ,n<=5)
others = others$phylum

rda = mutate(rda,phylum=case_when(phylum%in%others~"Others",
                                  T~phylum))

ggplot(rda,aes(x=RDA1,y=RDA2)) +
  geom_point(aes(color=phylum,shape=type,size=type),alpha=.8) +
  theme_bw() +
  scale_shape_manual(values = c("species"=16,
                                "samples"=15,
                                "arrows"=17)) +
  scale_size_manual(values = c("species"=1.5,
                                "samples"=2.5,
                                "arrows"=.5)) +
  scale_color_brewer(palette = "Set3") +
  theme(legend.title = element_blank(),
        legend.background = element_blank(),
        legend.key.height = unit(5, "pt"),
        legend.key.width = unit(3, "pt"))
ggsave("5.RDA.phylum.pdf",wi=4.5,he=3)
