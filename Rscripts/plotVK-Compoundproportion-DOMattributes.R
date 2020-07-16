setwd("D:/OneDrive/Study/paper/Algae biofim is promising to reduce dissolved organic nitrogen/FT/MFAassign")

library(tidyverse)
library(stringr)
library(ggpubr)

# Load data
ab1 = read_tsv("2.AB1.formula.tsv") %>%
  filter(str_detect(group,pattern="N"))
ab2 = read_tsv("2.AB2.formula.tsv") %>%
  filter(str_detect(group,pattern="N"))
as = read_tsv("2.AS.formula.tsv") %>%
  filter(str_detect(group,pattern="N"))
formula_ann = read_tsv("0.formula.Info.tsv")
don.occ = read_tsv("2.combined.DON.tsv") %>%
  mutate(AB1 = case_when((AB1.1 + AB1.2 + AB1.3 > 1)~"stable",
                         (AB1.1 + AB1.2 + AB1.3 == 1)~"stochastic",
                         (AB1.1 + AB1.2 + AB1.3 == 0)~"absent"),
         AB2 = case_when((AB2.1 + AB2.2 + AB2.3 > 1)~"stable",
                         (AB2.1 + AB2.2 + AB2.3 == 1)~"stochastic",
                         (AB2.1 + AB2.2 + AB2.3 == 0)~"absent"),
         AS = case_when((AS1 + AS2 + AS3 > 1)~"stable",
                        (AS1 + AS2 + AS3 == 1)~"stochastic",
                        (AS1 + AS2 + AS3 == 0)~"absent")) %>%
  select(formula, AB1, AB2, AS) %>%
  left_join(formula_ann) %>%
  #filter(AB1=="stable"|AB2=="stable"|AS=="stable") %>%
  mutate(AB1toAS = case_when(AB1!="absent"&AS=="absent" ~ "AB",
                            AB1!="absent"&AS!="absent" ~ "both",
                            AB1=="absent"&AS!="absent" ~ "AS")) %>%
  mutate(AB2toAS = case_when(AB2!="absent"&AS=="absent" ~ "AB",
                            AB2!="absent"&AS!="absent"~"both",
                            AB2=="absent"&AS!="absent" ~ "AS")) %>%
  mutate(AB2toAB1 = case_when(AB2!="absent"&AB1=="absent" ~ "A2",
                             AB2!="absent"&AB1!="absent"~"both",
                             AB2=="absent"&AB1!="absent" ~ "A1")) %>%
  mutate(AB1toAS.s = case_when(AB1=="stable"|AS=="stable" ~ "stable",
                              T~"stochastic"))%>%
  mutate(AB2toAS.s = case_when(AB2=="stable"|AS=="stable" ~ "stable",
                               T~"stochastic"))
write_tsv(don.occ,"6.don.groupInfo.tsv")

###################
# Plot VK diagram #
###################
# AB1toAS
ggplot(don.occ %>% filter(!(is.na(AB1toAS))),aes(x=O/C,y=H/C,color = AB1toAS))+
  geom_point(aes(size=AB1toAS.s),alpha = .8)+
  geom_rect(xmin = 0, xmax = 0.2, ymin = 1.7, ymax = 2.2,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0.2, xmax = 0.6, ymin = 1.5, ymax = 2.2,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0.6, xmax = 1, ymin = 1.5, ymax = 2.2,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0, xmax = 0.1, ymin = 0.7, ymax = 1.5,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0.1, xmax = 0.6, ymin = 0.6, ymax = 1.7,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0.6, xmax = 1, ymin = 0.5, ymax = 1.5,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0, xmax = 1, ymin = 0.3, ymax = 0.7,fill="white",alpha=0, color="black")+
  theme_bw()+
  scale_color_brewer(palette = "Set1") +
  scale_size_manual(values = c("stable"=1.2,"stochastic"=.2)) +
  scale_x_continuous(limits = c(0,1))+
  scale_y_continuous(limits = c(0,2.5),expand = c(0,0), breaks = c(0,0.5,1,1.5,2,2.5))+
  theme(rect = element_rect(fill=NULL),
        legend.title = element_blank(),
        legend.background = element_blank())
ggsave("6.DON.source.AB1toAS.pdf",device = "pdf",wi=5,he=3)
#AB2toAS
ggplot(don.occ %>% filter(!(is.na(AB2toAS))),aes(x=O/C,y=H/C,color = AB2toAS))+
  geom_point(aes(size=AB2toAS.s),alpha = .8)+
  geom_rect(xmin = 0, xmax = 0.2, ymin = 1.7, ymax = 2.2,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0.2, xmax = 0.6, ymin = 1.5, ymax = 2.2,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0.6, xmax = 1, ymin = 1.5, ymax = 2.2,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0, xmax = 0.1, ymin = 0.7, ymax = 1.5,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0.1, xmax = 0.6, ymin = 0.6, ymax = 1.7,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0.6, xmax = 1, ymin = 0.5, ymax = 1.5,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0, xmax = 1, ymin = 0.3, ymax = 0.7,fill="white",alpha=0, color="black")+
  theme_bw()+
  scale_color_brewer(palette = "Set1") +
  scale_size_manual(values = c("stable"=1.2,"stochastic"=.2)) +
  scale_x_continuous(limits = c(0,1))+
  scale_y_continuous(limits = c(0,2.5),expand = c(0,0), breaks = c(0,0.5,1,1.5,2,2.5))+
  theme(rect = element_rect(fill=NULL),
        legend.title = element_blank(),
        legend.background = element_blank())
ggsave("6.DON.source.AB2toAS.pdf",device = "pdf",wi=5,he=3)
#AB2toAB1
ggplot(don.occ %>% filter(!(is.na(AB2toAB1))),aes(x=O/C,y=H/C,color = AB2toAB1))+
  geom_point(size=1)+
  geom_rect(xmin = 0, xmax = 0.2, ymin = 1.7, ymax = 2.2,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0.2, xmax = 0.6, ymin = 1.5, ymax = 2.2,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0.6, xmax = 1, ymin = 1.5, ymax = 2.2,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0, xmax = 0.1, ymin = 0.7, ymax = 1.5,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0.1, xmax = 0.6, ymin = 0.6, ymax = 1.7,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0.6, xmax = 1, ymin = 0.5, ymax = 1.5,fill="white",alpha=0, color="black")+
  geom_rect(xmin = 0, xmax = 1, ymin = 0.3, ymax = 0.7,fill="white",alpha=0, color="black")+
  theme_bw()+
  scale_color_brewer(palette = "Set1") +
  scale_x_continuous(limits = c(0,1))+
  scale_y_continuous(limits = c(0,2.5),expand = c(0,0), breaks = c(0,0.5,1,1.5,2,2.5))+
  theme(rect = element_rect(fill=NULL))
ggsave("6.DON.source.AB2toAB1.pdf",device = "pdf",wi=5,he=3)

# Compound classes
cols <- c("Lipids" = "#cd4f39",
          "Proteins/Amino sugars" = "#1874cd",
          "Carbohydrates" = "#eec900",
          "Unsaturated hydrocarbons" = "#00cd00",
          "Lignin" = "#ff00ff",
          "Tannins" = "#ff7f00",
          "Condensed aromatics" = "#43cd80",
          "Z.Others" = "#878787")
comp.prop.AB1 = filter(don.occ,AB1 != "absent") %>%
  group_by(compound) %>%
  summarise(AB1 = n())
comp.prop.AB2 = filter(don.occ,AB2 != "absent") %>%
  group_by(compound) %>%
  summarise(AB2 = n())
comp.prop.AS = filter(don.occ,AS != "absent") %>%
  group_by(compound) %>%
  summarise(AS = n())
comp.prop = full_join(comp.prop.AB1,comp.prop.AB2) %>%
  full_join(comp.prop.AS) %>%
  pivot_longer(-compound,names_to = "group",values_to = "num") %>%
  mutate(compound = case_when(compound == "Others"~"Z.Others",
                              T~compound))
# Plot
ggplot(comp.prop, aes(x = group, y = num, fill = compound)) +
  geom_col() +
  theme_bw() +
  scale_fill_brewer(palette = "Set2")
ggsave("6.compound.num.pdf", device = "pdf",
       wi = 4, he = 3)

##########################
# plot attributes violin #
##########################
ab1.att = filter(don.occ,AB1!="absent") %>%
  select(c(formula,AB1,C,H,N,theor_mass,DBEO,AImod,NOSC,class,group)) %>%
  rename(occ=AB1) %>% mutate(source = "AB1")
ab2.att = filter(don.occ,AB2!="absent") %>%
  select(c(formula,AB2,C,H,N,theor_mass,DBEO,AImod,NOSC,class,group)) %>%
  rename(occ=AB2) %>% mutate(source = "AB2")
as.att = filter(don.occ,AS!="absent") %>%
  select(c(formula,AS,C,H,N,theor_mass,DBEO,AImod,NOSC,class,group)) %>%
  rename(occ=AS) %>% mutate(source = "AS")
att = rbind(ab1.att,ab2.att,as.att)
# MW
ggplot(att,aes(x=source,y=theor_mass)) +
  geom_violin(aes(fill=occ),scale="width") +
  geom_boxplot(aes(fill=occ),width=.2,position=position_dodge(.9)) +
  theme_bw() +
  theme(panel.background = element_blank(),
        legend.title = element_blank(),
        legend.background = element_blank()) +
  scale_fill_brewer(palette = "Set1")
ggsave("6.MW.pdf",device="pdf",wi=4,he=3)
# DBEO
ggplot(att,aes(x=source,y=DBEO)) +
  geom_violin(aes(fill=occ),scale="width") +
  geom_boxplot(aes(fill=occ),width=.2,position=position_dodge(.9)) +
  theme_bw() +
  theme(panel.background = element_blank(),
        legend.title = element_blank(),
        legend.background = element_blank()) +
  scale_fill_brewer(palette = "Set1")
ggsave("6.DBEO.pdf",device="pdf",wi=4,he=3)
# AImod
ggplot(att,aes(x=source,y=AImod)) +
  geom_violin(aes(fill=occ),scale="width") +
  geom_boxplot(aes(fill=occ),width=.2,position=position_dodge(.9)) +
  theme_bw() +
  theme(panel.background = element_blank(),
        legend.title = element_blank(),
        legend.background = element_blank()) +
  scale_fill_brewer(palette = "Set1")
ggsave("6.AImod.pdf",device="pdf",wi=4,he=3)
# NOSC
ggplot(att,aes(x=source,y=NOSC)) +
  geom_violin(aes(fill=occ),scale="width") +
  geom_boxplot(aes(fill=occ),width=.2,position=position_dodge(.9)) +
  theme_bw() +
  theme(panel.background = element_blank(),
        legend.title = element_blank(),
        legend.background = element_blank()) +
  scale_fill_brewer(palette = "Set1")
ggsave("6.NOSC.pdf",device="pdf",wi=4,he=3)

# Formate into attribute table
att.tb = att %>%
  group_by(source,occ) %>%
  summarise(MW=mean(theor_mass),MWstd=sd(theor_mass),
            Cn=mean(C),Cstd=sd(C),
            Nn=mean(N),Nstd=sd(N),
            DBEO=mean(DBEO),DBEO.std=sd(DBEO),
            AImod=mean(AImod),AImod.std=sd(AImod),
            NOSC=mean(NOSC),NOSC.std=sd(NOSC))
DON.sum = att %>%
  group_by(source,occ) %>%
  summarise(totalNumber=n())
DON.degradable= filter(att,H/C>1.5) %>%
  group_by(source,occ) %>%
  summarise(degradableNumber=n())
MLBL = left_join(DON.degradable,DON.sum) %>%
  mutate(MLBL = degradableNumber/totalNumber)
# significance test
sig <- compare_means(AImod~source, #change the object
                     data = att, 
                     paired = F, 
                     method = "kruskal.test", 
                     p.adjust.method = "BH")
# Tukey HSD
library(agricolae)
fm1 <- aov(N ~ source, #change subject
           data = att)
summary(fm1)
TukeyHSD(fm1, "source", ordered = TRUE)
hsd <- HSD.test(fm1, "source", group = T, alpha = 0.05)
print(hsd)
